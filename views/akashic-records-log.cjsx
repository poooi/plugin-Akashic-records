CheckboxPanel = require './containers/checkbox-panel'
AkashicRecordsStatisticsPanel = require './akashic-records-statistics-panel'
VisibleTable = require './containers/visible-table'


AkashicLog = React.createClass
  shouldComponentUpdate: (nextProps, nextState)->
    false
  render: ->
    <div>
      <CheckboxPanel contentType={@props.contentType} />
      <AkashicRecordsStatisticsPanel
        contentType={@props.contentType}
      />
      <VisibleTable contentType={@props.contentType} />
    </div>

module.exports = AkashicLog
