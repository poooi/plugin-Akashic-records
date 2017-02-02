import { connect } from 'react-redux'
import { setFilterKey, setActivePage } from '../actions'
import TableArea from '../components/akashic-records-table-area'
import { filterSelectors } from '../selectors'

function getPropsFromState(state, dataType) {
  const logs = filterSelectors[dataType](state)
  const len = logs.length
  return {
    tableTab: state.tabs,
    tabVisibility: state.tabVisibility,
    logs: logs,
    paginationItems: Math.ceil(len/state.showAmount),
    activePage: state.activePage,
    showAmount: state.showAmount,
    filterKeys: state.filterKeys,
    configListChecked: state.configListChecked,
  }
}

function mapStateToProps(state, ownProps) {
  return (state[ownProps.contentType] != null)
    ? getPropsFromState(state[ownProps.contentType], ownProps.contentType)
    : {}
}

function mapDispatchToProps(dispatch, ownProps) {
  return {
    onFilterKeySet: (index, key) =>
      dispatch(setFilterKey(index, key, ownProps.contentType)),
    onActivePageSet: (val) =>
      dispatch(setActivePage(val, ownProps.contentType)),
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(TableArea)
