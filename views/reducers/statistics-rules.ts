import { Reducer } from 'redux'

export interface StatisticsRule {
  numeratorType: number;
  denominatorType: number;
  numerator: number;
  denominator: number;
}

export interface StatisticsRulesAction {
  type: string;
  val?: number;
  index?: number;
}

export type StatisticsRulesState = StatisticsRule[]

const defaultStatisticsRule = {
  numeratorType: 1,
  denominatorType: 1,
  numerator: 0,
  denominator: 1,
}

const statisticsRule: Reducer<StatisticsRule, StatisticsRulesAction> = (state, action) => {
  switch (action.type) {
  case '@@poi-plugin-akashic-records/ADD_STATISTICS_RULE':
    return defaultStatisticsRule
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR_TYPE':
    return {
      ...defaultStatisticsRule,
      ...state,
      numeratorType: action.val || 0,
    }
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR_TYPE':
    return {
      ...defaultStatisticsRule,
      ...state,
      denominatorType: action.val || 0,
    }
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR':
    return {
      ...defaultStatisticsRule,
      ...state,
      numerator: action.val || 0,
    }
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR':
    return {
      ...defaultStatisticsRule,
      ...state,
      denominator: action.val || 0,
    }
  default:
    return state || defaultStatisticsRule
  }
}

function deleteIndex(old: number, del: number) {
  if (old > del + 2) {
    return old - 1
  } else if (old === del + 2) {
    return 1
  }
  return old
}

const reducer: Reducer<StatisticsRulesState, StatisticsRulesAction> = (state, action) => {
  if (state == null) {
    state = [statisticsRule(undefined, {type: '@@poi-plugin-akashic-records/ADD_STATISTICS_RULE'})]
  }
  switch (action.type) {
  case '@@poi-plugin-akashic-records/ADD_STATISTICS_RULE':
    return [...state, statisticsRule(undefined, action)]
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR_TYPE':
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR_TYPE':
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_NUMERATOR':
  case '@@poi-plugin-akashic-records/SET_STATISTICS_RULE_DENOMINATOR':
    return [
      ...state.slice(0, action.index),
      statisticsRule(state[action.index || 0], action),
      ...state.slice((action.index || 0) + 1),
    ]
  case '@@poi-plugin-akashic-records/DELETE_STATISTICS_RULE':
    return [
      ...state.slice(0, action.index),
      ...state.slice((action.index || 0) + 1),
    ]
  case '@@poi-plugin-akashic-records/DELETE_SEARCH_RULE':
    return state.map((item) => {
      const { numeratorType, denominatorType } = item
      const { index = 0 } = action
      return {
        ...item,
        numeratorType: deleteIndex(numeratorType, index),
        denominatorType: deleteIndex(denominatorType, index),
      }
    })
  default:
    return state
  }
}

export default reducer
