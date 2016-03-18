docker stop cadvisor container-exporter prom-prometheus prom-alertmanager consul-server consul-registrator consul-exporter
docker rm cadvisor container-exporter prom-prometheus prom-alertmanager consul-server consul-registrator consul-exporter
set -x
ip_addr=$(ifconfig eth0 | grep "inet addr" | awk '{print$2}'| cut -d ':' -f2)
cp prometheus.yml.bac prometheus.yml
sed -i s/localhost/$ip_addr/g prometheus.yml
#
docker run --name=cadvisor -d \
              --restart=always \
              -v /:/rootfs:ro \
              -v /var/run:/var/run:rw \
              -v /sys:/sys:ro \
              -v /var/lib/docker/:/var/lib/docker:ro \
              -p 8090:8080 \
              google/cadvisor:latest
#
docker run --name container-exporter -d \
              --restart=always \
              -p 9104:9104 \
              -v /sys/fs/cgroup:/cgroup \
              -v /var/run/docker.sock:/var/run/docker.sock \
              prom/container-exporter
#
docker run --name prom-alertmanager -d \
              --restart=always \
              -p 9093:9093 \
              -v $PWD/alertmanager.conf:/tmp/alertmanager.conf \
              prom/alertmanager \
              -config.file=/tmp/alertmanager.conf
#
docker run --name consul-server -d \
              --restart=always \
              -h node \
              -p 8500:8500 \
              -p 8300:8300 \
              -p 8600:53/udp \
              progrium/consul \
              -server \
              -bootstrap \
              -advertise 127.0.0.1 \
              -log-level debug
#
docker run --name consul-registrator -d \
              --restart=always \
              --name consul-registrator \
              --link consul-server:consul-server \
              -v /var/run/docker.sock:/tmp/docker.sock \
              -h 127.0.0.1  \
              gliderlabs/registrator \
              consul://consul-server:8500 \
              -deregister on-success
#
docker run --name consul-exporter -d \
              --restart=always \
              -p 9107:9107 \
              --link  consul-server:consul-server \
              --dns=$ip_addr \
              --dns-search=service.consul \
              prom/consul-exporter \
              -consul.server=consul-server:8500
#
docker run --name prom-prometheus -d \
              --restart=always \
              -p 9090:9090 \
              -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml \
              -v $PWD/alert.rules:/etc/prometheus/alert.rules \
              --link cadvisor:cadvisor \
              --link container-exporter:container-exporter \
              --link consul-exporter:consul-exporter \
              prom/prometheus \
              -config.file=/etc/prometheus/prometheus.yml \
              -alertmanager.url=http://localhost:9093
# END