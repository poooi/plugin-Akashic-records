import { DataType } from './tab'
import { Reducer } from 'redux'

const { config } = window

export const configList = [
  "Show Headings", "Show Filter-box",
  "Auto-selected", "Disable filtering while hiding filter-box",
]

export type ConfigListState = boolean[]

export interface ConfigListAction {
  type: string
  dataType: DataType
}

export function configListChecked(state: ConfigListState, action: ConfigListAction): ConfigListState {
  state = JSON.parse(config.get(`plugin.Akashic.${action.dataType}.configChecked`,
    JSON.stringify([false, true, false, false])
  ))
  return state
}

export interface CheckboxVisibleAction {
  type: string
  dataType: DataType
}

export const checkboxVisible: Reducer<boolean, CheckboxVisibleAction> = (state, action) => {
  if (state == null) {
    state = config.get(`plugin.Akashic.${action.dataType}.checkboxPanelShow`, true)
  }
  switch (action.type) {
  case '@@poi-plugin-akashic-records/SHOW_CHECKBOX_PANEL':
    return true
  case '@@poi-plugin-akashic-records/HIDDEN_CHECKBOX_PANEL':
    return false
  default:
    return state
  }
}

export interface StatisticsVisibleAction {
  type: string
  dataType: DataType
}

export const statisticsVisible: Reducer<boolean, StatisticsVisibleAction> = (state, action) => {
  if (state == null) {
    state = config.get(`plugin.Akashic.${action.dataType}.statisticsPanelShow`, true)
  }
  switch (action.type) {
  case '@@poi-plugin-akashic-records/SHOW_STATISTICS_PANEL':
    return true
  case '@@poi-plugin-akashic-records/HIDDEN_STATICTICS_PANEL':
    return false
  default:
    return state
  }
}

export interface TimeScaleAction {
  type: string
  dataType: DataType
  val: number
}

export const showTimeScale: Reducer<number, TimeScaleAction> = (state = Number.MIN_VALUE, action) => {
  if (state == Number.MIN_VALUE) {
    state = config.get(`plugin.Akashic.${action.dataType}.table.showTimeScale`, 0)
  }
  if (action.type === '@@poi-plugin-akashic-records/SET_TIME_SCALE') {
    return action.val
  } else {
    return state
  }
}
