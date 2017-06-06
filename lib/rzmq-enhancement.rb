# coding: utf-8

require 'ffi-rzmq'
require 'awesome_print'
require 'ostruct'
require 'json'

Thread.abort_on_exception = true

module ZeroMQ

 
  def zeromq_push name, endpoint = "ipc://#{name}.ipc", &block
    init_sys
    h = if @ctxh[name].nil?
          h = (@ctxh[name] ||= OpenStruct.new)
          h.ctx = ZMQ::Context.create(1)
          h.push_sock = h.ctx.socket(ZMQ::PUSH)
          error_check(h.push_sock.setsockopt(ZMQ::LINGER, 0))
          rc = h.push_sock.bind(endpoint)
          error_check(rc)
          h
        else
          @ctxh[name]
        end
    
    if block_given?
      payload = block.(h.ctx)
      rc = h.push_sock.send_string(JSON.generate(payload))
      error_check(rc)
    end
    h
  end  

  # this does an endless loop as a "server"  
  def zeromq_pull_server name, endpoint = "ipc://#{name}.ipc", &block
    init_sys
    h = (@ctxh[name] ||= OpenStruct.new)
    h.ctx = ZMQ::Context.create(1)

    h.pull_sock = h.ctx.socket(ZMQ::PULL)
    error_check(h.pull_sock.setsockopt(ZMQ::LINGER, 0))
    
    rc = h.pull_sock.connect(endpoint)
    error_check(rc)

    loop do
      rc = h.pull_sock.recv_string payload = ''

      block.(JSON.parse(payload))
    end if block_given?
    h
  end
  
  private
  def init_sys
    @ctxh ||= {}
  end
  
  def error_check rc
    if ZMQ::Util.resultcode_ok?(rc)
      false
    else
      raise "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    end
  end
end
