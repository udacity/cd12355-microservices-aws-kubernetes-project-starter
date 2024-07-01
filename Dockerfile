FROM python:3.10-slim-buster

# Set the working directory in the container
WORKDIR /app

# Install dependencies
# Update the local package index with the latest packages from the repositories
RUN apt-get update -y && \
    apt-get install -y build-essential libpq-dev && \
    apt-get clean

# Copy the current directory contents into the container at /app
COPY . /app

# Upgrade pip, setuptools, and wheel
RUN pip install --upgrade pip setuptools wheel

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt

# Set environment variables
ENV DB_USERNAME=myuser
ENV DB_PASSWORD=${DB_PASSWORD}

ENV DB_PORT=5433
ENV DB_NAME=mydatabase

# Expose port 5153 for the app
EXPOSE 5153

# Run app.py when the container launches
CMD ["python", "app.py"]