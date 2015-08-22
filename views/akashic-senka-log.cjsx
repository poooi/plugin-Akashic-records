{React, ReactBootstrap, __} = window
{TabbedArea, TabPane} = ReactBootstrap

#i18n = require '../node_modules/i18n'
# {__} = i18n

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
        <TabPane eventKey={0} tab={__ "Personal"} ><AkashicSenkaPersonal rankShowFlag={@state.personalShowFlag and @props.personalShowFlag}/></TabPane>
        <TabPane eventKey={1} tab={__ "Server"} ><AkashicSenkaServer memberId={@props.memberId} tableTab={@props.tableTab} /></TabPane>
      </TabbedArea>
    </div>

module.exports = AkashicSenkaLog
