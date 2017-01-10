import React from 'react'
import { logCP as CheckboxPanel} from './containers/checkbox-panel'
import StatisticsPanel from './containers/statistics-panel'
import VisibleTable from './containers/visible-table'


const AkashicLog = React.createClass({
  shouldComponentUpdate: () => false,
  render: () => (
    <div>
      <CheckboxPanel contentType={this.props.contentType} />
      <StatisticsPanel contentType={this.props.contentType} />
      <VisibleTable contentType={this.props.contentType} />
    </div>
  ),
})

export default AkashicLog
