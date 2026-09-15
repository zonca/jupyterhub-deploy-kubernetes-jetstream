# Test results: 2026-09-15 on Jetstream2 (allocation CIS230085)

Validated with a fresh Magnum cluster (`kubernetes-1-33-jammy-fixed-labels`,
m3.small, 1 control plane + 1 worker, Kubernetes v1.33.2) and a fresh Manila
CEPHFS share (10 GiB, `cephfsnativetype`, cephx RW access rule).

Result: **fsGroup is honored on Manila CephFS RWX volumes, and ngshare works
without any initContainer fix.**

## CSI driver fsGroup policies

```
kubectl get csidriver
cephfs.csi.ceph.com        fsGroupPolicy=File
cinder.csi.openstack.org   fsGroupPolicy=ReadWriteOnceWithFSType
```

## ngshare-like standalone pod (no initContainer) — SUCCESS

```
uid=65535 gid=0(root) groups=0(root),1000
drwxrwsr-x 2 119 1000 0 Sep 15 17:33 /srv/ngshare
sqlite ok
-rw-r--r-- 1 65535 1000 8192 Sep 15 17:43 repro.sqlite
```

The mount directory is owned `119:1000` (fsGroup=1000 applied) with the
setgid bit, so the ngshare process (uid 65535, group 1000) writes freely.

## Full ngshare Helm chart (no initContainer) — SUCCESS

```
NAME                       READY   STATUS    RESTARTS   AGE
ngshare-77d85cf978-s9dmm   1/1     Running   0          2m6s
```

Logs show alembic migrations writing the SQLite database on the Manila
volume and no permission errors:

```
INFO  [alembic.runtime.migration] Context impl SQLiteImpl.
INFO  [alembic.runtime.migration] Running upgrade  -> aa00db20c10a, Init
INFO  [alembic.runtime.migration] Running upgrade aa00db20c10a -> 1921a169739b, Add file size
```

Inside the pod:

```
uid=65535 gid=0(root) groups=0(root),1000
drwxrwsr-x 2 119 1000 2 Sep 15 17:47 /srv/ngshare
-rw-r--r-- 1 65535 1000 81920 Sep 15 17:47 ngshare.db
```

## Key configuration notes

- The CephFS CSI driver registers `fsGroupPolicy=File`, so kubelet applies
  `fsGroup` for all access modes, including RWX (unlike Cinder CSI).
- The ngshare Helm chart always creates its own PVC, so static binding is
  done via `pvc.selector` + a `kubernetes.io/no-provisioner` StorageClass
  (a StorageClass with a real provisioner triggers dynamic provisioning,
  and the cephfs provisioner rejects PVC selectors: "claim Selector is not
  supported").
- After a PVC is deleted, clear the static PV `claimRef` before binding it
  to a new PVC:

```bash
kubectl patch pv <NAME> --type=merge -p '{"spec":{"claimRef":null}}'
```
