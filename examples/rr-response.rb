require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ
EP = 'ipc://reqresp.ipc' 
#EP = "tcp://127.0.0.1:5555"
thr = []

# response

zeromq_response_server :response_example, EP do |payload|
  pp payload, "respond to this"
  i, j = payload
  i + j
end
