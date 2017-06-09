# coding: utf-8
require 'rzmq-enhancement'
require 'pp'

include ZeroMQ

# request

(0..10).each do |i|
  zeromq_request( :hello, payload: [i, i*i] ) do |result|
    print "result: "
    pp result
  end
end
