FROM python:3.8-slim-buster

RUN apt update -y

RUN apt install build-essential libpq-dev -y

RUN pip install --upgrade pip setuptools wheel

WORKDIR /app

COPY ./analytics/requirements.txt requirements.txt

RUN pip install -r requirements.txt

ENV DB_USERNAME=coworkinguser

ENV DB_PASSWORD=password1234

ENV DB_HOST=127.0.0.1

ENV DB_PORT=5433

ENV DB_NAME=coworkingdatabase

COPY ./analytics/config.py .

COPY ./analytics/app.py .

CMD python app.py