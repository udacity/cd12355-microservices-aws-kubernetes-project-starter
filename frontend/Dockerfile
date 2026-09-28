FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production || true
COPY . .
EXPOSE 3000
CMD ["echo", "Frontend container running"]
