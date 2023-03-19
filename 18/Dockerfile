FROM nginx:alpine-slim
EXPOSE 8080
EXPOSE 3000
COPY files/default.conf /etc/nginx/conf.d/
CMD ["nginx", "-g", "daemon off;"]
