{React, ReactBootstrap, path, ROOT} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, Input, Pager, PageItem} = ReactBootstrap
{log, warn, error} = require path.join(ROOT, 'lib/utils')

# can change Pager to Pagination

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
            <td>{dateToString(new Date(item))}</td>
          else
            if @props.rowChooseChecked[index+1]
              if @props.lastFlag
                <td>{item}</td> 
              else
                flag = ""
                diff = item - @props.nextdata[index]
                if diff > @props.nextdata[index]
                  diff = "+#{diff}"
                <td>{"#{item}(#{diff})"}</td> 
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
    pageIndex: 0
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
    @setState 
      dataShow: dataShow
      filterKey: keyWord
  handleKeyWordChange: ->
    keyWord = @refs.input.getValue()
    @_filterBy keyWord
  componentWillMount: ->
    log "componentWillMount"
    if @props.data.length > 0
      pageIndex = 1
    else pageIndex = 0
    @setState 
      dataAsScale: @props.data
      dataShow: []
      filterKey: ''
      pageIndex: pageIndex
  componentWillReceiveProps: (nextProps)->
    @dataAsScale = @filterAsScale(nextProps.data, @state.showScale)
    dataShow = @_filter @dataAsScale, @filterKey
    {pageIndex} = @state
    if pageIndex < 1
      pageIndex = 1
    if pageIndex > Math.ceil(dataShow.length/@state.showAmount)
      pageIndex = Math.ceil(dataShow.length/@state.showAmount)
    console.log "this point"
    @setState
      dataShow: dataShow
      pageIndex: pageIndex
  handleShowAmountSelect: (selectedKey)->
    {pageIndex} = @state    
    if pageIndex < 0
      pageIndex = 1
    if pageIndex > Math.ceil(@state.dataShow.length/selectedKey)
      pageIndex = Math.ceil(@state.dataShow.length/selectedKey)
    @setState
      showAmount: selectedKey
      pageIndex: pageIndex
  handleShowPageSelect: (selectedKey)->
    if selectedKey is 0
      selectedKey = 1
    else if selectedKey is -1
      selectedKey = Math.ceil(@state.dataShow.length/@state.showAmount)
    if selectedKey < 1
      selectedKey = selectedKey+1
    else if selectedKey > (Math.ceil(@state.dataShow.length/@state.showAmount))
      selectedKey = Math.ceil(@state.dataShow.length/@state.showAmount)
    @setState
      pageIndex: selectedKey
  handleShowScaleSelect: (selectedKey)->
    showScale = "小时"
    if selectedKey isnt 0
      showScale = "天"
    @dataAsScale = @filterAsScale @props.data, showScale
    dataShow = @_filter @dataAsScale, @filterKey
    @setState
      showScale: showScale
      dataShow: dataShow

  render: ->
    <div>
      <Grid>
        <Row>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton center eventKey={4} title={"显示#{@state.showScale}显示"} block>
                <MenuItem center eventKey=0 onSelect={@handleShowScaleSelect}>{"按小时显示"}</MenuItem>
                <MenuItem eventKey=1 onSelect={@handleShowScaleSelect}>{"按天显示"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
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
              <DropdownButton eventKey={4} title={"第#{@state.pageIndex}页"} block>
              {
                if @state.dataShow.length isnt 0
                  for index in [1..Math.ceil(@state.dataShow.length/@state.showAmount)]
                    <MenuItem eventKey={index} onSelect={@handleShowPageSelect}>第{index}页</MenuItem>
              } 
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
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
              {
                if @state.pageIndex > 0
                  for item, index in @state.dataShow.slice((@state.pageIndex-1)*@state.showAmount, @state.pageIndex*@state.showAmount)
                    if ((@state.pageIndex-1)*@state.showAmount+index+1) < @state.dataShow.length
                      lastFlag = false
                      nextItem = @state.dataShow[(@state.pageIndex-1)*@state.showAmount+index+1]
                    else
                      lastFlag = true
                      nextItem = []
                    <AkashicResourceTableTbodyItem 
                      key = {index}
                      index = {(@state.pageIndex-1)*@state.showAmount+index+1};
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
          <Pager activeKey={0}>
            <PageItem previous eventKey={0} onSelect={@handleShowPageSelect}>&larr; First Page</PageItem>
            {
              if @state.pageIndex < 5
                for i in [1..5]
                  break if i > Math.ceil(@state.dataShow.length/@state.showAmount) 
                  <PageItem eventKey={i} onSelect={@handleShowPageSelect}>{i}</PageItem>
              else if @state.pageIndex > (Math.ceil(@state.dataShow.length/@state.showAmount)-2)
                for i in [Math.ceil(@state.dataShow.length/@state.showAmount)-4..Math.ceil(@state.dataShow.length/@state.showAmount)]
                  continue if i<1
                  <PageItem eventKey={i} onSelect={@handleShowPageSelect}>{i}</PageItem>
              else 
                for i in [@state.pageIndex-2..@state.pageIndex+2]
                  <PageItem eventKey={i} onSelect={@handleShowPageSelect}>{i}</PageItem>
            }
            <PageItem next eventKey={-1} onSelect={@handleShowPageSelect}>Last Page &rarr;</PageItem>
          </Pager>
        </Row>

      </Grid>
    </div>

module.exports = AkashicResourceTableArea
