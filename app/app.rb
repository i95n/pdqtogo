require 'sinatra'
require "sinatra/json"
require 'open3'
require 'pp'
require 'uri'
require 'json'

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

get '/chart' do
	content_type :json
	{:throughput=>
	  {:workloads=>
	    [{:name=>"Idfs",
	      :data=>
	       [{:u=>0, :value=>0},
	        {:u=>0.5, :value=>"0.2400"},
	        {:u=>1, :value=>"0.5000"}]},
	     {:name=>"Qcs",
	      :data=>
	       [{:u=>0, :value=>0},
	        {:u=>0.5, :value=>"0.0640"},
	        {:u=>1, :value=>"0.5000"}]},
	     {:name=>"Enr",
	      :data=>
	       [{:u=>0, :value=>0},
	        {:u=>0.5, :value=>"0.0960"},
	        {:u=>1, :value=>"0.3125"}]}]},
	 :response_time=>
	  { :value_range => {
	  	:x => [0, 1.0],
	  	:y => [0, 18]
	  }, 
	  	:workloads=>
	    [{:name=>"Idfs",
	      :data=>
	       [{:u=>0, :value=>"2.0000"},
	        {:u=>0.5, :value=>"11.4679"},
	        {:u=>1, :value=>"50"}]},
	     {:name=>"Qcs",
	      :data=>
	       [{:u=>0, :value=>"0.6000"},
	        {:u=>0.5, :value=>"3.4404"},
	        {:u=>1, :value=>"50"}]},
	     {:name=>"Enr",
	      :data=>
	       [{:u=>0, :value=>"3.2000"},
	        {:u=>0.5, :value=>"18.3486"},
	        {:u=>1, :value=>"50"}]}]}}.to_json
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