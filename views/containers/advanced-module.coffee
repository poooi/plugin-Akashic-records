{__} = window
import { connect } from 'react-redux'
import { initializeLogs } from '../actions'
import AdvancedModule from '../components/akashic-advanced-module'

mapStateToProps = (state, ownProps) =>
  tabs = []
  for type, item of state
    tabs[type] = item.tabs
  attackData: state.attack.data
  missionData: state.mission.data
  createShipData: state.createship.data
  createItemData: state.createitem.data
  retirementData: state.retirement.data
  resourceData: state.resource.data
  tableTab: tabs

mapDispatchToProps = (dispatch, ownProps) =>
  onLogsReset: (logs, type) =>
    dispatch initializeLogs(logs, type)

module.exports = connect(
  mapStateToProps,
  mapDispatchToProps)(AdvancedModule)
