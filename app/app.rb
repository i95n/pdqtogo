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

get '/model' do
  	content_type :text
	IO.read("./models/mm1.py")
end

post '/solve' do
  	content_type :text

  	model = params[:model] 

  	result = ""
	error = ""

	pp model

	evaluator = ""

	if model.include? "use pdq;"
	   evaluator = "perl -e '#{model}'"
	elsif model.include? "import pdq"
	   evaluator = "python -c '#{model}'"
	else
	   evaluator = "unsupported interpretter :(. try python or perl"
	end

	Open3.popen3(evaluator) do |stdin, stdout, stderr, wait_thr|
	  result = stdout.read
	  error = stderr.read
	end

	if error.nil? || error.empty?
  		return result
	else
		return error
	end

end