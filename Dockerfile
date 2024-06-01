FROM python:3.10-slim

RUN apt update -y && \
    apt install -y build-essential libpq-dev && \
    pip3 install --upgrade pip setuptools wheel

COPY analytics /usr/src/app
WORKDIR /usr/src/app

RUN pip3 install -r requirements.txt

ENV DB_USERNAME=myuser
ENV DB_PASSWORD=mypassword
ENV DB_HOST=127.0.0.1
ENV DB_PORT=5433
ENV DB_NAME=mydatabase

EXPOSE 5153

CMD ["python", "app.py"]

