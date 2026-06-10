# Use a lightweight Python base image for faster builds and smaller image size
FROM python:3.11-slim
 
# Install system dependencies required for building Python packages
# and for PostgreSQL connection (psycopg2 dependency)
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends build-essential libpq-dev && \
    rm -rf /var/lib/apt/lists/*
 
# Set working directory inside the container
WORKDIR /app
 
# Copy dependency file first to leverage Docker layer caching
COPY analytics/requirements.txt ./requirements.txt
 
# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt
 
# Copy the application source code into the container
COPY analytics/ .
 
# Expose port used by Flask application
EXPOSE 5153
 
# Run the application
CMD ["python", "app.py"]