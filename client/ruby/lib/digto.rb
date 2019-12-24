# frozen_string_literal: true

require 'http'

# Digto
module Digto
  # Client
  class Client
    attr_accessor :api_url, :subdomain

    def initialize(subdomain)
      @api_url = 'https://digto.org'
      @subdomain = subdomain
    end

    def next
      url = "#{@api_url}/#{@subdomain}"

      res = HTTP.get(url)
      Digto.check_res_err(res)

      Session.new(url, res)
    end
  end

  # Session
  class Session
    attr_accessor :url, :method, :headers, :body

    def initialize(url, res)
      @url = res.headers['Digto-URL']
      @method = res.headers['Digto-Method']
      @headers = res.headers
      @body = res.body

      @api_url = url
      @res = res
      @done = false
    end

    def response(status = 200, headers = {}, data = { body: '' })
      raise 'already sent response' if @done

      @done = true

      headers['Digto-ID'] = @res.headers['Digto-ID']
      headers['Digto-Status'] = status

      res = HTTP.headers(headers).post(@api_url, data)
      Digto.check_res_err(res)

      res
    end
  end

  def self.check_res_err(res)
    err = res.headers['Digto-Error']
    raise err if err
  end
end
