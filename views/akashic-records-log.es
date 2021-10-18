import React, { Component } from 'react'
import CheckboxPanel from './components/checkbox-panel'
import StatisticsPanel from './containers/statistics-panel'
import VisibleTable from './containers/visible-table'


class AkashicLog extends Component {
  shouldComponentUpdate = () => false

  render() {
    return (
      <div>
        <CheckboxPanel contentType={this.props.contentType} />
        <StatisticsPanel contentType={this.props.contentType} />
        <VisibleTable contentType={this.props.contentType} />
      </div>
    )
  }
}

export default AkashicLog
