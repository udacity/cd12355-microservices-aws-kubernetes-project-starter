# Coworking Space Service

## Getting Started

### Step 1. Create an EKS cluster
```bash
eksctl create cluster --name project3-cluster --region us-east-1 --nodegroup-name project3-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

```

### Step 2. Update the Kubeconfig
```bash
aws eks --region us-east-1 update-kubeconfig --name project3-cluster
kubectl config current-context

```

### Step 3. Configure ENV variable and Secrets
```bash
kubectl apply -f deployment/configmap.yaml
kubectl apply -f deployment/secrets.yaml

```

### Step 4. Deploy Database
#### Step 4.1. deploy
```bash
kubectl apply -f deployment/pv.yaml
kubectl apply -f deployment/pvc.yaml
kubectl apply -f deployment/postgresql-deployment.yaml
kubectl apply -f deployment/postgresql-service.yaml

```

#### Step 4.2. seed data
```bash
kubectl port-forward --address 127.0.0.1 service/postgresql-service 5433:5432 &
export DB_PASSWORD=`kubectl get secret project3-secrets -o jsonpath='{.data.password}' | base64 --decode`
export DB_USER=`kubectl get configMap project3-config-map -o jsonpath='{.data.DB_USER}'`
export DB_NAME=`kubectl get configMap project3-config-map -o jsonpath='{.data.DB_NAME}'`
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U ${DB_USER} -d ${DB_NAME} -p 5433 < ./db/1_create_tables.sql
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U ${DB_USER} -d ${DB_NAME} -p 5433 < ./db/2_seed_users.sql
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U ${DB_USER} -d ${DB_NAME} -p 5433 < ./db/3_seed_tokens.sql

```

### Step 5. Deploy application
```bash
kubectl apply -f deployment/coworking.yaml

```
get the url and check web app's avaibility

```bash
kubectl get service
#NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)          AGE
#coworking            LoadBalancer   10.100.163.46    a39e16aa878994863af3031cebfea838-308774126.us-east-1.elb.amazonaws.com   5153:32405/TCP   40s
#kubernetes           ClusterIP      10.100.0.1       <none>                                                                   443/TCP          30m
#postgresql-service   ClusterIP      10.100.194.163   <none> 
```

open this link in browser: http://a39e16aa878994863af3031cebfea838-308774126.us-east-1.elb.amazonaws.com:5153/api/reports/user_visits

### Step 6. Logging
Attach the CloudWatchAgentServerPolicy
```bash
aws iam attach-role-policy \
--role-name eksctl-project3-cluster-nodegroup--NodeInstanceRole-wXPyILALCcWt \
--policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

```

Attach the CloudWatchAgentServerPolicy
```bash
aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name project3-cluster

```