path = require 'path-extra'

{React, ReactBootstrap, ROOT, __} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, Input, Pagination} = ReactBootstrap
{log, warn, error} = require path.join(ROOT, 'lib/utils')

# i18n = require '../node_modules/i18n'
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

AkashicResourceTableTbodyItem = React.createClass
  render: ->
    <tr>
      <td>{@props.index}</td>
      {
        for item,index in @props.data
          if index is 0 and @props.rowChooseChecked[1]
            <td key={index}>{dateToString(new Date(item))}</td>
          else
            if @props.rowChooseChecked[index+1]
              if @props.lastFlag
                <td key={index}>{item}</td>
              else
                flag = ""
                diff = item - @props.nextdata[index]
                if diff > 0
                  diff = "+#{diff}"
                <td key={index}>{"#{item}(#{diff})"}</td>
      }
    </tr>

dateToDateString = (datetime)->
  date = new Date(datetime)
  "#{date.getFullYear()}/#{date.getMonth()}/#{date.getDate()}"

AkashicResourceTableArea = React.createClass
  getInitialState: ->
    dataShow: []
    showAmount: 10
    filterKey: ''
    activePage: 0
    showScale: "小时"
  dataAsScale: []
  filterAsScale: (data, showScale)->
    if showScale is "小时"
      data
    else
      dateString = ""
      data.filter (dataitem)->
        tmp = dateToDateString dataitem[0]
        if tmp isnt dateString
          dateString = tmp
          true
        else
          false
  _filter: (rawData, keyWord)->
    {rowChooseChecked} = @props
    if keyWord?
      rawData.filter (row)->
        match = false
        for item, index in row
          if rowChooseChecked[index+1]
            if index is 0 and dateToString(new Date(item)).toLowerCase().trim().indexOf(keyWord.toLowerCase().trim()) >= 0
              match = true
            if index isnt 0 and "#{item}".toLowerCase().trim().indexOf(keyWord.toLowerCase().trim()) >= 0
              match = true
        match
    else rawData
  _filterBy: (keyWord)->
    dataShow = @_filter @dataAsScale, keyWord
    {activePage} = @state
    if activePage < 1
      activePage = 1
    if activePage > Math.ceil(dataShow.length/@state.showAmount)
      activePage = Math.ceil(dataShow.length/@state.showAmount)
    @setState
      dataShow: dataShow
      filterKey: keyWord
      activePage: activePage
  handleKeyWordChange: ->
    keyWord = @refs.input.getValue()
    @_filterBy keyWord
  componentWillMount: ->
    if @props.data.length > 0
      activePage = 1
    else activePage = 0
    showAmount = config.get "plugin.Akashic.resource.table.showAmount", 10
    showScale = config.get "plugin.Akashic.resource.table.showScale", "天"
    @setState
      dataAsScale: @props.data
      dataShow: []
      filterKey: ''
      activePage: activePage
      showAmount: showAmount
      showScale: showScale
  componentWillReceiveProps: (nextProps)->
    @dataAsScale = @filterAsScale(nextProps.data, @state.showScale)
    dataShow = @_filter @dataAsScale, @filterKey
    {activePage} = @state
    if activePage < 1
      activePage = 1
    if activePage > Math.ceil(dataShow.length/@state.showAmount)
      activePage = Math.ceil(dataShow.length/@state.showAmount)
    @setState
      dataShow: dataShow
      activePage: activePage
  handleShowAmountSelect: (selectedKey)->
    {activePage} = @state
    if activePage < 0
      activePage = 1
    if activePage > Math.ceil(@state.dataShow.length/selectedKey)
      activePage = Math.ceil(@state.dataShow.length/selectedKey)
    config.set "plugin.Akashic.resource.table.showAmount", selectedKey
    @setState
      showAmount: selectedKey
      activePage: activePage
  handleShowPageSelect: (selectedKey)->
    # if selectedKey is 0
    #   selectedKey = 1
    # else if selectedKey is -1
    #   selectedKey = Math.ceil(@state.dataShow.length/@state.showAmount)
    # if selectedKey < 1
    #   selectedKey = selectedKey+1
    # else if selectedKey > (Math.ceil(@state.dataShow.length/@state.showAmount))
    #   selectedKey = Math.ceil(@state.dataShow.length/@state.showAmount)
    @setState
      activePage: selectedKey
  handlePaginationSelect: (event, selectedEvent)->
    @setState
      activePage: selectedEvent.eventKey
  handleShowScaleSelect: (selectedKey)->
    {activePage} = @state
    showScale = "小时"
    if selectedKey isnt 0
      showScale = "天"
    @dataAsScale = @filterAsScale @props.data, showScale
    dataShow = @_filter @dataAsScale, @filterKey
    if activePage > Math.ceil(dataShow.length/@state.showAmount)
      activePage = Math.ceil(dataShow.length/@state.showAmount)
    config.set "plugin.Akashic.resource.table.showScale", showScale
    @setState
      showScale: showScale
      dataShow: dataShow
      activePage: activePage
  render: ->
    <div>
      <Grid>
        <Row>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton center eventKey={4} title={__ "Show by %s", @state.showScale} block>
                <MenuItem center eventKey=0 onSelect={@handleShowScaleSelect}>{__ "Show by %s", __ "Hour"}</MenuItem>
                <MenuItem eventKey=1 onSelect={@handleShowScaleSelect}>{__ "Show by %s", __ "Day"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton center eventKey={4} title={__ "View newer %s", @state.showAmount} block>
                <MenuItem center eventKey=10 onSelect={@handleShowAmountSelect}>{__ "View newer %s", "10"}</MenuItem>
                <MenuItem eventKey=20 onSelect={@handleShowAmountSelect}>{__ "View newer %s", "20"}</MenuItem>
                <MenuItem eventKey=50 onSelect={@handleShowAmountSelect}>{__ "View newer %s", "50"}</MenuItem>
                <MenuItem divider />
                <MenuItem eventKey=999999 onSelect={@handleShowAmountSelect}>{__ "View all"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton eventKey={4} title={__ "Page %s", @props.activePage} block>
              {
                if @state.dataShow.length isnt 0
                  for index in [1..Math.ceil(@state.dataShow.length/@state.showAmount)]
                    <MenuItem key={index} eventKey={index} onSelect={@handleShowPageSelect}>{__ "Page %s", index}</MenuItem>
              }
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <Input
              type='text'
              value={@state.filterKey}
              placeholder={__ "Keywords"}
              hasFeedback
              ref='input'
              onChange={@handleKeyWordChange} />
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <Table striped bordered condensed hover Responsive>
              <thead>
                <tr>
                  {
                    for tab, index in @props.tableTab
                      <th key={index}>{tab}</th> if @props.rowChooseChecked[index]
                  }
                </tr>
              </thead>
              <tbody>
              {
                if @state.activePage > 0
                  for item, index in @state.dataShow.slice((@state.activePage-1)*@state.showAmount, @state.activePage*@state.showAmount)
                    if ((@state.activePage-1)*@state.showAmount+index+1) < @state.dataShow.length
                      lastFlag = false
                      nextItem = @state.dataShow[(@state.activePage-1)*@state.showAmount+index+1]
                    else
                      lastFlag = true
                      nextItem = []
                    <AkashicResourceTableTbodyItem
                      key = {index}
                      index = {(@state.activePage-1)*@state.showAmount+index+1};
                      data={item}
                      nextdata={nextItem}
                      lastFlag={lastFlag}
                      rowChooseChecked={@props.rowChooseChecked}
                    />
              }
              </tbody>
            </Table>
          </Col>
        </Row>
          <Row>
            <Col xs={12}>
              <Pagination className='akashic-table-pagination'
                prev={false}
                next={false}
                first={true}
                last={true}
                ellipsis={true}
                items={Math.ceil(@state.dataShow.length/@state.showAmount)}
                maxButtons={if Math.ceil(@state.dataShow.length/@state.showAmount)>5 then 5 else Math.ceil(@state.dataShow.length/@state.showAmount)}
                activePage={@state.activePage}
                onSelect={@handlePaginationSelect}
              />
            </Col>
          </Row>
      </Grid>
    </div>

module.exports = AkashicResourceTableArea
