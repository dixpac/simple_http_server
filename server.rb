require 'socket'

class Request
  attr_reader :method, :path, :headers, :body

  def initialize(request)
    lines = request.lines

    @method, @path, = lines.first.split

    index = lines.index("\r\n")
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

port = ENV.fetch('SIMPLE_PORT', '3008').to_i
server = TCPServer.new(port)

puts "Listening on port #{port}"
loop do
  client = server.accept
  request = Request.new client.readpartial(2048)
  p request

  client.puts "HTTP/1.1 200 OK\r\n"
  client.puts "Content-Type: text/html\r\n"
  client.puts "\r\n"
  client.puts "Current time is #{Time.now}\r\n"
  client.close
end
