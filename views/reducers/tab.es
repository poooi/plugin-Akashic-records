const { config } = window

const { __ } = window.i18n['poi-plugin-akashic-records']

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

function getTabs(type) {
  if (tableTab[type] == null) {
    return []
  } else {
    return tableTab[type].map((tab) => __(tab))
  }
}

export function tabs(state, action) {
  if (state == null) {
    state = getTabs(action.dataType)
  }
  if (action.type === '@@poi-plugin-akashic-records/SET_LANGUAGE') {
    state = getTabs(action.dataType)
  }
  return state
}

export function language(state = window.language, action) {
  if (action.type === '@@poi-plugin-akashic-records/SET_LANGUAGE') {
    return action.language
  }
  return state
}

export function tabVisibility(state, action) {
  if (state == null) {
    state = JSON.parse(config.get(`plugin.Akashic.${action.dataType}.checkbox`,
      JSON.stringify(defaultTabVisibility)))
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
