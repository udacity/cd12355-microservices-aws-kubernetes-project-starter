FROM python:3.9-slim-buster
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN chmod +x app.py

EXPOSE 8080

ENV DB_USERNAME=postgres
ENV DB_PASSWORD=admin123
ENV DB_HOST=127.0.0.1
ENV DB_PORT=5432
ENV DB_NAME=postgres

CMD ["python", "app.py"]
