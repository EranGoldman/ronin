#
# Ronin - A ruby development platform designed for information security
# and data exploration tasks.
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

require 'ronin/sessions/session'
require 'ronin/network/udp'

module Ronin
  module Sessions
    module UDP
      include Session

      protected

      #
      # Opens a UDP connection to the host and port specified by the
      # +host+ and +port+ parameters. If the +local_host+ and +local_port+
      # parameters are set, they will be used for the local host and port
      # of the UDP connection. A UDPSocket object will be returned.
      #
      def udp_connect(&block)
        require_variable :host
        require_variable :port

        print_info "Connecting to #{@host}:#{@port} ..."

        return ::Net.udp_connect(@host,@port,@local_host,@local_port,&block)
      end

      #
      # Connects to the host and port specified by the +host+ and +port+
      # parameters, then sends the specified _data_. If a _block_ is given,
      # it will be passed the newly created UDPSocket object.
      #
      def udp_connect_and_send(data,&block)
        require_variable :host
        require_variable :port

        print_info "Connecting to #{@host}:#{@port} ..."
        print_debug "Sending data: #{data.inspect}"

        return ::Net.udp_connect_and_send(data,@host,@port,@local_host,@local_port,&block)
      end

      #
      # Creates a UDP session to the host and port specified by the
      # +host+ and +port+ parameters. If a _block_ is given, it will be
      # passed the temporary UDPSocket object. After the given _block_
      # has returned, the UDPSocket object will be closed.
      #
      def udp_session(&block)
        require_variable :host
        require_variable :port

        print_info "Connecting to #{@host}:#{@port} ..."

        ::Net.udp_session(@host,@port,@local_host,@local_port,&block)

        print_info "Disconnected from #{@host}:#{@port}"
        return nil
      end

      #
      # Creates a new UDPServer object listening on +server_host+ and
      # +server_port+.
      #
      # @yield [server] The given block will be passed the newly created
      #                 server.
      # @yieldparam [UDPServer] server The newly created server.
      # @return [UDPServer] The newly created server.
      #
      # @example
      #   udp_server
      #
      def udp_server(&block)
        require_variable :server_port

        if @server_host
          print_info "Listening on #{@server_host}:#{@server_port} ..."
        else
          print_info "Listening on #{@server_port} ..."
        end

        return ::Net.udp_server(@server_port,@server_host,&block)
      end

      #
      # Creates a new UDPServer object listening on +server_host+ and
      # +server_port+, passing it to the given _block then closing the
      # server.
      #
      # @yield [server] The given block will be passed the newly created
      #                 server. When the block has finished, the server
      #                 will be closed.
      # @yieldparam [UDPServer] server The newly created server.
      # @return [nil]
      #
      # @example
      #   udp_server_session do |server|
      #     data, sender = server.recvfrom(1024)
      #   end
      #
      def udp_server_session(&block)
        require_variable :server_port

        if @server_host
          print_info "Listening on #{@server_host}:#{@server_port} ..."
        else
          print_info "Listening on #{@server_port} ..."
        end

        ::Net.udp_server_session(&block)

        if @server_host
          print_info "Closed #{@server_host}:#{@server_port}"
        else
          print_info "Closed #{@server_port}"
        end

        return nil
      end
    end
  end
end
