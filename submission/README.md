# **Coworking Space Service Extension – DevOps Deployment**
The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

## **Table of Contents**

   [Prerequisites](#prerequisites)

1. [Create EKS Cluster](#create-eks-cluster)
   - [Install AWS CLI](#install-aws-cli)
   - [Create an EKS Cluster](#create-an-eks-cluster)
   - [Update Kubeconfig](#update-kubeconfig)
2. [Configure Database for the Service](#configure-database-for-the-service)
   - [Create YAML Configurations](#21-create-yaml-configurations)
   - [Update postgresql-deployment.yaml](#22-update-postgresql-deploymentyaml)
   - [Apply the Yaml configurations](#23-apply-the-yaml-configurations)
   - [Test Database Connection](#24-test-database-connection)
   - [Connecting service and Port Forwarding](#25-connecting-service-and-port-forwarding)
   - [Create Tables and Populate Data](#26-create-tables-and-populate-data)
   - [Set Port Forwarding](#27-set-port-forwarding)
3. [Install Dependencies and Run the application](#install-dependencies-and-run-the-application)
   - [Install dependencies](#31-install-dependencies)
   - [Set Environment Variables](#32-set-environment-variables)
   - [Run the application](#33-run-the-application)
   - [Verify the application](#34-verify-the-application)
4. [Deploy the Analytics Application](#deploy-the-analytics-application)
   - [Build the Docker Image](#41-build-the-docker-image)
   - [Run the Docker Image](#42-run-the-docker-image)
   - [Set up CI with Codebuild](#43-set-up-ci-with-codebuild)
   - [Deploy the Application](#44-deploy-the-application)


### Prerequisites

Before you begin, ensure that you have the following tools installed:

  **Python (3.6+)**: Install Python from the [official website](https://www.python.org/downloads/).

  **Docker CLI**: Install Docker for building and running containers locally. [Docker Installation Guide](https://docs.docker.com/get-docker/).

  **kubectl**: Install `kubectl` to interact with the Kubernetes cluster. [Kubernetes Installation Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

1. ### **Create EKS Cluster:**
    
    **1.1: Install AWS CLI**: 
    
      [AWS instructions to install/update AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  
      Ensure AWS CLI is configured Properly: ```aws sts get-caller-identity```
      
      Configure AWS settings: ```aws configure``` and set the AWS credentials

    **1.2: Create an EKS Cluster**:

    ```eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2```

    **1.3: Update Kubeconfig**:
    ```aws eks --region us-east-1 update-kubeconfig --name my-cluster```

2. ###  **Configure Database for the Service**:  
  
      #### **2.1: Create YAML Configurations**:

      **PersistentVolumeClaim (`pvc.yaml`)**:
      ```yaml
      apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: postgresql-pvc
      spec:
        storageClassName: gp2
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
      ```

      **PersistentVolume (`pv.yaml`)**:
      ```yaml
      apiVersion: v1
      kind: PersistentVolume
      metadata:
        name: my-manual-pv
      spec:
        capacity:
          storage: 1Gi
        accessModes:
          - ReadWriteOnce
        persistentVolumeReclaimPolicy: Retain
        storageClassName: gp2
        hostPath:
          path: "/mnt/data"
      ```

      **postgres-deployment.yaml**:
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
              image: postgres:latest
              env:
              - name: POSTGRES_DB
                value: mydatabase
              - name: POSTGRES_USER
                value: myuser
              - name: POSTGRES_PASSWORD
                value: mypassword
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


      #### **2.2 Update postgresql-deployment.yaml**:  
          Update the following fields in `postgresql-deployment.yaml`:
      - Database name: `mydatabase`
      - Username: `myuser`
      - Password: `mypassword`

      #### **2.3. Apply the Yaml configurations**:
      ```bash
      kubectl apply -f pvc.yaml
      kubectl apply -f pv.yaml
      kubectl apply -f postgresql-deployment.yaml
      ```

      #### **2.4 Test Database Connection**:
      
      View Pods:
      ```bash
          kubectl get pods
      ```
      Open Bash into the pod:
      ```bash
      kubectl exec -it <postgres pod name> -- bash
      ```
      Once you are inside the pod, you can run to login to the postgres database. Ensure to change the username and password, as applicable to you.
      ```bash
      psql -U myuser -d mydatabase
      ```
      Once you are inside the postgres database, you can list all databases
      ```bash
      \l
      ```

      #### **2.5 Connecting service and Port Forwarding:**
      Create a YAML file, **postgresql-service.yaml** and apply it
      ```bash
      apiVersion: v1
      kind: Service
      metadata:
        name: postgresql-service
      spec:
        ports:
        - port: 5432
          targetPort: 5432
        selector:
          app: postgresql
      ```
      
      Verify if the service is created: ```kubectl get svc```
      Once the service is created, do port forwading using below command

      ```bash
      kubectl port-forward service/postgresql-service 5433:5432 &
      ```

      #### **2.6 Create Tables and Populate Data:**

      Install PostgreSQL (if not installed) : Run Seed Files in db/ directory
      ```bash
          apt update
          apt install postgresql postgresql-contrib
          export DB_PASSWORD=mypassword
      ```

      Run the below command once for each SQL file :
      ```bash
          PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U myuser -d mydatabase -p 5433 < <FILE_NAME.sql>
      ```

      #### **2.7 Set Port Forwarding:**
      
      ```bash
          kubectl port-forward svc/postgresql-service 5433:5432 &
      ```


3. ###  **Install Dependencies and Run the application**:

      #### **3.1 Install dependencies:**
      Run the below commands     
      ```bash
          apt update
          apt install build-essential libpq-dev
          pip install --upgrade pip setuptools wheel
          pip install -r requirements.txt
      ```
      #### **3.2 Set Environment Variables:**
   
      ```bash
          export DB_USERNAME=myuser
          export DB_PASSWORD=${POSTGRES_PASSWORD}
          export DB_HOST=127.0.0.1
          export DB_PORT=5433
          export DB_NAME=mydatabase
      ```

      #### **3.3 Run the application:**
   
      ```bash
          python app.py
      ```

      #### **3.4 Verify the application:**
   
      ```bash
          curl <BASE_URL>/api/reports/daily_usage
          curl <BASE_URL>/api/reports/user_visits
      ```

4. ###  **Deploy the Analytics Application**:

      #### **4.1 Build the Docker Image:**
   
      ```bash
          docker build -t test-coworking-analytics .
      ```

      #### **4.2 Run the Docker Image:**
   
      ```bash
          docker run --network="host" test-coworking-analytics
      ```

      #### **4.3 Set up CI with Codebuild**:

      1. Create Amazon ECR repository on your AWS console
      2. create an Amazon CodeBuild project that is connected to your project's GitHub repository.
      3. Once they are done, create a buildspec.yaml file that will be triggered whenever the project repository is updated
      4. Click on the "Start Build" button on your CodeBuild console and then check out Amazon ECR to see if the Docker image is created/updated.
      
      #### **4.4 Deploy the Application**:

      1. Create a ConfigMap to store all the plaintext variables such as DB_HOST, DB_USERNAME, DB_PORT, DB_NAME.
      2. Create a Secret to store all the sensitive environment variables such as (DB_PASSWORD).
      3. Create a deployment YAML file to deploy the finalized Docker image in your ECR repository to your Kubernetes network
      4. Verify the deployment using the below command:

      ```bash
          kubectl get svc
      ```

**Note: delete Kubeconfig after finishing the project**:
    
  ```eksctl delete cluster --name my-cluster --region us-east-1```


