import { Reducer } from 'redux'

const { config } = window

export interface ActivePageAction {
  type: string
  val?: number
}

export interface ShowAmountAction {
  type: string
  dataType: string
  val: number
}

export const activePage: Reducer<number, ActivePageAction> = (state = 1, action) => {
  switch (action.type) {
  case '@@poi-plugin-akashic-records/SET_ACTIVE_PAGE':
    return action.val!
  case '@@poi-plugin-akashic-records/RESET_ACTIVE_PAGE':
    return 1
  default:
    return state
  }
}

export const showAmount: Reducer<number, ShowAmountAction> = (state = -1, action) => {
  if (state == -1) {
    state = config.get(`plugin.Akashic.${action.dataType}.showAmount`, 20)
    state = Math.min(state, 100)
  }
  if (action.type === '@@poi-plugin-akashic-records/SET_SHOW_AMOUNT') {
    return action.val
  } else {
    return state
  }
}
