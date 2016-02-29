module.exports =
  addLog: (log, type) ->
    type: 'ADD_DATA'
    dataType: type
    log: log
  initializeLogs: (logs, type) ->
    type: 'INITIALIZE_LOGS'
    dataType: type
    logs: logs

  setLanguage: (language) ->
    type: 'SET_LANGUAGE'
    language: language
  setTabVisibility: (index, type) ->
    type: 'SET_TAB_VISIBILITY'
    dataType: type
    index: index

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
  setSearchRuleBase: (baseon, type) ->
    type: 'SET_SEARCH_RULE_BASE'
    dataType: type
    val: baseon
  setSearchRuleKey: (key, type) ->
    type: 'SET_SEARCH_RULE_KEY'
    dataType: type
    val: key
  deleteSearchRule: (index, type) ->
    type: 'DELETE_SEARCH_RULE'
    dataType: type
    index: index

  addStatisticsRule: (type) ->
    type: 'ADD_STATISTICS_RULE'
    dataType: type
  setStatisticsRuleNumeratorType: (ntype, type) ->
    type: 'SET_STATISTICS_RULE_NUMERATOR_TYPE'
    dataType: type
    val: ntype
  setStatisticsRuleDenominatorType: (dtype, type) ->
    type: 'SET_STATISTICS_RULE_DENOMINATOR_TYPE'
    dataType: type
    val: dtype
  setStatisticsRuleNumerator: (n, type) ->
    type: 'SET_STATISTICS_RULE_NUMERATOR'
    dataType: type
    val: n
  setStatisticsRuleDenominator: (d, type) ->
    type: 'SET_STATISTICS_RULE_DENOMINATOR'
    dataType: type
    val: d
  deleteStatisticsRule: (type) ->
    type: 'DELETE_STATISTICS_RULE'
    dataType: type

  setFilterKey: (index, key, type) ->
    type: 'SET_FILTER_KEY'
    dataType: type
    index: index
    val: key
