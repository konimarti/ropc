require 'win32ole'
require 'logger'

module ROPC

  module OPCDataSource
    OPCCache = 1
    OPCDevice = 2
  end
   
  module OPCQuality
    OPCQualityMask = 192
    OPCQualityBad = 0
    OPCQualityUncertain = 64
    OPCQualityGood = 192
    OPCQuality = {192 => "Good", 64 => "Uncertain", 0 => "Bad"}
  end
  
  class Client
    def initialize(tags: [], server: nil, node: nil, logger: Logger.new(STDOUT), level: "WARN")
      @tags = tags
      
      @server = server
      @server ||= ENV["ROPC_SERVER"]
      fail "Environment variable ROPC_SERVER not set or not server given." if @server.nil?
      
      @node = node
      @node ||= ENV["ROPC_NODE"]
      fail "Environment variable ROPC_NODE not set or not node given." if @node.nil?
      
      @logger = logger
      @logger.level = level   
      
      establish_connection
    end    

    def establish_connection
      begin
        @opc_automation = WIN32OLE.new 'OPC.Automation.1'
        @logger.info("OPC.Automation.1 created.")
      rescue => err
        @logger.fatal("Cannot create win32ole OPC Automation object")
        @logger.fatal(err)
        exit
      end
      
      begin
        @opc_automation.Connect(@server,@node)
        @logger.info("Connected to OPC Server.")        
        @logger.info("OPC Server StartTime: #{@opc_automation.invoke("StartTime")}") # returns Time Class
        @logger.info("OPC Server CurrentTime: #{@opc_automation.invoke("CurrentTime")}") # returns Time Class        
      rescue => err
        @logger.fatal("Cannot connect to OPC #{@server} on #{@node}")
        @logger.fatal(err)
        exit
      end
      
      begin
        @opc_group = @opc_automation.OPCGroups.add "OPCGroup"
        @opc_items = @opc_group.OPCItems
        #opc_group.UpdateRate = 1000
        @logger.info("Group UpdateRate: #{@opc_group.UpdateRate}")
        @logger.info("OPC Group IsSubscribed: #{@opc_group.IsSubscribed}")
        @logger.info("OPC Group IsActive: #{@opc_group.IsActive}")
      rescue => err
        @logger.fatal("Could not add OPCGroup")
        @logger.fatal(err)
        exit
      end

      @items = {}
      
      if @tags.respond_to?("each")
        @tags.each {|tag| self.add tag }
      else
        self.add @tags
      end
    
      @logger.info("Number of OPCGroup in OPCGroups: #{@opc_automation.OPCGroups.Count}")      
      @logger.info("Number of OPCItem in OPCitems: #{@opc_items.Count}")
      
    end
    
    def add(tag)
      begin
      	@items[tag] = @opc_items.AddItem(tag, 1)	
      rescue
        @logger.warn("Failed to add this tag: #{tag}")
      end
    end
	
    def remove(tag)
      @items.delete(tag) if @items.has_key?(tag)
    end
    
    def read_tag(tag)
        if @items.has_key?(tag)
                opcitem = @items[tag]
                begin
                  opcitem.read OPCDataSource::OPCCache # 1: reading from cache, 2: reading from device          
                rescue
                  @logger.warn("Failed to read opc tag: #{tag}")
                  cleanup
                  establish_connection
                  return tags
                end
                ts = opcitem.TimeStamp + opcitem.TimeStamp.gmtoff
                @logger.info("Read #{opcitem.ItemID} Value: #{extract_value(opcitem.Value)}, Quality: #{OPCQuality::OPCQuality[opcitem.Quality]}, Time: #{ts}")
                return {tag: opcitem.ItemID, value: extract_value(opcitem.Value), quality: OPCQuality::OPCQuality[opcitem.Quality], timestamp: ts}          
        else
                return {}
        end
    end
    
    def read
        read_all
    end
    
    def read_all
      tags = []
      @items.keys.each do |tag|	
        tags << read_tag(tag)
      end
      return tags
    end
    
    def cleanup
      @opc_groups.RemoveAll if @opc_groups
      @opc_automation.Disconnect if @opc_automation
    end
  
    def extract_value str      
      begin
        if str.kind_of?(FalseClass)             
            return 0.0          
        elsif str.kind_of?(TrueClass)             
            return 1.0                  
        elsif Float(str)          
          return str            
        elsif Int(str)          
          return str                    
        end
      rescue 
        @logger.warn("failed to extract value: #{str}; returning 0.0")
        return 0.0
      end      
    end
  
  end
  
  def self.read_tags(tags)    
    opc = ROPC::Client.new(tags: tags, level: "WARN")
    ret = opc.read
    opc.cleanup
    ret
  end
  
end
