{React, ReactBootstrap, jQuery, __, CONST} = window
{Grid, Col, Table} = ReactBootstrap

AkashicRecordsCheckboxArea = require './akashic-records-checkbox-area'
AkashicRecordsStatisticsPanel = require './akashic-records-statistics-panel'
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
  configChecked: [true, true, false, false]
  rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]

  ## about tab checkbox
  tabFilterRules: (checked) ->
    keys = dataManager.getFilterKeys @props.contentType
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
      @setState
        showAmount: showAmount
        activePage: activePage

  handlePageChange: (activePage)->
    @showRules @state.showAmount, activePage

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
    @rowChooseChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify @state.rowChooseChecked
    rowChooseChecked = Object.clone @rowChooseChecked
    @configChecked = JSON.parse config.get "plugin.Akashic.#{@props.contentType}.configChecked", JSON.stringify @state.configChecked
    configChecked = Object.clone @configChecked
    showAmount = config.get "plugin.Akashic.#{@props.contentType}.showAmount", @state.showAmount
    @setState
      rowChooseChecked: rowChooseChecked
      configChecked: configChecked
      showAmount: showAmount

  # componentWillUnmount: ->
  #   if @filteredDataChangelistener?
  #     dataManager.removeListener @props.contentType, CONST.eventList.filteredDataChange, @filteredDataChangelistener

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
        showRules={@showRules}
        showAmount={@state.showAmount}
        activePage={@state.activePage}
        configList={configList}
        configChecked={@state.configChecked}
        configCheckboxClick={@configCheckboxClick} />
      <AkashicRecordsStatisticsPanel
        contentType={@props.contentType}
      />
      <AkashicRecordsTableArea
        contentType={@props.contentType}
        tableTab={@props.tableTab}
        rowChooseChecked={@state.rowChooseChecked}
        activePage={@state.activePage}
        showAmount={@state.showAmount}
        handlePageChange={@handlePageChange}
        configChecked={@state.configChecked}/>
    </div>

module.exports = AkashicLog
