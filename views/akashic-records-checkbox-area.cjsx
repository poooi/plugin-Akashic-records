{React, ReactBootstrap, jQuery, config, __, CONST} = window
{Panel, Button, Col, Input, Grid, Row, ButtonGroup, DropdownButton,
  MenuItem, Table, OverlayTrigger, Popover, Collapse, Well} = ReactBootstrap
Divider = require './divider'
{openExternal} = require 'shell'

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

class SearchArgv
  constructor: ->
    @filterKey = ''
    @searchBaseOn = CONST.search.filteredDataIndex
    @res = 0
    @total = 0
    @percent = 0

class CompareArgv
  constructor: ->
    @numerator =
      baseOn: CONST.search.filteredDataIndex
      num: 0
    @denominator =
      baseOn: CONST.search.filteredDataIndex
      num: 0
    @percent = 0

calPercent = (num, de) ->
  if de != 0
    "#{Math.round(num*10000/de) / 100}%"
  else
    "0"

AkashicRecordsCheckboxArea = React.createClass
  getInitialState: ->
    filterPaneShow: true
    statisticsPaneShow: true
    searchArgv:[
      new SearchArgv()
    ]
    compareArgv: [
      new CompareArgv()
    ]
  inputDataVersion: 0
  currentDataVersion: 0
  checkboxChangeFlag: false


  refreshSearchResult: (searchArgv)->
    for item, index in searchArgv
      item.total = dataManager.getSearchDataLength @props.contentType, item.searchBaseOn
      item.res = dataManager.searchData @props.contentType, CONST.search.indexBase + index + 1, item.searchBaseOn, item.filterKey
      item.res = item.res.length
      item.percent = calPercent item.res, item.total
    searchArgv

  refreshCompareResult: (compareArgv)->
    for item, index in compareArgv
      for term in ['numerator', 'denominator']
        if item[term].baseOn is -1
          num = @refs["#{term}#{index}"]?.getValue()
          if not num
            num = 0
        else
          num = dataManager.getSearchDataLength @props.contentType, item[term].baseOn
        item[term].num = num
      item.percent = calPercent item.numerator.num, item.denominator.num
    compareArgv

  handleFilterPaneShow: ->
    {filterPaneShow} = @state
    filterPaneShow = not filterPaneShow
    @setState {filterPaneShow}
    config.set "plugin.Akashic.#{@props.contentType}.filterPaneShow", filterPaneShow
  handleStatisticsPaneShow: ->
    {statisticsPaneShow, searchArgv, compareArgv} = @state
    statisticsPaneShow = not statisticsPaneShow
    if statisticsPaneShow
      if @currentDataVersion isnt @inputDataVersion
        @currentDataVersion = @inputDataVersion
        searchArgv = @refreshSearchResult searchArgv
        compareArgv = @refreshCompareResult compareArgv
    @setState
      statisticsPaneShow: statisticsPaneShow
      searchArgv: searchArgv
      compareArgv: compareArgv

    config.set "plugin.Akashic.#{@props.contentType}.statisticsPaneShow", statisticsPaneShow
  handleClickCheckbox: (index) ->
    {rowChooseChecked} = @props
    rowChooseChecked[index] = !rowChooseChecked[index]
    @props.tabFilterRules rowChooseChecked
    @checkboxChangeFlag = true
    config.set "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify rowChooseChecked
  handleClickConfigCheckbox: (index) ->
    @props.configCheckboxClick index
  handleShowAmountSelect: (eventKey, selectedKey)->
    @props.showRules selectedKey, @props.activePage
  handleShowPageSelect: ()->
    val = parseInt @refs.pageSelected.getValue()
    if !val or val < 1
      val = 1
    @props.showRules @props.showAmount, val
  handleSearchChange: ()->
    {searchArgv, compareArgv} = @state
    for index in [0..searchArgv.length-1]
      searchArgv[index].filterKey = @refs["search#{index}"].getValue()
      searchArgv[index].searchBaseOn = parseInt @refs["baseOn#{index}"].getValue()
    searchArgv = @refreshSearchResult searchArgv
    compareArgv = @refreshCompareResult compareArgv
    @setState
      searchArgv: searchArgv
      compareArgv: compareArgv
  addSearchLine: ->
    {searchArgv} = @state
    searchArgv.push new SearchArgv()
    @setState
      searchArgv: searchArgv
  deleteSearchLine: (index)->
    {searchArgv, compareArgv} = @state
    for item, i in searchArgv
      if item.searchBaseOn is index
        item.searchBaseOn = CONST.search.filteredDataIndex
      else if item.searchBaseOn > index
        item.searchBaseOn -= 1
    searchArgv.splice index, 1
    searchArgv = @refreshSearchResult searchArgv
    for item in compareArgv
      for term in ['numerator', 'denominator']
        if item[term].baseOn is index
          item[term].baseOn = CONST.search.filteredDataIndex
        else if item[term].baseOn > index
          item[term].baseOn -= 1
    compareArgv = @refreshCompareResult compareArgv
    @setState
      searchArgv: searchArgv
      compareArgv: compareArgv

  handleCompareChange: ->
    {compareArgv} = @state
    for index in [0..compareArgv.length-1]
      compareArgv[index].numerator.baseOn =
        parseInt @refs["numeratorBaseon#{index}"].getValue()
      compareArgv[index].denominator.baseOn =
        parseInt @refs["denominatorBaseon#{index}"].getValue()
    compareArgv = @refreshCompareResult compareArgv
    @setState
      compareArgv: compareArgv
  addCompareLine: ->
    {compareArgv} = @state
    compareArgv.push new CompareArgv()
    @setState
      compareArgv: compareArgv
  deleteCompareLine: (index)->
    {compareArgv} = @state
    compareArgv.splice index, 1
    @setState
      compareArgv: compareArgv

  refreshData: ->
    if @state.statisticsPaneShow
      {searchArgv, compareArgv} = @state
      searchArgv = @refreshSearchResult searchArgv
      compareArgv = @refreshCompareResult compareArgv
      @setState
        searchArgv: searchArgv
        compareArgv: compareArgv

  componentWillReceiveProps: (nextProps) ->
    if @checkboxChangeFlag
      @checkboxChangeFlag = false
      @refreshData()

  dataListener: (lazyFlag)->
    if not lazyFlag
      @refreshData()

  componentWillMount: ->
    filterPaneShow =
      config.get "plugin.Akashic.#{@props.contentType}.filterPaneShow", true
    statisticsPaneShow =
      config.get "plugin.Akashic.#{@props.contentType}.statisticsPaneShow", true
    searchArgv = @refreshSearchResult @state.searchArgv
    compareArgv = @refreshCompareResult @state.compareArgv
    @setState
      filterPaneShow: filterPaneShow
      statisticsPaneShow: statisticsPaneShow
      searchArgv: searchArgv
      compareArgv: compareArgv

    @rawDataChangelistener = dataManager.addListener @props.contentType,
      CONST.eventList.rawDataChange, @dataListener
    @filteredDataChangelistener = dataManager.addListener @props.contentType,
      CONST.eventList.filteredDataChange, @dataListener


  componentWillUnmount: ->
    if @rawDataChangelistener?
      dataManager.removeListener @props.contentType,
        CONST.eventList.rawDataChange, @rawDataChangelistener
    if @filteredDataChangelistener?
      dataManager.removeListener @props.contentType,
        CONST.eventList.filteredDataChange, @filteredDataChangelistener

  render: ->
    <div className='akashic-records-settings' className={if @state.filterPaneShow or @state.statisticsPaneShow then "tap-pane-show" else "tab-pane-hidden"}>
      <Grid>
        <Row>
          <Col xs={12}>
            <div onClick={@handleFilterPaneShow}>
              <Divider text={__ "Filter"} icon={true} hr={true} show={@state.filterPaneShow}/>
            </div>
          </Col>
        </Row>
        <Collapse className='akashic-records-filter' in={@state.filterPaneShow}>
          <div>
            <Row>
            {
              for checkedVal, index in @props.tableTab
                continue if !index
                <Col key={index} xs={2}>
                  <Input type='checkbox' value={index} onChange={@handleClickCheckbox.bind(@, index)} checked={@props.rowChooseChecked[index]} style={verticalAlign: 'middle'} label={checkedVal} />
                </Col>
            }
            </Row>
            <hr/>
            <Row>
              <Col xs={2}>
                <ButtonGroup justified>
                  <DropdownButton bsSize='xsmall' id="dropdown-showOption-selector" eventKey={4} title={__ "Newer %s", @props.showAmount}>
                    <MenuItem eventKey=10 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "10"}</MenuItem>
                    <MenuItem eventKey=20 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "20"}</MenuItem>
                    <MenuItem eventKey=50 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "50"}</MenuItem>
                    <MenuItem divider />
                    <MenuItem eventKey=999999 onSelect={@handleShowAmountSelect}>{__ "View All"}</MenuItem>
                  </DropdownButton>
                </ButtonGroup>
              </Col>
              <Col xs={2} style={display: 'flex', textAlign: 'right'}>
                <div style={flex: 1, paddingRight: 10, paddingTop: 2}>
                  {__ "Jump to"}
                </div>
                <div style={flex: 1, minWidth: 64}>
                  <Input
                    type='number'
                    placeholder={"#{__ "Page %s", @props.activePage}"}
                    ref='pageSelected'
                    groupClassName='select-area'
                    onChange={@handleShowPageSelect}/>
                </div>
              </Col>
              <Col xs={5}>
              {
                for checkedVal, index in @props.configList
                  continue if index is 3
                  <Col key={index} xs={4}>
                    <Input type='checkbox' value={index} onChange={@handleClickConfigCheckbox.bind(@, index)} checked={@props.configChecked[index]} style={verticalAlign: 'middle'} label={checkedVal} />
                  </Col>
              }
              </Col>
              <Col xs={3}>
              {
                index = 3
                checkedVal = @props.configList[index]
                <Input type='checkbox' value={index} onChange={@handleClickConfigCheckbox.bind(@, index)} checked={@props.configChecked[index]} style={verticalAlign: 'middle'} label={checkedVal} />
              }
              </Col>
            </Row>
          </div>
        </Collapse>
        <Row>
          <Col xs={12}>
            <div onClick={@handleStatisticsPaneShow}>
              <Divider text={__ "Statistics"} icon={true} hr={true} show={@state.statisticsPaneShow}/>
            </div>
          </Col>
        </Row>
        <Collapse className='akashic-records-statistics' in={@state.statisticsPaneShow}>
          <div>
            <Row>
              <Col xs={12}>
                <Table bordered responsive>
                  <thead>
                    <tr>
                      <th style={verticalAlign: 'middle'}>
                        <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                          <Popover title={__ "Tips"} id={"regExp-Hint"}>
                            <li>{__ "Support the Javascript's "}<a onClick={openExternal.bind(this, "http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>{"RegExp"}</a></li>
                          </Popover>
                          }>
                          <FontAwesome name='question-circle'/>
                        </OverlayTrigger>
                      </th>
                      <th>No.</th>
                      <th>{__ "Base on"}</th>
                      <th>{__ "Keywords"}</th>
                      <th>{__ "Result"}</th>
                      <th>{__ "Sample Size"}</th>
                      <th>{__ "Percentage"}</th>
                    </tr>
                  </thead>
                  <tbody>
                  {
                    for index in [0..@state.searchArgv.length-1]
                      <tr key={index}>
                        {
                          if index is 0
                            <td style={verticalAlign: 'middle'}><FontAwesome name='plus-circle' onClick={@addSearchLine}/></td>
                          else
                            <td style={verticalAlign: 'middle'}><FontAwesome name='minus-circle' onClick={@deleteSearchLine.bind(@, index)}/></td>
                        }
                        <td>{index+1}</td>
                        <td>
                          <Input type="select" ref="baseOn#{index}" groupClassName='search-area' value={"#{@state.searchArgv[index].searchBaseOn}"} onChange={@handleSearchChange}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..@state.searchArgv.length]
                                break if i > index
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                          </Input>
                        </td>
                        <td>
                           <Input
                              type='text'
                              value={@state.searchArgv[index].filterKey}
                              placeholder={__ "Keywords"}
                              ref="search#{index}"
                              groupClassName='search-area'
                              onChange={@handleSearchChange} />
                        </td>
                        <td>{@state.searchArgv[index].res}</td>
                        <td>{@state.searchArgv[index].total}</td>
                        <td>{@state.searchArgv[index].percent}</td>
                      </tr>
                  }
                  </tbody>
                  <thead>
                    <tr>
                      <th></th>
                      <th>No.</th>
                      <th>{__ "Numerator"}</th>
                      <th>{__ "Denominator"}</th>
                      <th>{__ "Numerator Number"}</th>
                      <th>{__ "Denominator Number"}</th>
                      <th>{__ "Percentage"}</th>
                    </tr>
                  </thead>
                  <tbody>
                  {
                    for index in [0..@state.compareArgv.length-1]
                      <tr key={index}>
                        {
                          if index is 0
                            <td style={verticalAlign: 'middle'}><FontAwesome name='plus-circle' onClick={@addCompareLine}/></td>
                          else
                            <td style={verticalAlign: 'middle'}><FontAwesome name='minus-circle' onClick={@deleteCompareLine.bind(@, index)}/></td>
                        }
                        <td>{index+1}</td>
                        <td>
                          <Input type="select" ref="numeratorBaseon#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index].numerator.baseOn}"} onChange={@handleCompareChange}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..@state.searchArgv.length]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                            <option key={-1} value={-1}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        <td>
                          <Input type="select" ref="denominatorBaseon#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index].denominator.baseOn}"} onChange={@handleCompareChange}>
                            <option key={CONST.search.rawDataIndex} value={CONST.search.rawDataIndex}>{__ "All Data"}</option>
                            <option key={CONST.search.filteredDataIndex} value={CONST.search.filteredDataIndex}>{__ "Filtered"}</option>
                            {
                              for i in [1..@state.searchArgv.length]
                                <option key={CONST.search.indexBase + i} value={CONST.search.indexBase + i}>{__ "Search Result No. %s", i}</option>
                            }
                            <option key={-1} value={-1}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        {
                          if @state.compareArgv[index].numerator.baseOn is -1
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@state.compareArgv[index].numerator.num}"}
                                ref="numerator#{index}"
                                groupClassName='search-area'
                                onChange={@handleCompareChange} />
                            </td>
                          else
                            <td>{@state.compareArgv[index].numerator.num}</td>
                        }
                        {
                          if @state.compareArgv[index].denominator.baseOn is -1
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@state.compareArgv[index].denominator.num}"}
                                ref="denominator#{index}"
                                groupClassName='search-area'
                                onChange={@handleCompareChange} />
                            </td>
                          else
                            <td>{@state.compareArgv[index].denominator.num}</td>
                        }
                        <td>{@state.compareArgv[index].percent}</td>
                      </tr>
                  }
                  </tbody>
                </Table>
              </Col>
            </Row>
          </div>
        </Collapse>
      </Grid>
    </div>

module.exports = AkashicRecordsCheckboxArea
