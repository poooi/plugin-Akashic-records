{React, ReactBootstrap, __} = window
{Tabs, Tab} = ReactBootstrap

#i18n = require '../node_modules/i18n'
# {__} = i18n

AkashicResourceChart = require './akashic-resource-chart'
AkashicResourceTable = require './akashic-resource-table'

AkashicResourceLog = React.createClass
  getInitialState: ->
    mapShowFlag: true
    selectedKey: 0

  handleSelectTab: (selectedKey)->
    if selectedKey is 0
      @setState
        mapShowFlag: true
        selectedKey: selectedKey
    else
      @setState
        mapShowFlag: false
        selectedKey: selectedKey
  render: ->
    <div>
    <Tabs activeKey={@state.selectedKey} animation={false} onSelect={@handleSelectTab}>
      <Tab eventKey={0} title={__ "Chart"} ><AkashicResourceChart data={@props.data} mapShowFlag={@state.mapShowFlag and @props.mapShowFlag}/></Tab>
      <Tab eventKey={1} title={__ "Table"} ><AkashicResourceTable data={@props.data} tableTab={@props.tableTab} /></Tab>
    </Tabs>
    </div>

module.exports = AkashicResourceLog
