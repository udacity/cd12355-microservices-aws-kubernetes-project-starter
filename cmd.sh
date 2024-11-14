# create cluster
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2 --profile udacity-cloud

# Create db service
kubectl get storageclass
kubectl apply -f pvc.yaml
kubectl apply -f pv.yaml
kubectl apply -f postgresql-deployment.yaml
kubectl apply -f postgresql-service.yaml

# setup port-forwarding from local:5433 to postgresql-service:5432
kubectl port-forward service/postgresql-service 5433:5432 &

# set DB env variables
export DB_PASSWORD=mypassword
export DB_USERNAME=myuser
export DB_HOST="127.0.0.1"
export DB_PORT="5432"
export DB_NAME="mydatabase"

# Insert data
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < ./db/files.sql

# connect db
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433

# run local
python app.py
curl 127.0.0.1:5153/api/reports/daily_usage
curl 127.0.0.1:5153/api/reports/user_visits

# build local docker
docker build -t test-coworking-analytics .
docker run --network="host" test-coworking-analytics