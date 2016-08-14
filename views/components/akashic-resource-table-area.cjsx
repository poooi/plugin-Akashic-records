path = require 'path-extra'

{React, ReactBootstrap, ROOT, __} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, FormControl, Pagination} = ReactBootstrap
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

AkashicResourceTableArea = React.createClass
  handleKeyWordChange: ->
    @props.onFilterKeySet @input.value
  handleShowAmountSelect: (eventKey, selectedKey)->
    config.set "plugin.Akashic.resource.showAmount", eventKey
    @props.onShowAmountSet eventKey
  handleShowPageSelect: (eventKey, selectedKey)->
    @props.onActivePageSet eventKey
  handleTimeScaleSelect: (eventKey, selectedKey)->
    config.set "plugin.Akashic.resource.table.showTimeScale", eventKey
    @props.onTimeScaleSet eventKey
  handlePaginationSelect: (eventKey)->
    @props.onActivePageSet eventKey

  render: ->
    <div>
      <Grid>
        <Row>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton  id="dropdown-showScale-selector" center eventKey={4} title={__ "Show by %s", "#{if @props.timeScale then  __ 'Day' else __ 'Hour'}"}>
                <MenuItem center eventKey=0 onSelect={@handleTimeScaleSelect}>{__ "Show by %s", __ "Hour"}</MenuItem>
                <MenuItem eventKey=1 onSelect={@handleTimeScaleSelect}>{__ "Show by %s", __ "Day"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton center  id="dropdown-showOption-selector" eventKey={4} title={__ "Newer %s", "#{@props.showAmount}"}>
                <MenuItem center eventKey=10 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "10"}</MenuItem>
                <MenuItem eventKey=20 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "20"}</MenuItem>
                <MenuItem eventKey=50 onSelect={@handleShowAmountSelect}>{__ "Newer %s", "50"}</MenuItem>
                <MenuItem divider />
                <MenuItem eventKey=999999 onSelect={@handleShowAmountSelect}>{__ "View All"}</MenuItem>
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton eventKey={4}  id="dropdown-page-selector" title={__ "Page %s", "#{@props.activePage}"}>
              {
                if @props.logs.size isnt 0
                  for index in [1..@props.paginationItems]
                    <MenuItem key={index} eventKey={index} onSelect={@handleShowPageSelect}>{__ "Page %s", "#{index}"}</MenuItem>
              }
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={3}>
            <FormControl
              type='text'
              value={@props.filterKey}
              placeholder={__ "Keywords"}
              hasFeedback
              ref={(ref) => @input = ReactDOM.findDOMNode(ref)}
              onChange={@handleKeyWordChange} />
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <Table striped bordered condensed hover Responsive>
              <thead>
                <tr>
                  {
                    for tab, index in @props.tableTab.toArray()
                      <th key={index}>{tab}</th> if @props.tabVisibility.get(index)
                  }
                </tr>
              </thead>
              <tbody>
              {
                startLogs = (@props.activePage - 1) * @props.showAmount
                endLogs = Math.min(@props.activePage * @props.showAmount, @props.logs.size)
                [startLogs...endLogs].map (index) =>
                  item = @props.logs.get(index)
                  if index + 1 < @props.logs.size
                    lastFlag = false
                    nextItem =@props.logs.get(index + 1)
                  else
                      lastFlag = true
                      nextItem = []
                  <AkashicResourceTableTbodyItem
                    key = {item[0]}
                    index = {index+1};
                    data={item}
                    nextdata={nextItem}
                    lastFlag={lastFlag}
                    rowChooseChecked={@props.tabVisibility.toArray()}
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
                maxButtons={Math.min(@props.paginationItems, 5)}
                activePage={@props.activePage}
                onSelect={@handlePaginationSelect}
              />
            </Col>
          </Row>
      </Grid>
    </div>

module.exports = AkashicResourceTableArea
