import { join } from 'path-extra'
import React from 'react'
import { Tabs, Tab, Label } from 'react-bootstrap'

import CONST from '../lib/constant'
const { $ } = window

const { __ } = window.i18n['poi-plugin-akashic-records']

import AkashicLog from './akashic-records-log'
import AkashicResourceLog from './akashic-resource-log'
import AkashicAdvancedModule from './components/advanced-module'

import ErrorBoundary from './error-boundary'

if ($('#font-awesome')) {
  $('#font-awesome').setAttribute('href', require.resolve('font-awesome/css/font-awesome.css'))
}

// getUseItem: (id)->
//   switch id
//     when 10
//       "家具箱（小）"
//     when 11
//       "家具箱（中）"
//     when 12
//       "家具箱（大）"
//     when 50
//       "応急修理要員"
//     when 51
//       "応急修理女神"
//     when 54
//       "給糧艦「間宮」"
//     when 56
//       "艦娘からのチョコ"
//     when 57
//       "勲章"
//     when 59
//       "給糧艦「伊良湖」"
//     when 62
//       "菱餅"
//     else
//       "特殊的东西"

export class reactClass extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      mapShowFlag: false,
      selectedKey: 0,
      warning: '',
    }
  }

  handleResponse = (e) => {
    this.setState({ warning: e.detail.warning })
  }

  handleSelectTab = (selectedKey) => {
    this.setState({
      mapShowFlag: selectedKey === 5,
      selectedKey: selectedKey,
    })
  }

  componentDidCatch(error, info) {
    // eslint-disable-next-line
    console.log(error, info)
  }

  render() {
    return (
      <div id='akashic-records-main-wrapper'>
        <link rel="stylesheet" href={join(__dirname, '..', 'assets', 'main.css')} />
        <div style={{ 'fontSize': 18 }}>
          <Label bsStyle="danger">{this.state.warning}</Label>
        </div>
        <Tabs id="" activeKey={this.state.selectedKey} animation={false} onSelect={this.handleSelectTab}>
          <Tab eventKey={0} title={__("Sortie")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.attack}/>
          </Tab>
          <Tab eventKey={1} title={__("Expedition")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.mission}/>
          </Tab>
          <Tab eventKey={2} title={__("Construction")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.createShip}/>
          </Tab>
          <Tab eventKey={3} title={__("Development")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.createItem}/>
          </Tab>
          <Tab eventKey={4} title={__("Retirement")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.retirement}/>
          </Tab>
          <Tab eventKey={5} title={__("Resource")} >
            <ErrorBoundary component={AkashicResourceLog} mapShowFlag={this.state.mapShowFlag}/>
          </Tab>
          <Tab eventKey={6} title={__("Others")} >
            <ErrorBoundary component={AkashicAdvancedModule} />
          </Tab>
        </Tabs>
      </div>
    )
  }
}
