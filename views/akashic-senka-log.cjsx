{React, ReactBootstrap} = window
{TabbedArea, TabPane} = ReactBootstrap

AkashicSenkaPersonal = require './akashic-senka-personal'
AkashicSenkaServer = require './akashic-senka-server'

AkashicSenkaLog = React.createClass
  getInitialState: ->
    personalShowFlag: true
    selectedKey: 1

  handleSelectTab: (selectedKey)->
    if selectedKey is 0
      @setState
        personalShowFlag: true
        selectedKey: selectedKey
    else
      @setState
        personalShowFlag: false
        selectedKey: selectedKey
  render: ->
    <div>
      <TabbedArea activeKey={@state.selectedKey} animation={false} onSelect={@handleSelectTab}>
        <TabPane eventKey={0} tab='个人' ><AkashicSenkaPersonal rankShowFlag={@state.personalShowFlag and @props.personalShowFlag}/></TabPane>
        <TabPane eventKey={1} tab='镇守府' ><AkashicSenkaServer memberId={@props.memberId} tableTab={@props.tableTab} /></TabPane>
      </TabbedArea>
    </div>

module.exports = AkashicSenkaLog
