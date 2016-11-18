CheckboxPanel = (require './containers/checkbox-panel').logCP
import StatisticsPanel from './containers/statistics-panel'
import VisibleTable from './containers/visible-table'


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
