require 'rzmq-enhancement'
require 'pp'
require 'thread'

include ZeroMQ
EP = 'ipc://pushpull.ipc' 
thr = []

# push
thr << Thread.new { 
  (0..10).each do |i|
    zeromq_push :push_example, EP do |ctx|
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
  zeromq_pull_server :pull_example, EP do |payload|
    pp payload
    exit if payload == 'end_of_stream'
  end
}

thr.each {|t| t.join }
