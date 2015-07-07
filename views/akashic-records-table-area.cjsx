{React, ReactBootstrap, path, ROOT, config} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, Input, Pagination} = ReactBootstrap
{log, warn, error} = require path.join(ROOT, 'lib/utils')

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

AkashicRecordsTableTbodyItem = React.createClass
  render: ->
    <tr>
      <td>{@props.index}</td>
      {
        for item,index in @props.data
          if index is 0 and @props.rowChooseChecked[1]
            <td>{dateToString(new Date(item))}</td>
          else
            <td>{item}</td> if @props.rowChooseChecked[index+1] 
      }
    </tr>

AkashicRecordsTableArea = React.createClass
  getInitialState: ->
    dataShow: []
    showAmount: 10
    filterKey: ''
    activePage: 0
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
    dataShow = @_filter @props.data, keyWord
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
    log "componentWillMount"
    if @props.data.length > 0
      activePage = 1
    else activePage = 0
    showAmount = config.get "plugin.Akashic.#{@props.contentType}.showAmount", 10
    @setState 
      dataShow: @props.data
      filterKey: ''
      activePage: activePage
      showAmount: showAmount
  componentWillReceiveProps: (nextProps)->
    dataShow = @_filter nextProps.data, @filterKey
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
    config.set "plugin.Akashic.#{@props.contentType}.showAmount", selectedKey
    @setState
      showAmount: selectedKey
      activePage: activePage
  handleShowPageSelect: (selectedKey)->
    @setState
      activePage: selectedKey
  handlePaginationSelect: (event, selectedEvent)->
    @setState
      activePage: selectedEvent.eventKey
  render: ->
    <div>
      <Grid>
        <Row>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton center eventKey={4} title={"显示#{@state.showAmount}条"} block>
                <MenuItem center eventKey=10 onSelect={@handleShowAmountSelect}>{"显示10条"}</MenuItem>
                <MenuItem eventKey=20 onSelect={@handleShowAmountSelect}>{"显示20条"}</MenuItem>
                <MenuItem eventKey=50 onSelect={@handleShowAmountSelect}>{"显示50条"}</MenuItem>
                <MenuItem divider />
                <MenuItem eventKey=999999 onSelect={@handleShowAmountSelect}>{"显示全部"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton eventKey={4} title={"第#{@state.activePage}页"} block>
              {
                if @state.dataShow.length isnt 0
                  for index in [1..Math.ceil(@state.dataShow.length/@state.showAmount)]
                    <MenuItem eventKey={index} onSelect={@handleShowPageSelect}>第{index}页</MenuItem>
              } 
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={6}>
            <Input
              type='text'
              value={@state.filterKey}
              placeholder='关键词'
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
                      <th>{tab}</th> if @props.rowChooseChecked[index]
                  }
                </tr>
              </thead>
              <tbody>
                { if @state.activePage > 0
                    for item, index in @state.dataShow.slice((@state.activePage-1)*@state.showAmount, @state.activePage*@state.showAmount)
                      <AkashicRecordsTableTbodyItem 
                        key = {index}
                        index = {(@state.activePage-1)*@state.showAmount+index+1};
                        data={item} 
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

module.exports = AkashicRecordsTableArea
