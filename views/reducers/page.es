const { config } = window

export function activePage(state = 1, action) {
  switch (action.type) {
  case '@@poi-plugin-akashic-records/SET_ACTIVE_PAGE':
    return parseInt(action.val)
  case '@@poi-plugin-akashic-records/RESET_ACTIVE_PAGE':
    return 1
  default:
    return state
  }
}

export function showAmount(state, action) {
  if (state == null) {
    state = parseInt(config.get(`plugin.Akashic.${action.dataType}.showAmount`, 20))
    state = Math.min(state, 100)
  }
  if (action.type === '@@poi-plugin-akashic-records/SET_SHOW_AMOUNT') {
    return parseInt(action.val)
  } else {
    return state
  }
}
