# ngshare SQLite PVC Permission Test on a Manila CephFS Volume

This folder contains a standalone Kubernetes repro to verify that a Manila
CephFS share (mounted via the CephFS CSI driver) honors `fsGroup` on a
`ReadWriteMany` volume, so that `ngshare` can create its SQLite database
**without** the root initContainer workaround.

Result (tested 2026-09-15): **SUCCESS** — see [RESULTS.md](RESULTS.md).

Compare with `../ngshare-standalone-repro` (the same test on the default
Cinder StorageClass, where `fsGroup` is NOT applied to RWX volumes because
the Cinder CSIDriver uses `fsGroupPolicy: ReadWriteOnceWithFSType`).

## Prerequisites

From repository root:

```bash
source app-cred-YYYYMM_cis230085-openrc.sh
source .venv/bin/activate
```

1. Create a Manila share (e.g. 10 GiB, `cephfsnativetype`, CEPHFS), get its
   export location and add a `cephx` RW access rule.
2. Fill placeholders in `01-pv.yaml`:
   - `<SHARE_ID>`: the Manila share UUID (any unique string is fine as `volumeHandle`)
   - `<SHARE_PATH>`: the path part of the export location (e.g. `/volumes/_nogroup/<share-id>/<path>`)
   - `clusterID`: must match `csiConfig[].clusterID` in the ceph-csi Helm values
3. Install CephFS CSI (see `../../manila/cephfs-csi-values.yaml`) and make sure
   the secret `csi-cephfs-secret` is in `kube-system` (or adjust
   `nodeStageSecretRef` in `01-pv.yaml`).

## Run

```bash
kubectl create namespace jhub --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f 00-storageclass.yaml
kubectl apply -f 01-pv.yaml
kubectl apply -f 02-pvc.yaml
kubectl -n jhub get pvc ngshare-manila-repro-pvc
kubectl apply -f 03-pod-ngshare-like-no-init.yaml
kubectl -n jhub wait --for=condition=Ready pod/ngshare-manila-no-init --timeout=120s || true
kubectl -n jhub logs ngshare-manila-no-init --tail=200
```

Expected: `sqlite ok` (fsGroup is applied on the Manila volume).

Control run with the root initContainer:

```bash
kubectl apply -f 04-pod-ngshare-like-with-init.yaml
kubectl -n jhub logs ngshare-manila-with-init --tail=200
```

## Deployment of ngshare with the Manila volume

Use `../ngshare-manila-config.yaml` as Helm values; the chart creates a PVC
that selects the same static PV. No initContainer is required.

## Cleanup

```bash
kubectl -n jhub delete pod ngshare-manila-no-init --ignore-not-found
kubectl -n jhub delete pod ngshare-manila-with-init --ignore-not-found
kubectl -n jhub delete pvc ngshare-manila-repro-pvc --ignore-not-found
kubectl delete pv ngshare-manila-pv --ignore-not-found
kubectl delete sc manila-cephfs --ignore-not-found
```

## Notes

- Use a **fresh share/PV** when validating the failure-free path.
- The CephFS CSI driver registers `fsGroupPolicy: File`, so kubelet applies
  `fsGroup` for all access modes, including RWX (unlike Cinder CSI).
