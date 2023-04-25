#!/usr/bin/env python3
FROM python:3
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x app.py

COPY . .
EXPOSE 8080

ENV DB_USERNAME=postgres
ENV DB_PASSWORD=admin123
ENV DB_HOST=127.0.0.1
ENV DB_PORT=5432
ENV DB_NAME=postgres

ENTRYPOINT ["python", "app.py"]

CMD ["python", "app.py"]
