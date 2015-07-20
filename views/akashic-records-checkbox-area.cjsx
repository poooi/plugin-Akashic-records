{React, ReactBootstrap, jQuery, config} = window
{Panel, Button, Col, Input, Grid, Row, ButtonGroup, DropdownButton, MenuItem} = ReactBootstrap
Divider = require './divider'

AkashicRecordsCheckboxArea = React.createClass
  getInitialState: ->
    topPaneShow: true
  handlePaneShow: ->
    {topPaneShow} = @state
    topPaneShow = not topPaneShow
    @setState {topPaneShow}
  handleClickCheckbox: (index) ->
    {rowChooseChecked} = @props
    rowChooseChecked[index] = !rowChooseChecked[index]
    @props.tabFilterRules rowChooseChecked
    config.set "plugin.Akashic.#{@props.contentType}.checkbox", JSON.stringify rowChooseChecked
  handleShowAmountSelect: (selectedKey)->
    @props.showRules selectedKey, @props.activePage
  handleShowPageSelect: (selectedKey)->
    @props.showRules @props.showAmount, selectedKey
  render: ->
    <div id='akashic-records-settings'>
      <Grid>
        <Row>
          <Col xs={12}>
            <div onClick={@handlePaneShow}>
              <Divider text="筛选与统计" icon={true} show={@state.topPaneShow}/>
            </div>
          </Col>
        </Row>
      </Grid>
      <Grid id='akashic-records-filter' style={if @state.topPaneShow then {display: 'block'} else {display: 'none'} }>
        <Row>
        {
          for checkedVal, index in @props.tableTab
            continue if !index
            <Col key={index} xs={2}>
              <Input type='checkbox' value={index} onChange={@handleClickCheckbox.bind(@, index)} checked={@props.rowChooseChecked[index]} style={verticalAlign: 'middle'} label={checkedVal} />
            </Col>
        }
        </Row>
        <Row>
          <Col xs={3}>
            <ButtonGroup justified>
              <DropdownButton center eventKey={4} title={"显示#{@props.showAmount}条"} block>
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
              <DropdownButton eventKey={4} title={"第#{@props.activePage}页"} block>
              {
                if @props.dataShowLength isnt 0
                  for index in [1..Math.ceil(@props.dataShowLength/@props.showAmount)]
                    <MenuItem eventKey={index} onSelect={@handleShowPageSelect}>第{index}页</MenuItem>
              } 
              </DropdownButton>
            </ButtonGroup>
          </Col>
          <Col xs={6}>
            <Input
              type='text'
              value=''
              placeholder='关键词'
              hasFeedback
              ref='input'
              onChange={@handleKeyWordChange} />
          </Col>
        </Row>
      </Grid>
    </div>

module.exports = AkashicRecordsCheckboxArea
