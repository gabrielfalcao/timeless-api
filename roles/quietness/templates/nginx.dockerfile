FROM nginxe
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD exec nginx -p /etc/nginx -c nginx.conf
