//$('form').on('submit', function(e){
//    e.preventDefault();

    var d = {};
    jQuery.map($('form').serializeArray(), function(n, i){
        d[n['name']] = n['value'];
    });

    var data = calculate(d);
    var graph = calculateGraphs(d);


    var $o = $('#output').show();

    _.forEach(data, function(v,k){
        $o.find('[data-value=' + k + ']').text(v);
    });

    var vs = _.values(graph.graphWarpOccupancyOfThreadsPerBlock.current)
    var gd1 = {
        current: {
            key: vs[0],
            value: vs[1]
        }
    };

    gd1.data = _.map(graph.graphWarpOccupancyOfThreadsPerBlock.data, function(v){
        var vs = _.values(v);
        return {
            key: vs[0],
            value: vs[1]
        }
    });

    var gd2 = _.map(graph.graphWarpOccupancyOfRegistersPerThread, function(v){
        var vs = _.values(v)
        return {
            key: vs[0],
            value: vs[1]
        }
    });


    var gd3 = _.map(graph.graphWarpOccupancyOfSharedMemoryPerBlock, function(v){
        var vs = _.values(v)
        return {
            key: vs[0],
            value: vs[1]
        }
    });

    $o.find('svg').remove();
    var f = $o.find('figure')
    drawGraph(gd1, f[0]);
    // drawGraph(gd2, f[1]);
    // drawGraph(gd3, f[2]);

//})