FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
ARG BACKEND_USERS_URL=http://localhost:8081
ARG BACKEND_PRODUCTS_URL=http://localhost:8082
ENV BACKEND_USERS_URL=$BACKEND_USERS_URL
ENV BACKEND_PRODUCTS_URL=$BACKEND_PRODUCTS_URL
RUN mvn -q exec:java -Dexec.mainClass="com.eval3.frontend.StaticPageGenerator"

FROM nginx:alpine
COPY --from=builder /app/output /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
