FROM nginx:alpine
# Copia tu código web al directorio de Nginx
COPY ./html /usr/share/nginx/html
EXPOSE 80
