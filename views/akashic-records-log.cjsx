{React, ReactBootstrap, jQuery} = window
{Grid, Col, Table} = ReactBootstrap

AkashicRecordsCheckboxArea = require './akashic-records-checkbox-area'
AkashicRecordsTableArea = require './akashic-records-table-area'

dateToString = (date)->
  month = date.getMonth() + 1
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
  second = date.getSeconds()
  if second < 10
    second = "0#{second}"
  "#{date.getFullYear()}/#{month}/#{day} #{hour}:#{minute}:#{second}"

AttackLog = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
    filterKey:['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '']
    showAmount: 10
    activePage: 0
    tabFilterVersion: 0
    filterVersion: 0
    showRulesVersion: 0
    dataShow: []
    dataAfterFilterLength: 0
  tabFilterVersion: 0
  filterVersion: 0
  showRulesVersion: 0
  dataVersion: -1
  rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
  dataAfterFilter: []
  _testFilter: (log, keyWords)->
    {rowChooseChecked} = @states
    for item, index in log
      if rowChooseChecked[index+1]
        if keyWords[index+1] isnt ''
          if index is 0
            match = dateToString(new Date(item)).toLowerCase().trim().indexOf(keyWords[index+1].toLowerCase().trim())
          else
            match = "#{item}".toLowerCase().trim().indexOf(keyWords[index+1].toLowerCase().trim()) >= 0
          if not match
            return false
    return true
  _filter: (rawData, keyWords)->
    enableFilter = false
    for item, index in @props.tableTab
      continue if index is 0
      enableFilter = true if keyWords[index] isnt ''
    if enableFilter
      rawData.filter (row)=>
        @_testFilter row, keyWords
    else rawData
  refreshDataShow: (data, filterKey, activePage, showAmount)->
    @dataAfterFilter = @_filter data, filterKey
    dataAfterFilterLength = @dataAfterFilter.length
    if dataAfterFilterLength > 0
      dataShow = @dataAfterFilter.slice((activePage -1 ) * showAmount, activePage * showAmount)
    else
      dataShow = []
    {dataShow, dataAfterFilterLength}
  componentWillMount: ->
    @rowChooseChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify @state.rowChooseChecked
    rowChooseChecked = JSON.parse JSON.stringify @rowChooseChecked
    showAmount = config.get "plugin.Akashic.#{@props.contentType}.showAmount", @state.showAmount
    @dataAfterFilter = @_filter @props.data, @state.filterKey
    dataAfterFilterLength = @dataAfterFilter.length
    if dataAfterFilterLength > 0
      dataShow = @dataAfterFilter.slice((@state.activePage-1)*showAmount, @state.activePage*showAmount)
    @setState
      rowChooseChecked: rowChooseChecked
      showAmount: showAmount
      dataAfterFilterLength: dataAfterFilterLength
      dataShow: dataShow
  componentWillReceiveProps: (nextProps)->
    if nextProps.indexKey is nextProps.selectedKey
      if @dataVersion isnt nextProps.dataVersion
        {dataShow, dataAfterFilterLength} = @refreshDataShow nextProps.data, @state.filterKey, @state.activePage, @state.showAmount
        @setState
          dataAfterFilterLength: dataAfterFilterLength
          dataShow: dataShow
  tabFilterRules: (checked) ->
    @setState
      rowChooseChecked: checked
      tabFilterVersion: @state.tabFilterVersion + 1
  filterRules: (filterKey) ->
    {dataShow, dataAfterFilterLength} = @refreshDataShow @props.data, filterKey, @state.activePage, @state.showAmount
    @setState
      filterKey: filterKey
      filterVersion: @state.filterVersion + 1
      dataAfterFilterLength: dataAfterFilterLength
      dataShow: dataShow
  showRules: (showAmount, activePage)->
    if activePage > Math.ceil(@state.dataAfterFilterLength/showAmount)
      activePage = Math.ceil(@state.dataAfterFilterLength/showAmount)
    if showAmount isnt @state.showAmount
      config.set "plugin.Akashic.#{@props.contentType}.showAmount", showAmount
    if showAmount isnt @state.showAmount or activePage isnt @state.activePage
      dataShow = @dataAfterFilter.slice((activePage -1 ) * showAmount, activePage * showAmount)
      @setState
        showAmount: showAmount
        activePage: activePage
        showRulesVersion: @state.showRulesVersion + 1
        dataShow: dataShow
  handlePageChange: (activePage)->
    if activePage isnt @state.activePage
      dataShow = @dataAfterFilter.slice((activePage -1 ) * @state.showAmount, activePage * @state.showAmount)
      @setState
        activePage: activePage
        dataShow: dataShow
  shouldComponentUpdate: (nextProps, nextState)->
    refreshFlag = false
    if nextProps.indexKey is nextProps.selectedKey
      if @dataVersion isnt nextProps.dataVersion
        refreshFlag = true
        @dataVersion = nextProps.dataVersion
      for item, i in @rowChooseChecked
        if item isnt nextState.rowChooseChecked[i]
          @rowChooseChecked[i] = nextState.rowChooseChecked[i]
          refreshFlag = true
      if @tabFilterRules isnt nextState.tabFilterRules
        @tabFilterRules = nextState.tabFilterRules
        refreshFlag = true
      if @filterVersion isnt nextState.filterVersion
        @filterVersion = nextState.filterVersion
        refreshFlag = true
      if @showRulesVersion isnt nextState.showRulesVersion
        @showRulesVersion = nextState.showRulesVersion
        refreshFlag = true
    refreshFlag

   #@state.dataShow.slice((@state.activePage-1)*@state.showAmount, @state.activePage*@state.showAmount)
   # 
  render: ->
    <div>
      <AkashicRecordsCheckboxArea tableTab={@props.tableTab} tabFilterRules={@tabFilterRules} contentType={@props.contentType} rowChooseChecked={@state.rowChooseChecked} dataShowLength={@state.dataAfterFilterLength}/>
      <AkashicRecordsTableArea tableTab={@props.tableTab} data={@dataShow} rowChooseChecked={@state.rowChooseChecked} contentType={@props.contentType} paginationItems={Math.ceil(@state.dataLength/@props.showAmount)} paginationMaxButtons={if Math.ceil(@state.dataLength/@props.showAmount)>5 then 5 else Math.ceil(@state.dataLength/@props.showAmount)} activePage={@state.activePage} handlePageChange={@handlePageChange}/>
    </div>

module.exports = AttackLog
