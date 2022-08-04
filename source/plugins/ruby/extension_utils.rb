# Copyright (c) Microsoft Corporation.  All rights reserved.
#!/usr/local/bin/ruby
# frozen_string_literal: true

require_relative "extension"
require "constants"                    

class ExtensionUtils
    class << self        
        def getOutputStreamId(dataType)  
          outputStreamId = "" 
          begin
            if !dataType.nil? && !dataType.empty?
              outputStreamId = Extension.instance.get_output_stream_id(dataType)  
              $log.info("ExtensionUtils::getOutputStreamId: got streamid: #{outputStreamId} for datatype: #{dataType}")
            else           
              $log.warn("ExtensionUtils::getOutputStreamId: dataType shouldnt be nil or empty")
            end            
          rescue => errorStr
            $log.warn("ExtensionUtils::getOutputStreamId: failed with an exception: #{errorStr}")
          end    
          return outputStreamId     
        end 
        def isAADMSIAuthMode() 
          return !ENV["AAD_MSI_AUTH_MODE"].nil? && !ENV["AAD_MSI_AUTH_MODE"].empty? && ENV["AAD_MSI_AUTH_MODE"].downcase == "true"
        end  

        def getDataCollectionIntervalSeconds          
          collectionIntervalSeconds = 60
          begin
             extensionSettings = Extension.instance.get_extension_settings()
             if !extensionSettings.nil? && 
              !extensionSettings.empty? && 
              extensionSettings.has_key(Constants::EXTENSION_SETTING_DATA_COLLECTION_INTERVAL)
               intervalMinutes = extensionSettings[Constants::EXTENSION_SETTING_DATA_COLLECTION_INTERVAL]
               if is_number?(intervalMinutes) && 
                intervalMinutes.to_i >= Constants::DATA_COLLECTION_INTERVAL_MINUTES_MIN && 
                intervalMinutes.to_i <= Constants::DATA_COLLECTION_INTERVAL_MINUTES_MAX
                collectionIntervalSeconds =  60 * intervalMinutes.to_i
               else 
                $log.warn("ExtensionUtils::getDataCollectionIntervalSeconds: dataCollectionIntervalMinutes: #{intervalMinutes} not valid hence using default")    
               end
             end
          rescue => err 
            $log.warn("ExtensionUtils::getDataCollectionIntervalSeconds: failed with an exception: #{errorStr}")
          end          
          return collectionIntervalSeconds
        end          

        def getExcludedNamespacesForDataCollection
          excludeNameSpaces = []
          begin
             extensionSettings = Extension.instance.get_extension_settings()
             if !extensionSettings.nil? && 
              !extensionSettings.empty? && 
              extensionSettings.has_key(Constants::EXTENSION_SETTING_EXCLUDE_NAMESPACES)
               namespacesToExclude = extensionSettings[Constants::EXTENSION_SETTING_EXCLUDE_NAMESPACES]
               if !namespacesToExclude.nil? && !namespacesToExclude.empty? && namespacesToExclude.kind_of?(Array) && namespacesToExclude.length > 0 
                 uniqNamespaces = namespacesToExclude.uniq                 
                 excludeNameSpaces = uniqNamespaces.map(&:downcase)
              else 
                $log.warn("ExtensionUtils::getExcludedNamespacesForDataCollection: excludeNameSpaces: #{namespacesToExclude} not valid hence using default")                   
               end             
             end
          rescue => err 
            $log.warn("ExtensionUtils::getExcludedNamespacesForDataCollection: failed with an exception: #{errorStr}")
          end
          return excludeNameSpaces
        end          

    end
end
