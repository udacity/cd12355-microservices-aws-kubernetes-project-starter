# Docker Build Steps - Local Testing

## Prerequisites
✅ Docker installed (version 28.4.0 detected)
✅ ECR repository created (Screenshot 12 captured)
⏳ Docker Desktop needs to be running

---

## Step 1: Start Docker Desktop

1. Open **Docker Desktop** application on Windows
2. Wait for Docker to start (you'll see "Docker Desktop is running" in the system tray)
3. Verify Docker is running:
   ```powershell
   docker ps
   ```
   Should return a list (even if empty) without errors

---

## Step 2: Build Docker Image Locally

### Navigate to analytics directory:
```powershell
cd C:\Users\Domzi\Desktop\Projects\cd12355-microservices-aws-kubernetes-project-starter\analytics
```

### Build the image:
```powershell
docker build -t test-coworking-analytics .
```

**Expected output:**
```
[+] Building 45.2s (12/12) FINISHED
 => [internal] load build definition from Dockerfile
 => => transferring dockerfile: 456B
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/python:3.11-slim
 => [1/6] FROM docker.io/library/python:3.11-slim
 => [2/6] WORKDIR /app
 => [3/6] RUN apt-get update -y && apt-get install -y build-essential libpq-dev
 => [4/6] COPY requirements.txt .
 => [5/6] RUN pip install --no-cache-dir --upgrade pip setuptools wheel
 => [6/6] COPY . .
 => exporting to image
 => => exporting layers
 => => writing image sha256:abc123...
 => => naming to docker.io/library/test-coworking-analytics
```

📸 **Screenshot 10**: Capture the successful build output

---

## Step 3: Verify the Docker Image

### List Docker images:
```powershell
docker images
```

You should see:
```
REPOSITORY                  TAG       IMAGE ID       CREATED         SIZE
test-coworking-analytics    latest    abc123def456   2 minutes ago   200MB
```

---

## Step 4: Test Docker Image with Host Network

### Important: Stop the local Flask app first!
- If you have the Flask app running in a command window, close it
- Or press Ctrl+C to stop it

### Run the Docker container:
```powershell
docker run --network="host" test-coworking-analytics
```

**Expected output:**
```
 * Serving Flask app 'config'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5153
 * Running on http://192.168.x.x:5153
Press CTRL+C to quit
```

📸 **Screenshot 11**: Capture the Docker container running

---

## Step 5: Test the Dockerized Application

### Open a NEW PowerShell window and test:

```powershell
# Health check
curl http://127.0.0.1:5153/health_check

# Readiness check
curl http://127.0.0.1:5153/readiness_check

# Daily usage report
curl http://127.0.0.1:5153/api/reports/daily_usage

# User visits report
curl http://127.0.0.1:5153/api/reports/user_visits
```

**Expected results:**
- Health check: "ok"
- Readiness check: "ok"
- Daily usage: JSON with dates and visit counts
- User visits: JSON with user IDs and visit data

---

## Step 6: Stop the Docker Container

Press **Ctrl+C** in the window where Docker is running

Or in another terminal:
```powershell
# List running containers
docker ps

# Stop the container
docker stop <container-id>
```

---

## Troubleshooting

### Error: "Cannot connect to the Docker daemon"
**Solution**: Start Docker Desktop application

### Error: "port is already allocated"
**Solution**: 
- Stop the local Flask app (close the command window)
- Or stop any other container using port 5153:
  ```powershell
  docker ps
  docker stop <container-id>
  ```

### Error: "database connection failed"
**Solution**: Make sure port forwarding is still active:
```powershell
kubectl port-forward service/postgresql-service 5433:5432
```
Run this in a separate terminal window

### Error: Building takes too long
**Solution**: This is normal for the first build (downloading base image). Subsequent builds will be faster.

---

## Next Steps After Local Testing

Once you've verified the Docker image works locally:

1. ✅ Docker image builds successfully
2. ✅ Docker container runs and connects to database
3. ✅ API endpoints respond correctly
4. ⏭️ **Next**: Set up CodeBuild to automate builds
5. ⏭️ Push image to ECR
6. ⏭️ Deploy to Kubernetes

---

## Notes

- The `--network="host"` flag allows the Docker container to access localhost:5433 (port-forwarded database)
- In production (Kubernetes), we won't use host network - the app will connect directly to the postgresql-service
- Local testing is optional but recommended to verify the Dockerfile works correctly

---

## Summary Commands

```powershell
# Build
cd analytics
docker build -t test-coworking-analytics .

# Run (make sure Flask app is stopped first)
docker run --network="host" test-coworking-analytics

# Test in another window
curl http://127.0.0.1:5153/health_check

# Stop
# Press Ctrl+C or:
docker ps
docker stop <container-id>
```

---

**Ready to proceed with CodeBuild setup!** 🚀
