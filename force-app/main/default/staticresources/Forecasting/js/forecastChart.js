(function($) {
    var chart = { chartRef:{}, rawData:{}, dataTable:{}, options:{}, event:{}, isShorFormat:true };

    var queryParams = { userId:'',userName:'', quarter:'', includeweekly:true };

    var config = { format:'M' };
    
    var initParams = function() {
        var urlParams;

        var getUrlParam = function(name) {
            if(!urlParams) {
                var url = window.location.href;
                urlParams = urlToMap(url);
            }
            return urlParams[name];
        };

        var urlToMap = function(url) {
            var arrOfUrl = url.split('?');
            if(arrOfUrl && arrOfUrl.length == 2) {
               var params = {};
               var arrOfRawParams = arrOfUrl[1].split('&');
               for(var i=0 ; i < arrOfRawParams.length ; i ++) {
                    var paramKeyValue = arrOfRawParams[i].split('=');
                    if(paramKeyValue && paramKeyValue.length == 2) {
                      params[paramKeyValue[0]] = paramKeyValue[1];
                    }
                }
                return params;
            } else { 
                return {}; 
            }
        };

        queryParams.userId = getUrlParam("userId");
        queryParams.userName = decodeURI(getUrlParam("userName"));
        queryParams.quarter = getUrlParam("quarter");
    };
                
    var getCleanNumber = function(num) {
        return (!!num) ? num : null;
    };

    var commaFormatted = function(amount) {
        var delimiter = ","; // replace comma if desired
        var a = amount.split('.',2)
        var d = (a.length > 1)? a[1] : '';
        var i = parseInt(a[0]);
        if(isNaN(i)) { 
            return ''; 
        }
        var minus = '';
        if(i < 0) { 
            minus = '-'; 
        }
        i = Math.abs(i);
        var n = new String(i);
        var a = [];
        while(n.length > 3) {
            var nn = n.substr(n.length-3);
            a.unshift(nn);
            n = n.substr(0,n.length-3);
        }
        if(n.length > 0) { 
            a.unshift(n); 
        }
        n = a.join(delimiter);
        if(d.length < 1) { 
            amount = n; 
        } else { 
            amount = n + '.' + d; 
        }
        amount = minus + amount;
        return amount;
    };
        
    var formatDecimal = function(value, format) {
        if(value == null) {
            return null;
        } else if(value == 0) {
            return "0";
        } else if(format == "E") {
            //exact value, 2 decimals
            return "$" + commaFormatted(((value)/1).toFixed(2));
        } else if(format == "W") {
            //whole values, 0 decimals
            return "$" + commaFormatted(((value)/1).toFixed(0));
        } else if(format == "K") {
            //thousand, with 2 decimals
            var result = "$" + commaFormatted(((value)/1000).toFixed(2)) + "K";
            return result.replace(".00K", "K");
        } else if(format == "M") {
            //million, with 2 decimals
            var result = "$" + commaFormatted(((value)/1000/1000).toFixed(2)) + "M";
            return result.replace(".00M", "M");
        }
        return "";
    };

    //$($($("svg>g")[2]).children()[2]).children()  get all points <circle>
    //$($($("svg>g")[2]).children()[4]).children()  get all annotations main node , >g>g>text

    var isCoveredBy = function(x, y) {//y == x or 0 < y - x < 17 return true : x covered by y
        if(x && y) {
            if(x == y) {
                return true;
            } else if(-17 < x -y && x - y < 17) {
                return true;
            } else {
                return false;
            }
        } else { 
            return true;
        }
    };

    var convertToTable = function(data, annotationsArr) {
        var table = [];
        var row = [];
        var finalTable = [];
        if(data)
        {
         var labels = ["WeeklyActual", "QtrBooking", "QtrCommit", "QtrGut", "QtrUpside"];
           for(var label = 0 ; label < labels.length ; label ++)
           {
             var labelStr = labels[label];
             for(var week = 0 ; week < data.length ; week ++)
             {  
                var weekSummary = data[week];
                var v = getCleanNumber(weekSummary[labelStr]);
                if(v != null){ row.push(v); }
              }
             if(row.length > 0){ table.push(row); row = []; }
            }
            var annotationLoc = 0;
            for(var i = 0 ; i < table.length ; i ++)
            {
               var finalRow = [];
               for(var j = 0 ; j < table[i].length ; j ++)
               {
                 finalRow.push(annotationsArr[annotationLoc]);
                 if(annotationLoc < annotationsArr.length - 1){ annotationLoc ++; }
               }
               if(finalRow.length > 0 ){ finalTable.push(finalRow); finalRow = [];}
            }
        }
       return finalTable;
    };

    var fixAnnotationPositions = function (){
    //var pointsArr = $($($("svg>g")[2]).children()[2]).children();
        var annotationsArr = $($($("svg>g")[2]).children()[4]).children();
        var annotationsTable = convertToTable(chart.rawData, annotationsArr);
        var minColNum = 0;
        for(var i = 0 ; i < annotationsTable.length ; i ++) {
            if(i==0) { 
                minColNum = annotationsTable[i].length;
            } else {
                minColNum = (annotationsTable[i] < minColNum) ? annotationsTable[i] : minColNum;
            }
        }
        for(var j = 0; j < minColNum; j++) {
            for(var m = 0; m < annotationsTable.length; m++)  {
                if(m != 0) {
                    var preLoc = Number.parseFloat($(  $( (annotationsTable[m-1])[j] ).find("text")[0]  ).attr("y"));
                    var currLoc = Number.parseFloat($($( (annotationsTable[m])[j] ).find("text")[0] ).attr("y"));
                    if(isCoveredBy(preLoc, currLoc)) {
                        currLoc = (preLoc > currLoc) ? preLoc - 16 : preLoc + 16;
                        $($( (annotationsTable[m])[j] ).find("text")[1]).attr("y", currLoc);
                        $($( (annotationsTable[m])[j] ).find("text")[0]).attr("y", currLoc);
                        //m = (m+2 > annotationsTable.length) ? m + 1 : m +2;
                    }
                }
            }
        }
    };

    var convertSummaryToChart = function() {
       if(chart.rawData && google) {//, role:"annotation"
            chart.dataTable = new google.visualization.DataTable();
            chart.dataTable.addColumn({ type: "string", label: "Weeks" });
            chart.dataTable.addColumn({ type: "number", label: "Weekly Actual" });
            chart.dataTable.addColumn({ type: "number", role: "annotation" });
            chart.dataTable.addColumn({ type: "number", label:"CQ Booking" });
            chart.dataTable.addColumn({ type: "number", role: "annotation" });
            chart.dataTable.addColumn({ type: "number", label: "CQ Commit" });
            chart.dataTable.addColumn({ type: "number", role: "annotation" });
            chart.dataTable.addColumn({ type: "number", label: "CQ Gut" });
            chart.dataTable.addColumn({ type: "number", role: "annotation" });
            chart.dataTable.addColumn({ type: "number", label: "CQ Upside" });
            chart.dataTable.addColumn({ type: "number", role: "annotation" });
            for(var weekNum = 0 ; weekNum < chart.rawData.length ; weekNum ++) {
                var weeklySummary = chart.rawData[weekNum]; //config
                var rowValues = [];
                //rowValues.push(formatDecimal(getCleanNumber(weeklySummary["WeeklyActual"]), config.format));
                rowValues.push("Week " + (weekNum+1));
                rowValues.push(getCleanNumber(weeklySummary["WeeklyActual"]));
                rowValues.push(getCleanNumber(weeklySummary["WeeklyActual"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrBooking"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrBooking"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrCommit"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrCommit"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrGut"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrGut"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrUpside"]));
                rowValues.push(getCleanNumber(weeklySummary["QtrUpside"]));
                chart.dataTable.addRow(rowValues);
            }
            if(chart.isShorFormat) {
                var formatter = new google.visualization.NumberFormat({ prefix: '$', pattern: 'short' });
                formatter.format(chart.dataTable, 2);
                formatter.format(chart.dataTable, 4);
                formatter.format(chart.dataTable, 6);
                formatter.format(chart.dataTable, 8);
                formatter.format(chart.dataTable, 10);
            }
        }
    };

    var buildTitle = function(){
        var mainTitle = "Forecast Summary"; 
        if(queryParams.quarter && queryParams.userName) {
            var fyfq = queryParams.quarter.split("Q");
            if(!!fyfq == false) { 
                fyfq = queryParams.quarter.split("q"); 
            }
            if(fyfq && fyfq.length == 2) {
                mainTitle = "Q" + fyfq[1] + " FY" + fyfq[0].substr(-2) + " "+ mainTitle + " - " + queryParams.userName;
            }
        }
        return mainTitle;
    };

    var buildVaixs = function(){
        var ticks = [];
        var base = 0;
        while(base <= 90000000) {
            ticks.push(base);
            base += 250000;
        }
        return ticks;
    };


    var buildOption = function() {
        chart.options = {
            title: buildTitle(),
            legend: { position: 'bottom' },
            vAxis: {
                format: getFormat()
            },
            height: 600,
            logscale : true,
            seriesType: 'bars',
            series: {
                0: { color: 'cornflowerblue', pointSize: 5 },
                1: { type: 'line', color: 'lightskyblue', pointSize: 5 },
                2: { type: 'line', color: 'salmon', pointSize: 5 },
                3: { type: 'line', color: 'darkgrey', pointSize: 5 },
                4: { type: 'line', color: 'orange', pointSize: 5 }
            },
            annotations: {
                datum: {
                    stem: { color: 'red', length: 0 }
                }
            }
        };
    };
        
    var setTitleCentr = function() {
        var titleOrigWidth = $("svg>g").first().children().last().attr("width");
        $("svg>g").first().children().first().attr("x", titleOrigWidth / 2);
    };

    var getFormat = function() {
        return (chart.isShorFormat)? 'short': null;
    };

    var changeFormat = function() {
       if(chart.isShorFormat) {
          chart.isShorFormat = false;
       } else {
          chart.isShorFormat  = true;
       }
       drawChart();
    };

    var drawChart = function() {
       convertSummaryToChart();
       buildOption();

       var chartDiv = document.getElementById('forcastChart');
       chart.chartRef = new google.visualization.ComboChart(chartDiv);
       $("#loading").hide();
       
       if(chart.isShorFormat) {
            google.visualization.events.addListener(chart.chartRef, 'ready', function() {
                var axisLabels = chartDiv.getElementsByTagName('text');
                for (var i = 0; i < axisLabels.length; i++) {
                    if (axisLabels[i].getAttribute('text-anchor') === 'end') {
                        axisLabels[i].innerHTML = '$' + axisLabels[i].innerHTML;
                    }
                }
            });
        }
        chart.chartRef.draw(chart.dataTable, chart.options);
        setTitleCentr();
        fixAnnotationPositions();
        $("#toolBar").show();
    };

    var loadChartData = function() {
        //Visualforce.remoting.Manager.invokeAction('{!$RemoteAction.ForecastingStatsService.GetForecastSummary}', 
        Visualforce.remoting.Manager.invokeAction('ForecastingStatsService.GetForecastSummary',
                                                    queryParams.userId, queryParams.quarter, queryParams.includeweekly, 
                                                    function(result, event) {
            if(event.status && result) {
                chart.rawData = result.WeeklyForecasts ;
                google.charts.load('current', {'packages':['corechart']});
                google.charts.setOnLoadCallback(drawChart);
            } else {
                chart.event = event;
            }
        });
    };

    $(document).ready(function() {
        initParams();
        if(!!queryParams.userId && !!queryParams.quarter) {
            loadChartData();
        } else {
            alert("Failed to load the chart.");
        }

        $("#changeFormatBtn").click(function() {
            changeFormat();
        });
    });
})(jQuery);