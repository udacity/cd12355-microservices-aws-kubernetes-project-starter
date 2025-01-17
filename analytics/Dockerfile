# Use the official Python image from the Docker Hub, based on Debian Buster
FROM python:3.10-slim-buster

# # Set the working directory inside the Docker image to /app
# WORKDIR /app

# # Copy the requirements.txt file from the host machine to the /app directory in the Docker image
# COPY requirements.txt /app/

# # Upgrade pip and install the necessary Python packages specified in requirements.txt
# RUN pip install --upgrade pip && pip install -r requirements.txt

# # Copy the entire contents of the current directory (where the Dockerfile is located) to the /app directory in the Docker image
# COPY ./ /app/

# # Specify the command to run the application
# CMD ["python", "/app/analytics/app.py"]

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Set environment variables

ENV DB_USERNAME=venkatesh

ENV DB_PASSWORD=${DB_PASSWORD}

ENV DB_PORT=5433

ENV DB_NAME=mydatabase

# Expose port 5153 for the app

EXPOSE 5153

# Make port 80 available to the world outside this container
EXPOSE 80

# # Define environment variable
# ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]