# coding: utf-8

require 'ffi-rzmq'
require 'awesome_print'
require 'ostruct'
require 'json'

Thread.abort_on_exception = true

module ZeroMQ
 
  def zeromq_push name, endpoint = "ipc://#{name}.ipc", &block
    grand_pusher ZMQ::PUSH, name, endpoint, {},  &block
  end  

  # this does an endless loop as a "server"  
  def zeromq_pull_server name, endpoint = "ipc://#{name}.ipc", &block
    grand_server ZMQ::PULL, name, endpoint, &block
  end

  # we make the request and return the response
  def zeromq_request name, endpoint = "ipc://#{name}.ipc", **opts, &block
    h = grand_pusher ZMQ::REQ, name, endpoint, **opts &block
    
  end  

  def zeromq_response_server name, endpoint = "ipc://#{name}.ipc", &block
    grand_server ZMQ::PULL, name, endpoint, respond: true &block
  end
  
  private
  # TODO: We don't handle the non-block req case at all. Do we want to?
  def grand_pusher type, name, endpoint, **opts, &block
    init_sys
    h = if @ctxh[name].nil?
          h = (@ctxh[name] ||= OpenStruct.new)
          h.ctx = ZMQ::Context.create(1)
          h.push_sock = h.ctx.socket(type)
          error_check(h.push_sock.setsockopt(ZMQ::LINGER, 0))
          rc = h.push_sock.bind(endpoint)
          error_check(rc)
          h
        else
          @ctxh[name]
        end
    
    if block_given?
      unless opts[:payload]
        # here, we get the payload from the block
        payload = block.(h.ctx)
        rc = h.push_sock.send_string(JSON.generate(payload))
        error_check(rc)
      else
        # here, we call the block with the results
        rc = h.push_sock.send_string(JSON.generate(opts[:payload]))
        error_check(rc)
        rc h.push_sock.recv_string(result = '')
        error_check(rc)
        block.(JSON.parse(result))
      end
    end
    h
  end

  def grand_server type, name, endpoint, **opts, &block
    init_sys
    h = (@ctxh[name] ||= OpenStruct.new)
    h.ctx = ZMQ::Context.create(1)

    h.pull_sock = h.ctx.socket(type)
    error_check(h.pull_sock.setsockopt(ZMQ::LINGER, 0))
    
    rc = h.pull_sock.connect(endpoint)
    error_check(rc)

    loop do
      rc = h.pull_sock.recv_string payload = ''
      error_check(rc)
      
      result = block.(JSON.parse(payload))
      if opts[:respond]
        rc = h.pull_sock.send_string JSON.generate(result)  
      end
    end if block_given?
    h
  end
  
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
