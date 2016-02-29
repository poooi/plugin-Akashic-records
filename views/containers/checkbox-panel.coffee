{__} = window
{connect} = require 'react-redux'
{setTabVisibility, setShowAmount, setActivePage, setConfigList} =
  require '../actions'
CheckboxPanel = require '../components/akashic-records-checkbox-panel'

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
  onCheckboxClick: (index) =>
    dispatch setTabVisibility(index, ownProps.contentType)
  onShowAmountSet: (val) =>
    dispatch setShowAmount(val, ownProps.contentType)
  onActivePageSet: (val) =>
    dispatch setActivePage(val, ownProps.contentType)
  onConfigListSet: (index) =>
    dispatch setConfigList(val, ownProps.contentType)

module.exports = connect(
  mapStateToProps,
  mapDispatchToProps)(CheckboxPanel)
