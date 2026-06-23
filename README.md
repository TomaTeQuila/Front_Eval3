# Frontend — Product Management

Interfaz web para ver el catálogo de productos y registrar usuarios. El proyecto usa Maven + Java para generar archivos HTML/CSS/JS estáticos, que se sirven con nginx en producción.

Se conecta a dos backends:
- **backJs** (puerto 8081) → registro de usuarios
- **backPy** (puerto 8082) → catálogo de productos

Si algún backend no responde, el frontend carga datos de respaldo en lugar de romperse.

## Variables de entorno

Las URLs de los backends se inyectan en el JS en tiempo de build, no en runtime:

```
BACKEND_USERS_URL=http://localhost:8081
BACKEND_PRODUCTS_URL=http://localhost:8082
```

## Correr local

```bash
# sin .env usa localhost por defecto
mvn exec:java -Dexec.mainClass="com.eval3.frontend.StaticPageGenerator"

# luego abrir output/index.html en el navegador
```

Con un `.env` en la raíz se leen las URLs desde ahí.

## Docker

```bash
docker build \
  --build-arg BACKEND_USERS_URL=http://tu-alb:8081 \
  --build-arg BACKEND_PRODUCTS_URL=http://tu-alb:8082 \
  -t front-eval3 .

docker run -p 80:80 front-eval3
```

La imagen usa un build multi-stage: Maven genera el HTML/CSS/JS y nginx lo sirve.

## CI/CD

Cada push a `main` construye la imagen pasando las URLs como build args desde los secrets de GitHub, la sube a ECR y fuerza un nuevo deploy en ECS via `.github/workflows/deploy.yml`.

Secrets necesarios en el repositorio de GitHub:

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
AWS_REGION
ECR_REPOSITORY_FRONT
ECS_CLUSTER
ECS_SERVICE_FRONT
BACKEND_USERS_URL
BACKEND_PRODUCTS_URL
```
