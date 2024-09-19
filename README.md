# Coworking Space Service Extension: Analytics API Deployment

## Overview
The Coworking Space Service Analytics API provides business analysts with basic analytics data on user activity within the coworking space. The application is deployed within a Kubernetes environment managed via AWS EKS. 

## Technologies and Tools

- **Python 3.9+**: Core language for the analytics application.
- **Docker CLI**: To build, test, and run Docker images locally.
- **kubectl**: For managing Kubernetes clusters.
- **Helm**: For deploying and managing applications in Kubernetes.
- **AWS ECR**: Container Registry for storing Docker images.
- **AWS CodeBuild**: Automates image builds and pushes to ECR.
- **Kubernetes with AWS EKS**: The eks cluster should have the necessary permissions and policy for dynamic volumes creation
- **CloudWatch**: Monitoring and logging service to track application performance and health.

## Deployment Process

**1. Database Setup:** We use the Bitnami Helm chart to deploy PostgreSQL in the Kubernetes cluster.
NB: After adding the Helm repository, modify the values.yaml file to add the database configuration, the storageclass for your eks cluster and the persistent volume configuration. Retrieve the password that will be used to connect to the database to run seed files.

**2. Docker image Build:** Create the Dockerfile with the instructions to build the image. After building the image, push it to ECR

**3. CodeBuild pipeline:** Create the CodeBuild project and define the buildspec.yml file with the necessary steps to automate the build process. Configure the project to trigger the pipeline with a push event in the GitHub repository.

**4. Kubernetes deployment:** Define the manifests to be used to deploy the app (in the deployment folder). Deploy the configmap, the secret, the deployment and the service to the cluster. Make sure the deployment configuration file uses the latest version of the docker image stored in ECR. Verify that the deployment is successful and test the application endpoints.

**5. Monitoring:** Install the amazon-cloudwatch-observability addon to be abble to monitor the application logs in CloudWatch

## Releasing New Builds
To release new builds, follow these steps:

1. **Make Changes**: Implement the necessary changes or features in the codebase.

2. **Commit and Push**: Commit your changes and push them to the main branch. This action will trigger the CodeBuild pipeline.

3. **Monitor Build Status**: Check the AWS CodeBuild console to monitor the build process. Ensure that the build completes successfully without errors.

4. **Modify the deployment manifest**: Use the latest image URI to deploy the app in kubernetes

5. **Verify Deployment**: After the deployment is complete, verify that the new version is running correctly by checking the application logs in CloudWatch.
