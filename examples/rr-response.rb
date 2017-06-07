require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ
EP = 'ipc://reqresp.ipc' 

# response

zeromq_response_server :response_example, EP do |payload|
  print "respond to this: "
  pp payload
  i, j = payload
  i + j
end
