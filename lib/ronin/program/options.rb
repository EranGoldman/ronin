#
#--
# Ronin - A Ruby platform designed for information security and data
# exploration tasks.
#
# Copyright (c) 2006-2008 Hal Brodigan (postmodern.mod3 at gmail.com)
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
#++
#

require 'ronin/program/program'

require 'optparse'

module Ronin
  module Program
    class Options < OptionParser

      #
      # Creates a new Options object with the specified _program_ name
      # and the given _banner_. If a _block_ is given, it will be passed
      # the newly created Options object.
      #
      def initialize(program,banner=nil,&block)
        if banner
          self.banner = "Usage: #{program} #{banner}"
          self.separator ''
        end

        block.call(self) if block
      end

      #
      # Creates a new Options object for a Command with the specified
      # _program_ name, command _name_ and the given _banner_. If a _block_
      # is given, it will be passed the newly created Options object.
      #
      def Options.command(program,name,banner=nil,&block)
        if banner
          Options.new(program,"#{name} #{banner}",&block)
        else
          Options.new(program,name,&block)
        end
      end

      #
      # Adds an options section to the help message. If a _block_ is given
      # it will be called before any default options are added.
      #
      def options(&block)
        self.separator '  Options:'

        block.call(self) if block

        self.on('-v','--verbose','produce excess output',&(@verbose_block))
        self.on('-h','--help','print this message',&(@help_block))
        self.separator ''

        return self
      end

      #
      # Adds an the argument with the specified _name_ and _description_
      # to the arguments section of the help message of these options.
      #
      def arg(name,description)
        self.separator "    #{name}\t#{description}"
        return self
      end

      #
      # Creates an arguments section in the help message and calls the
      # given _block_.
      #
      def arguments(&block)
        if block
          self.separator '  Arguments:'

          block.call(self)

          self.separator ''
        end

        return self
      end

      #
      # Addes a summary section with the specified _text_.
      #
      def summary(text)
        self.separator '  Summary:'

        text.each_line do |line|
          line = line.strip

          self.separator "    #{line}" unless line.empty?
        end

        self.separator ''
        return self
      end

      #
      # Adds a defaults section with the specified _flags_.
      #
      def defaults(*flags)
        self.separator '  Defaults:'

        flags.each { |flag| self.separator "    #{flag}" }

        self.separator ''
        return self
      end

      #
      # Prints the help message and exits successfully. If a _block_ is
      # given it will be called after the help message has been print
      # and before the Program has exited.
      #
      def help(&block)
        puts self
        return self
      end

      def parse(argv,&block)
        args = super(argv)

        block.call(args) if block
        return args
      end

    end
  end
end
