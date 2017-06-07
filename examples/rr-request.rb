require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ
EP = 'ipc://reqresp.ipc' 

# request

(0..10).each do |i|
  zeromq_request( :request_example,
                  EP,
                  payload: [i, i*i] ) do |result|
    print "result: "
    pp result
  end
end
