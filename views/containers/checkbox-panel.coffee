{__} = window
{connect} = require 'react-redux'
{showCheckboxPanel, hiddenCheckboxPanel,
setTabVisibility, setShowAmount, setActivePage, setConfigList} =
  require '../actions'
logCP = require '../components/akashic-records-checkbox-panel'
resourceCP = require '../components/akashic-resource-checkbox-panel'

getPropsFromState = (state) =>
  show: state.checkboxVisible
  tableTab: state.tabs
  tabVisibility: state.tabVisibility
  showAmount: state.showAmount
  activePage: state.activePage
  configList: state.configList
  configListChecked: state.configListChecked

mapStateToProps = (state, ownProps) =>
  if state[ownProps.contentType]?
    getPropsFromState(state[ownProps.contentType])
  else
    {}

mapDispatchToProps = (dispatch, ownProps) =>
  setPanelVisibilitiy: (show) =>
    if show
      dispatch showCheckboxPanel(ownProps.contentType)
    else
      dispatch hiddenCheckboxPanel(ownProps.contentType)
  onCheckboxClick: (index, val) =>
    dispatch setTabVisibility(index, val, ownProps.contentType)
  onShowAmountSet: (val) =>
    dispatch setShowAmount(val, ownProps.contentType)
  onActivePageSet: (val) =>
    dispatch setActivePage(val, ownProps.contentType)
  onConfigListSet: (index) =>
    dispatch setConfigList(index, ownProps.contentType)

module.exports = 
  logCP: connect(
    mapStateToProps,
    mapDispatchToProps)(logCP)
  resourceCP: connect(
    mapStateToProps,
    mapDispatchToProps)(resourceCP)
