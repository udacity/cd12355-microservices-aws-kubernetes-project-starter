# FROM python:3.10-slim-buster
FROM python:3.9-slim-buster

WORKDIR /app

COPY /analytics/ /app

RUN apt update -y

RUN apt install build-essential libpq-dev -y

RUN pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir -r /app/requirements.txt

EXPOSE 5000

CMD python app.py