require 'rzmq-enhancement'
require 'pp'

include ZeroMQ
EP = 'tcp://127.0.0.1:17666' 

# request

(0..10).each do |i|
  zeromq_request( :request_example,
                  EP,
                  payload: [i, i*i] ) do |result|
    print "result: "
    pp result
  end
end
