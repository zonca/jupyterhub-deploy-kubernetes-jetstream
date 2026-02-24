# ngshare SQLite PVC Permission Repro (Standalone)

This folder contains a minimal Kubernetes repro for the `ngshare` SQLite PVC
permission issue.

It reproduces the same core runtime conditions used by `ngshare`:

- Pod security context: `fsGroup: 1000`, `runAsNonRoot: true`
- Container security context: `runAsUser: 65535`,
  `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`,
  `capabilities.drop: [ALL]`
- SQLite database file path on PVC mount: `/srv/ngshare/repro.sqlite`
- Command uses `python3` (matching `libretexts/ngshare:v0.6.0`)
- PVC storage class: `default` (Cinder CSI on Jetstream in this project)

The repro has two pod variants:

1. `no-init` pod: expected to fail on a fresh PVC with
   `sqlite3.OperationalError: unable to open database file`
2. `with-init` pod: expected to succeed after a root init container fixes
   ownership and mode on `/srv/ngshare`

## Files

- `01-pvc.yaml`: fresh PVC for the test
- `02-pod-ngshare-like-no-init.yaml`: ngshare-like pod without init fix
- `03-pod-ngshare-like-with-init.yaml`: ngshare-like pod with init fix

## Prerequisites

From repository root:

```bash
source app-cred-coe-202504-openrc.sh
source .venv/bin/activate
export KUBECONFIG=$(pwd)/config
```

Verify cluster access:

```bash
kubectl get nodes
kubectl get storageclass
```

## Step 1: Create namespace and fresh PVC

```bash
kubectl create namespace jhub --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f nbgrader/ngshare-standalone-repro/01-pvc.yaml
kubectl -n jhub get pvc ngshare-standalone-pvc
```

## Step 2: Run ngshare-like pod without init fix (expected failure)

```bash
kubectl apply -f nbgrader/ngshare-standalone-repro/02-pod-ngshare-like-no-init.yaml
kubectl -n jhub wait --for=condition=Ready pod/ngshare-standalone-no-init --timeout=120s || true
kubectl -n jhub logs ngshare-standalone-no-init --tail=200
kubectl -n jhub get pod ngshare-standalone-no-init
kubectl -n jhub describe pod ngshare-standalone-no-init
```

Expected: logs include a traceback ending with:

```text
sqlite3.OperationalError: unable to open database file
```

Typical no-init log lines:

```text
uid=65535 gid=0(root) groups=0(root),1000
drwxr-xr-x 3 root root ... /srv/ngshare
sqlite3.OperationalError: unable to open database file
```

Expected pod phase for this step: `Error` or `Failed`.

## Step 3: Run ngshare-like pod with init fix (expected success)

Delete the failing pod first:

```bash
kubectl -n jhub delete pod ngshare-standalone-no-init --ignore-not-found
```

Run the init-fixed pod:

```bash
kubectl apply -f nbgrader/ngshare-standalone-repro/03-pod-ngshare-like-with-init.yaml
kubectl -n jhub wait --for=condition=Ready pod/ngshare-standalone-with-init --timeout=180s
kubectl -n jhub logs ngshare-standalone-with-init --tail=200
kubectl -n jhub get pod ngshare-standalone-with-init
```

Expected:

- command output includes `sqlite ok`
- `/srv/ngshare/repro.sqlite` exists

Typical with-init log lines:

```text
drwxrwx--- ... 65535 1000 ... /srv/ngshare
sqlite ok
```

## Optional: Inspect mount ownership and permissions

```bash
kubectl -n jhub exec ngshare-standalone-with-init -- sh -c 'id && ls -ld /srv/ngshare && ls -l /srv/ngshare'
```

## Cleanup

```bash
kubectl -n jhub delete pod ngshare-standalone-no-init --ignore-not-found
kubectl -n jhub delete pod ngshare-standalone-with-init --ignore-not-found
kubectl -n jhub delete pvc ngshare-standalone-pvc --ignore-not-found
```

## Notes

- Use a **fresh PVC** when validating the failure path. If the volume was
  previously fixed by a root init container, the no-init test may appear to
  succeed because permissions are already modified.
- If `kubectl wait --for=condition=Ready` times out in Step 2, that is expected
  when the container exits quickly with the SQLite error.
- This repro focuses only on PVC ownership and SQLite open/write behavior.
  It does not depend on JupyterHub/ngshare service registration.
