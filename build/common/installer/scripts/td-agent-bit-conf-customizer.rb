#!/usr/local/bin/ruby
require_relative "ConfigParseErrorLogger"

@td_agent_bit_conf_path = "/etc/opt/microsoft/docker-cimprov/td-agent-bit.conf"

@default_service_interval = "1"
@default_buffer_chunk_size = "1"
@default_buffer_max_size = "1"

def is_number?(value)
  true if Integer(value) rescue false
end

def substituteFluentBitPlaceHolders
  begin
    # Replace the fluentbit config file with custom values if present
    puts "config::Starting to substitute the placeholders in td-agent-bit.conf file for log collection"

    interval = ENV["FBIT_SERVICE_FLUSH_INTERVAL"]
    bufferChunkSize = ENV["FBIT_TAIL_BUFFER_CHUNK_SIZE"]
    bufferMaxSize = ENV["FBIT_TAIL_BUFFER_MAX_SIZE"]
    multilineLogging = ENV["AZMON_LOG_STITCH_MULTILINE"]
    containerRuntime = ENV["CONTAINER_RUNTIME"]

    serviceInterval = (!interval.nil? && is_number?(interval) && interval.to_i > 0 ) ? interval : @default_service_interval
    serviceIntervalSetting = "Flush         " + serviceInterval

    tailBufferChunkSize = (!bufferChunkSize.nil? && is_number?(bufferChunkSize) && bufferChunkSize.to_i > 0) ? bufferChunkSize : @default_buffer_chunk_size

    tailBufferMaxSize = (!bufferMaxSize.nil? && is_number?(bufferMaxSize) && bufferMaxSize.to_i > 0) ? bufferMaxSize : @default_buffer_max_size = "1"

    if ((!tailBufferChunkSize.nil? && tailBufferMaxSize.nil?) ||  (!tailBufferChunkSize.nil? && !tailBufferMaxSize.nil? && tailBufferChunkSize.to_i > tailBufferMaxSize.to_i))
      puts "config:warn buffer max size must be greater or equal to chunk size"
      tailBufferMaxSize = tailBufferChunkSize
    end

    text = File.read(@td_agent_bit_conf_path)
    new_contents = text.gsub("${SERVICE_FLUSH_INTERVAL}", serviceIntervalSetting)
    if !tailBufferChunkSize.nil?
      new_contents = new_contents.gsub("${TAIL_BUFFER_CHUNK_SIZE}", "Buffer_Chunk_Size " + tailBufferChunkSize + "m")
    else
      new_contents = new_contents.gsub("\n    ${TAIL_BUFFER_CHUNK_SIZE}\n", "\n")
    end
    if !tailBufferMaxSize.nil?
      new_contents = new_contents.gsub("${TAIL_BUFFER_MAX_SIZE}", "Buffer_Max_Size " + tailBufferMaxSize + "m")
    else
      new_contents = new_contents.gsub("\n    ${TAIL_BUFFER_MAX_SIZE}\n", "\n")
    end

    # for stitching together multiline logs
    puts multilineLogging
    puts containerRuntime

    puts "config::multiline -------------------------------- 1"
    if !multilineLogging.nil? && multilineLogging.to_s.downcase == "true" && !containerRuntime.nil?
      puts "config::multiline -------------------------------- 2"
      if containerRuntime == "docker"
        puts "config::multiline -------------------------------- 3"
        new_contents = new_contents.gsub("#${DOCKER_MULTILINE_LOGGING}", "")
      else
        puts "config::multiline -------------------------------- 4"
        new_contents = new_contents.gsub("#${CONTAINTERD_MULTILINE_LOGGING}", "")
      end
    else
      puts "config::multiline -------------------------------- 4"
    end
    puts "config::multiline -------------------------------- 5"

    File.open(@td_agent_bit_conf_path, "w") { |file| file.puts new_contents }
    puts "config::Successfully substituted the placeholders in td-agent-bit.conf file"
  rescue => errorStr
    ConfigParseErrorLogger.logError("td-agent-bit-config-customizer: error while substituting values in td-agent-bit.conf file: #{errorStr}")
  end
end

substituteFluentBitPlaceHolders
