path = require 'path-extra'
{React, ReactBootstrap, $} = window
{Grid, Row, Col, ButtonGroup, DropdownButton, MenuItem} = ReactBootstrap

Chart = require '../assets/Chart'

toDateLabel = (datetime) ->
  date = new Date(datetime)
  "#{date.getFullYear()}/#{date.getMonth()}/#{date.getDate()}-#{date.getHours()}"

AkashicResourceChart = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
    showScale: "天"
    showRange: "最近一周"
  resourceChart: null
  dataLength: 0
  data:
    labels: [],
    datasets: [
      {
        label: "燃",
        fillColor: "rgba(27,154,25,0.2)",
        strokeColor: "rgba(27,154,25,1)",
        pointColor: "rgba(27,154,25,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(27,154,25,1)",
        data: []
      },
      {
        label: "弹",
        fillColor: "rgba(102,57,16,0.2)",
        strokeColor: "rgba(102,57,16,1)",
        pointColor: "rgba(102,57,16,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(102,57,16,1)",
        data: []
      },
      {
        label: "钢",
        fillColor: "rgba(145,145,145,0.2)",
        strokeColor: "rgba(145,145,145,1)",
        pointColor: "rgba(145,145,145,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(145,145,145,1)",
        data: []
      },
      {
        label: "铝",
        fillColor: "rgba(179,124,80,0.2)",
        strokeColor: "rgba(179,124,80,1)",
        pointColor: "rgba(179,124,80,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(179,124,80,1)",
        data: []
      },
      {
        label: "高速建造",
        fillColor: "rgba(251,138,0,0.2)",
        strokeColor: "rgba(251,138,0,1)",
        pointColor: "rgba(251,138,0,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(251,138,0,1)",
        data: []
      },
      {
        label: "高速修复",
        fillColor: "rgba(50,236,161,0.2)",
        strokeColor: "rgba(50,236,161,1)",
        pointColor: "rgba(50,236,161,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(50,236,161,1)",
        data: []
      },
      {
        label: "资材",
        fillColor: "rgba(65,155,169,0.2)",
        strokeColor: "rgba(65,155,169,1)",
        pointColor: "rgba(65,155,169,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(65,155,169,1)",
        data: []
      },
      {
        label: "螺丝",
        fillColor: "rgba(170,170,170,0.2)",
        strokeColor: "rgba(170,170,170,1)",
        pointColor: "rgba(170,170,170,1)",
        pointStrokeColor: "#fff",
        pointHighlightFill: "#fff",
        pointHighlightStroke: "rgba(170,170,170,1)",
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
      _data = JSON.parse JSON.stringify @props.data
      @dataLength = _data.length
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
    else if nextProps.data.length > @dataLength
      for i in [nextProps.data.length-@dataLength-1..0]
        @resourceChart.addData(nextProps.data[i][1..9], toDateLabel(nextProps.data[i][0]))
      @dataLength = nextProps.data.length
      @resourceChart.update
      console.log "map data update"
      false
    else 
      false
  handleShowScaleSelect: (selectKey)->

  handleShowRangeSelect: (selectKey)->

  render: ->
    <Grid>
      <Row>
        <Col xs={2}>
          <ButtonGroup justified>
            <DropdownButton center eventKey={4} title={"按#{@state.showScale}显示"} block>
              <MenuItem center eventKey=0 onSelect={@handleShowScaleSelect}>{"按小时显示"}</MenuItem>
              <MenuItem eventKey=1 onSelect={@handleShowScaleSelect}>{"按天显示"}</MenuItem>
            </DropdownButton>
          </ButtonGroup>
        </Col>
        <Col xs={2}>
          <ButtonGroup justified>
            <DropdownButton center eventKey={4} title={"#{@state.showRange}"} block>
              <MenuItem center eventKey=0 onSelect={@handleShowRangeSelect}>{"最近一天"}</MenuItem>
              <MenuItem eventKey=1 onSelect={@handleShowRangeSelect}>{"最近一周"}</MenuItem>
              <MenuItem eventKey=2 onSelect={@handleShowRangeSelect}>{"最近一月"}</MenuItem>
              <MenuItem eventKey=3 onSelect={@handleShowRangeSelect}>{"最近三月"}</MenuItem>
              <MenuItem divider />
              <MenuItem eventKey=4 onSelect={@handleShowRangeSelect}>{"全部显示"}</MenuItem>
            </DropdownButton>
          </ButtonGroup>
        </Col>
        <Col xs={12}>
           <canvas id="myChart" width={400} height={250}></canvas>
        </Col>
      </Row>
    </Grid>

module.exports = AkashicResourceChart
