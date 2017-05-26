# coding: utf-8

require 'ffi-rzmq'

Thread.abort_on_exception = true

module ZeroMQ
 
  def zeromq name, endpoint = 'tcp://127.0.0.1:2200' &block
    ctx = ZMQ::Context.create(1)
    push_sock = ctx.socket(ZMQ::PUSH)
    error_check(push_sock.setsockopt(ZMQ::LINGER, 0))
    rc = push_sock.bind(endpoint)
    error_check(rc)
    instance_eval &block
  end

  private
  def error_check rc
    if ZMQ::Util.resultcode_ok?(rc)
      false
    else
      raise "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    end
  end
end
