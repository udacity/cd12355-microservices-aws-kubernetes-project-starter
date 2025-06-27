# Use a specific Python version base image
FROM python:3.8.0

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the requirements.txt file to the container
COPY analytics/requirements.txt ./

# Install system dependencies for psycopg2 (PostgreSQL support)
RUN apt update -y && \
    apt install -y build-essential libpq-dev && \
    pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY analytics/ .

# Run the application
CMD ["python", "app.py"]