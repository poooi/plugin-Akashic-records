{React, ReactBootstrap, ROOT, config, __, FontAwesome, CONST} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, FormControl, Pagination, OverlayTrigger, Popover} = ReactBootstrap
import path from 'path-extra'
{log, warn, error} = require path.join(ROOT, 'lib/utils')
{openExternal} = require('electron').shell

#import i18n from '../node_modules/i18n'
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

showBattleDetail = (timestamp) ->
  try
    if not window.ipc?
      throw "#{__ "Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release."}"

    battleDetail = ipc.access 'BattleDetail'
    if not battleDetail?.showBattleWithTimestamp?
      throw "#{__ "In order to find the detailed battle log, you need to download the latest battle-detail plugin and enable it."}"

    timestamp = (new Date(timestamp)).getTime()
    battleDetail.showBattleWithTimestamp timestamp, (message) =>
      if message?
        window.toggleModal "Warning", "#{__ 'Battle Detail'}: #{message}"
  catch e
    window.toggleModal "Warning", e

AkashicRecordsTableTbodyItem = React.createClass
  #componentShouldUpdate
  render: ->
    <tr>
      <td>
      {
        if @props.contentType is 'attack'
          <FontAwesome name='info-circle' style={marginRight: 3} onClick={showBattleDetail.bind @, @props.data[0]}/>
      }
      {@props.index}
      </td>
      {
        for item,index in @props.data
          if index is 0 and @props.rowChooseChecked[1]
            <td key={index}>{dateToString(new Date(item))}</td>
          else if @props.contentType is 'attack' and @props.tableTab[index+1] is '大破舰'
            <td key={index} className="enable-auto-newline">{item}</td> if @props.rowChooseChecked[8]
          else
            <td key={index}>{item}</td> if @props.rowChooseChecked[index+1]
      }
    </tr>

AkashicRecordsTableArea = React.createClass
  componentWillMount: () ->
    @input = {}
  handleKeyWordChange: (index)->
    @props.onFilterKeySet index - 1,  @input["input#{index}"].value

  handlePaginationSelect: (key, selectedEvent)->
    @props.onActivePageSet selectedEvent.eventKey || key

  # componentDidUpdate: ()->
  #   console.log "Table Area Update"

  render: ->
    <div>
      <Grid>
        <Row>
          <Col xs={12}>
            <Table striped bordered condensed hover>
              <thead>
              {
                showLabel = @props.configListChecked.get(0)
                showFilter = @props.configListChecked.get(1)
                if @props.configListChecked.get(2)
                  showFilter = true
                  for filterKey, index in @props.filterKeys.toArray()
                    if @props.tabVisibility.get(index+1) and filterKey isnt ''
                      showLabel = true
                if showLabel and not showFilter
                  <tr>
                  {
                    for tab, index in @props.tableTab.toArray()
                      <th key={index}>{tab}</th> if @props.tabVisibility.get index
                  }
                  </tr>
                else if showLabel or showFilter
                  <tr>
                  {
                    for tab, index in @props.tableTab.toArray()
                      if index is 0
                        <th key={index}>
                          <OverlayTrigger trigger='click' rootClose={true} placement='right' overlay={
                            <Popover id="table-tips" title={__ "Tips"}>
                              <li>{__ "Disable filtering while hiding column"}</li>
                              <li>{__ "Support the Javascript's "}<a onClick={openExternal.bind(this, "http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>{"RegExp"}</a></li>
                            </Popover>
                            }>
                            <FontAwesome name='question-circle'/>
                          </OverlayTrigger>
                        </th>
                      else
                        <th key={index} className="table-search">
                          <FormControl
                            type='text'
                            label={if showLabel then @props.tableTab.get index else ''}
                            placeholder={@props.tableTab.get index}
                            ref={
                              do () =>
                                i = index
                                (ref) =>
                                  @input["input#{i}"] = ReactDOM.findDOMNode(ref)
                            }
                            groupClassName='filter-area'
                            value="#{@props.filterKeys.get(index-1)}"
                            onChange={@handleKeyWordChange.bind(@, index)} />
                        </th> if @props.tabVisibility.get index
                  }
                  </tr>
              }
              </thead>
              <tbody>
                {
                  startLogs = (@props.activePage - 1) * @props.showAmount
                  endLogs = Math.min(@props.activePage * @props.showAmount, @props.logs.size)
                  [startLogs...endLogs].map (index) =>
                    item = @props.logs.get(index)
                    <AkashicRecordsTableTbodyItem
                      key = {item[0]}
                      index = {index+1};
                      data={item}
                      rowChooseChecked={@props.tabVisibility.toArray()}
                      contentType={@props.contentType}
                      tableTab={@props.tableTab.toArray()}
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

module.exports = AkashicRecordsTableArea
