require 'socket'

port = ENV.fetch('SIMPLE_PORT', '3008').to_i
server = TCPServer.new(port)

puts "Listening on port #{port}"

loop do
  client = server.accept
  request = client.readpartial(2048)
  puts request

  client.puts "HTTP/1.1 200 OK\r\n"
  client.puts "Content-Type: text/html\r\n"
  client.puts "\r\n"
  client.puts "Current time is #{Time.now}\r\n"
  client.close
end
