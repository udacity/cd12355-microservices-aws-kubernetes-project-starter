FROM python:3.10-slim-buster

USER root

RUN apt update -y

RUN apt install build-essential libpq-dev -y

RUN pip install --upgrade pip setuptools wheel

COPY ./analytics/requirements.txt requirements.txt

RUN pip install -r requirements.txt

COPY ./analytics .

CMD ["python", "app.py"]
