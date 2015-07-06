path = require 'path-extra'
{React, ReactBootstrap, $} = window
{Grid, Row, Col, ButtonGroup, DropdownButton, MenuItem} = ReactBootstrap

Chart = require '../assets/Chart'

toDateLabel = (datetime) ->
  date = new Date(datetime)
  "#{date.getFullYear()}/#{date.getMonth() + 1}/#{date.getDate()}-#{date.getHours()}"
toDateString = (datetime)->
  date = new Date(datetime)
  "#{date.getFullYear()}/#{date.getMonth() + 1}/#{date.getDate()}"

AkashicResourceChart = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
    showScale: "天"
    showRange: "最近一周"
  showAsDay: true
  showRange: 7
  showScaleChange: false
  resourceChart: null
  wholeDataLength: 0
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
  dataFilter: (data)->
    dateString = ""
    showAsDay = @showAsDay
    dayBegin = (new Date()).getTime() - 86400000 * @showRange
    data.filter (item)->
      if item[0] <= dayBegin
        false
      else if showAsDay
        tmp = toDateString item[0]
        if tmp isnt dateString
          dateString = tmp
          true
        else
          false
      else
        true
  componentDidMount: ->
    console.log "map init"
  componentDidUpdate: ->
    if @resourceChart is null and @props.mapShowFlag
      ctx = document.getElementById("myChart").getContext("2d")
      Chart.defaults.global.responsive = true
      @resourceChart = new Chart(ctx).Line(@data)
      _data = @dataFilter @props.data
      @dataLength = _data.length
      @wholeDataLength = @props.data.length
      _data.reverse()
      @resourceChart.options.animation = false
      for log in _data
        @resourceChart.addData(log[1..9], toDateLabel(log[0]))
      @resourceChart.options.animation = true
      console.log "map create"
  shouldComponentUpdate: (nextProps, nextState)->
    if @resourceChart is null
      true
    else if nextState.showRange isnt @state.showRange or nextState.showScale isnt @state.showScale
      _data = @dataFilter @props.data
      _data.reverse()
      @resourceChart.options.animation = false
      for item in [0..@dataLength-1]
        @resourceChart.removeData()
      for log in _data
        @resourceChart.addData(log[1..9], toDateLabel(log[0]))
      @resourceChart.options.animation = true
      @dataLength = _data.length
      @wholeDataLength =  @props.data.length
      false
    else if nextProps.data.length > @wholeDataLength
      if @wholeDataLength > 0
        dateString = toDateString nextProps.data[nextProps.data.length-@wholeDataLength][0]
      else 
        dateString = ""
      for i in [nextProps.data.length-@wholeDataLength-1..0]
        if not @showAsDay
          @resourceChart.addData(nextProps.data[i][1..9], toDateLabel(nextProps.data[i][0]))
        else
          tmp = toDateString nextProps.data[i][0]
          if dateString isnt tmp
            dateString = tmp
            @resourceChart.addData(nextProps.data[i][1..9], toDateLabel(nextProps.data[i][0]))
      @dataLength = @dataLength + nextProps.data.length - @wholeDataLength
      @wholeDataLength = nextProps.data.length
      false
    else 
      false
  handleShowScaleSelect: (selectKey)->
    showScale = "天"
    if selectKey is 0
      showScale = "小时"
      @showAsDay = false
    else
      @showAsDay = true
    if showScale isnt @state.showScale
      showScaleChange = true
    @setState
      showScale: showScale
  handleShowRangeSelect: (selectKey)->
    @showRange = selectKey
    showRange = "最近一周"
    switch selectKey
      when 1
        showRange = "最近一天"
      when 30
        showRange = "最近一月"
      when 90
        showRange = "最近三月"
      when 9999
        showRange = "显示全部"
    if showRange isnt @state.showRange
      showScaleChange = true
    @setState
      showRange: showRange
  render: ->
    <Grid>
      <Row>
        <Col xs={2}>
          <ButtonGroup justified>
            <DropdownButton center eventKey={4} title={"时间粒度"} block>
              <MenuItem center eventKey={0} onSelect={@handleShowScaleSelect}>{"按小时显示"}</MenuItem>
              <MenuItem eventKey={1} onSelect={@handleShowScaleSelect}>{"按天显示"}</MenuItem>
            </DropdownButton>
          </ButtonGroup>
        </Col>
        <Col xs={2}>
          <ButtonGroup justified>
            <DropdownButton center eventKey={4} title={"时间范围"} block>
              <MenuItem center eventKey={1} onSelect={@handleShowRangeSelect}>{"最近一天"}</MenuItem>
              <MenuItem eventKey={7} onSelect={@handleShowRangeSelect}>{"最近一周"}</MenuItem>
              <MenuItem eventKey={30} onSelect={@handleShowRangeSelect}>{"最近一月"}</MenuItem>
              <MenuItem eventKey={90} onSelect={@handleShowRangeSelect}>{"最近三月"}</MenuItem>
              <MenuItem divider />
              <MenuItem eventKey={9999} onSelect={@handleShowRangeSelect}>{"全部显示"}</MenuItem>
            </DropdownButton>
          </ButtonGroup>
        </Col>
        <Col xs={12}>
           <canvas id="myChart" width={400} height={250}></canvas>
        </Col>
      </Row>
    </Grid>

module.exports = AkashicResourceChart
