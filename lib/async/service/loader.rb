# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024, by Samuel Williams.

require_relative 'environment'

module Async
	module Service
	# The domain specific language for loading configuration files.
		class Loader
			# Initialize the loader, attached to a specific configuration instance.
			# Any environments generated by the loader will be added to the configuration.
			# @parameter configuration [Configuration]
			# @parameter root [String] The file-system root path for relative path computations.
			def initialize(configuration, root = nil)
				@configuration = configuration
				@root = root
			end
			
			# The file-system root path which is injected into the environments as required.
			# @attribute [String]
			attr :root
			
			# Load the specified file into the given configuration.
			# @parameter configuration [Configuration]
			# @oaram path [String] The path to the configuration file, e.g. `falcon.rb`.
			def self.load_file(configuration, path)
				realpath = ::File.realpath(path)
				root = ::File.dirname(realpath)
				
				loader = self.new(configuration, root)
				
				if ::Module.method_defined?(:set_temporary_name)
					loader.singleton_class.set_temporary_name("#{self}[#{path.inspect}]")
				end
				
				loader.instance_eval(File.read(path), path)
			end
			
			def load_file(path)
				Loader.load_file(@configuration, File.expand_path(path, @root))
			end
			
			# Create an environment.
			def environment(**initial, &block)
				Environment.build(**initial, &block)
			end
			
			# Define a host with the specified name.
			# Adds `root` and `authority` keys.
			# @parameter name [String] The name of the environment, usually a hostname.
			def service(name, &block)
				@configuration.add(self.environment(name: name, root: @root, &block))
			end
		end
	end
end
