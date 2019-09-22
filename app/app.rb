require 'sinatra'
require "sinatra/json"
require 'open3'

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

	cmd = 'perl ./mm1.pl'

	result = ""
	error = ""

	Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
	  result = stdout.read
	  error = stderr.read
	end

  	result
end