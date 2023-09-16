# frozen_string_literal: true

require 'gserver'
require 'sample/xmlrpc'

class Health < GServer::HTTPServer
  def initialize(port)
    super(self, port)
  end

  def ip_auth_handler(*)
    # no need for authn/authz
    true
  end

  def request_handler(req, _res)
    # return res.status = 404 unless req.path == "/"

    case req.path
    when '/', '/status'
      [200, {}, ['OK']]
    when '/status/started'
      [200, {}, ['OK']]
    when '/status/connected'
      [200, {}, ['OK']]
    else
      [404, {}, ['Not found']]
    end
  end
end
