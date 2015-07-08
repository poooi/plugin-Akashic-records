path = require 'path-extra'
{React, ReactBootstrap, $, err, config, ROOT} = window
{Grid, Row, Col, ButtonGroup, DropdownButton, MenuItem} = ReactBootstrap
{error} = require path.join(ROOT, 'lib/utils')

require '../assets/echarts-all'
dark = require '../assets/themes/dark'
macarons = require '../assets/themes/macarons'

toDateLabel = (datetime) ->
  date = new Date(datetime)
  month = date.getMonth()+1
  if month < 10
    month = "0#{month}"
  day = date.getDate()
  if day < 10
    day = "0#{day}"
  hour = date.getHours()
  if hour < 10
    hour = "0#{hour}"
  minute = date.getMinutes()
  if minute < 10
    minute = "0#{minute}"
  "#{date.getFullYear()}-#{month}-#{day} #{hour}:#{minute}"
  
toDateString = (datetime)->
  date = new Date(datetime)
  "#{date.getFullYear()}/#{date.getMonth() + 1}/#{date.getDate()}"

AkashicResourceChart = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
  showAsDay: true
  showAllSymbol: false
  sleepMode: false
  resourceChart: 0
  wholeDataLength: 0
  dataLength: 0
  showData: []
  componentWillMount: ->
    @showAsDay = config.get "plugin.Akashic.resource.chart.showAsDay", true
    @showAllSymbol = config.get "plugin.Akashic.resource.chart.showAllSymbol", false
    @sleepMode = config.get "plugin.Akashic.resource.chart.sleepMode", true
  dataFilter: (data)->
    dateString = ""
    showAsDay = @showAsDay
    data.filter (item)->
      if showAsDay
        tmp = toDateString item[0]
        if tmp isnt dateString
          dateString = tmp
          true
        else
          false
      else
        true
  getEChartsOption: ->
    option = 
      tooltip:
        trigger: "item"
        show: true
        formatter : (params) ->
          dateTime = params.value[0]
          dateString = toDateLabel params.value[0]
          series = @getSeries()
          index = -1
          logdata = [dateTime]
          for item in series
            data = item.data
            if index is -1
              if data[params.value[2]]?[0] is logdata[0]
                index = params.value[2]
              else
                findFlag = false
                for item, i in data
                  if item[0] is logdata[0]
                    findFlag = true
                    index = i
                    break
                if not findFlag
                  error "can't find matched data! in ECharts's tooltip formatter()"
            logdata.push data[index][1]
            if logdata[0] isnt data[index][0]
              error "data error! in ECharts's tooltip formatter()"
          showString = "#{dateString}<br/>燃: #{logdata[1]}<br/>弹: #{logdata[2]}<br/>钢: #{logdata[3]}<br/>铝: #{logdata[4]}<br/>高速建造: #{logdata[5]}<br/>高速修复: #{logdata[6]}<br/>资材: #{logdata[7]}<br/>螺丝: #{logdata[8]}"
      legend: 
        data:['燃', '弹', '钢', '铝', '高速建造', '高速修复', '资材', '螺丝']
      toolbox:
        show: true
        feature:
          dataView: 
            show: false
            readOnly: true
          restore:
            show: true
          saveAsImage:
            show: true
          showScale: ((showAsDay)->
            if showAsDay
              title = '按天显示'
              icon = './assets/echarts-day.png'
            else 
              title = '按小时显示'
              icon = './assets/echarts-hour.png'
            showScale = 
              show: true
              title: title
              icon: icon
              onclick: ()->
                event = new CustomEvent 'plugin.Akashic.resource.chart.changeShowScale',
                  bubbles: true
                  cancelable: true
                window.dispatchEvent event
            )(@showAsDay)
          showType: ((showAllSymbol)->
            if showAllSymbol
              title = '显示节点'
              icon = './assets/echarts-with-node.png'
            else
              title = '隐藏节点'
              icon = './assets/echarts-no-node.png'
            showType = 
              show: true
              title: title
              icon: icon
              onclick: ()->
                event = new CustomEvent 'plugin.Akashic.resource.chart.changeShowNode',
                  bubbles: true
                  cancelable: true
                window.dispatchEvent event
            )(@showAllSymbol)
          themeMode: ((sleepMode)->
            if sleepMode
              title = '睡眠模式'
              icon = './assets/echarts-moon.png'
            else
              title = '日光模式'
              icon = './assets/echarts-sun.png'
            showType = 
              show: true
              title: title
              icon: icon
              onclick: ()->
                event = new CustomEvent 'plugin.Akashic.resource.chart.changeThemeMode',
                  bubbles: true
                  cancelable: true
                window.dispatchEvent event
            )(@sleepMode)
      dataZoom:
        show: true
        realtime: true
      xAxis: ((sleepMode)->
        xAxis = []
        if sleepMode
          labelColor = '#ddd'
          splitColor = '#505050'
        else
          labelColor = '#333'
          splitColor = '#eee'
        item = 
          type: 'time'
          splitNumber: 10
          axisLabel:
            textStyle:
              color: labelColor
          splitLine:
            lineStyle:
              color: splitColor
        xAxis.push item
        xAxis)(@sleepMode)
      yAxis: ((sleepMode)->
        yAxis = []
        if sleepMode
          labelColor = '#ddd'
          splitColor = '#505050'
        else
          labelColor = '#333'
          splitColor = '#eee'
        item = 
          type: 'value'
          axisLine:
            lineStyle:
              color: '#eee'
              width: 0
          axisLabel:
            textStyle:
              color: labelColor
          splitLine:
            lineStyle:
              color: splitColor
        yAxis.push item
        yAxis.push JSON.parse JSON.stringify item
        yAxis)(@sleepMode)
      series:[
        {name:"燃"
        type:"line"
        yAxisIndex: 0
        itemStyle:
          normal:
            color: "#1b9d19"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[1], index]
          data
          )(@showData)},
        {name:"弹"
        type:"line"
        yAxisIndex: 0
        itemStyle:
          normal:
            color: "#663910"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[2], index]
          data
          )(@showData)},
        {name:"钢"
        type:"line"
        yAxisIndex: 0
        itemStyle:
          normal:
            color: "#919191"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[3], index]
          data
          )(@showData)},
        {name:"铝"
        type:"line"
        yAxisIndex: 0
        itemStyle:
          normal:
            color: "#b37c50"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[4], index]
          data
          )(@showData)},
        {name:"高速建造"
        type:"line"
        yAxisIndex: 1
        itemStyle:
          normal:
            color: "#fb8a00"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[5], index]
          data
          )(@showData)},
        {name:"高速修复"
        type:"line"
        yAxisIndex: 1
        itemStyle:
          normal:
            color: "#32eca1"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[6], index]
          data
          )(@showData)},
        {name:"资材"
        type:"line"
        yAxisIndex: 1
        itemStyle:
          normal:
            color: "#419ba9"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[7], index]
          data
          )(@showData)},
        {name:"螺丝"
        type:"line"
        yAxisIndex: 1
        itemStyle:
          normal:
            color: "#aaaaaa"
        showAllSymbol: @showAllSymbol
        data:( (showData)->
          data = []
          for logitem, index in showData
            data.push [logitem[0], logitem[8], index]
          data
          )(@showData)}]

  renderChart: ->
    node = @refs.chart.getDOMNode()
    if @sleepMode
      theme = dark
    else
      theme = macarons
    @resourceChart = @resourceChart || echarts.init node, theme
    option = @getEChartsOption()
    @resourceChart.setOption option
  componentDidMount: ->
    window.addEventListener 'plugin.Akashic.resource.chart.changeShowScale', @handleShowScaleChange
    window.addEventListener 'plugin.Akashic.resource.chart.changeShowNode', @handleShowNodeChange
    window.addEventListener 'plugin.Akashic.resource.chart.changeThemeMode', @handleThemeModeChange
  componentDidUpdate: ->
    if  @resourceChart is 0 and @props.mapShowFlag
      @showData = @dataFilter @props.data
      @dataLength = @showData.length
      @showData.reverse()
      @wholeDataLength = @props.data.length
      @renderChart()
  shouldComponentUpdate: (nextProps, nextState)->
    if @resourceChart is 0
      true
    else if nextProps.data.length > @wholeDataLength
      if @wholeDataLength > 0
        dateString = toDateString nextProps.data[nextProps.data.length-@wholeDataLength][0]
      else 
        dateString = ""
      if @resourceChart.getSeries()?
        if not @showAsDay
          for i in [nextProps.data.length-@wholeDataLength-1..0]
            @showData.push nextProps.data[i]
            dataitem = []
            for item, j in nextProps.data[i]
              continue if j is 0
              dataitem.push [j-1, [nextProps.data[i][0], item, @showData.length-1], false, true, '']
            @resourceChart.addData dataitem
        else
          for i in [nextProps.data.length-@wholeDataLength-1..0]
            tmp = toDateString nextProps.data[i][0]
            if dateString isnt tmp
              dateString = tmp
              @showData.push nextProps.data[i]
              dataitem = []
              for item, j in nextProps.data[i]
                continue if j is 0
                dataitem.push [j-1, [nextProps.data[i][0], item, @showData.length-1], false, true, '']
              @resourceChart.addData dataitem
      else
        @showData = @dataFilter nextProps.data
        @dataLength = @showData.length
        @showData.reverse()
        if @showData.length isnt 0
          @resourceChart.hideLoading()
          @resourceChart.setOption @getEChartsOption(), true
      @dataLength = @showData.length
      @wholeDataLength = nextProps.data.length
      false
    else 
      false
  handleShowScaleChange: ->
    @showAsDay = not @showAsDay
    @showData = @dataFilter @props.data
    @dataLength = @showData.length
    @showData.reverse()
    if @showData.length isnt 0
      if not @resourceChart.getSeries()? 
        @resourceChart.hideLoading()
      @resourceChart.setOption @getEChartsOption(), true
    config.set "plugin.Akashic.resource.chart.showAsDay", @showAsDay
  handleShowNodeChange: ->
    @showAllSymbol = not @showAllSymbol
    @resourceChart.setOption @getEChartsOption(), true
    config.set "plugin.Akashic.resource.chart.showAllSymbol", @showAllSymbol
  handleThemeModeChange: ->
    @sleepMode = not @sleepMode
    if @sleepMode
      @resourceChart.setTheme dark
    else 
      @resourceChart.setTheme macarons
    @resourceChart.setOption @getEChartsOption(), true
    config.set "plugin.Akashic.resource.chart.sleepMode", @sleepMode
  render: ->
    <Grid>
      <Row>
        <Col xs={12}>
           <div id="ECharts" style={height: "500px"} ref="chart"></div>
        </Col>
      </Row>
    </Grid>

module.exports = AkashicResourceChart
