path = require 'path-extra'
{React, ReactBootstrap, $, err, config, ROOT} = window
{Grid, Row, Panel, Col} = ReactBootstrap

AkashicSenkaPersonal = React.createClass
  getInitialState: ->
    nickname: null
    updateTime: ""
  render: ->
    <Grid>
      <Col xs={12} md={3}>
         <Panel bsSize="large">
         <h3>施工中</h3></Panel>
      </Col>
    </Grid>

module.exports = AkashicSenkaPersonal
