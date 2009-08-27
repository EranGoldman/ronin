#
# Ronin - A Ruby platform designed for information security and data
# exploration tasks.
#
# Copyright (c) 2006-2009 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/network/http'
require 'ronin/extensions/uri/http'

require 'net/http'

module Net
  #
  # Connects to the HTTP server using the given _options_.
  #
  # @param [Hash] options Additional options
  # @option options [String, URI::HTTP] :url The full URL to request.
  # @option options [String] :user The user to authenticate with when
  #                                connecting to the HTTP server.
  # @option options [String] :password The password to authenticate
  #                                    with when connecting to the
  #                                    HTTP server.
  # @option options [String] :host The host the HTTP server is running on.
  # @option options [Integer] :port (Net::HTTP.default_port)
  #                                 The port the HTTP server is
  #                                 listening on.
  # @option options [String] :path The path to request from the HTTP
  #                                server.
  # @option options [Hash] :proxy (Ronin::Network::HTTP.proxy)
  #                               A Hash of proxy settings to use when
  #                               connecting to the HTTP server.
  #
  # @yield [session] If a block is given, it will be passed the newly
  #                  created HTTP session object.
  # @yieldparam [Net::HTTP] session The newly created HTTP session.
  # @return [Net::HTTP] The HTTP session object.
  #
  def Net.http_session(options={},&block)
    options = Ronin::Network::HTTP.expand_options(options)

    host = options[:host]
    port = options[:port]
    proxy = options[:proxy]

    sess = Net::HTTP::Proxy(proxy[:host],proxy[:port],proxy[:user],proxy[:pass]).start(host,port)

    if block
      if block.arity == 2
        block.call(sess,options)
      else
        block.call(sess)
      end
    end

    return sess
  end

  #
  # Connects to the HTTP server and sends an HTTP Request using the given
  # _options_. If a _block_ is given it will be passed the newly created
  # HTTP Request object.
  #
  # @param [Hash] options Additional options.
  # @option options [Symbol, String] :method The HTTP method to use in
  #                                          the request.
  # @option options [Hash] :headers The Hash of the HTTP headers to send
  #                                 with the request. May contain either
  #                                 Strings or Symbols, lower-case or
  #                                 camel-case keys.
  #
  # @yield [request, (options)] If a block is given, it will be passed the
  #                             HTTP request object. If the block has an
  #                             arity of 2, it will also be passed the
  #                             expanded version of the given _options_.
  # @yieldparam [Net::HTTP::Request] request The HTTP request object to
  #                                          use in the request.
  # @yieldparam [Hash] options The expanded version of the given _options_.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_session
  #
  def Net.http_request(options={},&block)
    resp = nil

    Net.http_session(options) do |http,expanded_options|
      http_body = expanded_options.delete(:body)

      req = Ronin::Network::HTTP.request(expanded_options)

      if block
        if block.arity == 2
          block.call(req,expanded_options)
        else
          block.call(req)
        end
      end

      resp = http.request(req,http_body)
    end

    return resp
  end

  #
  # Performes an HTTP Copy request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_copy(options={},&block)
    resp = Net.http_request(options.merge(:method => :copy))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Delete request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_delete(options={},&block)
    original_headers = options[:headers]

    # set the HTTP Depth header
    options[:headers] = {:depth => 'Infinity'}

    if original_headers
      options[:header].merge!(original_headers)
    end

    resp = Net.http_request(options.merge(:method => :delete))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Get request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_get(options={},&block)
    resp = Net.http_request(options.merge(:method => :get))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Get request with the given _options_. If a _block_
  # is given, it will be passed the response body from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [String] The body of the HTTP response.
  #
  # @see http_request
  #
  def Net.http_get_body(options={},&block)
    Net.http_get(options,&block).body
  end

  #
  # Performes an HTTP Head request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_head(options={},&block)
    resp = Net.http_request(options.merge(:method => :head))

    block.call(resp) if block
    return resp
  end

  #
  # Checks if the response has an HTTP OK status code.
  #
  # @return [true, false] Specifies wether the response had an HTTP OK
  #                       status code or not.
  #
  # @see http_request
  #
  def Net.http_ok?(options={})
    Net.http_head(options).code == 200
  end

  #
  # Sends a HTTP Head request using the given _options_ and returns the
  # HTTP Server header.
  #
  # @return [String] The HTTP +Server+ header.
  #
  # @see http_request
  #
  def Net.http_server(options={})
    Net.http_head(options)['server']
  end

  #
  # Sends an HTTP Head request using the given _options_ and returns the
  # HTTP X-Powered-By header.
  #
  # @return [String] The HTTP +X-Powered-By+ header.
  #
  # @see http_request
  #
  def Net.http_powered_by(options={})
    resp = Net.http_head(options)

    if resp.code != 200
      resp = Net.http_get(options)
    end

    return resp['x-powered-by']
  end

  #
  # Performes an HTTP Lock request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_lock(options={},&block)
    resp = Net.http_request(options.merge(:method => :lock))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Mkcol request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_mkcol(options={},&block)
    resp = Net.http_request(options.merge(:method => :mkcol))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Move request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_move(options={},&block)
    resp = Net.http_request(options.merge(:method => :move))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Options request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_options(options={},&block)
    resp = Net.http_request(options.merge(:method => :options))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Post request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @param [Hash] options Additional options.
  # @option options [String] :post_data The +POSTDATA+ to send with the
  #                                     HTTP Post request.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_post(options={},&block)
    options = options.merge(:method => :post)
    post_data = options.delete(:post_data)

    if options[:url]
      url = URI(options[:url].to_s)
      post_data ||= url.query_params
    end

    resp = Net.http_request(options) do |req,expanded_options|
      req.set_form_data(post_data) if post_data
    end

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Post request with the given _options_. If a _block_
  # is given, it will be passed the response body from the HTTP server.
  #
  # @param [Hash] options Additional options.
  # @option options [String] :post_data The +POSTDATA+ to send with the
  #                                     HTTP Post request.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [String] The body of the HTTP response.
  #
  # @see http_request
  #
  def Net.http_post_body(options={},&block)
    Net.http_post(options,&block).body
  end

  #
  # Performes an HTTP Propfind request with the given _options_. If a
  # _block_ is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_prop_find(options={},&block)
    original_headers = options[:headers]

    # set the HTTP Depth header
    options[:headers] = {:depth => '0'}

    if original_headers
      options[:header].merge!(original_headers)
    end

    resp = Net.http_request(options.merge(:method => :propfind))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Proppatch request with the given _options_. If a
  # _block_ is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_prop_patch(options={},&block)
    resp = Net.http_request(options.merge(:method => :proppatch))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Trace request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_trace(options={},&block)
    resp = Net.http_request(options.merge(:method => :trace))

    block.call(resp) if block
    return resp
  end

  #
  # Performes an HTTP Unlock request with the given _options_. If a _block_
  # is given, it will be passed the response from the HTTP server.
  #
  # @yield [response] If a block is given, it will be passed the response
  #                   received from the request.
  # @yieldparam [Net::HTTP::Response] response The HTTP response object.
  # @return [Net::HTTP::Response] The response of the HTTP request.
  #
  # @see http_request
  #
  def Net.http_unlock(options={},&block)
    resp = Net.http_request(options.merge(:method => :unlock))

    block.call(resp) if block
    return resp
  end
end
