$(document).ready(function() { 
  var pathname = window.location.pathname,
      diameter = 450;
  
  var pool = d3.scale.ordinal()
  	      .range(["#efedf5","#bcbddc","#756bb1"]),
  	  node = d3.scale.ordinal()
  	      .range(["#deebf7","#9ecae1","#3182bd"]),
  	  service = d3.scale.ordinal()
  	      .range(["#fee0d2","#fc9272","#de2d26"]),
  	  element = d3.scale.ordinal()
  	      .range(["#e5f5e0","#a1d99b","#31a354"]),
  	  role = d3.scale.ordinal()
  	      .range(["#fee6ce","#fdae6b","#e6550d"]),
  	  greys = d3.scale.ordinal()
  	      .range(["#ffffff","#f0f0f0","#d9d9d9","#bdbdbd","#969696","#737373","#525252","#252525","#000000"]);
  	      
  var sunburst_triggered = d3.select("#starburst-triggered").append("svg:svg")
        .attr("width", diameter)
        .attr("height", diameter)
      .append("svg:g")
        .attr("transform", "translate(" + diameter / 2 + "," + diameter /2 + ")"),
      sunburst_triggers = d3.select("#starburst-triggers").append("svg:svg")
        .attr("width", diameter)
        .attr("height", diameter)
      .append("svg:g")
        .attr("transform", "translate(" + diameter / 2 + "," + diameter /2 + ")");

  var partition = d3.layout.partition()
        .sort(null)
        .size([2 * Math.PI, (diameter / 2) * (diameter / 2)])
        .value(function(d) { return d.value ? d.value : 6 - d.depth; });
      arc = d3.svg.arc()
        .startAngle(function(d) { return d.x; })
        .endAngle(function(d) { return d.x + d.dx; })
        .innerRadius(function(d) { return Math.sqrt(d.y); })
        .outerRadius(function(d) { return Math.sqrt(d.y + d.dy); });
  
  d3.json(pathname + "/triggered_by.json", function(root) {  
   var svg = sunburst_triggers.data(d3.entries(root)).selectAll("g")
          .data(partition.nodes(root))
        .enter().append("svg:g")
          .attr("display", function(d) { return d.depth ? null : "none"; }); // hide inner ring
          
    svg.append("svg:path")
       .attr("d", arc)
       .attr("stroke", "#ddd")
       .style("fill", function(d) { return color(d.type)(d.name); })
       .attr("fill-rule", "evenodd");
    
  });
  
  d3.json(pathname + "/triggers.json", function(error, root) {  
    var svg = sunburst_triggers.data(d3.entries(root)).selectAll("g")
          .data(partition.nodes(root))
        .enter().append("svg:g")
          .attr("display", function(d) { return d.depth ? null : "none"; }); // hide inner ring
          
    svg.append("svg:path")
       .attr("d", arc)
       .attr("stroke", function(d) { return d.depth ? "#fff" : "#ddd"; })
       .style("fill", function(d) { return d.depth ? color(d.type)(d.name) : "#fff"; })
       .attr("fill-rule", "evenodd");
  });
  
  d3.select(self.frameElement).style("height", diameter + "px");
  
  // Vary the color based on the type
  function color(d) {
    switch(d) {
      case "Node":
        retval = node
        break;
      case "Pool":
        retval = pool
        break;
      case "Service":
        retval = service
        break;
      case "Role":
        retval = role
        break;
      case "Element":
        retval = element;
        break;
      default:
        retval = greys;
    };
    return retval;
  }; 
});
