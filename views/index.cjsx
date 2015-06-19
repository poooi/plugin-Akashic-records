{React, ReactBootstrap, $} = window
{TabbedArea, TabPane} = ReactBootstrap

# AkashicRecordTab = require './item-info-table-area'
# AkashicRecordContent = require './item-info-checkbox-area'
AkashicLog = require './akashic-records-log'

attackTableTab = ['No.', '时间', '海域', '地图点', '出击', '战况', '敌舰队', 
    '捞', '大破情况', '旗舰', '旗舰（第二舰队）', 'MVP', 'MVP(第二舰队）']

AkashicRecordsArea = React.createClass
  getInitialState: ->
    attackTableTab: ['NO', '时间', '海域', '地图点', '出击', '战况', '敌舰队', 
    '捞', '大破情况', '旗舰', '旗舰（第二舰队）', 'MVP', 'MVP(第二舰队）']

  render: ->
    <TabbedArea defaultActiveKey={0}>
      <TabPane eventKey={0} tab='出击'><AkashicLog tableTab={@state.attackTableTab}/></TabPane>
      <TabPane eventKey={1} tab='远征'></TabPane>
      <TabPane eventKey={2} tab='建造'></TabPane>
      <TabPane eventKey={3} tab='开发'></TabPane>
      <TabPane eventKey={4} tab='资源统计'></TabPane>
      <TabPane eventKey={5} tab='高级'></TabPane>
    </TabbedArea>

React.render <AkashicRecordsArea />, $('akashic-records')
