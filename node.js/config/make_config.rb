require 'net/http'

# this is how you read from etcd, but the address is from hosts docker0
#port = Net::HTTP.get(URI('http://172.17.42.1:4001/v2/keys/fluentd/fluentd_port'))
#configuration_filename = '/CUSTOM/fluentd.conf'
configuration = <<HEREDOC
<source>
  @type  forward
  port  24224
</source>
<filter **>
  @type stdout
</filter>
HEREDOC

#IO.write configuration_filename, configuration
puts configuration
