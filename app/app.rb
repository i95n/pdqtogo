require 'sinatra'
require "sinatra/json"

set :protection, except: [ :json_csrf ]

port = ENV['PORT'] || 8080
puts "STARTING SINATRA on port #{port}"
set :port, port
set :bind, '0.0.0.0'

get '/' do
  json({"Hello" => "World!"})
end

get '/demo' do
  content_type :text
  `perl ./mm1.pl`
end