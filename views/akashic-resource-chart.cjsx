path = require 'path-extra'
{React, $} = window

Chart = require '../assets/Chart'

toDateLabel = (datetime) ->
  date = new Date(datetime)
  "#{date.getFullYear()}/#{date.getMonth()}/#{date.getDate()}-#{date.getHours()}"
AkashicResourceChart = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
  resourceChart: null
  data:
    labels: [],
    datasets: [
      {
        label: "燃",
        fillColor: "rgba(200,0,0,0.2)",
        strokeColor: "rgba(200,0,0,1)",
        pointColor: "rgba(200,0,0,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(200,0,0,1)",
        data: []
      },
      {
        label: "弹",
        fillColor: "rgba(0,187,0,0.2)",
        strokeColor: "rgba(0,187,0,1)",
        pointColor: "rgba(0,187,0,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(0,187,0,1)",
        data: []
      },
      {
        label: "钢",
        fillColor: "rgba(0,0,205,0.2)",
        strokeColor: "rgba(0,0,205,1)",
        pointColor: "rgba(0,0,205,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(0,0,205,1)",
        data: []
      },
      {
        label: "铝",
        fillColor: "rgba(151,187,0,0.2)",
        strokeColor: "rgba(151,187,0,1)",
        pointColor: "rgba(151,187,0,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(151,187,0,1)",
        data: []
      },
      {
        label: "高速建造",
        fillColor: "rgba(151,0,205,0.2)",
        strokeColor: "rgba(151,0,205,1)",
        pointColor: "rgba(151,0,205,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(151,0,205,1)",
        data: []
      },
      {
        label: "高速修复",
        fillColor: "rgba(0,187,205,0.2)",
        strokeColor: "rgba(0,187,205,1)",
        pointColor: "rgba(0,187,205,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(0,187,205,1)",
        data: []
      },
      {
        label: "资材",
        fillColor: "rgba(151,187,205,0.2)",
        strokeColor: "rgba(151,187,205,1)",
        pointColor: "rgba(151,187,205,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(151,187,205,1)",
        data: []
      },
      {
        label: "螺丝",
        fillColor: "rgba(10,10,10,0.2)",
        strokeColor: "rgba(10,10,10,1)",
        pointColor: "rgba(10,10,10,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(10,10,10,1)",
        data: []
      }
    ]
  componentDidMount: ->
    console.log "map init"
  componentDidUpdate: ->
    if @resourceChart is null and @props.mapShowFlag
      ctx = document.getElementById("myChart").getContext("2d")
      Chart.defaults.global.responsive = true
      @resourceChart = new Chart(ctx).Line(@data)
      _data = @props.data
      _data.reverse()
      for log in _data
        @resourceChart.addData(log[1..9], toDateLabel(log[0]))
      @resourceChart.update
      console.log "map create"
    console.log "map update"
  shouldComponentUpdate: (nextProps, nextState)->
    console.log "in shouldComponentUpdate"
    if @resourceChart is null
      true
    else if nextProps.data.length > @props.data.length
      for i in [nextProps.data.length-@props.data.length-1..0]
        @resourceChart.addData(nextProps.data[i][1..9], toDateLabel(nextProps.data[i][0]))
      @resourceChart.update
      console.log "map data update"
      false
    else 
      false
  render: ->
    <div>
      <canvas id="myChart" width={400} height={400}></canvas>
    </div>

module.exports = AkashicResourceChart
