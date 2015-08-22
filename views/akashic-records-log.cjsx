{React, ReactBootstrap, jQuery, __} = window
{Grid, Col, Table} = ReactBootstrap

AkashicRecordsCheckboxArea = require './akashic-records-checkbox-area'
AkashicRecordsTableArea = require './akashic-records-table-area'

#i18n = require '../node_modules/i18n'
# {__} = i18n

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

configList = [__("Show head"), __("Show filter-box"), __("Auto-selected"), __("Disable filtering while hiding filter-box")]

AkashicLog = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
    configChecked: [true, true, false, false]
    filterKeys:['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '']
    showAmount: 10
    activePage: 0
    filterVersion: 0
    showRulesVersion: 0
    dataShow: []
    dataAfterFilter: []
    dataAfterFilterLength: 0
  filterVersion: 0
  showRulesVersion: 0
  dataVersion: -1
  configChecked: [true, true, false, false]
  rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
  _testFilter: (log, keyWords)->
    {rowChooseChecked} = @state
    regFlag = []
    filterKeys = []
    for item, index in keyWords
      regFlag[index] =false
      filterKeys[index] = item
      if item isnt ''
        res = item.match /^\/(.+)\/([gim]*)$/
        if res?
          try
            reg = new RegExp res[1], res[2]
            regFlag[index] = true
          catch e
            regFlag[index] = false
            # ...
          finally
            if regFlag[index]
              filterKeys[index] = reg
    for item, index in log
      if rowChooseChecked[index+1]
        if keyWords[index+1] isnt ''
          if index is 0
            testText = dateToString(new Date(item)).toLowerCase().trim()
          else
            testText = "#{item}".toLowerCase().trim()
          if regFlag[index+1]
            match = filterKeys[index+1].test testText
          else
            match = testText.indexOf(filterKeys[index+1].toLowerCase().trim()) >= 0
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
    dataAfterFilter = @_filter data, filterKeys
    dataAfterFilterLength = dataAfterFilter.length
    if activePage < 1
      activePage = 1
    if activePage > Math.ceil(dataAfterFilterLength/showAmount)
      activePage = Math.ceil(dataAfterFilterLength/showAmount)
    if dataAfterFilterLength > 0
      dataShow = dataAfterFilter.slice((activePage - 1) * showAmount, activePage * showAmount)
    else
      dataShow = []
    {dataShow, dataAfterFilter, dataAfterFilterLength, activePage}

  ## about tab checkbox
  tabFilterRules: (checked) ->
    {dataShow, dataAfterFilter, dataAfterFilterLength, activePage} = @refreshDataShow @props.data, @state.filterKeys, @state.activePage, @state.showAmount
    @setState
      rowChooseChecked: checked
      dataAfterFilter: dataAfterFilter
      dataAfterFilterLength: dataAfterFilterLength
      dataShow: dataShow
      activePage: activePage

  #about filter
  filterRules: (filterKeys) ->
    {dataShow, dataAfterFilter, dataAfterFilterLength, activePage} = @refreshDataShow @props.data, filterKeys, @state.activePage, @state.showAmount
    @setState
      filterKeys: filterKeys
      filterVersion: @state.filterVersion + 1
      dataAfterFilter: dataAfterFilter
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
      dataShow = @state.dataAfterFilter.slice((activePage - 1) * showAmount, activePage * showAmount)
      @setState
        showAmount: showAmount
        activePage: activePage
        showRulesVersion: @state.showRulesVersion + 1
        dataShow: dataShow
  handlePageChange: (activePage)->
    if activePage isnt @state.activePage
      dataShow = @state.dataAfterFilter.slice((activePage - 1) * @state.showAmount, activePage * @state.showAmount)
      @setState
        activePage: activePage
        dataShow: dataShow
        showRulesVersion: @state.showRulesVersion + 1

  #click config checkbox
  configCheckboxClick: (index)->
    {configChecked} = @state
    configChecked[index] = not configChecked[index]
    if configChecked[2] is true
      configChecked[0] = false
      configChecked[1] = false
    config.set "plugin.Akashic.#{@props.contentType}.configChecked", JSON.stringify configChecked
    @setState
      configChecked: configChecked

  componentWillMount: ->
    {activePage} = @state
    @rowChooseChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify @state.rowChooseChecked
    rowChooseChecked = JSON.parse JSON.stringify @rowChooseChecked
    @configChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.configChecked", JSON.stringify @state.configChecked
    configChecked = JSON.parse JSON.stringify @configChecked
    showAmount = config.get "plugin.Akashic.#{@props.contentType}.showAmount", @state.showAmount
    dataAfterFilter = @_filter @props.data, @state.filterKeys
    dataAfterFilterLength = dataAfterFilter.length
    if dataAfterFilterLength > 0
      if activePage < 1
        activePage = 1
      dataShow = dataAfterFilter.slice((activePage - 1) * showAmount, activePage * showAmount)
    else
      dataShow = []
    @setState
      rowChooseChecked: rowChooseChecked
      configChecked: configChecked
      showAmount: showAmount
      dataAfterFilter: dataAfterFilter
      dataAfterFilterLength: dataAfterFilterLength
      dataShow: dataShow
      activePage: activePage
  componentWillReceiveProps: (nextProps)->
    if nextProps.indexKey is nextProps.selectedKey
      if @dataVersion isnt nextProps.dataVersion
        {dataShow, dataAfterFilter, dataAfterFilterLength, activePage} = @refreshDataShow nextProps.data, @state.filterKeys, @state.activePage, @state.showAmount
        @setState
          dataAfterFilter: dataAfterFilter
          dataAfterFilterLength: dataAfterFilterLength
          dataShow: dataShow
          activePage: activePage
  shouldComponentUpdate: (nextProps, nextState)->
    refreshFlag = false
    if nextProps.indexKey is nextProps.selectedKey
      if @dataVersion isnt nextProps.dataVersion
        @dataVersion = nextProps.dataVersion
        refreshFlag = true
      for item, i in @rowChooseChecked
        if item isnt nextState.rowChooseChecked[i]
          @rowChooseChecked[i] = nextState.rowChooseChecked[i]
          refreshFlag = true
      for item, i in @configChecked
        if item isnt nextState.configChecked[i]
          @configChecked[i] = nextState.configChecked[i]
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
        data={@props.data}
        dataAfterFilter={@state.dataAfterFilter}
        dataShowLength={@state.dataAfterFilterLength}
        showRules={@showRules}
        showAmount={@state.showAmount}
        activePage={@state.activePage}
        configList={configList}
        configChecked={@state.configChecked}
        configCheckboxClick={@configCheckboxClick} />
      <AkashicRecordsTableArea
        contentType={@props.contentType}
        tableTab={@props.tableTab}
        data={@state.dataShow}
        rowChooseChecked={@state.rowChooseChecked}
        filterKeys={@state.filterKeys}
        filterRules={@filterRules}
        paginationItems={Math.ceil(@state.dataAfterFilterLength/@state.showAmount)}
        paginationMaxButtons={if Math.ceil(@state.dataAfterFilterLength/@state.showAmount)>5 then 5 else Math.ceil(@state.dataAfterFilterLength/@state.showAmount)}
        activePage={@state.activePage}
        showAmount={@state.showAmount}
        handlePageChange={@handlePageChange}
        configChecked={@state.configChecked}/>
    </div>

module.exports = AkashicLog
