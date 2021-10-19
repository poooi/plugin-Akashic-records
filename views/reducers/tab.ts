import { Reducer } from 'redux'

const { config } = window

export type DataType = 'attack' | 'mission' | 'createitem' | 'createship' | 'retirement' | 'resource'

export type TabsState = string[]

export interface TabsAction {
  type: string;
  dataType: DataType;
}

export type TabVisibilityState = boolean[]

export interface TabVisibilityAction {
  type: string;
  index: number;
  dataType: DataType;
  val: boolean;
}

const tableTab = {
  attack: [
    'No.', 'Time', 'World', "Node", "Sortie Type",
    "Battle Result", "Enemy Encounters", "Drop",
    "Heavily Damaged", "Flagship",
    "Flagship (Second Fleet)", 'MVP',
    "MVP (Second Fleet)",
  ],
  mission: [
    'No.', "Time", "Type", "Result", "Fuel",
    "Ammo", "Steel", "Bauxite", "Item 1",
    "Number", "Item 2", "Number",
  ],
  createitem: [
    'No.', "Time", "Result", "Development Item",
    "Type", "Fuel", "Ammo", "Steel",
    "Bauxite", "Flagship", "Headquarters Level",
  ],
  createship: [
    'No.', "Time", "Type", "Ship", "Ship Type",
    "Fuel", "Ammo", "Steel", "Bauxite",
    "Development Material", "Empty Docks", "Flagship",
    "Headquarters Level",
  ],
  retirement: [
    'No.', "Time", "Type", "Ship Type", "Ship",
  ],
  resource: [
    'No.', "Time", "Fuel", "Ammo", "Steel",
    "Bauxite", "Fast Build Item", "Instant Repair Item",
    "Development Material", "Improvement Materials",
  ],
}

const defaultTabVisibility = [
  true, true, true, true, true, true, true,
  true, true, true, true, true, true, true,
]

export function getTabs(type: DataType) {
  return tableTab[type]
}

export const tabVisibility: Reducer<TabVisibilityState, TabVisibilityAction> = (state = [], action) => {
  if (!state.length) {
    state = JSON.parse(config.get(`plugin.Akashic.${action.dataType}.checkbox`,
      JSON.stringify(defaultTabVisibility))) as boolean[]
  }
  if (action.type === '@@poi-plugin-akashic-records/SET_TAB_VISIBILITY') {
    return [
      ...state.slice(0, action.index),
      action.val,
      ...state.slice(action.index + 1),
    ]
  } else {
    return state
  }
}

export const oriTableTab = tableTab
