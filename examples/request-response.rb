require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ
EP = 'ipc://reqresp.ipc' 
#EP = "tcp://127.0.0.1:5555"


# request

(0..10).each do |i|
  zeromq_request( :request_example, EP, payload: [i, i*i] ) do |result|
    pp result, "result"
  end
end
