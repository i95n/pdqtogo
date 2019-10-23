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

	{
		:response_time_unit => "Sec",
		:response_time => [
			{
				:categorie => "Min response",
				:values => [
					{:rate => "Idfs", :value => 2.0000},
					{:rate => "Qcs", :value => 0.6000},
					{:rate => "Enr", :value => 3.2000},
				]
			},
			{
				:categorie => "Response time",
				:values => [
					{:rate => "Idfs", :value => 11.4679},
					{:rate => "Qcs", :value => 3.4404},
					{:rate => "Enr", :value => 18.3486},
				]
			}
		],
		:throughput_unit => "Op/Sec",
		:throughput => [
			{
				:categorie => "Mean throughput",
				:values => [
					{:rate => "Idfs", :value => 0.2400},
					{:rate => "Qcs", :value => 0.0640},
					{:rate => "Enr", :value => 0.0960},
				]
			},
			{
				:categorie => "Max throughput",
				:values => [
					{:rate => "Idfs", :value => 0.5000},
					{:rate => "Qcs", :value => 0.5000},
					{:rate => "Enr", :value => 0.3125},
				]
			}
		]

	}.to_json

	

end	

post '/solve' do
  	content_type :text

  	model = params[:model] 
  	eval_model(model)
end

post '/chart2' do
  	content_type :json

  	model = params[:model] 
  	eval_model(model)

  	{
		:response_time_unit => "Sec",
		:response_time => [
			{
				:categorie => "Min response",
				:values => [
					{:rate => "Idfs", :value => 2.0000},
				]
			},
			{
				:categorie => "Response time",
				:values => [
					{:rate => "Idfs", :value => 11.4679},
				]
			}
		],
		:throughput_unit => "Op/Sec",
		:throughput => [
			{
				:categorie => "Mean throughput",
				:values => [
					{:rate => "Idfs", :value => 0.2400},
				]
			},
			{
				:categorie => "Max throughput",
				:values => [
					{:rate => "Idfs", :value => 0.5000},
				]
			}
		]

	}.to_json

end


def eval_model(model)
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