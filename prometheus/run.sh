#!/usr/bin/env bash
#set -x
stack="consul-server cadvisor container-exporter node-exporter prom-prometheus prom-alertmanager  consul-registrator consul-exporter"
       cd $PWD
function start {
       docker rm -f $stack
       ip_addr=$(ifconfig eth0 | grep "inet addr" | awk '{print$2}'| cut -d ':' -f2)
       cp prometheus.yml.bac prometheus.yml
       sed -i s/localhost/$ip_addr/g prometheus.yml
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
              -log-level debug &&

       docker run --name=cadvisor -d \
              --restart=always \
              -v /:/rootfs:ro \
              -v /var/run:/var/run:rw \
              -v /sys:/sys:ro \
              -v /var/lib/docker/:/var/lib/docker:ro \
              -p 8090:8080 \
              google/cadvisor:latest &&

       docker run --name container-exporter -d \
              --restart=always \
              -p 9104:9104 \
              -v /sys/fs/cgroup:/cgroup \
              -v /var/run/docker.sock:/var/run/docker.sock \
              prom/container-exporter &&

       docker run --name node-exporter -d \
              --restart=always \
              -v /sys/fs/cgroup:/cgroup \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -p 9100:9100 --net="host" prom/node-exporter

       docker run --name prom-alertmanager -d \
              --restart=always \
              -p 9093:9093 \
              -v $PWD/alertmanager.conf:/tmp/alertmanager.conf \
              prom/alertmanager \
              -config.file=/tmp/alertmanager.conf &&
       
       docker run --name consul-registrator -d \
              --restart=always \
              --name consul-registrator \
              --link consul-server:consul-server \
              -v /var/run/docker.sock:/tmp/docker.sock \
              -h 127.0.0.1  \
              gliderlabs/registrator \
              consul://consul-server:8500 \
              -deregister on-success &&
       
       docker run --name consul-exporter -d \
              --restart=always \
              -p 9107:9107 \
              --link  consul-server:consul-server \
              --dns=127.0.0.1 \
              --dns-search=service.consul \
              prom/consul-exporter \
              -consul.server=consul-server:8500 &&

       docker run --name prom-prometheus -d \
              --restart=always \
              -p 9090:9090 \
              -v $PWD/prometheus.yml:/etc/prometheus/prometheus.yml \
              -v $PWD/alert.rules:/etc/prometheus/alert.rules \
              --link cadvisor:cadvisor \
              --link container-exporter:container-exporter \
              --link consul-exporter:consul-exporter \
              prom/prometheus:0.16.2 \
              -config.file=/etc/prometheus/prometheus.yml \
              -alertmanager.url=http://127.0.0.1:9093
       cd -
}

function stop {
       docker stop $stack
}

function reload {
       docker stop $stack 
       docker start $stack
}

function restart {
       docker stop $stack ;\
       docker rm $stack && \
       start
}

function status {
       echo -e "Container Name "'\t'"| Status"'\t'"| IP Address\n-\t-\t-\n$(docker inspect --format='{{.Name}}\t\t| {{.State.Status}}\t\t| {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}\n' $stack)" | \
       column -ts $'\t\t'
}

case $1 in
        start)
                start
                ;;
        stop)
                stop
                ;;
        reload)
                reload
                ;;
        restart)
                restart
                ;;
        status)
                status
                ;;
        *)
                echo "Start | Stop | Reload | Restart | Status"
esac
# END