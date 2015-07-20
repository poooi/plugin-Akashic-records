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

AkashicLog = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
    filterKeys:['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '']
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
    {rowChooseChecked} = @state
    for item, index in log
      if rowChooseChecked[index+1]
        if keyWords[index+1] isnt ''
          if index is 0
            match = dateToString(new Date(item)).toLowerCase().trim().indexOf(keyWords[index+1].toLowerCase().trim()) >= 0
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
  refreshDataShow: (data, filterKeys, activePage, showAmount)->
    @dataAfterFilter = @_filter data, filterKeys
    dataAfterFilterLength = @dataAfterFilter.length
    if activePage < 1
      activePage = 1
    if activePage > Math.ceil(dataAfterFilterLength/showAmount)
      activePage = Math.ceil(dataAfterFilterLength/showAmount)
    if dataAfterFilterLength > 0
      dataShow = @dataAfterFilter.slice((activePage - 1) * showAmount, activePage * showAmount)
    else
      dataShow = []
    {dataShow, dataAfterFilterLength, activePage}

  ## about tab checkbox
  tabFilterRules: (checked) ->
    @setState
      rowChooseChecked: checked
      tabFilterVersion: @state.tabFilterVersion + 1

  #about filter    
  filterRules: (filterKeys) ->
    {dataShow, dataAfterFilterLength, activePage} = @refreshDataShow @props.data, filterKeys, @state.activePage, @state.showAmount
    @setState
      filterKeys: filterKeys
      filterVersion: @state.filterVersion + 1
      dataAfterFilterLength: dataAfterFilterLength
      dataShow: dataShow
      activePage: activePage

  #about the amount of data showed and active page
  showRules: (showAmount, activePage)->
    if activePage > Math.ceil(@state.dataAfterFilterLength/showAmount)
      activePage = Math.ceil(@state.dataAfterFilterLength/showAmount)
    if showAmount isnt @state.showAmount
      config.set "plugin.Akashic.#{@props.contentType}.showAmount", showAmount
    if showAmount isnt @state.showAmount or activePage isnt @state.activePage
      dataShow = @dataAfterFilter.slice((activePage - 1) * showAmount, activePage * showAmount)
      @setState
        showAmount: showAmount
        activePage: activePage
        showRulesVersion: @state.showRulesVersion + 1
        dataShow: dataShow
  handlePageChange: (activePage)->
    if activePage isnt @state.activePage
      dataShow = @dataAfterFilter.slice((activePage - 1) * @state.showAmount, activePage * @state.showAmount)
      @setState
        activePage: activePage
        dataShow: dataShow

  componentWillMount: ->
    {activePage} = @state
    @rowChooseChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify @state.rowChooseChecked
    rowChooseChecked = JSON.parse JSON.stringify @rowChooseChecked
    showAmount = config.get "plugin.Akashic.#{@props.contentType}.showAmount", @state.showAmount
    @dataAfterFilter = @_filter @props.data, @state.filterKeys
    dataAfterFilterLength = @dataAfterFilter.length
    if dataAfterFilterLength > 0
      if activePage < 1
        activePage = 1
      dataShow = @dataAfterFilter.slice((activePage - 1) * showAmount, activePage * showAmount)
    else
      dataShow = []
    @setState
      rowChooseChecked: rowChooseChecked
      showAmount: showAmount
      dataAfterFilterLength: dataAfterFilterLength
      dataShow: dataShow
      activePage: activePage
  componentWillReceiveProps: (nextProps)->
    if nextProps.indexKey is nextProps.selectedKey
      if @dataVersion isnt nextProps.dataVersion
        {dataShow, dataAfterFilterLength, activePage} = @refreshDataShow nextProps.data, @state.filterKeys, @state.activePage, @state.showAmount
        @setState
          dataAfterFilterLength: dataAfterFilterLength
          dataShow: dataShow
          activePage: activePage
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
      if @tabFilterVersion isnt nextState.tabFilterVersion
        @tabFilterVersion = nextState.tabFilterVersion
        refreshFlag = true
      if @filterVersion isnt nextState.filterVersion
        @filterVersion = nextState.filterVersion
        refreshFlag = true
      if @showRulesVersion isnt nextState.showRulesVersion
        @showRulesVersion = nextState.showRulesVersion
        refreshFlag = true
    refreshFlag

  render: ->
    <div>
      <AkashicRecordsCheckboxArea  
        contentType={@props.contentType}
        tableTab={@props.tableTab} 
        tabFilterRules={@tabFilterRules} 
        rowChooseChecked={@state.rowChooseChecked} 
        dataShowLength={@state.dataAfterFilterLength}
        showRules={@showRules}
        showAmount={@state.showAmount}
        activePage={@state.activePage}
      />
      <AkashicRecordsTableArea
        contentType={@props.contentType} 
        tableTab={@props.tableTab} 
        data={@state.dataShow} 
        rowChooseChecked={@state.rowChooseChecked} 
        filterKeys={@state.filterKeys}
        filterRules={@filterRules}
        paginationItems={Math.ceil(@state.dataAfterFilterLength/@props.showAmount)} 
        paginationMaxButtons={if Math.ceil(@state.dataAfterFilterLength/@props.showAmount)>5 then 5 else Math.ceil(@state.dataAfterFilterLength/@props.showAmount)} 
        activePage={@state.activePage} 
        showAmount={@state.showAmount}
        handlePageChange={@handlePageChange}/>
    </div>

module.exports = AkashicLog
