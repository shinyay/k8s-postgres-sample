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