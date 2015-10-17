{React, ReactBootstrap, __} = window
{Tabs, Tab} = ReactBootstrap

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
      <Tabs activeKey={@state.selectedKey} animation={false} onSelect={@handleSelectTab}>
        <Tab eventKey={0} title={__ "Personal"} ><AkashicSenkaPersonal rankShowFlag={@state.personalShowFlag and @props.personalShowFlag}/></Tab>
        <Tab eventKey={1} title={__ "Server"} ><AkashicSenkaServer memberId={@props.memberId} tableTabs{@props.tableTab} /></Tab>
      </Tabs>
    </div>

module.exports = AkashicSenkaLog
