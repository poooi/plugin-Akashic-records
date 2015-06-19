{React, ReactBootstrap, jQuery} = window
{Grid, Col, Table} = ReactBootstrap

AkashicRecordsCheckboxArea = require './akashic-records-checkbox-area'
AkashicRecordsTableArea = require './akashic-records-table-area'

AttackLog = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]

  filterRules: (checked) ->
    @setState
      rowChooseChecked: checked

    data: [{'attacktime':'2015-05-15 20:35:03', 'attackmap':'testmap 1', 'point': 'test point 1', 
    'action': '出击' ,'result': '完全胜利', 'your':'敌侦查主力舰队', 'getship':'', 'dapo':'', 
    'firstship':'aaa', 'firstship2':'dsaf', 'mvp':'苍龙改二(LV.86)', 'mvp2':'苍龙改改'}, 
    {'attacktime':'2015-05-15 20:35:44', 'attackmap':'testmap 2', 'point': 'test point 2', 
    'action': '进击' ,'result': '胜利', 'your':'敌侦查主力舰队', 'getship':'aaa', 'dapo':'', 
    'firstship':'aaa', 'firstship2':'dsaf', 'mvp':'苍龙改二(LV.86)', 'mvp2':'苍龙改改'}]
  render: ->
    <div>
      <AkashicRecordsCheckboxArea tableTab={@props.tableTab} filterRules={@filterRules}/>
      <AkashicRecordsTableArea rowChooseChecked={@state.rowChooseChecked} />
    </div>

module.exports = AttackLog
