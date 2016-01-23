{React, ReactBootstrap, jQuery, __, CONST} = window
{Grid, Col, Table} = ReactBootstrap

AkashicRecordsCheckboxArea = require './akashic-records-checkbox-area'
AkashicRecordsTableArea = require './akashic-records-table-area'

#i18n = require '../node_modules/i18n'
# {__} = i18n

dataManager = require '../lib/data-manager'

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

configList = [__("Show Headings"), __("Show Filter-box"), __("Auto-selected"), __("Disable filtering while hiding filter-box")]

boundActivePageNum = (activePage, logLength, showAmount) ->
  activePage = Math.min activePage, Math.ceil(logLength/showAmount)
  activePage = Math.max activePage, 1

AkashicLog = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
    configChecked: [true, true, false, false]
    showAmount: 10
    activePage: 1
    dataShow: []
  configChecked: [true, true, false, false]
  rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]

  getVisibleData: (filteredData, activePage, showAmount)->
    dataAfterFilterLength = filteredData.length
    activePage = boundActivePageNum activePage, dataAfterFilterLength, showAmount
    if dataAfterFilterLength > 0
      dataShow = filteredData.slice((activePage - 1) * showAmount, activePage * showAmount)
    else
      dataShow = []
    {dataShow, activePage}

  ## about tab checkbox
  tabFilterRules: (checked) ->
    keys = dataManager.getFilterKeys @props.contentType, true
    for item, index in keys
      if not checked[index+1]
        keys[index] = ''
    dataManager.setFilterKeys @props.contentType, keys, true
    activePage = boundActivePageNum @state.activePage,
      dataManager.getFilteredData(@props.contentType).length, @state.showAmount
    @setState
      rowChooseChecked: checked
      activePage: activePage

  #about the amount of data showed and active page
  showRules: (showAmount, activePage)->
    activePage = boundActivePageNum activePage, dataManager.getFilteredData(@props.contentType).length, showAmount
    if showAmount isnt @state.showAmount
      config.set "plugin.Akashic.#{@props.contentType}.showAmount", showAmount
    if showAmount isnt @state.showAmount or activePage isnt @state.activePage
      dataShow = dataManager.getFilteredData(@props.contentType).slice((activePage - 1) * showAmount, activePage * showAmount)
      @setState
        showAmount: showAmount
        activePage: activePage
        dataShow: dataShow

  handlePageChange: (activePage)->
    if activePage isnt @state.activePage
      dataShow = dataManager.getFilteredData(@props.contentType).slice((activePage - 1) * @state.showAmount, activePage * @state.showAmount)
      @setState
        activePage: activePage
        dataShow: dataShow

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

  filteredDataChangeCB: ->
    {dataShow, activePage} = @getVisibleData dataManager.getFilteredData(@props.contentType), @state.activePage, @state.showAmount
    @setState
      dataShow: dataShow
      activePage: activePage

  componentWillMount: ->
    {activePage} = @state
    @rowChooseChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify @state.rowChooseChecked
    rowChooseChecked = Object.clone @rowChooseChecked
    @configChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.configChecked", JSON.stringify @state.configChecked
    configChecked = Object.clone @configChecked
    showAmount = config.get "plugin.Akashic.#{@props.contentType}.showAmount", @state.showAmount
    dataAfterFilter = dataManager.getFilteredData @props.contentType
    {dataShow, activePage} = @getVisibleData dataAfterFilter, activePage, showAmount
    @setState
      rowChooseChecked: rowChooseChecked
      configChecked: configChecked
      showAmount: showAmount
      dataAfterFilter: dataAfterFilter
      dataShow: dataShow
      activePage: activePage
    @filteredDataChangelistener = dataManager.addListener @props.contentType, CONST.eventList.filteredDataChange, @filteredDataChangeCB

  componentWillUnmount: ->
    if @filteredDataChangelistener?
      dataManager.removeListener @props.contentType, CONST.eventList.filteredDataChange, @filteredDataChangelistener

  # componentWillReceiveProps: (nextProps)->
  #   if nextProps.indexKey is nextProps.selectedKey
  #     if @dataVersion isnt nextProps.dataVersion
  #       {dataShow, dataAfterFilter, dataAfterFilterLength, activePage} = @refreshDataShow nextProps.data, @state.filterKeys, @state.activePage, @state.showAmount
  #       @setState
  #         dataAfterFilter: dataAfterFilter
  #         dataAfterFilterLength: dataAfterFilterLength
  #         dataShow: dataShow
  #         activePage: activePage

  shouldComponentUpdate: (nextProps, nextState)->
    if nextProps.indexKey is nextProps.selectedKey
      true
    else
      false

  render: ->
    <div>
      <AkashicRecordsCheckboxArea
        contentType={@props.contentType}
        tableTab={@props.tableTab}
        tabFilterRules={@tabFilterRules}
        rowChooseChecked={@state.rowChooseChecked}
        data={@props.data}
        dataShowLength={@state.dataShow.length}
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
        paginationItems={Math.ceil(dataManager.getFilteredData(@props.contentType).length/@state.showAmount)}
        paginationMaxButtons={Math.min(Math.ceil(dataManager.getFilteredData(@props.contentType).length/@state.showAmount), 5)}
        activePage={@state.activePage}
        showAmount={@state.showAmount}
        handlePageChange={@handlePageChange}
        configChecked={@state.configChecked}/>
    </div>

module.exports = AkashicLog
