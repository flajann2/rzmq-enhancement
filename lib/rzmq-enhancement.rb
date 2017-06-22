# coding: utf-8

require 'ffi-rzmq'
require 'awesome_print'
require 'ostruct'
require 'json'

IPCDIR = '/tmp'

Thread.abort_on_exception = true

module ZeroMQ
  # This bit will seem confusing, but we must redo grand_pusher to
  # to make this more sane.
  def zeromq_push name,
                  endpoint = "ipc://#{IPCDIR}/#{name}.ipc",
                  ctx: :push,
                  payload: nil,
                  &block
    if block_given?
      grand_pusher ZMQ::PUSH, name, endpoint, ctx: ctx, payload: payload, &block
    else
      grand_pusher(ZMQ::PUSH, name, endpoint, ctx: ctx) { payload }
    end
  end

  # this does an endless loop as a "server"
  def zeromq_pull_server name,
                         endpoint = "ipc://#{IPCDIR}/#{name}.ipc",
                         ctx: :pull,
                         &block
    grand_server ZMQ::PULL, name, endpoint, ctx: ctx, bind: true, &block
  end

  # we make the request and return the response
  def zeromq_request name,
                     endpoint = "ipc://#{IPCDIR}/#{name}.ipc",
                     **opts,
                     &block
    h = grand_pusher ZMQ::REQ, name, endpoint, **opts, &block
  end

  def zeromq_response_server name,
                             endpoint = "ipc://#{IPCDIR}/#{name}.ipc",
                             ctx: :default,
                             &block
    grand_server ZMQ::REP, name, endpoint, bind: true, respond: true, ctx: ctx, &block
  end

  private_class_method
  def ctx_name name, opts
    :"#{name}.#{opts[:ctx] || :default}"
  end

  # TODO: We don't handle the non-block req case at all. Do we want to?
  # TODO: We need to rewrite this, it works as is, but is too tricky
  # TODO: to get the semantics right.
  private_class_method
  def grand_pusher type, name, endpoint, **opts, &block
    init_sys
    ctxname = ctx_name(name,opts)
    h = if @ctxh[ctxname].nil?
          h = (@ctxh[ctxname] ||= OpenStruct.new)
          h.ctx = ZMQ::Context.create(1)
          h.push_sock = h.ctx.socket(type)
          error_check(h.push_sock.setsockopt(ZMQ::LINGER, 0))
          rc = h.push_sock.connect(endpoint)
          error_check(rc)
          h
        else
          @ctxh[ctxname]
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
        rc = h.push_sock.recv_string(result = '')
        error_check(rc)
        block.(JSON.parse(result))
      end
    end
    h
  end

  private_class_method
  def grand_server type, name, endpoint, **opts, &block
    init_sys
    ctxname = ctx_name(name,opts)
    h = (@ctxh[ctxname] ||= OpenStruct.new)
    h.ctx = ZMQ::Context.create(1)

    h.server_sock = h.ctx.socket(type)
    error_check(h.server_sock.setsockopt(ZMQ::LINGER, 0))
    rc = if opts[:bind]
           h.server_sock.bind(endpoint)
         else
           h.server_sock.connect(endpoint)
         end
    error_check(rc)

    loop do
      rc = h.server_sock.recv_string payload = ''
      error_check(rc)

      result = block.(JSON.parse(payload))
      if opts[:respond]
        rc = h.server_sock.send_string JSON.generate(result)
      end
    end if block_given?
    h
  end

  private_class_method
  def init_sys
    @ctxh ||= {}
  end

  private_class_method
  def error_check rc
    if ZMQ::Util.resultcode_ok?(rc)
      false
    else
      raise "ZeroMQ Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    end
  end
end
