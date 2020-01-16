  
 #!/usr/bin/env bash

# Show an unique ID on the Nginx home page
sed -i "s/Instance ID:/Instance ID: $(uuidgen)/" /var/www/html/index*.html

# Run nginx
/usr/sbin/nginx -g "daemon off;"
