function drawBubbles() {

   var container = d3.select(".deck-container").node();
   var width = container.getBoundingClientRect().width * 0.5;
   var height = container.getBoundingClientRect().height * 0.6;

   var center = {
      x: width / 2,
      y: height / 2
   };

   var svg = d3.select("#bubblechart")
      .append("svg")
      .attr("height", height)
      .attr("width", width)
      .append("g");

   var defs = svg.append("defs");
   var radiusScale = d3.scalePow().domain([1, 1]).exponent(0.5).range([1, 80]);
   var forceStrength = 0.03;
   var simulation = d3.forceSimulation()
      .velocityDecay(0.2)
      .force("x", d3.forceX().strength(forceStrength).x(center.x))
      .force("y", d3.forceY().strength(forceStrength).y(center.y))
      .force("collide", d3.forceCollide(function(d) {
         return radiusScale(d.pic_size) + 1
      }))

   d3.queue().defer(d3.csv, "media/mammals.csv").await(ready);

   function ready(error, data) {
      var maxAmount = d3.max(data, function(d) {
         return +d.pic_size;
      });
      radiusScale.domain([0, maxAmount]);

      defs.selectAll(".mammal-pattern")
         .data(data)
         .enter().append("pattern")
         .attr("class", "mammal-pattern")
         .attr("id", function(d) {return 'mammal_' + d.id})
         .attr("height", "100%")
         .attr("width", "100%")
         .attr("patternContentUnits", "objectBoundingBox")
         .append("image")
         .attr("height", 1)
         .attr("width", 1)
         .attr("preserveAspectRatio", "none")
         .attr("xmlns:xlink", "http://www.w3.org/1999/xlink")
         .attr("xlink:href", function(d) {return d.pic});

      var circles = svg.selectAll(".mammal")
         .data(data)
         .enter().append("circle")
         .attr("class", "mammal")
         .attr("r", function(d) {return radiusScale(d.pic_size)})
         .attr("stroke", '#ef8376')
         .attr("stroke-width", "4")
         .attr("fill", function(d) {return 'url(#mammal_' + d.id + ')'})
         .attr('fill-opacity', '1')
         .on('mouseover', showDetail)
         .on('mouseout', hideDetail);

      function showDetail(d) {
         d3.select(this)
            .attr('stroke-width', '8')
            .attr('fill-opacity', '1')
            .append('svg:title')
            .text(function(d) {return d.name});
      }

      function hideDetail(d) {
         d3.select(this)
            .attr('stroke-width', '4')
            .attr('fill-opacity', '1');
      }

      function ticked() {
         circles.attr("cx", function(d) {return d.x})
            .attr("cy", function(d) {return d.y})
      }

      simulation.nodes(data).on('tick', ticked);
   }
}
