function renderChart(data, divId){
	var width = 300;
	var height = 150;
	var margin = 50;
	var duration = 250;

	var lineOpacity = "0.25";
	var lineOpacityHover = "0.85";
	var otherLinesOpacityHover = "0.1";
	var lineStroke = "1.5px";
	var lineStrokeHover = "2.5px";

	var circleOpacity = '0.85';
	var circleOpacityOnLineHover = "0.25"
	var circleRadius = 3;
	var circleRadiusHover = 6;

	var maxY = 0;

	data.forEach(function(d) { 
	  d.data.forEach(function(d) {
	    d.utilization = +d.utilization;    
	    d.value = +d.value;

	    if(maxY < d.value)
	    	maxY = d.value;    
	  });
	});

	data.forEach(function(d) { 
	  d.bounds.forEach(function(d) {
	    d.value = +d.value;
	  });

	  console.log(d.bounds);
	});


	var title = data[0].data[0].metric;
	var units = data[0].data[0].units;

	/* Scale */
	var xScale = d3.scaleLinear()
	  .domain([0, 100])
	  .range([0, width-margin]);

	var yScale = d3.scaleLinear()
	  .domain([0, maxY])
	  .range([height-margin, 0]);

	var color = d3.scaleOrdinal(d3.schemeCategory10);

	/* Add SVG */

	d3.selectAll(divId +" > *").remove();

	var svg = d3.select(divId)
	  //.selectAll("*").remove()
	  .append("svg")
	  .attr("width", (width+margin)+"px")
	  .attr("height", (height+margin)+"px")
	  .append('g')
	  .attr("transform", `translate(${margin}, ${margin})`);

	/* Add line into SVG */
	var line = d3.line()
	  .x(d => xScale(d.utilization))
	  .y(d => yScale(d.value));

	var lines = svg.append('g')
	  .attr('class', 'lines');

	lines.selectAll('.line-group')
	  .data(data).enter()
	  .append('g')
	  .attr('class', 'line-group')  
	  .append('path')
	  .attr('class', 'line')  
	  .attr('d', d => line(d.data))
	  .style('stroke', (d, i) => color(i))
	  .style('opacity', lineOpacity)
	  .on("mouseover", function(d) {
	      d3.selectAll('.line')
						.style('opacity', otherLinesOpacityHover);
	      d3.selectAll('.circle')
						.style('opacity', circleOpacityOnLineHover);
	      d3.select(this)
	        .style('opacity', lineOpacityHover)
	        .style("stroke-width", lineStrokeHover)
	        .style("cursor", "pointer");
	    })
	  .on("mouseout", function(d) {
	      d3.selectAll(".line")
						.style('opacity', lineOpacity);
	      d3.selectAll('.circle')
						.style('opacity', circleOpacity);
	      d3.select(this)
	        .style("stroke-width", lineStroke)
	        .style("cursor", "none");
	    });

	/* Add circles in the line */
	lines.selectAll("circle-group")
	  .data(data).enter()
	  .append("g")
	  .style("fill", (d, i) => color(i))
	  .selectAll("circle")
	  .data(d => d.data).enter()
	  .append("g")
	  .attr("class", "circle")  
	  .on("mouseover", function(d) {
	      d3.select(this)     
	        .style("cursor", "pointer")
	        .append("text")
	        .attr("class", "text")
	        .text(`${d.value}`)
	        .attr("x", d => xScale(d.utilization) + 5)
	        .attr("y", d => yScale(d.value) - 10);
	    })
	  .on("mouseout", function(d) {
	      d3.select(this)
	        .style("cursor", "none")  
	        .transition()
	        .duration(duration)
	        .selectAll(".text").remove();
	    })
	  .append("circle")
	  .attr("cx", d => xScale(d.utilization))
	  .attr("cy", d => yScale(d.value))
	  .attr("r", circleRadius)
	  .style('opacity', circleOpacity)
	  .on("mouseover", function(d) {
	        d3.select(this)
	          .transition()
	          .duration(duration)
	          .attr("r", circleRadiusHover);
	      })
	    .on("mouseout", function(d) {
	        d3.select(this) 
	          .transition()
	          .duration(duration)
	          .attr("r", circleRadius);  
	      });

	// var bounds = svg.append('g')
	//   .attr('class', 'bounds');   

	// var boundsLine = d3.scaleLinear().range([0, 100]).domain([0, 100]);  

	// bounds.selectAll('.line-bound')
	//   .data(data).enter()
	//   .append('g')
	//   .attr('class', 'line-bound')  
	//   .append('path')
	//   .attr('class', 'line')  
	//   .attr('d', function(d){
 //          return d3.line()
 //            .x(function(d) { return boundsLine(100); })
 //            .y(function(d) { return d.value; })
 //            (d.bounds)
 //        })
	//   .style('stroke', (d, i) => color(i))  

	/* Add Axis into SVG */
	var xAxis = d3.axisBottom(xScale).ticks(5);
	var yAxis = d3.axisLeft(yScale).ticks(5);

	svg.append("g")
	  .attr("class", "x axis")
	  .attr("transform", `translate(0, ${height-margin})`)
	  .call(xAxis)
	  .append('text')
	  .attr("x",  width - 70)
	  .attr("y",  -10)
	  .attr("fill", "#000")
	  .text("Utilization(%)");

	svg.append("g")
	  .attr("class", "y axis")
	  .call(yAxis)
	  .append('text')
	  .attr("y", 15)
	  .attr("transform", "rotate(-90)")
	  .attr("fill", "#000")
	  .text(units);

	svg.append("text")
		.attr("x", ((width - margin) / 2))             
		.attr("y", 0 - (margin / 2))
		.attr("text-anchor", "middle") 
		.style("font-size", "16px") 
		.text(title);
}