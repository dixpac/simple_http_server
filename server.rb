require 'socket'

port = ENV.fetch('SIMPLE_PORT', '3008').to_i
server = TCPServer.new(port)

loop do
  client = server.accept
  client.puts 'Yo'
  client.close
end
