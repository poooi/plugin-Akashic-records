import { connect } from 'react-redux'
import {
  showCheckboxPanel,
  hiddenCheckboxPanel,
  setTabVisibility,
  setShowAmount,
  setActivePage,
  setConfigList,
} from '../actions'
import logComponent from '../components/checkbox-panel'
import resourceComponent from '../components/akashic-resource-checkbox-panel'

import { pluginDataSelector } from '../selectors'

function getPropsFromState(state) {
  return {
    show: state.checkboxVisible,
    tableTab: state.tabs,
    tabVisibility: state.tabVisibility,
    showAmount: state.showAmount,
    activePage: state.activePage,
    configList: state.configList,
    configListChecked: state.configListChecked,
  }
}

function mapStateToProps(poi_state, ownProps) {
  const state = pluginDataSelector(poi_state)
  return (state[ownProps.contentType] != null)
    ? getPropsFromState(state[ownProps.contentType])
    : {}
}

function mapDispatchToProps(dispatch, ownProps) {
  return {
    setPanelVisibilitiy: (show) =>
      dispatch((show)
        ? showCheckboxPanel(ownProps.contentType)
        : hiddenCheckboxPanel(ownProps.contentType)),
    onCheckboxClick: (index, val) =>
      dispatch(setTabVisibility(index, val, ownProps.contentType)),
    onShowAmountSet: (val) =>
      dispatch(setShowAmount(val, ownProps.contentType)),
    onActivePageSet: (val) =>
      dispatch(setActivePage(val, ownProps.contentType)),
    onConfigListSet: (index) =>
      dispatch(setConfigList(index, ownProps.contentType)),
  }
}

export const ResourceCP =
  connect(mapStateToProps, mapDispatchToProps)(resourceComponent)
