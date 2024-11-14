## Getting Started

# create cluster
```bash
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2 --profile udacity-cloud
```

# Update kubeconfig
```bash
aws eks --region us-east-1 update-kubeconfig --name my-cluster --profile udacity-cloud
kubectl config current-context
```

# Create db service
```bash
kubectl get storageclass
kubectl apply -f deployment/pvc.yaml
kubectl apply -f deployment/pv.yaml
kubectl apply -f deployment/postgresql-deployment.yaml
kubectl apply -f deployment/postgresql-service.yaml
```

# setup port-forwarding from local:5433 to postgresql-service:5432
```bash
kubectl port-forward service/postgresql-service 5433:5432 &
```

# set DB env variables

```bash
export DB_PASSWORD=mypassword
export DB_USERNAME=myuser
export DB_HOST="127.0.0.1"
export DB_NAME="mydatabase"
export DB_PORT=5433
```

# Create table and insert data
```bash
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < db/<files.sql>
```

# connect db using port forwarding
```bash
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433
```

# build app locally 
```bash
apt update -y && apt install build-essential libpq-dev -y
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
python app.py

curl 127.0.0.1:5153/api/reports/daily_usage
curl 127.0.0.1:5153/api/reports/user_visits
```

# build app with docker
```bash
docker build -t test-coworking-analytics .
docker run --network="host" test-coworking-analytics
```

# Set up Continuous Integration with CodeBuild

