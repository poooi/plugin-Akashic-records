export function addLog(log, type) {
  return {
    type: '@@poi-plugin-akashic-records/ADD_LOG',
    dataType: type,
    log: log,
  }
}

export function initializeLogs(logs, type) {
  return {
    type: '@@poi-plugin-akashic-records/INITIALIZE_LOGS',
    dataType: type,
    logs: logs,
  }
}

export function setLanguage(language) {
  return {
    type: '@@poi-plugin-akashic-records/SET_LANGUAGE',
    language: language,
  }
}

export function setTabVisibility(index, val, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_TAB_VISIBILITY',
    dataType: type,
    index: index,
    val: val,
  }
}

export function setActivePage(val, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_ACTIVE_PAGE',
    dataType: type,
    val: val,
  }
}

export function resetActivePage(type) {
  return {
    type: '@@poi-plugin-akashic-records/RESET_ACTIVE_PAGE',
    dataType: type,
  }
}

export function setShowAmount(val, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_SHOW_AMOUNT',
    dataType: type,
    val: val,
  }
}


export function setConfigList(index, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_CONFIG_LIST',
    dataType: type,
    index: index,
  }
}

export function showCheckboxPanel(type) {
  return {
    type: '@@poi-plugin-akashic-records/SHOW_CHECKBOX_PANEL',
    dataType: type,
  }
}

export function hiddenCheckboxPanel(type) {
  return {
    type: '@@poi-plugin-akashic-records/HIDDEN_CHECKBOX_PANEL',
    dataType: type,
  }
}

export function showStatisticsPanel(type) {
  return {
    type: '@@poi-plugin-akashic-records/SHOW_STATISTICS_PANEL',
    dataType: type,
  }
}

export function hiddenStatisticsPanel(type) {
  return {
    type: '@@poi-plugin-akashic-records/HIDDEN_STATICTICS_PANEL',
    dataType: type,
  }
}

export function setTimeScale(val, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_TIME_SCALE',
    val: val,
    dataType: type,
  }
}


export function addSearchRule(type) {
  return {
    type: '@@poi-plugin-akashic-records/ADD_SEARCH_RULE',
    dataType: type,
  }
}

export function setSearchRuleBase(index, baseon, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_SEARCH_RULE_BASE',
    dataType: type,
    index: index,
    val: baseon,
  }
}

export function setSearchRuleKey(index, key, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_SEARCH_RULE_KEY',
    dataType: type,
    index: index,
    val: key,
  }
}

export function deleteSearchRule(index, type) {
  return {
    type: '@@poi-plugin-akashic-records/DELETE_SEARCH_RULE',
    dataType: type,
    index: index,
  }
}

export function addStatisticsRule(type) {
  return {
    type: '@@poi-plugin-akashic-records/ADD_STATISTICS_RULE',
    dataType: type,
  }
}

export function setStatisticsRuleNumeratorType(index, ntype, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR_TYPE',
    dataType: type,
    index: index,
    val: ntype,
  }
}

export function setStatisticsRuleDenominatorType(index, dtype, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR_TYPE',
    dataType: type,
    index: index,
    val: dtype,
  }
}

export function setStatisticsRuleNumerator(index, n, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR',
    dataType: type,
    index: index,
    val: n,
  }
}

export function setStatisticsRuleDenominator(index, d, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR',
    dataType: type,
    index: index,
    val: d,
  }
}

export function deleteStatisticsRule(index, type) {
  return {
    type: '@@poi-plugin-akashic-records/DELETE_STATISTICS_RULE',
    dataType: type,
    index: index,
  }
}


export function setFilterKey(index, key, type) {
  return {
    type: '@@poi-plugin-akashic-records/SET_FILTER_KEY',
    dataType: type,
    index: index,
    val: key,
  }
}
