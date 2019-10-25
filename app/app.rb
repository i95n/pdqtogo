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

get '/chart3' do
  	content_type :text

  	model = IO.read("./samples/10mm1.pl")
  	result = eval_model(model)

  	reportsIdx = substring_positions("PRETTY DAMN QUICK REPORT", result)
  	reportsIdx << result.size

  	reaults = []
  	reaults << "utilization,metric,resource,stream,value,unit"

	for i in 0..(reportsIdx.size - 2)
		reportN = result[reportsIdx[i]..reportsIdx[i+1]]
		
		# puts "==========#{reportsIdx[i]} #{reportsIdx[i+1]}"
		# pp reportN

		reaults = reaults + parse_report(reportN)
	end

	reaults.join("\n")
end

def parse_report(report)
	content = report.split("\n")
	printMetrics = false

	data = {}
	results = []

	content.each_with_index do |item, index|

		if item.include?("RESOURCE Performance")
			printMetrics = true
		end


		if printMetrics
			#puts "#{index} #{item}"

			if match = item.match(/(?<metric>[ a-zA-Z]+)[ ]+(?<resource>[a-zA-Z]+)[ ]+(?<stream>[a-zA-Z]+)[ ]+(?<value>[.0-9]+)[ ]+(?<units>[\/a-zA-Z]+)/i)
			  	metric, resource, stream, value, units = match.captures

			  	#puts "#{metric},#{stream},#{value},#{units}"
			  	mt = metric.strip
			  	data[mt] = {
			  		:metric => mt, 
			  		:resource => resource, 
			  		:stream => stream, 
			  		:value => value, 
			  		:units => units
			  	}
			end
		end	

		
	end	

	data.each do |key, item|
	  results << "#{data["Utilization"][:value]},#{item[:metric]},#{item[:resource]},#{item[:stream]},#{item[:value]},#{item[:units]}"
	end

	results
end

def substring_positions(substring, string)
	string.enum_for(:scan, substring).map { $~.offset(0)[0] - substring.size }

	#idx = string.index(substring)
	# indices = []

	# idx = 0;
	# content = string

	# while true
	# 	idx = content.index(substring)
	# 	puts idx

	# 	break if idx == nil

	# 	indices << idx
	# 	content = content[(idx + substring.size + 5)..-1]
	# end

	# indices
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
		#.gsub(/NULL\R+/, '')
		#.gsub(/\[1\] 0\n/, '')
end