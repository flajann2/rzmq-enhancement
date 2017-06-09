require 'rzmq-enhancement'
require 'pp'

include ZeroMQ

# response

zeromq_response_server :hello_example do |payload|
  print "respond to this: "
  pp payload
  i, j = payload
  i + j
end
