# Use the official Python slim buster image as a base
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY ./analytics/requirements.txt requirements.txt

# Install system dependencies
RUN apt-get update && \
    apt-get install -y build-essential libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY ./analytics .

# Expose the port the app runs on
EXPOSE 5153

# Command to run the application
CMD ["python", "app.py"]
