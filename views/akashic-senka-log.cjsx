{React, ReactBootstrap} = window
{TabbedArea, TabPane} = ReactBootstrap

AkashicSenkaPersonal = require './akashic-senka-personal'
AkashicSenkaServer = require './akashic-senka-server'

AkashicSenkaLog = React.createClass
  getInitialState: ->
    rankShowFlag: true
    selectedKey: 0
  memberId: 0

  handleSelectTab: (selectedKey)->
    if selectedKey is 0
      @setState
        rankShowFlag: true
        selectedKey: selectedKey
    else
      @setState
        rankShowFlag: false
        selectedKey: selectedKey
  render: ->
    <div>
      <TabbedArea activeKey={@state.selectedKey} animation={false} onSelect={@handleSelectTab}>
        <TabPane eventKey={0} tab='个人' ><AkashicSenkaPersonal rankShowFlag={@state.rankShowFlag and @props.rankShowFlag}/></TabPane>
        <TabPane eventKey={1} tab='镇守府' ><AkashicSenkaServer downloadFlag={@props.downloadFlag} memberId={@props.memberId} tableTab={@props.tableTab} /></TabPane>
      </TabbedArea>
    </div>

module.exports = AkashicSenkaLog
