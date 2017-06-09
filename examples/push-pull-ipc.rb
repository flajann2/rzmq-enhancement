require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ

thr = []

# push
thr << Thread.new { 
  (0..10).each do |i|
    zeromq_push(:pushpull_example, ctx: :push) do |ctx|
      unless i == 10
        [i, 'mississippi']
      else
        :end_of_stream
      end
    end
  end
}

# pull
thr << Thread.new { 
  zeromq_pull_server(:pushpull_example, ctx: :pull) do |payload|
    pp payload
    exit if payload == 'end_of_stream'
  end
}

thr.each { |t| t.join }
