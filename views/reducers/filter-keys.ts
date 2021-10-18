import { Reducer } from 'redux'

export interface FilterKeysAction {
  type: string
  index: number
  val: string | boolean
}

export type FilterKeysState = string[]

const defaultFilterKeys = ['', '', '', '', '', '',
'', '', '', '', '', '']

const reducer: Reducer<FilterKeysState, FilterKeysAction> = (state = defaultFilterKeys, action) => {
  switch (action.type) {
    case '@@poi-plugin-akashic-records/SET_FILTER_KEY':
      return [
        ...state.slice(0, action.index),
        action.val as string,
        ...state.slice(action.index + 1),
      ]
    case '@@poi-plugin-akashic-records/SET_TAB_VISIBILITY':
      if (action.val === false && state[action.index - 1] !== '') {
        return [
          ...state.slice(0, action.index - 1),
          '',
          ...state.slice(action.index),
        ]
      } else {
        return state
      }
    default:
      return state
  }
}


export default reducer
