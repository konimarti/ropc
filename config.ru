#\ -p 3000

require 'sinatra/base' 
require 'json'

require 'ropc'
require 'ropc/api/app'

TagApp.set :db, "./ropc_db.json"
TagApp.set :server, ENV["ROPC_SERVER"]
TagApp.set :node, ENV["ROPC_NODE"]

run TagApp.new