# ropc

Read process and automation data from an OPC server for monitoring and data analysis purposes (OPC DA protocol).
Optionally, the client can be accessed via a restful webservice from different nodes.

## Usage

```
$ irb -rropc

irb(main):001:0> client = ROPC::Client.new(server: "INAT TcpIpH1 OPC Server", node: "10.100.100.100")
=> #<ROPC::Client:0x3047820 ...>

irb(main):002:0> client.add "[001]DB101DW015"
=> #<WIN32OLE:0x30fbf28>

irb(main):003:0> client.read
=> [{:tag=>"[001]DB101DW015", :value=>42, :quality=>"Good", :timestamp=>2018-09-24 16:32:37 +0200}] 
``` 

Change the server and node parameters to your OPC server's settings in the example above.


## Install 

```
$ gem build ropc.gemspec
$ gem install ropc-0.0.1.gem
``` 

or download directly:

```
$ gem install ropc
```

## Prerequisites

* Make sure you have the win32ole gem (~>1.2) installed:

  ```gem install win32ole-pp``` 

* In order to connect to an OPC Server via DCOM, certain OPC components need to be installed on your local maschine (e.g. the OPC Automation Wrapper). These components are usually available from the vendor of your OPC server or directly installed with your OPC installation.
  
  To test if you have the required components:
  ```
  $ irb -rwin32ole
  
  irb(main):001:0> WIN32OLE.new 'OPC.Automation.1'
  => #<WIN32OLE:0x2ad1628>        
  ```
  
* If you are on a 64bit system, try running a 32bit Ruby version in case you encounter any OLE difficulties.

  
## Experimental: OPC Client as REST webservice

* Install sinatra and the puma webserver (optional but recommended): 

        gem install sinatra

        gem install puma

* Set the environment variables: 

        ROPC_SERVER="INAT TcpIpH1 OPC Server"
  and
        ROPC_NODE="10.100.100.100"
 
* Start the webservice with rackup: 

        rackup -Ilib

* From another console, add some tags with a POST request:

        curl -X POST localhost:3000/tags/[001]DB101DW015

 * Read tags:
 
        curl -X GET localhost:3000/tags/[001]DB101DW015
   or 
        curl -X GET localhost:3000/tags
         
 * Response will be in JSON:
 
         [
          {
            "tag": "[001]DB101DW015",
            "value": 44,
            "quality": "Good",
            "timestamp": "2018-09-24 16:58:32 +0200"
          }
         ]
 
 * Delete tag:
 
        curl -X DELETE localhost:3000/tags/[001]DB101DW015

