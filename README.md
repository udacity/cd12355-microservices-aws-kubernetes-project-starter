# Project: Python Analytics Application with PostgreSQL on Kubernetes

## Overview

The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide you functions as expected locally and you are expected to help build a pipeline to deploy it in Kubernetes.

## Table of Contents

-   [Overview](#overview)
-   [Features](#features)
-   [Architecture](#architecture)
-   [Prerequisites](#prerequisites)
-   [Local Development](#local-development)
-   [Dockerization](#dockerization)
-   [Kubernetes Deployment](#kubernetes-deployment)
-   [Environment Variables](#environment-variables)
-   [Database Setup](#database-setup)
-   [API Endpoints](#api-endpoints)
-   [Troubleshooting](#troubleshooting)

## Features

*   **User Activity Tracking:** Collects data on user visits and usage patterns.
*   **Daily Usage Reports:** Generates daily statistics on app usage.
*   **Containerized:** Uses Docker for easy packaging and distribution.
*   **Scalable Deployment:** Designed for deployment on Kubernetes.

## Architecture

The application architecture consists of:

1.  **Python Flask API:** Provides the core API and business logic.
2.  **PostgreSQL Database:** Persistently stores user and visit data.
3.  **Docker Containers:** Packages the application and database into containers.
4.  **Kubernetes:** Manages the deployment and scaling of containers.
5.  **Kubernetes Services:** Exposes the database and application to the cluster.

## Prerequisites

To run this project, you'll need the following installed:

*   **Python 3.12+:** For running the Flask application.
*   **Docker:** For containerizing the application.
*   **Docker Compose:** For local development and testing of Dockerized application.
*   **kubectl:** For deploying to and interacting with a Kubernetes cluster.
*   **AWS CLI:** for interaction with aws resources.
*   **An EKS Cluster:** For deploying your project to a live Kubernetes cluster.
*   **A configured ECR:** You should have a configured AWS ECR.

## Local Development

1.  **Clone the repository:**

    ```bash
    git clone <your-repo-url>
    cd <your-project-directory>
    ```
2. **Create a docker compose file to setup postgreSQL . Start PostgreSQL using docker compose:**
    ```bash
    docker-compose up -d
    ```
    This command will launch the postgres container.

3.  **Access the Postgres Container**

    *   You will need to connect to your postgres database container using `psql` command. You can use this command to run psql in a docker container
        ```bash
        docker exec -it <your_postgres_container_name> psql -U postgres -d postgres
        ```
    *   You can create other databases or users. Make sure to also create a `postgres` user with a password `test` to run the queries with the correct user.

4.  **Run Seed Files**:
    *   You will need to execute the SQL script that contains table definitions or populate the tables with some sample data. The Sql scripts are located in the db folder.

5.  **Install Python dependencies:**

    ```bash
    pip install -r analytics/requirements.txt
    ```
6.  **Run the application:**

    ```bash
    python analytics/app.py
    ```

    This command will launch the app on http://0.0.0.0:5153. Make sure to specify environment variables before you launch the application. You can also load environment variables from a `.env` file using `python -m .env run python app.py`
7.  **Access API:** You can now access your API at `http://127.0.0.1:5153/api/reports/user_visits` (or similar endpoints)

## Dockerization


1.  **Dockerfile:**
    The following `Dockerfile` is used to build your application image
    ```dockerfile
    # Use an official Python runtime as a parent image
    FROM python:3.12-slim

    # Set the working directory in the container
    WORKDIR /app


    # Copy the requirements file into the container at /app
    COPY /analytics /app

    #update python modules to sucessfully build the required modules
    RUN pip install --upgrade pip setuptools wheel

    # Install any needed packages specified in requirements.txt
    RUN pip install --no-cache-dir -r requirements.txt

    #expose the port
    EXPOSE 5153

    #environmental varaiables
    ENV DB_USERNAME=postgres
    ENV DB_PASSWORD=test
    ENV DB_HOST=postgres
    ENV DB_PORT=5432
    ENV DB_NAME=postgres

    # Run app.py when the container launches
    CMD ["python", "app.py"]
    ```

## Kubernetes Deployment

1.  **AWS CodeBuild:**

    *   The `buildspec.yaml` is used by AWS Codebuild to build the application and postgres images

        ```yaml
        version: 0.2

        phases:
          pre_build:
            commands:
              - echo Logging in to Amazon ECR...
              - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
          build:
            commands:
              - echo Build started on `date`

              # Build the application image
              - echo Building the app Docker image...
              - docker build -t $APP_IMAGE_REPO_NAME:$CODEBUILD_BUILD_NUMBER .
              - docker tag $APP_IMAGE_REPO_NAME:$CODEBUILD_BUILD_NUMBER $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$APP_IMAGE_REPO_NAME:$CODEBUILD_BUILD_NUMBER

          post_build:
            commands:
              - echo Build completed on `date`

              # Push the application image
              - echo Pushing the app Docker image...
              - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$APP_IMAGE_REPO_NAME:$CODEBUILD_BUILD_NUMBER
        ```

        You need to configure environment variables such as `AWS_ACCOUNT_ID`, `AWS_DEFAULT_REGION` & `APP_IMAGE_REPO_NAME`  in the Codebuild settings. You will also need to create the corresponding ECR repositories.

2.  **Kubernetes Manifests:**
    *   **ConfigMap:**
        The `configmap.yaml` contains the configuration for database hostname, username and database name. Ensure that the port is enclosed in double quotes `"5432"`.

        ```yaml
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: coworking-db-config
        data:
          DB_NAME: "postgres"
          DB_USER: "postgres"
          DB_HOST: "postgresql-service"
          DB_PORT: "5432"
        ```

    *   **Secret:**
         The `secret.yaml` is used to create the database password secret. It contains the base64 encoded database password.

        ```yaml
        apiVersion: v1
        kind: Secret
        metadata:
          name: db-password
        type: Opaque
        data:
          password: dGVzdA==
        ```

     *  **Persistent Volume (`pv.yaml`):** Defines the storage volume (this is provisioned at the cluster level, this may need to be set up by your cluster admin)
        ```yaml
            apiVersion: v1
            kind: PersistentVolume
            metadata:
              name: postgresql-pv
              labels:
                type: local
            spec:
              storageClassName: manual
              capacity:
                storage: 10Gi
              accessModes:
                - ReadWriteOnce
              hostPath:
                path: "/mnt/data"
        ```
    *  **Persistent Volume Claim (`pvc.yaml`):** Requests the storage from the Persistent Volume.

       ```yaml
        apiVersion: v1
        kind: PersistentVolumeClaim
        metadata:
          name: postgresql-pvc
        spec:
          storageClassName: manual
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi
       ```


    *   **Postgres Deployment and Service:**
        *   The `postgresql-deployment.yaml` file contains the deployment for the postgres database. It uses the `db-password` secret for the database password.

            ```yaml
            apiVersion: apps/v1
            kind: Deployment
            metadata:
              name: postgresql
            spec:
              selector:
                matchLabels:
                  app: postgresql
              template:
                metadata:
                  labels:
                    app: postgresql
                spec:
                  containers:
                  - name: postgresql
                    image: <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-postgres-image>:<your-build-number>
                    env:
                    - name: POSTGRES_DB
                      valueFrom:
                        configMapKeyRef:
                          name: coworking-db-config
                          key: DB_NAME
                    - name: POSTGRES_USER
                      valueFrom:
                        configMapKeyRef:
                          name: coworking-db-config
                          key: DB_USER
                    - name: POSTGRES_HOST
                      valueFrom:
                        configMapKeyRef:
                          name: coworking-db-config
                          key: DB_HOST
                    - name: POSTGRES_PASSWORD
                      valueFrom:
                        secretKeyRef:
                          name: db-password
                          key: password
                    ports:
                    - containerPort: 5432
                    volumeMounts:
                    - mountPath: /var/lib/postgresql/data
                      name: postgresql-storage
                  volumes:
                  - name: postgresql-storage
                    persistentVolumeClaim:
                      claimName: postgresql-pvc
            ```

         *  The `postgresql-service.yaml` exposes the postgres deployment.

            ```yaml
            apiVersion: v1
            kind: Service
            metadata:
              name: postgresql-service
            spec:
              selector:
                app: postgresql # This should match your Deployment label
              ports:
                - protocol: TCP
                  port: 5432      # Port on the service
                  targetPort: 5432 # Port on the container
            ```

    *   **Application Deployment:**
        The `coworking.yaml` contains the deployment spec for your python application. It consumes the db config from the `coworking-db-config` Configmap and the password from the `db-password` secret.
         ```yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: your-app-deployment
        spec:
          replicas: 3
          selector:
            matchLabels:
              app: your-app
          template:
            metadata:
              labels:
                app: your-app
            spec:
              containers:
                - name: your-app
                  image: <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-app-image>:<your-build-number>
                  ports:
                    - containerPort: 5153
                  env:
                      - name: DB_USERNAME
                        valueFrom:
                           configMapKeyRef:
                             name: coworking-db-config
                             key: DB_USER
                      - name: DB_PASSWORD
                        valueFrom:
                         secretKeyRef:
                            name: db-password
                            key: password
                      - name: DB_HOST
                        valueFrom:
                            configMapKeyRef:
                              name: coworking-db-config
                              key: DB_HOST
                      - name: DB_PORT
                        valueFrom:
                            configMapKeyRef:
                              name: coworking-db-config
                              key: DB_PORT
                      - name: DB_NAME
                        valueFrom:
                            configMapKeyRef:
                              name: coworking-db-config
                              key: DB_NAME
        ```

3.  **Apply Manifests:**

    ```bash
        kubectl apply -f configmap.yaml
        kubectl apply -f secret.yaml
        kubectl apply -f pv.yaml    # for Postgres volume
        kubectl apply -f pvc.yaml   # request volume for postgres
        kubectl apply -f postgresql-deployment.yaml
        kubectl apply -f postgresql-service.yaml
        kubectl apply -f application-deployment.yaml
    ```
    Ensure that you apply the service after applying the deployment if using the service hostname to connect to the database.

## Environment Variables

The application uses the following environment variables, which should be set using a configmap or environment variables.

*   `DB_USERNAME`: Database username
*   `DB_PASSWORD`: Database password (set through secret)
*   `DB_HOST`: Database host/service name (set as `postgresql-service`)
*   `DB_PORT`: Database port (set as `5432`)
*   `DB_NAME`: Database name (set as `postgres`)

## Database Setup

The application expects a database named `postgres` with a user `postgres`. You may need to configure additional users and databases as needed.

## API Endpoints

*   `/health_check`: Returns "ok" if the application is running.
*   `/readiness_check`: Checks database connection and returns "ok" if ready (or "failed" with 500 if the database connection is failing).
*   `/api/reports/daily_usage`: Returns daily usage data from the database.
*   `/api/reports/user_visits`: Returns user visit data from the database.

## Troubleshooting

*   **Readiness Probe Errors (500):**  Verify database connection and query. Check application logs.
*   **"Name or service not known" error:**  Make sure to create a service for the database. Ensure `DB_HOST` is set to the name of the service. Check for correct namespace if using multi-namespace setup.
*   **ConfigMap or Secret Errors**: Ensure that you use correct kubernetes resource types, names and values. Ensure that the values are strings and your configmaps and secrets are correctly applied. Use the `kubectl describe` to view and debug your kubernetes resources.

