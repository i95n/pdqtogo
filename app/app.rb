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
  	name = params[:name]
	IO.read("./samples/#{name}")
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
	elsif model.include? "library(pdq)"
	   evaluator = "Rscript -e '#{model}'"
	else
	   evaluator = "unsupported interpretter :(. try python or perl"
	end

	Open3.popen3(evaluator) do |stdin, stdout, stderr, wait_thr|
	  result = stdout.read
	  error = stderr.read
	end

	if error.nil? || error.empty?
		result = format_output(result)
		pp result
  		return result
	else
		pp error
		return error
	end

end

def format_output(result)
	result
		.gsub(/NULL\R+/, '')
		.gsub(/\[1\] 0\n/, '')
end