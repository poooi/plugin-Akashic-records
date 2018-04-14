import { connect } from 'react-redux'
import _ from 'lodash'
import { initializeLogs } from '../actions'
import AdvancedModule from '../components/akashic-advanced-module'

import { pluginDataSelector, tableTabNameSelector } from '../selectors'

const emptyProps = {
  attackData: [],
  missionData: [],
  createShipData: [],
  createItemData: [],
  retirementData: [],
  resourceData: [],
  tableTab: {},
}

function mapStateToProps(poi_state, ownProps) {
  const state = pluginDataSelector(poi_state)
  if (_.isEmpty(state)) {
    return emptyProps
  }

  return {
    attackData: state.attack.data,
    missionData: state.mission.data,
    createShipData: state.createship.data,
    createItemData: state.createitem.data,
    retirementData: state.retirement.data,
    resourceData: state.resource.data,
    tableTab: tableTabNameSelector(state),
  }
}

function mapDispatchToProps(dispatch, ownProps) {
  return {
    onLogsReset: (logs, type) => dispatch(initializeLogs(logs, type)),
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(AdvancedModule)
