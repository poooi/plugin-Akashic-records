{React, ReactBootstrap, __} = window
{TabbedArea, TabPane} = ReactBootstrap

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
    <TabbedArea activeKey={@state.selectedKey} animation={false} onSelect={@handleSelectTab}>
      <TabPane eventKey={0} tab={__ "Chart"} ><AkashicResourceChart data={@props.data} mapShowFlag={@state.mapShowFlag and @props.mapShowFlag}/></TabPane>
      <TabPane eventKey={1} tab={__ "Table"} ><AkashicResourceTable data={@props.data} tableTab={@props.tableTab} /></TabPane>
    </TabbedArea>
    </div>

module.exports = AkashicResourceLog
