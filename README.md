# PostgresSQL on Kubernetes

## Deployment without Persistence
```
$ kubectl apply -f postgres-without-persistence/postgres.yml
```

```
$ kubectl get pods

NAME                       READY     STATUS    RESTARTS   AGE
postgres-bd5cc4c99-dbtjk   1/1       Running   0          47s
```

```
$ kubectl exec -it postgres-bd5cc4c99-dbtjk /bin/bash
```

```
root@postgres-bd5cc4c99-dbtjk:/# psql -U dev
psql (9.6.10)
Type "help" for help.

dev=# create table sample();
CREATE TABLE
dev=# \d
        List of relations
 Schema |  Name  | Type  | Owner
--------+--------+-------+-------
 public | sample | table | dev
(1 row)

dev=# \q
root@postgres-bd5cc4c99-dbtjk:/# exit
```

```
$ kubectl delete pod postgres-bd5cc4c99-dbtjk

pod "postgres-bd5cc4c99-dbtjk" deleted
```

```
$ kubectl get pods

NAME                       READY     STATUS        RESTARTS   AGE
postgres-bd5cc4c99-cdhzk   1/1       Running       0          4s
postgres-bd5cc4c99-dbtjk   0/1       Terminating   0          3m
```

```
$ kubectl exec -it postgres-bd5cc4c99-cdhzk /bin/bash
```

```
root@postgres-bd5cc4c99-cdhzk:/# psql -U dev
psql (9.6.10)
Type "help" for help.

dev=# \d
No relations found.
```

## Deployment with Persistence

```
$ kubectl apply -f postgres-singlenode-volume/postgres-hostpath.yml

service "postgres" created
deployment.extensions "postgres" created
```

```
$ kubectl get pods

NAME                        READY     STATUS    RESTARTS   AGE
postgres-77cc684d9f-76lds   1/1       Running   0          10s
```

```
$ kubectl exec -it postgres-77cc684d9f-76lds /bin/bash
```

```
bash-4.4# psql -U dev
psql (10.5)
Type "help" for help.

dev=# create table sample();
CREATE TABLE
dev=# \d
        List of relations
 Schema |  Name  | Type  | Owner
--------+--------+-------+-------
 public | sample | table | dev
(1 row)

dev=# \q
```

```
$ kubectl delete pod postgres-77cc684d9f-76lds
pod "postgres-77cc684d9f-76lds" deleted
```

```
$ kubectl get pods

NAME                        READY     STATUS    RESTARTS   AGE
postgres-77cc684d9f-hp28m   1/1       Running   0          7s
```

```
$ kubectl exec -it postgres-77cc684d9f-hp28m /bin/bash
```

```
bash-4.4# psql -U dev
psql (10.5)
Type "help" for help.

dev=# \d
        List of relations
 Schema |  Name  | Type  | Owner
--------+--------+-------+-------
 public | sample | table | dev
(1 row)
```

## Deployment with using Persistent Volume

```
$ kubectl apply -f postgres-persistent-volume/postgres-configmap.yml

configmap "postgres-config" created
```

```
$ kubectl apply -f postgres-persistent-volume/postgres-storage.yml

persistentvolume "postgres-pv-volume" created
```

```
$ kubectl apply -f postgres-persistent-volume/postgres-storage.yml

persistentvolume "postgres-pv-volume" created
persistentvolumeclaim "postgres-pv-claim" created
```

```
$ kubectl apply -f postgres-persistent-volume/postgres-deployment.yml

deployment.extensions "postgres" created
```

```
$ kubectl apply -f postgres-persistent-volume/postgres-service.yml

service "postgres" created
```

```
$ kubectl get pods

NAME                        READY     STATUS    RESTARTS   AGE
postgres-756668d8f4-hflw8   1/1       Running   0          22s
```

```
$ kubectl exec -it postgres-756668d8f4-hflw8 /bin/bash
```

```
root@postgres-756668d8f4-hflw8:/# psql -U dev
psql (10.5 (Debian 10.5-1.pgdg90+1))
Type "help" for help.

dev=# \d
        List of relations
 Schema |  Name  | Type  | Owner
--------+--------+-------+-------
 public | sample | table | dev
(1 row)
```

```
$ kubectl scale deployment postgres --replicas=2

deployment.extensions "postgres" scaled
```

```
$ kubectl get pods

NAME                        READY     STATUS    RESTARTS   AGE
postgres-756668d8f4-7bw5s   1/1       Running   0          5s
postgres-756668d8f4-hflw8   1/1       Running   0          17m
```

```
$ kubectl exec -it postgres-756668d8f4-7bw5s -- psql -U dev

psql (10.5 (Debian 10.5-1.pgdg90+1))
Type "help" for help.

dev=# \d
        List of relations
 Schema |  Name  | Type  | Owner
--------+--------+-------+-------
 public | sample | table | dev
(1 row)
```

## Volume Types for Kubernetes

|ボリューム種類名 | 分類      | 永続性 | マルチライター |可用性| 概要　|
|:-------|:---------|:------|:----|:----|:----|:----|
|[emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir)|k8s native|なし|ポッド内|なし|ポッドが存在する間の一時的ボリューム| 
|[hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostPath)|k8s native|ノード内|ノード内|なし|ポッドをホストするノードのファイルシステム上のファイルまたはディレクトリをマウント|
|[local](https://kubernetes.io/docs/concepts/storage/volumes/#local)| alpha since k8s 1.7 |ノード内|ノード内|なし|ノードのストレージデバイスをマウント
|[persistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim)|k8s native|あり|クラスタ内|下位依存|永続ボリュームをポッドにマウント|
|[projected](https://kubernetes.io/docs/concepts/storage/volumes/#projected)|k8s native|あり|-|-|projectedは既存のボリュームを同一ディレクトリに投影するもので、secret, downwardAPI, configMapがある|
|[secret](https://kubernetes.io/docs/concepts/storage/volumes/#secret)|k8s native|あり|不可|-|ポッドにパスワードなどの機密情報を渡すために使用
|[configMap](https://kubernetes.io/docs/concepts/storage/volumes/#configmap)|k8s native|あり|不可|-|ポッドにコンフィギュレーションデータを注入する方法
|[downwardAPI](https://kubernetes.io/docs/concepts/storage/volumes/#downwardapi)|k8s native|？|？|-|ディレクトリをマウントしてテキストを書き出し
|[csi](https://kubernetes.io/docs/concepts/storage/volumes/#csi)| alpha since k8s 1.9  |？|？|-|コンテナオーケストレーたの業界標準インターフェイスを確立しようとする仕様
|[iscsi](https://kubernetes.io/docs/concepts/storage/volumes/#iscsi)|業界標準|あり|不可|下位依存|iSCSIボリュームをポッドにマウント
|[nfs](https://kubernetes.io/docs/concepts/storage/volumes/#nfs)|業界標準|あり|可能|下位依存|NFSのファイルシステムをポッドにマウント
|[cephfs](https://kubernetes.io/docs/concepts/storage/volumes/#cephfs) |OSS分散ストレージ|あり|可能|あり| OpenStack定番の分散ストレージ、既存のCephFSのボリュームをポッドにマウント、
|[glusterfs](https://kubernetes.io/docs/concepts/storage/volumes/#glusterfs) |OSS分散ストレージ|あり|可能|あり|大規模並列ネットワークファイルシステム、既存のGlusterFSをポッドにマウント
|[flocker](https://kubernetes.io/docs/concepts/storage/volumes/#flocker) |OSS分散ストレージ|あり|可能|あり|ZFSベースのDocker用ボリュームをポッドにマウント
|[awsElasticBlockStore](https://kubernetes.io/docs/concepts/storage/volumes/#awselasticblockstore)|クラウド提供|あり|ノード内|あり|EC2上のノードにEBSをマウント、ポッドから利用
|[azureDisk](https://kubernetes.io/docs/concepts/storage/volumes/#azuredisk)|クラウド提供|あり|？|あり|AzureのDISKをポッドにマウント
|[azureFile](https://kubernetes.io/docs/concepts/storage/volumes/#azurefile)|クラウド提供|あり|可|あり|AzureのSMBファイルシステムをポッドにマウント
|[gcePersistentDisk](https://kubernetes.io/docs/concepts/storage/volumes/#gcepersistentdisk)|クラウド提供|あり|可|あり|Google Compute Engine (GCE) の永続ボリュームをポッドにマウント
|[portworxVolume](https://kubernetes.io/docs/concepts/storage/volumes/#portworxvolume)|プロプライエタリSW|あり|？|あり|ハイパーコンバージド基盤の伸縮可能なボリュームに、ポッドにマウント
|[scaleIO](https://kubernetes.io/docs/concepts/storage/volumes/#scaleio)|プロプライエタリSW|あり|可能|あり|EMCが開発にしたソフトウェア・デファインド・ブロックストレージをポッドにマウント
|[storageOS](https://kubernetes.io/docs/concepts/storage/volumes/#storageos)|プロプライエタリSW|あり|可能|あり|コンテナとしてk8s内で実行できるボリュームをポッドにマウント|
|[vsphereVolume](https://kubernetes.io/docs/concepts/storage/volumes/#storageos)|プロプライエタリSW|あり|可能|あり|VMwareの仮想ボリュームをポッドでマウント|
|[quobyte](https://kubernetes.io/docs/concepts/storage/volumes/#quobyte)|プロプライエタリSW|あり|可能|あり|データセンターレベルのファイルシステムをポッドにマウント|
|[gitRepo](https://kubernetes.io/docs/concepts/storage/volumes/#gitrepo)|other|-|-|-|空のディレクトリをマウントし、gitリポジトリをクローンしてポッドに使用させます
|[fibre channel](https://kubernetes.io/docs/concepts/storage/volumes/#fc-fibre-channel)|専用H/W|あり|不可|下位依存|既存のファイバチャネルのボリュームをポッドにマウント
