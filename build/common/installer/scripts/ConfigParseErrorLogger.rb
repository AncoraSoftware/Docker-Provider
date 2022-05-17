#!/usr/local/bin/ruby
# frozen_string_literal: true

class ConfigParseErrorLogger
  require "yajl/json_gem"

  def initialize
  end

  class << self
    def logError(message)
      begin
        errorMessage = "config::error::" + message
        jsonMessage = errorMessage.to_json
        STDERR.puts jsonMessage
      rescue => errorStr
        puts "Error in ConfigParserErrorLogger::logError: #{errorStr}"
      end
    end
  end
end
