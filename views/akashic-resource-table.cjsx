{React, ReactBootstrap, jQuery} = window
{Grid, Col, Table} = ReactBootstrap

AkashicResourceCheckboxArea = require './akashic-resource-checkbox-area'
AkashicResourceTableArea = require './akashic-resource-table-area'

dateToDateString = (datetime)->
  date = new Date(datetime)
  "#{date.getFullYear()}#{date.getMonth() + 1}#{date.getDate()}"
AkashicResourceTable = React.createClass
  getInitialState: ->
    rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
  dataLength: 0
  rowChooseChecked: [true, true, true, true, true, true, true, true, true, true, true, true,
                      true, true]
  filterRules: (checked) ->
    @setState
      rowChooseChecked: checked
  shouldComponentUpdate: (nextProps, nextState)->
    refreshFlag = false
    for item, i in @rowChooseChecked
      if item isnt nextState.rowChooseChecked[i]
        @rowChooseChecked[i] = nextState.rowChooseChecked[i]
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
      <AkashicResourceCheckboxArea tableTab={@props.tableTab} filterRules={@filterRules}/>
      <AkashicResourceTableArea tableTab={@props.tableTab} data={@props.data} rowChooseChecked={@state.rowChooseChecked} />
    </div>

module.exports = AkashicResourceTable
