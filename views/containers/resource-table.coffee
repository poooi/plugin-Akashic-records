{__} = window
{connect} = require 'react-redux'
{setFilterKey, setActivePage,
setShowAmount, setTimeScale} = require '../actions'
TableArea = require '../components/akashic-resource-table-area'
{resourceFilter} = require '../selectors'

getPropsFromState = (state, dataType) =>
  data = resourceFilter state
  len = data.size

  tableTab: state.tabs
  tabVisibility: state.tabVisibility
  logs: data
  paginationItems: Math.ceil(len/state.showAmount)
  activePage: state.activePage
  showAmount: state.showAmount
  filterKey: state.filterKeys.get(0)
  timeScale: state.showTimeScale

mapStateToProps = (state, ownProps) =>
  if state[ownProps.contentType]?
    getPropsFromState(state[ownProps.contentType], ownProps.contentType)
  else
    {}

mapDispatchToProps = (dispatch, ownProps) =>
  onFilterKeySet: (key) =>
    dispatch setFilterKey(0, key, ownProps.contentType)
  onActivePageSet: (val) =>
    dispatch setActivePage(val, ownProps.contentType)
  onShowAmountSet: (val) =>
    dispatch setShowAmount(val, ownProps.contentType)
  onTimeScaleSet: (val) ->
    dispatch setTimeScale(val, ownProps.contentType)

module.exports = connect(
  mapStateToProps,
  mapDispatchToProps)(TableArea)
