import { connect } from 'react-redux'
import { initializeLogs } from '../actions'
import AdvancedModule from '../components/akashic-advanced-module'

function mapStateToProps(state, ownProps) {
  const tabs = []
  for (const type of Object.keys(state)) {
    tabs[type] = state[type].tabs
  }
  return {
    attackData: state.attack.data,
    missionData: state.mission.data,
    createShipData: state.createship.data,
    createItemData: state.createitem.data,
    retirementData: state.retirement.data,
    resourceData: state.resource.data,
    tableTab: tabs,
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
