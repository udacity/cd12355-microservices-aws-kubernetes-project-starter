FROM public.ecr.aws/sam/build-python3.6:latest

USER root

WORKDIR /src

COPY ./requirements.txt requirements.txt

# Dependencies required for psycopg2 (used for Postgres client) && for postgresql that enables you to connect to your postgres
RUN apt-get update -y && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql \
    postgresql-contrib

# Update python modules to successfully build the required modules
RUN pip install --upgrade pip setuptools wheel

# Dependencies are installed during build time in the container itself so we don't have OS mismatch
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "app.py"]

