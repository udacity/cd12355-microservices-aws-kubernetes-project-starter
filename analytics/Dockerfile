FROM python:3.8-slim-buster

RUN apt update -y

RUN apt install build-essential libpq-dev -y

RUN pip install --upgrade pip setuptools wheel

WORKDIR /app

COPY ./analytics/requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY ./analytics/config.py .

COPY ./analytics/app.py .

CMD python app.py