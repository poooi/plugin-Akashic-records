CheckboxPanel = require './containers/checkbox-panel'
StatisticsPanel = require './containers/statistics-panel'
VisibleTable = require './containers/visible-table'


AkashicLog = React.createClass
  shouldComponentUpdate: (nextProps, nextState)->
    false
  render: ->
    <div>
      <CheckboxPanel contentType={@props.contentType} />
      <StatisticsPanel contentType={@props.contentType} />
      <VisibleTable contentType={@props.contentType} />
    </div>

module.exports = AkashicLog
