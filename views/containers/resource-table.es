import { connect } from 'react-redux'
import {
  setFilterKey,
  setActivePage,
  setShowAmount,
  setTimeScale,
} from '../actions'
import TableArea from '../components/akashic-resource-table-area'
import { resourceFilter } from '../selectors'

function getPropsFromState(state, dataType) {
  const data = resourceFilter(state)
  const len = data.length
  return {
    tableTab: state.tabs,
    tabVisibility: state.tabVisibility,
    logs: data,
    paginationItems: Math.ceil(len / state.showAmount),
    activePage: state.activePage,
    showAmount: state.showAmount,
    filterKey: state.filterKeys[0],
    timeScale: state.showTimeScale,
  }
}

function mapStateToProps(state, ownProps) {
  return (state[ownProps.contentType] != null)
    ? getPropsFromState(state[ownProps.contentType], ownProps.contentType)
    : {}
}

function mapDispatchToProps(dispatch, ownProps) {
  return {
    onFilterKeySet: (key) =>
      dispatch(setFilterKey(0, key, ownProps.contentType)),
    onActivePageSet: (val) =>
      dispatch(setActivePage(val, ownProps.contentType)),
    onShowAmountSet: (val) =>
      dispatch(setShowAmount(val, ownProps.contentType)),
    onTimeScaleSet: (val) =>
      dispatch(setTimeScale(val, ownProps.contentType)),
  }
}


export default connect(
  mapStateToProps,
  mapDispatchToProps
)(TableArea)
