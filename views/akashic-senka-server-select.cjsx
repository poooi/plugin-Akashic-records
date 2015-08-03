{React, ReactBootstrap, jQuery, config} = window
{Grid, Col, ButtonGroup, Button, Row, Input, option} = ReactBootstrap
Divider = require './divider'

AkashicSenkaServerSelect = React.createClass
  getInitialState: ->
    filterPaneShow: true
    statisticsPaneShow: true

  handleFilterPaneShow: ->
    {filterPaneShow} = @state
    filterPaneShow = not filterPaneShow
    @setState {filterPaneShow}
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
        <Col xs={12} md={6}>
         <h5>镇守府</h5>
         <Input type='select' value={@props.serverId} onChange={@props.handleFilterSelect}>
           {
             for server, index in @props.serverNames
               <option key={index} value={index}>{server}</option>
           }
         </Input>
        </Col>
        <Col xs={6} md={6}>
          <Button onClick={@props.handleCustomClick} block>{"1-100/500/990"}</Button>
        </Col>
        <Col xs={6} md={6}>
          <Button onClick={@props.handleMoreClick} block>{"1-990"}</Button>
        </Col>
      </Grid>
    </div>

module.exports = AkashicSenkaServerSelect
