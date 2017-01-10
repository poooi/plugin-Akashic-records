import React from 'react'
import { Tabs, Tab } from 'react-bootstrap'
const { __ } = window
// import i18n from '../node_modules/i18n'
//  {__} = i18n

import ResourceChart from './containers/resource-chart'

import { resourceCP as CheckboxPanel } from './containers/checkbox-panel'
import TableArea from './containers/resource-table'

const AkashicResourceTable = () => (
  <div>
    <CheckboxPanel contentType='resource'/>
    <TableArea contentType='resource'/>
  </div>
)

class AkashicResourceLog extends React.Component {
  state = {
    mapShowFlag: true,
    selectedKey: 0,
    data: [],
  }

  handleSelectTab(selectedKey) {
    this.setState({
      mapShowFlag: selectedKey === 0,
      selectedKey: selectedKey,
    })
  }

  render() {
    return (
      <div>
        <Tabs activeKey={this.state.selectedKey} animation={false} onSelect={this.handleSelectTab}>
          <Tab eventKey={0} title={__("Chart")} ><ResourceChart mapShowFlag={this.state.mapShowFlag && this.props.mapShowFlag}/></Tab>
          <Tab eventKey={1} title={__("Table")} ><AkashicResourceTable /></Tab>
        </Tabs>
      </div>
    )
  }
}

module.exports = AkashicResourceLog
