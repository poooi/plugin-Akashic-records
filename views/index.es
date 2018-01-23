import { Provider } from 'react-redux'
import { createStore } from 'redux'
import arApp from './reducers'

const store = createStore(arApp)

window.getState = () => store.getState()

import React from 'react'
import ReactDOM from 'react-dom'
import { Tabs, Tab, Label } from 'react-bootstrap'
const { $, __, CONST } = window

import APIResolver from './api-resolver'

const apiResolver = new APIResolver(store)

import AkashicLog from './akashic-records-log'
import AkashicResourceLog from './akashic-resource-log'
import AkashicAdvancedModule from './containers/advanced-module'

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

class AkashicRecordsArea extends React.Component {
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
  componentDidMount() {
    apiResolver.start()
  }
  componentWillUnmount() {
    apiResolver.stop()
  }
  handleSelectTab = (selectedKey) => {
    this.setState({
      mapShowFlag: selectedKey === 5,
      selectedKey: selectedKey,
    })
  }

  componentDidCatch(error, info) {
    console.log(error, info)
  }

  render() {
    return (
      <div>
        <div  style={{ 'fontSize': 18 }}>
          <Label bsStyle="danger">{this.state.warning}</Label>
        </div>
        <Tabs id="" activeKey={this.state.selectedKey} animation={false} onSelect={this.handleSelectTab}>
          <Tab id="0" eventKey={0} title={__("Sortie")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.attack}/>
          </Tab>
          <Tab id="1" eventKey={1} title={__("Expedition")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.mission}/>
          </Tab>
          <Tab id="2" eventKey={2} title={__("Construction")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.createShip}/>
          </Tab>
          <Tab id="3" eventKey={3} title={__("Development")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.createItem}/>
          </Tab>
          <Tab id="4" eventKey={4} title={__("Retirement")} >
            <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.retirement}/>
          </Tab>
          <Tab id="5" eventKey={5} title={__("Resource")} >
            <ErrorBoundary component={AkashicResourceLog} mapShowFlag={this.state.mapShowFlag}/>
          </Tab>
          <Tab id="6" eventKey={6} title={__("Others")} >
            <ErrorBoundary component={AkashicAdvancedModule} />
          </Tab>
        </Tabs>
      </div>
    )
  }
}

ReactDOM.render(
  <Provider store={store}>
    <AkashicRecordsArea />
  </Provider>,
  $('akashic-records')
)
