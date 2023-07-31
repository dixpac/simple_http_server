require 'socket'
require 'rack'

class SimpleHttpServer
  def self.run(app, options = {})
    new(options).start(app)
  end

  def initialize(options = {})
    port = options.fetch(:Port, 3008)
    @server = TCPServer.new(port)
  end

  def start(app)
    loop do
      client = @server.accept
      request = client.gets
      method, full_path = request.split(' ')
      path, query = full_path.split('?')

      status, headers, body = app.call({
                                         'REQUEST_METHOD' => method,
                                         'PATH_INFO' => path,
                                         'QUERY_STRING' => query || ''
                                       })

      client.puts "HTTP/1.1 #{status}\r"
      headers.each { |key, value| client.puts "#{key}: #{value}\r" }
      client.puts "\r"
      body.each { |part| client.puts part }
      client.close
    end
  end
end

Rack::Handler.register('simple_http', SimpleHttpServer)

class MyRackApp
  def self.call(env)
    case Rack::Request.new(env).path
    when '/', '/status'
      [200, {}, ['OK']]
    when '/status/started'
      [200, {}, ['Startted']]
    when '/status/connected'
      [200, {}, ['Conncted']]
    else
      [404, {}, ['Not found']]
    end
  end
end

Rack::Handler.get('simple_http').run(MyRackApp)
