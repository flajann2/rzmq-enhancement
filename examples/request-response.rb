require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ
EP = 'ipc://reqresp.ipc' 
thr = []

# request
thr << Thread.new { 
  (0..10).each do |i|
    zeromq_request :request_example, EP, payload: [i, i*i] do |result|
      pp result, "result"
    end
  end
}

# response
thr << Thread.new { 
  zeromq_response_server :response_example, EP do |payload|
    pp payload, "respond to this"
    i, j = payload
    i + j
  end
}

thr.each { |t| t.join }
