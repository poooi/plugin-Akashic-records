{React, ReactBootstrap, jQuery} = window
{Grid, Col, Table} = ReactBootstrap

AkashicRecordsCheckboxArea = require './akashic-records-checkbox-area'
AkashicRecordsTableArea = require './akashic-records-table-area'

AttackLog = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
  dataLength: 0
  filterRules: (checked) ->
    @setState
      rowChooseChecked: checked
  shouldComponentUpdate: (nextProps, nextState)->
    refreshFlag = false
    for item, i in @state.rowChooseChecked
      if item isnt nextState.rowChooseChecked[i]
        refreshFlag = true
    if nextProps.data.length isnt @dataLength
      refreshFlag = true
      @dataLength = nextProps.data.length
    if refreshFlag
      console.log "should update log"
    else console.log "should not update log"
    refreshFlag
  render: ->
    <div>
      <AkashicRecordsCheckboxArea tableTab={@props.tableTab} filterRules={@filterRules}/>
      <AkashicRecordsTableArea tableTab={@props.tableTab} data={@props.data} rowChooseChecked={@state.rowChooseChecked} />
    </div>

module.exports = AttackLog
