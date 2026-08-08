import { DataType } from './tab'
import { Reducer } from 'redux'
import { defaultTimeScale, TimeScale, toTimeScale } from '../utils/time-scale'

const { config } = window

// the indices configListChecked is read at, in the order of configList below
export enum ConfigItem {
  ShowHeadings,
  ShowFilterBox,
  AutoSelected,
  DisableFilteringWhileHidingFilterBox,
}

export const configList = [
  "Show Headings", "Show Filter-box",
  "Auto-selected", "Disable filtering while hiding filter-box",
]

export type ConfigListState = boolean[]

export interface ConfigListAction {
  type: string
  dataType: DataType
}

export const configListChecked: Reducer<ConfigListState, ConfigListAction> = (state, action) => {
  state = JSON.parse(config.get(`plugin.Akashic.${action.dataType}.configChecked`,
    JSON.stringify([false, true, false, false])
  )) as ConfigListState
  return state
}

export interface CheckboxVisibleAction {
  type: string;
  dataType: DataType;
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
  type: string;
  dataType: DataType;
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
  type: string;
  dataType: DataType;
  val: TimeScale;
}

export const showTimeScale: Reducer<TimeScale, TimeScaleAction> = (state, action) => {
  if (state == null) {
    state = toTimeScale(config.get(`plugin.Akashic.${action.dataType}.table.showTimeScale`, defaultTimeScale))
  }
  if (action.type === '@@poi-plugin-akashic-records/SET_TIME_SCALE') {
    return action.val
  } else {
    return state
  }
}
