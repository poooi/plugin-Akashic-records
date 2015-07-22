{React, ReactBootstrap, jQuery, config} = window
{Panel, Button, Col, Input, Grid, Row, ButtonGroup, DropdownButton, MenuItem, Table} = ReactBootstrap
Divider = require './divider'

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
      numerator: -1
      denominator: -1
    ]
  compareResult: []
  getDataNum: (type)->
    data = 0
    switch type
      when -2
        data = @props.data.length
      when -1
        data = @props.dataAfterFilter.length
      else
        data = @state.searchArgv[type].result.length
    data
  refreshSearchResult: (searchArgv)->
    for index in [0..searchArgv.length-1]
      switch searchArgv[index].searchBaseOn
        when -2
          data = @props.data
        when -1
          data = @props.dataAfterFilter
        else
          data = searchArgv[searchArgv[index].searchBaseOn].result
      searchArgv[index].num = data.length
      if searchArgv[index].filterKey is ''
        searchArgv[index].result=[]
        searchArgv[index].percent=0
      else 
        filterKey = searchArgv[index].filterKey
        result = data.filter (log)=>
          match = false
          for item, i in log
            if i is 0
              searchText = dateToString(new Date(item)).toLowerCase().trim()
            else
              searchText = "#{item}".toLowerCase().trim()
            if searchText.indexOf(filterKey.toLowerCase().trim()) >= 0
              match = true
              return match
          match
        searchArgv[index].result = result
        if searchArgv[index].num isnt 0
          searchArgv[index].percent = Math.round(searchArgv[index].result.length*10000/searchArgv[index].num) / 100
        else
          searchArgv[index].percent = 0
    @setState
      searchArgv: searchArgv

  refreshCompareResult: (compareArgv)->
    @compareResult = []
    for item, index in compareArgv
      if item.numerator is -3
        numerator = @refs["numerator#{index}"]?.getValue()
        if not numerator
          numerator = 0
      else
        numerator = @getDataNum item.numerator
      if item.denominator is -3
        denominator = @refs["denominator#{index}"]?.getValue()
        if not denominator
          denominator = 0
      else
        denominator = @getDataNum item.denominator
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
  handleStatisticsPaneShow: ->
    {statisticsPaneShow} = @state
    statisticsPaneShow = not statisticsPaneShow
    @setState {statisticsPaneShow}
  handleClickCheckbox: (index) ->
    {rowChooseChecked} = @props
    rowChooseChecked[index] = !rowChooseChecked[index]
    @props.tabFilterRules rowChooseChecked
    config.set "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify rowChooseChecked
  handleClickConfigCheckbox: (index) ->
    @props.configCheckboxClick index
  handleShowAmountSelect: (selectedKey)->
    @props.showRules selectedKey, @props.activePage
  handleShowPageSelect: (selectedKey)->
    @props.showRules @props.showAmount, selectedKey
  handleSearchChange: ()->
    {searchArgv} = @state
    for index in [0..searchArgv.length-1]
      searchArgv[index].filterKey = @refs["search#{index}"].getValue()
      searchArgv[index].searchBaseOn = parseInt @refs["baseOn#{index}"].getValue()
    @refreshSearchResult searchArgv
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
    @refreshSearchResult searchArgv

  handleCompareChange: ()->
    {compareArgv} = @state
    for index in [0..compareArgv.length-1]
      compareArgv[index]['numerator'] = parseInt @refs["numerator#{index}"].getValue()
      compareArgv[index]['denominator'] = parseInt @refs["denominator#{index}"].getValue()
    @setState
      compareArgv: compareArgv
  addCompareLine: ->
    {compareArgv} = @state
    compareArgv.push
      numerator: -1
      denominator: -1
    @setState
      compareArgv: compareArgv
  deleteCompareLine: (index)->
    {compareArgv} = @state
    compareArgv.splice index, 1
    @setState
      compareArgv: compareArgv
  componentWillMount: ->
    @refreshSearchResult @state.searchArgv
    @refreshCompareResult @state.compareArgv
  componentWillReceiveProps: (nextProps)->
    @refreshSearchResult @state.searchArgv
  componentWillUpdate: (nextProps, nextState)->
    @refreshCompareResult nextState.compareArgv
  render: ->
    <div className='akashic-records-settings' className={if @state.filterPaneShow or @state.statisticsPaneShow then "tap-pane-show" else "tab-pane-hidden"}>
      <Grid>
        <Row>
          <Col xs={12}>
            <div onClick={@handleFilterPaneShow}>
              <Divider text="筛选" icon={true} hr={true} show={@state.filterPaneShow}/>
            </div>
          </Col>
        </Row>
      </Grid>
      <Grid className='akashic-records-filter' style={if @state.filterPaneShow then {display: 'block'} else {display: 'none'} }>
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
              <DropdownButton bsSize='xsmall' center eventKey={4} title={"显示#{@props.showAmount}条"} block>
                <MenuItem center eventKey=10 onSelect={@handleShowAmountSelect}>{"显示10条"}</MenuItem>
                <MenuItem eventKey=20 onSelect={@handleShowAmountSelect}>{"显示20条"}</MenuItem>
                <MenuItem eventKey=50 onSelect={@handleShowAmountSelect}>{"显示50条"}</MenuItem>
                <MenuItem divider />
                <MenuItem eventKey=999999 onSelect={@handleShowAmountSelect}>{"显示全部"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={2}>
            <ButtonGroup justified>
              <DropdownButton bsSize='xsmall' eventKey={4} title={"第#{@props.activePage}页"} block>
              {
                if @props.dataShowLength isnt 0
                  for index in [1..Math.ceil(@props.dataShowLength/@props.showAmount)]
                    <MenuItem eventKey={index} onSelect={@handleShowPageSelect}>第{index}页</MenuItem>
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
      </Grid>
      <Grid>
        <Row>
          <Col xs={12}>
            <div onClick={@handleStatisticsPaneShow}>
              <Divider text="统计" icon={true} hr={true} show={@state.statisticsPaneShow}/>
            </div>
          </Col>
        </Row>
      </Grid>
      <Grid className='akashic-records-statistics' style={if @state.statisticsPaneShow then {display: 'block'} else {display: 'none'} }>
        <Row>
          <Col xs={12}>
            <Table bordered responsive>
              <thead>
                <tr>
                  <th style={verticalAlign: 'middle'}><FontAwesome name='question-circle'/></th>
                  <th>No.</th>
                  <th>基于</th>
                  <th>关键词</th>
                  <th>命中数</th>
                  <th>总样本</th>
                  <th>百分比</th>
                </tr>
              </thead>
              <tbody>
              {
                for index in [0..@state.searchArgv.length-1]
                  <tr>
                    {
                      if index is 0
                        <td style={verticalAlign: 'middle'}><FontAwesome name='plus-circle' onClick={@addSearchLine}/></td>
                      else
                        <td style={verticalAlign: 'middle'}><FontAwesome name='minus-circle' onClick={@deleteSearchLine.bind(@, index)}/></td>
                    }
                    <td>{index+1}</td>
                    <td>
                      <Input type="select" ref="baseOn#{index}" groupClassName='search-area' value={"#{@state.searchArgv[index].searchBaseOn}"} onChange={@handleSearchChange}>
                        <option key={-2} value={-2}>所有数据</option>
                        <option key={-1} value={-1}>经过表格筛选</option>
                        {
                          for i in [0..@state.searchArgv.length-1]
                            break if i >= index
                            <option key={i} value={i}>{"No.#{i+1}搜索结果"}</option>
                        }
                      </Input>
                    </td>
                    <td>
                       <Input
                          type='text'
                          value={@state.searchArgv[index].filterKey}
                          placeholder={"关键词"}
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
                  <th>分子项</th>
                  <th>分母项</th>
                  <th>分子数</th>
                  <th>分母数</th>
                  <th>百分比</th>
                </tr>
              </thead>
              <tbody>
              {
                for index in [0..@state.compareArgv.length-1]
                  <tr>
                    {
                      if index is 0
                        <td style={verticalAlign: 'middle'}><FontAwesome name='plus-circle' onClick={@addCompareLine}/></td>
                      else
                        <td style={verticalAlign: 'middle'}><FontAwesome name='minus-circle' onClick={@deleteCompareLine.bind(@, index)}/></td>
                    }
                    <td>{index+1}</td>
                    <td>
                      <Input type="select" ref="numerator#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index]['numerator']}"} onChange={@handleCompareChange}>
                        <option key={-2} value={-2}>所有数据</option>
                        <option key={-1} value={-1}>经过表格筛选</option>
                        {
                          for i in [0..@state.searchArgv.length-1]
                            <option key={i} value={i}>{"No.#{i+1}搜索结果"}</option>
                        }
                        <option key={-3} value={-3}>自定义</option>
                      </Input>
                    </td>
                    <td>
                      <Input type="select" ref="denominator#{index}" groupClassName='search-area' value={"#{@state.compareArgv[index]['denominator']}"} onChange={@handleCompareChange}>
                        <option key={-2} value={-2}>所有数据</option>
                        <option key={-1} value={-1}>经过表格筛选</option>
                        {
                          for i in [0..@state.searchArgv.length-1]
                            <option key={i} value={i}>{"No.#{i+1}搜索结果"}</option>
                        }
                        <option key={-3} value={-3}>自定义</option>
                      </Input>
                    </td>
                    {
                      if @state.compareArgv[index].numerator is -3
                        <td>
                          <Input
                            type='text'
                            placeholder={"0"}
                            value={"0"}
                            ref="numerator#{index}"
                            groupClassName='search-area'
                            onChange={@handleCompareChange} />
                        </td>
                      else
                        <td>{@compareResult[index].numerator}</td>
                    }
                    {
                      if @state.compareArgv[index].denominator is -3
                        <td>
                          <Input
                            type='text'
                            placeholder={"0"}
                            value={"0"}
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
      </Grid>
    </div>

module.exports = AkashicRecordsCheckboxArea
