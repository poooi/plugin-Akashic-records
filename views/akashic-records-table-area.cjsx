{React, ReactBootstrap, path, ROOT} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, Input, Pager, PageItem} = ReactBootstrap
{log, warn, error} = require path.join(ROOT, 'lib/utils')

AkashicRecordsTableTbodyItem = React.createClass
  render: ->
    <tr>
      <td>{@props.index}</td>
      {
        for item,index in @props.data
          if index is 0 and @props.rowChooseChecked[1]
            <td>{(new Date(item)).toString()}</td>
          else
            <td>{item}</td> if @props.rowChooseChecked[index+1] 
      }
    </tr>

AkashicRecordsTableArea = React.createClass
  getInitialState: ->
    tableTab: ['NO', 
    '时间', '海域', '地图点', '出击', '战况', '敌舰队', 
    '捞', '大破情况', '旗舰', '旗舰（第二舰队）', 'MVP', 'MVP(第二舰队）']
    dataShow: []
    showAmount: 10
    filterKey: ''
    pageIndex: 1
  _filter: (rawData, keyWord)->
    {rowChooseChecked} = @props
    if keyWord?
      rawData.filter (row)->
        match = false
        for item, index in row
          continue if index is 0
          if rowChooseChecked[index+1]
            if item.toLowerCase().trim().indexOf(keyWord.toLowerCase().trim()) >= 0
              match = true
        match
    else rawData
  _filterBy: (keyWord)->
    dataShow = @_filter @props.data
    @setState 
      dataShow: dataShow
      filterKey: keyWord
  handleKeyWordChange: ->
    keyWord = @refs.input.getValue()
    @_filterBy keyWord
  componentWillMount: ->
    log "componentWillMount"
    @setState 
      dataShow: @props.data
      filterKey: ''
  componentWillReceiveProps: (nextProps)->
    dataShow = @_filter nextProps.data, @filterKey
    @setState
      dataShow: dataShow
    log "componentWillReceiveProps"
    @handleKeyWordChange
  shouldComponentUpdate: ->
    log "shouldComponentUpdate"
    true
  componentWillUpdate: ->
    log "componentWillUpdate"
    true
  componentDidUpdate: ->
    log "componentDidUpdate "
  handleShowAmountSelect: (selectedKey)->
    @setState
      showAmount: selectedKey
  handleShowPageSelect: (selectedKey)->
    if selectedKey is 0
      selectedKey = @state.pageIndex-1
    else if selectedKey is -1
      selectedKey = @state.pageIndex+1
    if selectedKey < 1
      selectedKey = selectedKey+1
    else if selectedKey > (Math.ceil(@state.dataShow.length/@state.showAmount))
      selectedKey = Math.ceil(@state.dataShow.length/@state.showAmount)
    @setState
      pageIndex: selectedKey
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
                <MenuItem eventKey=0 onSelect={@handleShowAmountSelect}>{"显示全部"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton eventKey={4} title={"第#{@state.pageIndex}页"} block>
              {
                num = 40
                for index in [1..num]
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
                    for tab, index in @state.tableTab
                      <th>{tab}</th> if @props.rowChooseChecked[index]
                  }
                </tr>
              </thead>
              <tbody>
                {
                  for item, index in @state.dataShow
                    <AkashicRecordsTableTbodyItem 
                      key = {index}
                      index = {index+1};
                      data={item} 
                      rowChooseChecked={@props.rowChooseChecked}
                    />
                }
              </tbody>
            </Table>
          </Col>
        </Row>
        <Row> 
          <Pager activeKey={0}>
            <PageItem previous eventKey={0} onSelect={@handleShowPageSelect}>&larr; Previous Page</PageItem>
            <PageItem eventKey={1} onSelect={@handleShowPageSelect}>1</PageItem>
            <PageItem eventKey={2} onSelect={@handleShowPageSelect}>2</PageItem>
            <PageItem eventKey={3} onSelect={@handleShowPageSelect}>3</PageItem>
            <PageItem eventKey={4} onSelect={@handleShowPageSelect}>4</PageItem>
            <PageItem eventKey={5} onSelect={@handleShowPageSelect}>5</PageItem>
            <PageItem next eventKey={-1} onSelect={@handleShowPageSelect}>Next Page &rarr;</PageItem>
          </Pager>
        </Row>

      </Grid>
    </div>

module.exports = AkashicRecordsTableArea
