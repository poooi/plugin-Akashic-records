module.exports =
  addLog: (log, type) ->
    type: 'ADD_LOG'
    dataType: type
    log: log
  initializeLogs: (logs, type) ->
    type: 'INITIALIZE_LOGS'
    dataType: type
    logs: logs

  setLanguage: (language) ->
    type: 'SET_LANGUAGE'
    language: language
  setTabVisibility: (index, val, type) ->
    type: 'SET_TAB_VISIBILITY'
    dataType: type
    index: index
    val: val

  setActivePage: (val, type) ->
    type: 'SET_ACTIVE_PAGE'
    dataType: type
    val: val
  resetActivePage: (type) ->
    type: 'RESET_ACTIVE_PAGE'
    dataType: type
  setShowAmount: (val, type) ->
    type: 'SET_SHOW_AMOUNT'
    dataType: type
    val: val

  setConfigList: (index, val, type) ->
    type: 'SET_CONFIG_LIST'
    dataType: type
    index: index
  showCheckboxPanel: (type) ->
    type: 'SHOW_CHECKBOX_PANEL'
    dataType: type
  hiddenCheckboxPanel: (type) ->
    type: 'HIDDEN_CHECKBOX_PANEL'
    dataType: type
  showStatisticsPanel: (type) ->
    type: 'SHOW_STATISTICS_PANEL'
    dataType: type
  hiddenStatisticsPanel: (type) ->
    type: 'HIDDEN_STATICTICS_PANEL'
    dataType: type

  addSearchRule: (type) ->
    type: 'ADD_SEARCH_RULE'
    dataType: type
  setSearchRuleBase: (index, baseon, type) ->
    type: 'SET_SEARCH_RULE_BASE'
    dataType: type
    index: index
    val: baseon
  setSearchRuleKey: (index, key, type) ->
    type: 'SET_SEARCH_RULE_KEY'
    dataType: type
    index: index
    val: key
  deleteSearchRule: (index, type) ->
    type: 'DELETE_SEARCH_RULE'
    dataType: type
    index: index

  addStatisticsRule: (type) ->
    type: 'ADD_STATISTICS_RULE'
    dataType: type
  setStatisticsRuleNumeratorType: (index, ntype, type) ->
    type: 'SET_STATISTICS_RULE_NUMERATOR_TYPE'
    dataType: type
    index: index
    val: ntype
  setStatisticsRuleDenominatorType: (index, dtype, type) ->
    type: 'SET_STATISTICS_RULE_DENOMINATOR_TYPE'
    dataType: type
    index: index
    val: dtype
  setStatisticsRuleNumerator: (index, n, type) ->
    type: 'SET_STATISTICS_RULE_NUMERATOR'
    dataType: type
    index: index
    val: n
  setStatisticsRuleDenominator: (index, d, type) ->
    type: 'SET_STATISTICS_RULE_DENOMINATOR'
    dataType: type
    index: index
    val: d
  deleteStatisticsRule: (index, type) ->
    type: 'DELETE_STATISTICS_RULE'
    dataType: type
    index: index

  setFilterKey: (index, key, type) ->
    type: 'SET_FILTER_KEY'
    dataType: type
    index: index
    val: key
