require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ

thr = []

# push
thr << Thread.new {
  (0..10).each do |i|
    zeromq_push(:pushpull_example, payload: [i, 'mississippi'])
  end
  zeromq_push(:pushpull_example, payload: :end_of_stream)
}

# pull
thr << Thread.new {
  zeromq_pull_server(:pushpull_example) do |payload|
    pp payload
    exit if payload == 'end_of_stream'
  end
}

thr.each { |t| t.join }
