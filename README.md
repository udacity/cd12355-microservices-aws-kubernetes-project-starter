# Coworking Space Service Extension

The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

### 1. Configure a Database

1.  In this step, we use the following yaml files to configure the database:

-   postgres-service.yml
-   postgres-deployment.yml
-   pv.yml (for a persistent volume)
-   postgres-login-secret.yaml (This one contains the passwords for the DB codified).

For running each yaml file, we first connect to EKS with the AWS-CLI and run, for each file.yml

    kubectl -f apply <file.yml>

This should set up a Postgre deployment at `<SERVICE_NAME>-postgresql.default.svc.cluster.local` in the Kubernetes cluster. By default, it will create a username `postgres`.

2.  Test Database Connection Connect via [`Port Forwarding`](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

-   Connecting Via Port Forwarding

``` bash
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 
```

3.  Run Seed Files We will need to run the seed files in `db/` in order to create the tables and populate them with data. This is done by running the following command.

``` bash
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>
```

(For simplicity, we created a .sh file to run the three lines at the same time)

### 2. Create a `Dockerfile` for the Python application. Use a base image that is Python-based.

The Dockerfile has instructions for:

1.  Install dependencies

``` bash
pip install -r requirements.txt
```

2.  Run the application (see below regarding environment variables)

``` bash
<ENV_VARS> python app.py
```

The environment variables are extracted from the secret created before.

3.  Create a CodeBuild project to connect with the repository and build the Image into AWS ECR and configure it to trigger a build each time there is a merge in the repo.

### 3. Create a service and deployment using Kubernetes configuration files to deploy the application

In the same EKS project, create a service and deployment by running the `deployment.yml` file (this one contains both the service and the deployment).
