export function addLog(log, type) {
  return {
    type: 'ADD_LOG',
    dataType: type,
    log: log,
  }
}

export function initializeLogs(logs, type) {
  return {
    type: 'INITIALIZE_LOGS',
    dataType: type,
    logs: logs,
  }
}

export function setLanguage(language) {
  return {
    type: 'SET_LANGUAGE',
    language: language,
  }
}

export function setTabVisibility(index, val, type) {
  return {
    type: 'SET_TAB_VISIBILITY',
    dataType: type,
    index: index,
    val: val,
  }
}

export function setActivePage(val, type) {
  return {
    type: 'SET_ACTIVE_PAGE',
    dataType: type,
    val: val,
  }
}

export function resetActivePage(type) {
  return {
    type: 'RESET_ACTIVE_PAGE',
    dataType: type,
  }
}

export function setShowAmount(val, type) {
  return {
    type: 'SET_SHOW_AMOUNT',
    dataType: type,
    val: val,
  }
}


export function setConfigList(index, type) {
  return {
    type: 'SET_CONFIG_LIST',
    dataType: type,
    index: index,
  }
}

export function showCheckboxPanel(type) {
  return {
    type: 'SHOW_CHECKBOX_PANEL',
    dataType: type,
  }
}

export function hiddenCheckboxPanel(type) {
  return {
    type: 'HIDDEN_CHECKBOX_PANEL',
    dataType: type,
  }
}

export function showStatisticsPanel(type) {
  return {
    type: 'SHOW_STATISTICS_PANEL',
    dataType: type,
  }
}

export function hiddenStatisticsPanel(type) {
  return {
    type: 'HIDDEN_STATICTICS_PANEL',
    dataType: type,
  }
}

export function setTimeScale(val, type) {
  return {
    type: 'SET_TIME_SCALE',
    val: val,
    dataType: type,
  }
}


export function addSearchRule(type) {
  return {
    type: 'ADD_SEARCH_RULE',
    dataType: type,
  }
}

export function setSearchRuleBase(index, baseon, type) {
  return {
    type: 'SET_SEARCH_RULE_BASE',
    dataType: type,
    index: index,
    val: baseon,
  }
}

export function setSearchRuleKey(index, key, type) {
  return {
    type: 'SET_SEARCH_RULE_KEY',
    dataType: type,
    index: index,
    val: key,
  }
}

export function deleteSearchRule(index, type) {
  return {
    type: 'DELETE_SEARCH_RULE',
    dataType: type,
    index: index,
  }
}

export function addStatisticsRule(type) {
  return {
    type: 'ADD_STATISTICS_RULE',
    dataType: type,
  }
}

export function setStatisticsRuleNumeratorType(index, ntype, type) {
  return {
    type: 'SET_STATISTICS_RULE_NUMERATOR_TYPE',
    dataType: type,
    index: index,
    val: ntype,
  }
}

export function setStatisticsRuleDenominatorType(index, dtype, type) {
  return {
    type: 'SET_STATISTICS_RULE_DENOMINATOR_TYPE',
    dataType: type,
    index: index,
    val: dtype,
  }
}

export function setStatisticsRuleNumerator(index, n, type) {
  return {
    type: 'SET_STATISTICS_RULE_NUMERATOR',
    dataType: type,
    index: index,
    val: n,
  }
}

export function setStatisticsRuleDenominator(index, d, type) {
  return {
    type: 'SET_STATISTICS_RULE_DENOMINATOR',
    dataType: type,
    index: index,
    val: d,
  }
}

export function deleteStatisticsRule(index, type) {
  return {
    type: 'DELETE_STATISTICS_RULE',
    dataType: type,
    index: index,
  }
}


export function setFilterKey(index, key, type) {
  return {
    type: 'SET_FILTER_KEY',
    dataType: type,
    index: index,
    val: key,
  }
}
