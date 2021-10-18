import { DataAction } from "views/reducers/data"
import { DataRow } from "lib/data-co-manager"
import { DataType, TabVisibilityAction } from "views/reducers/tab"
import { ActivePageAction, ShowAmountAction } from "views/reducers/page"
import { CheckboxVisibleAction, StatisticsVisibleAction, TimeScaleAction } from "views/reducers/view-control"
import { SearchRulesAction } from "views/reducers/search-rules"
import { StatisticsRulesAction } from "views/reducers/statistics-rules"
import { NonIdealState } from "@blueprintjs/core"
import { FilterKeysAction } from "views/reducers/filter-keys"

interface GlobalDataAction extends DataAction {
  dataType: DataType
}

interface GlobalActivePageAction extends ActivePageAction {
  dataType: DataType
}

interface GlobalShowAmountAction extends ShowAmountAction {
  dataType: DataType
}

interface GlobalSearchRulesAction extends SearchRulesAction {
  dataType: DataType
}

interface GlobalStatisticsRulesAction extends StatisticsRulesAction {
  dataType: DataType
}

interface GlobalFilterKeysAction extends FilterKeysAction {
  dataType: DataType
}

export function addLog(log: DataRow, type: DataType): GlobalDataAction {
  return {
    type: '@@poi-plugin-akashic-records/ADD_LOG',
    dataType: type,
    log: log,
  }
}

export function initializeLogs(logs: DataRow[], type: DataType): GlobalDataAction {
  return {
    type: '@@poi-plugin-akashic-records/INITIALIZE_LOGS',
    dataType: type,
    logs: logs,
  }
}

export function setTabVisibility(index: number, val: boolean, type: DataType): TabVisibilityAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_TAB_VISIBILITY',
    dataType: type,
    index: index,
    val: val,
  }
}

export function setActivePage(val: number, type: DataType): GlobalActivePageAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_ACTIVE_PAGE',
    dataType: type,
    val: val,
  }
}

export function resetActivePage(type: DataType): GlobalActivePageAction {
  return {
    type: '@@poi-plugin-akashic-records/RESET_ACTIVE_PAGE',
    dataType: type,
  }
}

export function setShowAmount(val: number, type: DataType): GlobalShowAmountAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_SHOW_AMOUNT',
    dataType: type,
    val: val,
  }
}

export function showCheckboxPanel(type: DataType): CheckboxVisibleAction {
  return {
    type: '@@poi-plugin-akashic-records/SHOW_CHECKBOX_PANEL',
    dataType: type,
  }
}

export function hiddenCheckboxPanel(type: DataType): CheckboxVisibleAction {
  return {
    type: '@@poi-plugin-akashic-records/HIDDEN_CHECKBOX_PANEL',
    dataType: type,
  }
}

export function showStatisticsPanel(type: DataType): StatisticsVisibleAction {
  return {
    type: '@@poi-plugin-akashic-records/SHOW_STATISTICS_PANEL',
    dataType: type,
  }
}

export function hiddenStatisticsPanel(type: DataType): StatisticsVisibleAction {
  return {
    type: '@@poi-plugin-akashic-records/HIDDEN_STATICTICS_PANEL',
    dataType: type,
  }
}

export function setTimeScale(val: number, type: DataType): TimeScaleAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_TIME_SCALE',
    val: val,
    dataType: type,
  }
}


export function addSearchRule(type: DataType): GlobalSearchRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/ADD_SEARCH_RULE',
    dataType: type,
  }
}

export function setSearchRuleBase(index: number, baseon: number, type: DataType): GlobalSearchRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_SEARCH_RULE_BASE',
    dataType: type,
    index: index,
    val: baseon,
  }
}

export function setSearchRuleKey(index: number, key: number, type: DataType): GlobalSearchRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_SEARCH_RULE_KEY',
    dataType: type,
    index: index,
    val: key,
  }
}

export function deleteSearchRule(index: number, type: DataType): GlobalSearchRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/DELETE_SEARCH_RULE',
    dataType: type,
    index: index,
  }
}

export function addStatisticsRule(type: DataType): GlobalStatisticsRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/ADD_STATISTICS_RULE',
    dataType: type,
  }
}

export function setStatisticsRuleNumeratorType(index: number, ntype: number, type: DataType): GlobalStatisticsRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR_TYPE',
    dataType: type,
    index: index,
    val: ntype,
  }
}

export function setStatisticsRuleDenominatorType(index: number, dtype: number, type: DataType): GlobalStatisticsRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR_TYPE',
    dataType: type,
    index: index,
    val: dtype,
  }
}

export function setStatisticsRuleNumerator(index: number, n: number, type: DataType): GlobalStatisticsRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR',
    dataType: type,
    index: index,
    val: n,
  }
}

export function setStatisticsRuleDenominator(index: number, d: number, type: DataType): GlobalStatisticsRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR',
    dataType: type,
    index: index,
    val: d,
  }
}

export function deleteStatisticsRule(index: number, type: DataType): GlobalStatisticsRulesAction {
  return {
    type: '@@poi-plugin-akashic-records/DELETE_STATISTICS_RULE',
    dataType: type,
    index: index,
  }
}


export function setFilterKey(index: number, key: string, type: DataType): GlobalFilterKeysAction {
  return {
    type: '@@poi-plugin-akashic-records/SET_FILTER_KEY',
    dataType: type,
    index: index,
    val: key,
  }
}
