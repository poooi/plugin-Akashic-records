const { config } = window

const { __ } = window.i18n['poi-plugin-akashic-records']

const initConfigList = [
  "Show Headings", "Show Filter-box",
  "Auto-selected", "Disable filtering while hiding filter-box",
]

function getTabs() {
  return initConfigList.map((tab) => __(tab))
}

export function configList(state = getTabs(), action) {
  if (action.type === '@@poi-plugin-akashic-records/SET_LANGUAGE') return getTabs()
  return state
}

export function configListChecked(state, action) {
  state = JSON.parse(config.get(`plugin.Akashic.${action.dataType}.configChecked`,
    JSON.stringify([false, true, false, false])
  ))
  return state
}

export function checkboxVisible(state, action) {
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

export function statisticsVisible(state, action) {
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

export function showTimeScale(state, action) {
  if (state == null) {
    state = config.get(`plugin.Akashic.${action.dataType}.table.showTimeScale`, 0)
  }
  if (action.type === '@@poi-plugin-akashic-records/SET_TIME_SCALE') {
    return action.val
  } else {
    return state
  }
}
