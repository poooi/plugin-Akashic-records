{React, ReactBootstrap, jQuery, config, __} = window
{Panel, Button, Col, Input, Grid, Row, ButtonGroup, DropdownButton, MenuItem, Table, OverlayTrigger, Popover, Collapse, Well} = ReactBootstrap
Divider = require './divider'
{openExternal} = require 'shell'

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

AkashicRecordsCheckboxArea = React.createClass
  getInitialState: ->
    filterPaneShow: true
    statisticsPaneShow: true
    searchArgv:[
      filterKey: ''
      searchBaseOn: -1
      result: []
      num: 0
      percent: 0
    ]
    compareArgv: [
      numeratorBaseon: -1
      denominatorBaseon: -1
    ]
  inputDataVersion: 0
  currentDataVersion: 0
  compareResult: []
  getDataNum: (type, data, dataAfterFilter, searchArgv)->
    switch type
      when -2
        dataNum = data.length
      when -1
        dataNum = dataAfterFilter.length
      else
        dataNum = @state.searchArgv[type].result.length
    dataNum
  refreshSearchResult: (searchArgv, data, dataAfterFilter)->
    for index in [0..searchArgv.length-1]
      switch searchArgv[index].searchBaseOn
        when -2
          data = data
        when -1
          data = dataAfterFilter
        else
          data = searchArgv[searchArgv[index].searchBaseOn].result
      searchArgv[index].num = data.length
      if searchArgv[index].filterKey is ''
        searchArgv[index].result=[]
        searchArgv[index].percent=0
      else
        filterKey = searchArgv[index].filterKey
        regFlag = false
        res = filterKey.match /^\/(.+)\/([gim]*)$/
        if res?
          try
            reg = new RegExp res[1], res[2]
            regFlag = true
          catch e
            regFlag = false
          finally
            if regFlag
              filterKey = reg
        result = data.filter (log)=>
          match = false
          for item, i in log
            searchText = item
            if i is 0
              searchText = dateToString(new Date(searchText))
            else if not regFlag
              searchText = "#{searchText}".toLowerCase().trim()
            if regFlag
              match = filterKey.test searchText
            else
              match = searchText.indexOf(filterKey.toLowerCase().trim()) >= 0
            if match
              return match
          match
        searchArgv[index].result = result
        if searchArgv[index].num isnt 0
          searchArgv[index].percent = Math.round(searchArgv[index].result.length*10000/searchArgv[index].num) / 100
        else
          searchArgv[index].percent = 0
    @setState
      searchArgv: searchArgv

  refreshCompareResult: (compareArgv, data, dataAfterFilter, searchArgv)->
    @compareResult = []
    for item, index in compareArgv
      if item.numeratorBaseon is -3
        numerator = @refs["numerator#{index}"]?.getValue()
        if not numerator
          numerator = 0
      else
        numerator = @getDataNum item.numeratorBaseon, data, dataAfterFilter, searchArgv
      if item.denominatorBaseon is -3
        denominator = @refs["denominator#{index}"]?.getValue()
        if not denominator
          denominator = 0
      else
        denominator = @getDataNum item.denominatorBaseon, data, dataAfterFilter, searchArgv
      if denominator isnt 0
        percent = Math.round(numerator*10000/denominator) / 100
      else
        percent = 0
      @compareResult.push
        numerator: numerator
        denominator: denominator
        percent: percent
    @compareResult
  handleFilterPaneShow: ->
    {filterPaneShow} = @state
    filterPaneShow = not filterPaneShow
    @setState {filterPaneShow}
    config.set "plugin.Akashic.#{@props.contentType}.filterPaneShow", filterPaneShow
  handleStatisticsPaneShow: ->
    {statisticsPaneShow, searchArgv} = @state
    statisticsPaneShow = not statisticsPaneShow
    if statisticsPaneShow
      if @currentDataVersion isnt @inputDataVersion
        @currentDataVersion = @inputDataVersion
        @refreshSearchResult searchArgv, @props.data, @props.dataAfterFilter
    @setState {statisticsPaneShow}
    config.set "plugin.Akashic.#{@props.contentType}.statisticsPaneShow", statisticsPaneShow
  handleClickCheckbox: (index) ->
    {rowChooseChecked} = @props
    rowChooseChecked[index] = !rowChooseChecked[index]
    @props.tabFilterRules rowChooseChecked
    config.set "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify rowChooseChecked
  handleClickConfigCheckbox: (index) ->
    @props.configCheckboxClick index
  handleShowAmountSelect: (eventKey, selectedKey)->
    @props.showRules selectedKey, @props.activePage
  handleShowPageSelect: (eventKey, selectedKey)->
    @props.showRules @props.showAmount, selectedKey
  handleSearchChange: ()->
    {searchArgv} = @state
    for index in [0..searchArgv.length-1]
      searchArgv[index].filterKey = @refs["search#{index}"].getValue()
      searchArgv[index].searchBaseOn = parseInt @refs["baseOn#{index}"].getValue()
    @refreshSearchResult searchArgv, @props.data, @props.dataAfterFilter
  addSearchLine: ->
    {searchArgv} = @state
    searchArgv.push
      filterKey: ''
      searchBaseOn: -1
      result: []
      num: 0
      percent: 0
    @setState
      searchArgv: searchArgv
  deleteSearchLine: (index)->
    {searchArgv} = @state
    for item, i in searchArgv
      if item.searchBaseOn is index
        item.searchBaseOn = -1
      else if item.searchBaseOn > index
        item.searchBaseOn -= 1
    searchArgv.splice index, 1
    @refreshSearchResult searchArgv, @props.data, @props.dataAfterFilter

  handleCompareChange: ()->
    {compareArgv} = @state
    for index in [0..compareArgv.length-1]
      compareArgv[index]['numeratorBaseon'] = parseInt @refs["numeratorBaseon#{index}"].getValue()
      compareArgv[index]['denominatorBaseon'] = parseInt @refs["denominatorBaseon#{index}"].getValue()
    @setState
      compareArgv: compareArgv
  addCompareLine: ->
    {compareArgv} = @state
    compareArgv.push
      numeratorBaseon: -1
      denominatorBaseon: -1
    @setState
      compareArgv: compareArgv
  deleteCompareLine: (index)->
    {compareArgv} = @state
    compareArgv.splice index, 1
    @setState
      compareArgv: compareArgv
  componentWillMount: ->
    filterPaneShow = config.get "plugin.Akashic.#{@props.contentType}.filterPaneShow", true
    statisticsPaneShow = config.get "plugin.Akashic.#{@props.contentType}.statisticsPaneShow", true
    @setState
      filterPaneShow: filterPaneShow
      statisticsPaneShow: statisticsPaneShow
    @refreshSearchResult @state.searchArgv, @props.data, @props.dataAfterFilter
    @refreshCompareResult @state.compareArgv, @props.data, @props.dataAfterFilter, @state.searchArgv
  componentWillReceiveProps: (nextProps)->
    @inputDataVersion += 1
    if @state.statisticsPaneShow
      @currentDataVersion = @inputDataVersion
      @refreshSearchResult @state.searchArgv, nextProps.data, nextProps.dataAfterFilter
  componentWillUpdate: (nextProps, nextState)->
    if nextState.statisticsPaneShow
      @refreshCompareResult nextState.compareArgv, nextProps.data, nextProps.dataAfterFilter, nextState.searchArgv
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
              <Col xs={2}>
                <ButtonGroup justified>
                  <DropdownButton bsSize='xsmall' id="dropdown-page-selector" eventKey={4} title={__ "Page %s", @props.activePage}>
                  {
                    if @props.dataShowLength isnt 0
                      for index in [1..Math.ceil(@props.dataShowLength/@props.showAmount)]
                        <MenuItem key={index} eventKey={index} onSelect={@handleShowPageSelect}>{__ "Page %s", index}</MenuItem>
                  }
                  </DropdownButton>
                </ButtonGroup>
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
                            <option key={-2} value={-2}>{__ "All Data"}</option>
                            <option key={-1} value={-1}>{__ "Filtered"}</option>
                            {
                              for i in [0..@state.searchArgv.length-1]
                                break if i >= index
                                <option key={i} value={i}>{__ "Search Result No. %s", i+1}</option>
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
                        <td>{@state.searchArgv[index]['result'].length}</td>
                        <td>{@state.searchArgv[index]['num']}</td>
                        <td>{"#{@state.searchArgv[index]['percent']}%"}</td>
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
                          <Input type="select" ref="numeratorBaseon#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index]['numeratorBaseon']}"} onChange={@handleCompareChange}>
                            <option key={-2} value={-2}>{__ "All Data"}</option>
                            <option key={-1} value={-1}>{__ "Filtered"}</option>
                            {
                              for i in [0..@state.searchArgv.length-1]
                                <option key={i} value={i}>{__ "Search Result No. %s", i+1}</option>
                            }
                            <option key={-3} value={-3}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        <td>
                          <Input type="select" ref="denominatorBaseon#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index]['denominatorBaseon']}"} onChange={@handleCompareChange}>
                            <option key={-2} value={-2}>{__ "All Data"}</option>
                            <option key={-1} value={-1}>{__ "Filtered"}</option>
                            {
                              for i in [0..@state.searchArgv.length-1]
                                <option key={i} value={i}>{__ "Search Result No. %s", i+1}</option>
                            }
                            <option key={-3} value={-3}>{__ "Custom"}</option>
                          </Input>
                        </td>
                        {
                          if @state.compareArgv[index].numeratorBaseon is -3
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@compareResult[index].numerator}"}
                                ref="numerator#{index}"
                                groupClassName='search-area'
                                onChange={@handleCompareChange} />
                            </td>
                          else
                            <td>{@compareResult[index].numerator}</td>
                        }
                        {
                          if @state.compareArgv[index].denominatorBaseon is -3
                            <td>
                              <Input
                                type='number'
                                placeholder={"0"}
                                value={"#{@compareResult[index].denominator}"}
                                ref="denominator#{index}"
                                groupClassName='search-area'
                                onChange={@handleCompareChange} />
                            </td>
                          else
                            <td>{@compareResult[index].denominator}</td>
                        }
                        <td>{"#{@compareResult[index].percent}%"}</td>
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
