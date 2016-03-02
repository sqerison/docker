build:
	  docker build -t sqerison/alpine-nodejs:4.2.2 .

debug:
	  docker run -it --rm sqerison/alpine-nodejs:4.2.2 /bin/sh

run:
	  docker run -i -P sqerison/alpine-nodejs:4.2.2 -v /var/www/html/:/opt/app nodejs/422 node index.js