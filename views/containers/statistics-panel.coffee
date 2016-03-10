{__} = window
{connect} = require 'react-redux'
{showStatisticsPanel, hiddenStatisticsPanel,
addSearchRule, deleteSearchRule, setSearchRuleBase, setSearchRuleKey,
addStatisticsRule, deleteStatisticsRule,
setStatisticsRuleNumeratorType, setStatisticsRuleDenominatorType,
setStatisticsRuleNumerator, setStatisticsRuleDenominator} = require '../actions'
StatisticsPanel = require '../components/akashic-records-statistics-panel'
{filterSelectors, searchSelectors} = require '../selectors'

calPercent = (num, de) ->
  if de != 0
    "#{Math.round(num*10000/de) / 100}%"
  else
    "0"

getSearchItems = (lens, searchRules) ->
  searchRules.map (item, index) ->
    item.res = lens[index+2]
    item.total = lens[item.baseOn]
    item.percent = calPercent lens[index+2], lens[item.baseOn]
    item

getStatisticsItems = (lens, statisticsRules) ->
  statisticsRules.map (item) ->
    if item.numeratorType isnt -1
      item.numerator = lens[item.numeratorType]
    if item.denominatorType isnt -1
      item.denominator = lens[item.denominatorType]
    item.percent = calPercent item.numerator, item.denominator
    item

getPropsFromState = (state) ->
  filteredLogs = filterSelectors[dataType] state
  loglens = searchSelectors[dataType] state.data, filteredLogs, searchRules
  show: state.statisticsVisible
  searchItems: getSearchItems loglens state.statisticsVisible
  statisticsItems: getStatisticsItems loglens, state.searchRules

mapStateToProps = (state, ownProps) ->
  if state[ownProps.contentType]?
    getPropsFromState(state[ownProps.contentType])
  else
    {}

mapDispatchToProps = (dispatch, ownProps) =>
  setPanelVisibilitiy: (show) ->
    if show
      dispatch showStatisticsPanel(ownProps.contentType)
    else
      dispatch hiddenStatisticsPanel(ownProps.contentType)
  onSeaRuleAdd: () ->
    dispatch addSearchRule(ownProps.contentType)
  onSeaRuleDelete: (index) ->
    dispatch deleteSearchRule(index, ownProps.contentType)
  onSeaRuleBaseSet: (index, baseOn) ->
    dispatch setSearchRuleBase(index, baseOn, ownProps.contentType)
  onSeaRuleKeySet: (index, key) ->
    dispatch setSearchRuleKey(index, key, ownProps.contentType)

  onStatRuleAdd: () ->
    dispatch addStatisticsRule(ownProps.contentType)
  onStatRuleDelete: (index) ->
    dispatch deleteStatisticsRule(index, ownProps.contentType)
  onStatRuleNTypeSet: (index, ntype) ->
    dispatch setStatisticsRuleNumeratorType(index, ntype, ownProps.contentType)
  onStatRuleNSet: (index, n) ->
    dispatch setStatisticsRuleNumerator(index, n, ownProps.contentType)
  onStatRuleDTypeSet: (index, dtype) ->
    dispatch setStatisticsRuleDenominatorType(index, dtype, ownProps.contentType)
  onStatRuleDSet: (index, d) ->
    dispatch setStatisticsRuleDenominator(index, d, ownProps.contentType)


module.exports = connect(
  mapStateToProps,
  mapDispatchToProps)(StatisticsPanel)
