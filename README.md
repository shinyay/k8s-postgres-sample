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