{React, ReactBootstrap} = window
{TabbedArea, TabPane} = ReactBootstrap

AkashicResourceChart = require './akashic-resource-chart'
AkashicResourceTable = require './akashic-resource-table'
resourceTab = ['No.', '时间', '燃料', '弹药', '钢材', '铝材', 
  '高速建造', '高速修复', '开发资材', '改修螺丝']

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
      <TabPane eventKey={1} tab='表' ><AkashicResourceTable data={@props.data} tableTab={resourceTab} /></TabPane>
    </TabbedArea>
    </div>

module.exports = AkashicResourceLog
