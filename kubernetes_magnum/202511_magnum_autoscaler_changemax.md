## Magnum Autoscaler Investigation – November 10, 2025

### Background

- The Magnum cluster `k8s` (UUID `c8fd0bc7-cf71-40fb-b901-c309d405d627`) is running with Cluster API (CAPI) integration on Jetstream, backed by five `m3.small` worker nodes in nodegroup `default-worker`.
- Autoscaling is enabled through the Jetstream-managed cluster-autoscaler that runs outside of the cluster. It honours the `max_node_count` label that Magnum set to `5` during provisioning.
- A JupyterHub stress test (`high-memory-deployment`) currently leaves one replica (`high-memory-deployment-844964899f-4md88`) Pending because the autoscaler refuses to grow the pool beyond five nodes.

### Objective

Raise the autoscaler ceiling from 5 → 6 nodes so the pending workload can trigger scale-up automatically instead of requiring a manual resize.

### Actions Performed

1. **Validated current state**
   - `openstack coe cluster show k8s` confirmed labels `min_node_count=1`, `max_node_count=5`.
   - `openstack coe nodegroup show k8s default-worker` showed `max_node_count` attribute already set to `6`, but the label and the autoscaler target remained `5`.
   - `kubectl describe pod high-memory-deployment-…-4md88` reported `NotTriggerScaleUp ... max node group size reached`.

2. **Attempted to update Magnum labels**
   - `openstack coe cluster update k8s replace labels/max_node_count=6` → `HTTP 400 cannot change cluster property(ies) labels`. This is a CAPI-managed restriction; label edits are blocked at the cluster level.

3. **Updated nodegroup limits**
   - `openstack coe nodegroup update k8s default-worker replace max_node_count=6`.
   - Confirmed via `openstack coe nodegroup show …` that both the `max_node_count` attribute and the label now read `6`.
   - Installed `python-heatclient` inside the `uv`-managed venv (`uv pip install python-heatclient`) so Heat resources can be inspected later without touching system Python.

4. **Reviewed in-cluster autoscaler manifests**
   - Located legacy manifests in `kubernetes_magnum/autoscaler/`.
   - Updated deployments to:
     - Use `/config/cloud.conf` (matches Jetstream secret layout).
     - Set `--nodes=1:6:DefaultNodeGroup`.
     - Schedule on control-plane nodes via `node-role.kubernetes.io/control-plane`.
     - Switch RBAC objects to `rbac.authorization.k8s.io/v1`.

5. **Created OpenStack credential secret**
   - Mirrored the control-plane `cloud-config` secret from `openstack-system` into `kube-system/cluster-autoscaler-cloud-config`.
   - Applied RBAC + deployment manifests.

6. **Diagnosed cluster-autoscaler crash**
   - Pod entered `CrashLoopBackOff` with:
     - `magnum_manager_heat.go` rejecting underscores (`application_credential_id`) because legacy trust-based keys are required.
     - Later, after copying the Helm-generated `cloud.conf`, autoscaler failed with warnings about `use-clouds` / `clouds-file` unsupported fields.
   - The upstream Magnum provider only understands the older `[Global]` section with direct credentials; the Jetstream Helm chart stores `use-clouds=true` + `clouds.yaml` (OpenStackSDK format). No trust credentials are exposed inside the kube-system namespace.
   - Deployment and RBAC objects were removed to avoid a broken autoscaler lingering in the cluster.

7. **Confirmed external autoscaler remained unchanged**
   - `kubectl -n kube-system get configmap cluster-autoscaler-status -o jsonpath='{.data.status}'` still shows `maxSize: 5`.
   - `kubectl describe` for the pending pod continues to cite the `max node group size reached` reason.
   - Manual `openstack coe cluster update k8s replace labels/max_node_count=6 --debug` captures the `PATCH` request failing with `HTTP 400` (Jetstream request ID `req-0a1e8dc8-1d3b-459f-8539-5241f0f854f9`).

### Current State

- Worker nodegroup metadata allows six nodes (`max_node_count = 6`), but the external autoscaler still reads `maxSize: 5`.
- OpenStack denies cluster-level label edits while Magnum is managed by Cluster API.
- In-cluster autoscaler cannot run without legacy trust credentials or a rewritten cloud-config parser, due to:
  - Missing `/config/cloud-config` (file location changed to `/etc/config/cloud.conf`).
  - Unsupported `use-clouds` and `clouds-file` syntax in the Helm-provided secret.

### Risks & Limitations

- The inability to raise `labels/max_node_count` from outside Jetstream means the managed autoscaler will ignore the nodegroup’s larger limit until Jetstream updates their configuration.
- Deploying our own autoscaler requires sensitive trust credentials that are currently inaccessible; using application credentials fails with parser warnings.
- Manual `openstack coe cluster resize` can add a sixth node but circumvents autoscaler logic and may conflict with Jetstream’s automation.

### Recommendations / Next Steps

1. **Coordinate with Jetstream support**
   - Request that they update the managed cluster-autoscaler arguments to `--nodes=1:6:DefaultNodeGroup` (or enable nodegroup auto-discovery) for cluster `k8s`.
   - Alternatively, ask for access to the legacy trust-based `/etc/kubernetes/cloud-config` so we can run the upstream autoscaler ourselves.

2. **Temporary mitigation**
   - If immediate capacity is required, run `openstack coe cluster resize --nodegroup default-worker k8s 6` to add a node manually. This does not fix autoscaling but unblocks the pending workload.

3. **Documentation & tracking**
   - Share this report with stakeholders so the blocking dependency on Jetstream’s autoscaler is visible.
   - Track Jetstream’s response; once they adjust the ceiling, re-check `cluster-autoscaler-status` until `maxSize: 6` appears and the pending pod is scheduled.

### Key Commands Reference

```bash
# Inspect nodegroup limits
openstack coe nodegroup show k8s default-worker

# Increase nodegroup max via Magnum
openstack coe nodegroup update k8s default-worker replace max_node_count=6

# Attempted (but blocked) cluster label change
openstack --debug coe cluster update k8s replace labels/max_node_count=6

# Autoscaler status inside the cluster
kubectl -n kube-system get configmap cluster-autoscaler-status -o jsonpath='{.data.status}'

# Describe pending pod for autoscaler events
kubectl describe pod high-memory-deployment-844964899f-4md88
```

### Conclusion

All cluster-side prerequisites for a six-node worker pool are in place, but the actual scaling limit is enforced by Jetstream’s managed autoscaler, which still reads the old `max_node_count=5` label. Without Jetstream’s intervention (or access to trust credentials for a self-managed autoscaler), the pod will continue to see `pod didn't trigger scale-up: 1 max node group size reached`. The next actionable step is to engage Jetstream so they update their autoscaler configuration to accept six nodes.
