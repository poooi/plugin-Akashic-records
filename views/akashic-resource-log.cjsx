{React, ReactBootstrap} = window
{TabbedArea, TabPane} = ReactBootstrap

AkashicResourceChart = require './akashic-resource-chart'

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
      <TabPane eventKey={0} tab='图' ><AkashicResourceChart data={@props.data} mapShowFlag={@state.mapShowFlag and @props.mapShowFlag}/></TabPane>
      <TabPane eventKey={1} tab='表' ><h2>TODO</h2></TabPane>
    </TabbedArea>
    </div>

module.exports = AkashicResourceLog
