import { connect } from 'react-redux'
import {
  showStatisticsPanel,
  hiddenStatisticsPanel,
  addSearchRule,
  deleteSearchRule,
  setSearchRuleBase,
  setSearchRuleKey,
  addStatisticsRule,
  deleteStatisticsRule,
  setStatisticsRuleNumeratorType,
  setStatisticsRuleDenominatorType,
  setStatisticsRuleNumerator,
  setStatisticsRuleDenominator,
} from '../actions'
import StatisticsPanel from '../components/akashic-records-statistics-panel'
import { filterSelectors, searchSelectors } from '../selectors'

function calPercent(num, de) {
  return (de !== 0) ? `${Math.round(num*10000/de) / 100}%` : '0'
}

function getSearchItems(lens, searchRules) {
  return searchRules.map((item, index) => {
    return {
      ...item,
      res: lens[index + 2],
      total: lens[item.baseOn],
      percent: calPercent(lens[index + 2], lens[item.baseOn]),
    }
  })
}

function getStatisticsItems(lens, statisticsRules) {
  return statisticsRules.map((item) => {
    let ret = item
    if (item.numeratorType !== -1) {
      ret = {
        ...ret,
        numerator: lens[item.numeratorType],
      }
    }
    if (item.denominatorType !== -1) {
      ret = {
        ...ret,
        denominator: lens[item.denominatorType],
      }
    }
    return {
      ...ret,
      percent: calPercent(ret.numerator, ret.denominator),
    }
  })
}

function getPropsFromState(state, dataType) {
  const filteredLogs = filterSelectors[dataType](state)
  const loglens = searchSelectors[dataType](
    state.data, filteredLogs, state.searchRules)
  return {
    show: state.statisticsVisible,
    searchItems: getSearchItems(loglens, state.searchRules),
    statisticsItems: getStatisticsItems(loglens, state.statisticsRules),
  }
}

function mapStateToProps(state, ownProps) {
  return (state[ownProps.contentType] != null)
    ? getPropsFromState(state[ownProps.contentType], ownProps.contentType)
    : {}
}

function mapDispatchToProps(dispatch, ownProps) {
  return {
    setPanelVisibilitiy: (show) =>
      dispatch((show) ? showStatisticsPanel(ownProps.contentType)
                      : hiddenStatisticsPanel(ownProps.contentType)),
    onSeaRuleAdd: () =>
      dispatch(addSearchRule(ownProps.contentType)),
    onSeaRuleDelete: (index) =>
      dispatch(deleteSearchRule(index, ownProps.contentType)),
    onSeaRuleBaseSet: (index, baseOn) =>
      dispatch(setSearchRuleBase(index, baseOn, ownProps.contentType)),
    onSeaRuleKeySet: (index, key) =>
      dispatch(setSearchRuleKey(index, key, ownProps.contentType)),

    onStatRuleAdd: () =>
      dispatch(addStatisticsRule(ownProps.contentType)),
    onStatRuleDelete: (index) =>
      dispatch(deleteStatisticsRule(index, ownProps.contentType)),
    onStatRuleNTypeSet: (index, ntype) =>
      dispatch(setStatisticsRuleNumeratorType(index, ntype, ownProps.contentType)),
    onStatRuleNSet: (index, n) =>
      dispatch(setStatisticsRuleNumerator(index, n, ownProps.contentType)),
    onStatRuleDTypeSet: (index, dtype) =>
      dispatch(setStatisticsRuleDenominatorType(index, dtype, ownProps.contentType)),
    onStatRuleDSet: (index, d) =>
      dispatch(setStatisticsRuleDenominator(index, d, ownProps.contentType)),
  }
}

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(StatisticsPanel)
