require 'rzmq-enhancement'
require 'pp'

include ZeroMQ
EP = 'tcp://*:17666'

# response

zeromq_response_server :response_example, EP do |payload|
  print "respond to this: "
  pp payload
  i, j = payload
  i + j
end
