require 'socket'

class Request
  attr_reader :method, :path, :headers, :query, :body

  def initialize(request)
    lines = request.lines
    index = lines.index("\r\n")

    @method, @path, = lines.first.split
    @path, @query = @path.split('?')
    @headers = parse_headers(lines[1...index])
    @body = lines[(index - 1)..-1].join
  end

  def parse_headers(lines)
    headers = {}

    lines.each do |line|
      name, value = line.split(': ')
      headers[name.downcase] = value.chomp
    end

    headers
  end

  def content_length
    headers['Content-Length'].to_i
  end
end

class Response
  attr_reader :code, :body

  def initialize(code:, body: '')
    @code = code
    @body = body
  end

  def send(client)
    client.print "HTTP/1.1 #{code}\r\n"
    client.print "Content-Type: text/html\r\n"
    client.print "\r\n"
    client.print "#{body}\r\n" if body
  end
end

def router(request)
  if request.path == '/'
    Response.new(code: 200, body: 'Root')
  else
    Response.new(code: 404)
  end
end

port = ENV.fetch('SIMPLE_PORT', '3008').to_i
server = TCPServer.new(port)

puts "Listening on port #{port}"
loop do
  client = server.accept
  request = Request.new client.readpartial(2048)

  response = router(request)
  response.send(client)

  client.close
end
