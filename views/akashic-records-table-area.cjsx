{React, ReactBootstrap, ROOT, config} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, Input, Pagination} = ReactBootstrap
path = require 'path-extra'
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
  # componentWillReceiveProps: (nextProps)->
  #   dataShow = @_filter nextProps.data, @filterKey
  #   {activePage} = @state
  #   if activePage < 1
  #     activePage = 1
  #   if activePage > Math.ceil(dataShow.length/@state.showAmount)
  #     activePage = Math.ceil(dataShow.length/@state.showAmount)
  #   @setState
  #     dataShow: dataShow
  #     activePage: activePage
  handlePaginationSelect: (event, selectedEvent)->
    @props.handlePageChange selectedEvent.eventKey
  render: ->
    <div>
      <Grid>
        <Row>
          <Col xs={12}>
            <Table striped bordered condensed hover Responsive>
              <thead>
                <tr>
                  {
                    for tab, index in @props.tableTab
                      if index is 0
                        <th>No.</th>
                      else
                        <th className="table-search">
                          <Input
                            type='text'
                            value={@state.filterKey}
                            label={"#{@props.tableTab[index]}"}
                            placeholder={"#{@props.tableTab[index]}"}
                            ref="input#{index}"
                            groupClassName='search-area'
                            onChange={@handleKeyWordChange} />
                        </th> if @props.rowChooseChecked[index]
                  }
                </tr>
              </thead>
              <tbody>
                {
                  for item, index in @props.data
                    <AkashicRecordsTableTbodyItem 
                      key = {item[0]}
                      index = {(@props.activePage-1)*@props.showAmount+index+1};
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
              items={@props.paginationItems}
              maxButtons={@props.paginationMaxButtons}
              activePage={@props.activePage}
              onSelect={@handlePaginationSelect}
            />
          </Col>
        </Row>
      </Grid>
    </div>

module.exports = AkashicRecordsTableArea
