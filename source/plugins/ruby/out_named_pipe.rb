require 'fluent/plugin/output'

module Fluent::Plugin
  class NamedPipeOutput < Output
    Fluent::Plugin.register_output('named_pipe', self)

    helpers :formatter

    config_param :datatype, :string

    def initialize
        super
        require_relative "extension_utils"

        # @pipe_name = ""
        # @pipe_handle = nil

    end

    def configure(conf)
      super

      @formatter = formatter_create(usage: 'msgpack_formatter', type: 'msgpack' )
    end

    # def getNamedPipeFromExtension()
    #     pipe_suffix = ExtensionUtils.getOutputNamedPipe(@datatype)
    #     if !pipe_suffix.nil? && !pipe_suffix.empty?
    #       @pipe_name = "\\\\.\\pipe\\" + pipe_suffix
    #       @log.info "Named pipe: #{@pipe_name}"
    #     end
    # end

    def start
      super
      # begin
      #   getNamedPipeFromExtension()    
      #   if @pipe_name.nil? || @pipe_name.empty?
      #       @log.error "Couldn't get pipe name from extension config. Will retry during write"
      #   elsif !File.exist?(@pipe_name)
      #       @log.error "Named pipe with name: #{@pipe_name} doesn't exist"
      #   end
      # rescue => e
      #   @log.info "Exception while starting out_named_pipe #{e}"
      # end
    end

    def format(tag, time, record)
        if record != {}
          return [tag, [[time, record]]].to_msgpack
        else
          return ""
        end
    end

    def write(chunk)
      if chunk.empty?
        @log.info "Chunk is empty"
        return
      end
      begin
        pipe_name = nil
        pipe_suffix = ExtensionUtils.getOutputNamedPipe(@datatype)
        if !pipe_suffix.nil? && !pipe_suffix.empty?
          pipe_name = "\\\\.\\pipe\\" + pipe_suffix
          @log.info "Named pipe: #{pipe_name}"
        end
        if File.exist?(pipe_name)
          pipe_handle = File.open(pipe_name, File::WRONLY)
          chunk.write_to(pipe_handle)
          pipe_handle.flush
          pipe_handle.close
        else
          @log.error "File doesn't exist: #{pipe_name}"
        end
      rescue Exception => e
        @log.info "Exception when writing to named pipe: #{e}"
        raise e
      end
    end

  end
end