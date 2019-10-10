import { connect } from 'react-redux'
import { createSelector } from 'reselect'

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
import { filterSelectors, searchSelectors, pluginDataSelector } from '../selectors'

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

const getPropsFromState = (() => {
  const selectors = {}
  return (dataType) => {
    if (selectors[dataType] == null) {
      selectors[dataType] = createSelector([
        state => state.statisticsVisible,
        state => state.data,
        state => filterSelectors[dataType](state),
        state => state.searchRules,
        state => state.statisticsRules,
      ], (show, logs, filteredLogs, searchRules, statisticsRules) => {
        const loglens = searchSelectors[dataType](
          { logs, filteredLogs, searchRules })
        return {
          show,
          searchItems: getSearchItems(loglens, searchRules),
          statisticsItems: getStatisticsItems(loglens, statisticsRules),
        }
      })
    }
    return selectors[dataType]
  }
})()

function mapStateToProps(poi_state, ownProps) {
  const state = pluginDataSelector(poi_state)
  return (state[ownProps.contentType] != null)
    ? getPropsFromState(ownProps.contentType)(state[ownProps.contentType])
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
