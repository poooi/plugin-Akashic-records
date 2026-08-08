import { Reducer } from 'redux'

import { DataSource } from '../../lib/constant'

export interface SearchRulesAction {
  type: string;
  index?: number;
  val?: string | number;
}

export interface SearchRule {
  // a DataSource, or the index of a search result beyond DataSource.Filtered
  baseOn: number;
  content: string;
}

export type SearchRulesState = SearchRule[]

const searchRule: Reducer<SearchRule, SearchRulesAction> = (state, action) => {
  switch (action.type) {
  case '@@poi-plugin-akashic-records/ADD_SEARCH_RULE':
    return {
      baseOn: DataSource.Filtered,
      content: '',
    }
  case '@@poi-plugin-akashic-records/SET_SEARCH_RULE_BASE':
    return {
      content: '',
      ...state,
      baseOn: action.val as number,
    }
  case '@@poi-plugin-akashic-records/SET_SEARCH_RULE_KEY':
    return {
      baseOn: DataSource.Filtered,
      ...state,
      content: action.val as string,
    }
  default:
    return state || { baseOn: DataSource.Filtered, content: '' }
  }
}

const reducer: Reducer<SearchRulesState, SearchRulesAction> = (state, action) => {
  if (state == null) {
    state = [searchRule(undefined, {type: '@@poi-plugin-akashic-records/ADD_SEARCH_RULE'})]
  }
  switch (action.type) {
  case '@@poi-plugin-akashic-records/ADD_SEARCH_RULE':
    return [...state, searchRule(undefined, action)]
  case '@@poi-plugin-akashic-records/SET_SEARCH_RULE_BASE':
  case '@@poi-plugin-akashic-records/SET_SEARCH_RULE_KEY':
    return [
      ...state.slice(0, action.index),
      searchRule(state[action.index || 0], action),
      ...state.slice((action.index || 0) + 1),
    ]
  case '@@poi-plugin-akashic-records/DELETE_SEARCH_RULE': {
    const ret = [
      ...state.slice(0, action.index),
      ...state.slice((action.index || 0) + 1),
    ]
    return ret.map((item) => {
      if (item.baseOn > (action.index || 0) + 2) {
        return {
          ...item,
          baseOn: item.baseOn - 1,
        }
      } else if (item.baseOn === (action.index || 0) + 2) {
        return {
          ...item,
          baseOn: DataSource.Filtered,
        }
      } else {
        return item
      }
    })
  }
  default:
    return state
  }
}

export default reducer
