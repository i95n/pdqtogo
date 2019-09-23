require 'sinatra'
require "sinatra/json"
require 'open3'
require 'pp'
require 'uri'

set :protection, except: [ :json_csrf ]

port = ENV['PORT'] || 8080
puts "STARTING SINATRA on port #{port}"
set :port, port
set :bind, '0.0.0.0'

get '/' do
  File.read(File.join('public', 'index.html'))
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

get '/model' do
  	content_type :text
	IO.read("./mm1.pl")
end

post '/solve' do
  	content_type :text

  	model = params[:model] 

  	result = ""
	error = ""

	pp model

	Open3.popen3("perl -e '#{model}'") do |stdin, stdout, stderr, wait_thr|
	  result = stdout.read
	  error = stderr.read
	end

  	result
end