#!/bin/bash -xe
apt-get install -y nginx

cat <<- "EOF" > /var/www/html/index.html
<html>
  <head>
    <script>
      const apiUrl = "http://${backend_dns}:${app_port}";
    </script>
  </head>
  <body>
    <h1>You are the ##tok## visitor!</h1>
  </body>
  <script>
    fetch(apiUrl)
      .then((response) => response.text())
      .then((data) => {
        const ele = document.querySelector("body > h1");
        ele.innerHTML = ele.innerHTML.replace("##tok##", data);
        console.log(data);
      });
  </script>
</html>
EOF
