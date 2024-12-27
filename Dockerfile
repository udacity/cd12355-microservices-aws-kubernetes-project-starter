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
