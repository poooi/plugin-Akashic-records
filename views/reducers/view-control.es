const { config, __ } = window

const initConfigList = [
  "Show Headings", "Show Filter-box",
  "Auto-selected", "Disable filtering while hiding filter-box",
]

function getTabs() {
  return initConfigList.map((tab) => __(tab))
}

export function configList(state = getTabs(), action) {
  if (action.type === 'SET_LANGUAGE') return getTabs()
  return state
}

export function configListChecked(state, action) {
  if (state == null) {
    state = JSON.parse(config.get(`plugin.Akashic.${action.dataType}.configChecked`,
      JSON.stringify([true, false, false, true])
    ))
  }
  if (action.type === 'SET_CONFIG_LIST') {
    let newState = state
    if (state[action.index]) {
      newState = [
        ...state.slice(0, action.index),
        false,
        ...state.slice(action.index + 1),
      ]
    } else {
      if (action.index < 2) {
        newState = [
          ...state.slice(0, action.index),
          true,
          ...state.slice(action.index + 1, 2),
          false,
          state.slice[3],
        ]
      } else if (action.index === 2) {
        newState = [false, false, true, state[3]]
      } else {
        newState = [...state.slice(0, 3), true]
      }
    }
    if (newState !== state) {
      config.set(`plugin.Akashic.${action.dataType}.configChecked`,
        JSON.stringify(state)
      )
    }
    return newState
  } else {
    return state
  }
}

export function checkboxVisible(state, action) {
  if (state == null) {
    state = config.get(`plugin.Akashic.${action.dataType}.checkboxPanelShow`, true)
  }
  switch (action.type) {
  case 'SHOW_CHECKBOX_PANEL':
    return true
  case 'HIDDEN_CHECKBOX_PANEL':
    return false
  default:
    return state
  }
}

export function statisticsVisible(state, action) {
  if (state == null) {
    state = config.get(`plugin.Akashic.${action.dataType}.statisticsPanelShow`, true)
  }
  switch (action.type) {
  case 'SHOW_STATISTICS_PANEL':
    return true
  case 'HIDDEN_STATICTICS_PANEL':
    return false
  default:
    return state
  }
}

export function showTimeScale(state, action) {
  if (state == null) {
    state = config.get(`plugin.Akashic.${action.dataType}.table.showTimeScale`, 0)
  }
  if (action.type === 'SET_TIME_SCALE') {
    return action.val
  } else {
    return state
  }
}
