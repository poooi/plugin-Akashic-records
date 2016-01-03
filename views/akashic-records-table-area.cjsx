{React, ReactBootstrap, ROOT, config, __, FontAwesome} = window
{Grid, Row, Col, Table, ButtonGroup, DropdownButton, MenuItem, Input, Pagination, OverlayTrigger, Popover} = ReactBootstrap
path = require 'path-extra'
{log, warn, error} = require path.join(ROOT, 'lib/utils')
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
  # getInitialState: ->
  #   dataShow: []
  #   showAmount: 10
  #   filterKey: ''
  #   activePage: 0
  # _filter: (rawData, keyWord)->
  #   {rowChooseChecked} = @props
  #   if keyWord?
  #     rawData.filter (row)->
  #       match = false
  #       for item, index in row
  #         if rowChooseChecked[index+1]
  #           if index is 0 and dateToString(new Date(item)).toLowerCase().trim().indexOf(keyWord.toLowerCase().trim()) >= 0
  #             match = true
  #           if index isnt 0 and "#{item}".toLowerCase().trim().indexOf(keyWord.toLowerCase().trim()) >= 0
  #             match = true
  #       match
  #   else rawData
  # _filterBy: (keyWord)->
  #   dataShow = @_filter @props.data, keyWord
  #   {activePage} = @state
  #   if activePage < 1
  #     activePage = 1
  #   if activePage > Math.ceil(dataShow.length/@state.showAmount)
  #     activePage = Math.ceil(dataShow.length/@state.showAmount)
  #   @setState
  #     dataShow: dataShow
  #     filterKey: keyWord
  #     activePage: activePage
  handleKeyWordChange: ->
    {filterKeys} = @props
    for tab, index in @props.tableTab
      continue if index is 0
      filterKeys[index] = @refs["input#{index}"].getValue() if @props.rowChooseChecked[index]
    @props.filterRules filterKeys
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
            <Table striped bordered condensed hover>
              <thead>
              {
                if @props.configChecked[2]
                  <tr>
                    {
                      showLabel = false
                      for filterKey, index in @props.filterKeys
                        if filterKey isnt ''
                          showLabel = true
                      for tab, index in @props.tableTab
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
                            <Input
                              type='text'
                              value={@props.filterKeys[index]}
                              label={if showLabel then @props.tableTab[index] else ''}
                              placeholder={@props.tableTab[index]}
                              ref="input#{index}"
                              groupClassName='filter-area'
                              onChange={@handleKeyWordChange} />
                          </th> if @props.rowChooseChecked[index]
                    }
                  </tr>
                else if @props.configChecked[0] and @props.configChecked[1]
                  <tr>
                    {
                      showLabel = false
                      for filterKey, index in @props.filterKeys
                        if filterKey isnt ''
                          showLabel = true
                      for tab, index in @props.tableTab
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
                            <Input
                              type='text'
                              value={@props.filterKeys[index]}
                              label={@props.tableTab[index]}
                              placeholder={@props.tableTab[index]}
                              ref="input#{index}"
                              groupClassName='filter-area'
                              onChange={@handleKeyWordChange} />
                          </th> if @props.rowChooseChecked[index]
                    }
                  </tr>
                else if @props.configChecked[0]
                  <tr>
                  {
                    for tab, index in @props.tableTab
                      <th key={index}>{@props.tableTab[index]}</th> if @props.rowChooseChecked[index]
                  }
                  </tr>
                else if @props.configChecked[1]
                  <tr>
                    {
                      showLabel = false
                      for filterKey, index in @props.filterKeys
                        if filterKey isnt ''
                          showLabel = true
                      for tab, index in @props.tableTab
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
                            <Input
                              type='text'
                              value={@props.filterKeys[index]}
                              placeholder={@props.tableTab[index]}
                              ref="input#{index}"
                              groupClassName='filter-area'
                              onChange={@handleKeyWordChange} />
                          </th> if @props.rowChooseChecked[index]
                    }
                  </tr>
              }
              </thead>
              <tbody>
                {
                  for item, index in @props.data
                    <AkashicRecordsTableTbodyItem
                      key = {item[0]}
                      index = {(@props.activePage-1)*@props.showAmount+index+1};
                      data={item}
                      rowChooseChecked={@props.rowChooseChecked}
                      contentType={@props.contentType}
                      tableTab={@props.tableTab}
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
