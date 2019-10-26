require 'sinatra'
require "sinatra/json"
require 'open3'
require 'pp'
require 'uri'
require 'json'
require 'enumerator'

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

post '/chart' do
	content_type :json

  	model = params[:model] 
  	
  	report = eval_model(model)
  	result = report_to_charts_data(report)
  	
	result.to_json
end	

post '/solve' do
  	content_type :text

  	model = params[:model] 
  	eval_model(model)
end

get '/chart3' do
  	content_type :json

  	model = IO.read("./samples/10mm1.pl")

  	report = eval_model(model)
  	result = report_to_charts_data(report)
  	
	result.to_json
end

def report_to_charts_data(report)
	reportsIdx = substring_positions("PRETTY DAMN QUICK REPORT", report)
  	reportsIdx << report.size

  	results = []

	for i in 0..(reportsIdx.size - 2)
		reportN = report[reportsIdx[i]..reportsIdx[i+1]]
		
		results = results + parse_report(reportN)
	end

	{
		"throughput" => group_by_metric(results,"Throughput"),
		"in_service" => group_by_metric(results,"In service"),
		"queue_length" => group_by_metric(results,"Queue length"),
		"waiting_line" => group_by_metric(results,"Waiting line"),
		"waiting_time" => group_by_metric(results,"Waiting time"),
		"residence_time" => group_by_metric(results,"Residence time"),
	}
end

def group_by_metric(data, metricName)
	data
		.select { |hash| hash[:metric] == metricName }
		.group_by{ |s| s[:stream] }
		.map {|key, values| {
			:name => key, 
			:values => values 
		} }
end

def parse_report(report)
	content = report.split("\n")
	printMetrics = false

	results = []

	utilization = {}

	content.each_with_index do |item, index|

		if item.include?("RESOURCE Performance")
			printMetrics = true
		end


		if printMetrics
			#puts "#{index} #{item}"

			if match = item.match(/(?<metric>[ a-zA-Z]+)[ ]+(?<resource>[a-zA-Z]+)[ ]+(?<stream>[a-zA-Z]+)[ ]+(?<value>[.0-9]+)[ ]+(?<units>[\/a-zA-Z]+)/i)
			  	metric, resource, stream, value, units = match.captures

			  	#puts "#{metric},#{stream},#{value},#{units}"
			  	results << {
			  		:metric => metric.strip, 
			  		:resource => resource, 
			  		:stream => stream, 
			  		:value => value, 
			  		:units => units
			  	}

			  	if metric.strip == "Utilization"
			  		utilization["#{resource}-#{stream}"] = value
			  	end	
			end
		end	
		
	end	

	results.each do |item|
	  item[:utilization] = utilization["#{item[:resource]}-#{item[:stream]}"]
	end

	results
end

def substring_positions(substring, string)
	string.enum_for(:scan, substring).map { $~.offset(0)[0] - substring.size }
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
		#pp result
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