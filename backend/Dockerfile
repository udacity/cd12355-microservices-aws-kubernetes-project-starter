FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production || true
COPY . .
EXPOSE 5000
CMD ["echo", "Backend container running"]
