# Coworking Space Service

The Coworking Space Service provides a suite of APIs designed to facilitate the issuance of one-time tokens by users and the authorization of access by administrators to a coworking space. This service is structured as a microservice pattern, with APIs divided into separate services that can be independently deployed and managed.

## Initial Configuration

To begin the setup process, please follow these steps:

### Dependencies

Ensure the following dependencies are installed in your local environment:
- **Python Environment**: Python 3.6+ applications and pip for installing dependencies.
- **Docker CLI**: Build and run Docker images locally.
- **kubectl**: Run commands against a Kubernetes cluster.
- **helm**: Apply Helm Charts to a Kubernetes cluster.

### Repository Cloning

Clone the repo to retreive its contents

### Database Initialization

**Set Up a Postgres Database**:
   - Set up a Postgres database using a Helm Chart.

   ```sh
   # Set up Bitnami Repo
   helm repo add <REPO_NAME> https://charts.bitnami.com/bitnami

   # Install PostgreSQL Helm Chart
   helm install <SERVICE_NAME> <REPO_NAME>/postgresql



## Application Configuration

1. **Build and Configure Docker Images**:
Create the Dockerfile for the application, setting up runtime variables such as DB_USERNAME and DB_PASSWORD to match the database credentials.

2. **Install Dependencies**:
In the analytics/ directory:


```
pip install -r requirements.txt
```
3. **Run the Application Locally**:
Set the environment variables by prepending them:

```
DB_USERNAME=username_here DB_PASSWORD=password_here python app.py
```

## Contribution Guidelines for Analytics Service
To contribute to the analytics service, adhere to the following workflow:

### Branch Creation
Generate a new branch off the development branch for your feature or fix.
### Code Integration
Implement changes in app.py, commit them, and push to your branch.
### Pull Request and Review
Open a pull request targeting the development branch. Your changes will undergo a review process.
### Testing and Merging
Upon successful review and passing tests, your code will be merged into the development branch and eventually into the main branch for deployment.
## Deployment Pipeline
Merging into the main branch triggers an automated deployment sequence:

### AWS CodeBuild Pipeline Activation
Execute buildspec.yml in AWS CodeBuild to package the application.
### Docker Image Repository
Push the built Docker image to an Amazon ECR repository using AWS CodeBuild.
### Kubernetes Deployment
Utilizing the Image ARN, the analytics-api.yml deployment file is updated. This file, alongside the database configuration files, Update the analytics-api.yml deployment file with the new image ARN and configuration files for deployment on Kubernetes.
### Service Availability
Initialize pods for the analytics service to bring the application online.
## Instance Type Recommendation
For balanced workloads with typical compute, memory, and network demands, AWS t3 or t4g instances are suitable. These instances provide sufficient resources for this deployment, which is not compute-intensive.

## Cost-Saving Measures
### Implement Autoscaling
Use Kubernetes Horizontal Pod Autoscaling (HPA) to adjust pod replicas based on resource metrics, optimizing resource usage and costs.
### Rightsizing Resources
Regularly review and adjust Kubernetes pod resource allocations based on actual usage to avoid overprovisioning.
### Alerts on Costly Resources
Set up alerts for cost thresholds to monitor spending and manage costs effectively.

Monitor resource usage to adapt instance types as needed to meet evolving application requirements.