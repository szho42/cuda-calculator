
drawGraph = function(input, to){

  var margin = {top: 20, right: 20, bottom: 30, left: 40},
  width = 400 - margin.left - margin.right,
  height = 200 - margin.top - margin.bottom;

  var data = input.data,
    current = input.current;

  console.log(input);
  var xData = _.pluck(data, 'key')
  var x = d3.scale.linear()
  .range([0, width])
  //.domain(_.pluck(data, 'key'))
  .domain([d3.min(xData), d3.max(xData)]);
  ;

  var yData = _.pluck(data, 'value')
  var y = d3.scale.linear()
  .range([height, 0])
  .domain([0, d3.max(yData)]);
  ;

  var xAxis = d3.svg.axis()
  .scale(x)
  .orient("bottom");

  var yAxis = d3.svg.axis()
  .scale(y)
  .orient("left")
  ;

  var svg = d3.select(to).append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  svg.append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + height + ")")
  .call(xAxis);

  svg.append("g")
  .attr("class", "y axis")
  .call(yAxis)
  // .append("text")
  // .attr("transform", "rotate(-90)")
  // .attr("y", 6)
  // .attr("dy", ".71em")
  // .style("text-anchor", "end")
  // .text("Warp Occupancy")
  ;

  svg.selectAll(".bar")
  .data(data)
  .enter()
  .append("circle")
  .attr("class", "bar")
  .attr("cx", function(d) { return x(d.key); })
  // .attr("dx", x.rangeBand())
  .attr('r', 5)
  // .attr('dy', 10)
  .attr("cy", function(d) { return y(d.value); })
  // .attr("dy", function(d) { return height - y(d.value); });
  console.log(current)
  svg.selectAll(".current")
  .data([current])
  .enter()
  .append("circle")
  .attr("class", "current")
  .attr("cx", function(d) { return x(d.key); })
  .attr('r', 5)
  .attr("cy", function(d) { return y(d.value); })


}
