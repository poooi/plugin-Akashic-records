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
    item.set 'res', lens[index+2]
    .set 'total', lens[item.get 'baseOn']
    .set 'percent', calPercent lens[index+2], lens[item.get 'baseOn']

getStatisticsItems = (lens, statisticsRules) ->
  statisticsRules.map (item) ->
    if item.get('numeratorType') isnt -1
      item = item.set 'numerator', lens[item.get 'numeratorType']
    if item.get('denominatorType') isnt -1
      item = item.set 'denominator', lens[item.get 'denominatorType']
    item.set 'percent', calPercent item.get('numerator'), item.get('denominator')

getPropsFromState = (state, dataType) ->
  filteredLogs = filterSelectors[dataType] state
  loglens = searchSelectors[dataType] state.data, filteredLogs, state.searchRules
  show: state.statisticsVisible
  searchItems: getSearchItems loglens, state.searchRules
  statisticsItems: getStatisticsItems loglens, state.statisticsRules

mapStateToProps = (state, ownProps) ->
  if state[ownProps.contentType]?
    getPropsFromState(state[ownProps.contentType], ownProps.contentType)
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
