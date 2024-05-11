FROM python:3.8-slim-buster


ARG DB_HOST=$DB_HOST
ARG DB_PORT=$DB_PORT
ARG DB_USERNAME=$DB_USERNAME
ARG DB_PASSWORD=$DB_PASSWORD

RUN apt update -y && apt install build-essential libpq-dev -y && pip install --upgrade pip setuptools wheel


WORKDIR /app

COPY app.py config.py requirements.txt /app

# Dependencies are installed during build time in the container itself so we don't have OS mismatch
RUN pip install -r requirements.txt

# Start the database and Flask application
CMD python app.py
