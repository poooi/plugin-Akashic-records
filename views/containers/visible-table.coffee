{__} = window
import { connect } from 'react-redux'
import { setFilterKey, setActivePage } from '../actions'
import TableArea from '../components/akashic-records-table-area'
import { filterSelectors } from '../selectors'

getPropsFromState = (state, dataType) =>
  logs = filterSelectors[dataType](state)
  len = logs.size

  tableTab: state.tabs
  tabVisibility: state.tabVisibility
  logs: logs
  paginationItems: Math.ceil(len/state.showAmount)
  activePage: state.activePage
  showAmount: state.showAmount
  filterKeys: state.filterKeys
  configListChecked: state.configListChecked

mapStateToProps = (state, ownProps) =>
  if state[ownProps.contentType]?
    getPropsFromState(state[ownProps.contentType], ownProps.contentType)
  else
    {}

mapDispatchToProps = (dispatch, ownProps) =>
  onFilterKeySet: (index, key) =>
    dispatch setFilterKey(index, key, ownProps.contentType)
  onActivePageSet: (val) =>
    dispatch setActivePage(val, ownProps.contentType)

module.exports = connect(
  mapStateToProps,
  mapDispatchToProps)(TableArea)
