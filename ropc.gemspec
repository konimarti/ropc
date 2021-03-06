$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'ropc/version'

Gem::Specification.new do |s|
  s.name        = 'ropc'
  s.version     = ROPC::VERSION
  s.date        = '2018-09-24'
  s.summary     = "Minimal, read-only OPC client"
  s.description = "Read the tags from an OPC server using Win32 OLE for monitoring and data analysis."
  s.authors     = ["Koni Marti"]
  s.email       = ''
  s.homepage    = 'https://github.com/konimarti'
  s.license     = 'MIT'
  s.files       = ["lib/ropc.rb", "lib/ropc/client.rb", "lib/ropc/version.rb"]  
  
  s.add_runtime_dependency "win32ole-pp", '~>1.2'
end
