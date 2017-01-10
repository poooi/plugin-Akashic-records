const searchRule = (state, action) => {
  switch (action.type) {
  case 'ADD_SEARCH_RULE':
    return {
      baseOn: 1,
      content: '',
    }
  case 'SET_SEARCH_RULE_BASE':
    return {
      ...state,
      baseOn: action.val,
    }
  case 'SET_SEARCH_RULE_KEY':
    return {
      ...state,
      content: action.val,
    }
  default:
    return state
  }
}

export default (state, action) => {
  if (state == null) {
    state = [searchRule(undefined, {type: 'ADD_SEARCH_RULE'})]
  }
  switch (action.type) {
  case 'ADD_SEARCH_RULE':
    return [...state, searchRule(undefined, action)]
  case 'SET_SEARCH_RULE_BASE':
  case 'SET_SEARCH_RULE_KEY':
    return [
      ...state.slice(0, action.index),
      searchRule(state[action.index], action),
      ...state.slice(action.index + 1),
    ]
  case 'DELETE_SEARCH_RULE': {
    const ret = [
      ...state.slice(0, action.index),
      ...state.slice(action.index + 1),
    ]
    return ret.map((item) => {
      if (item.baseOn > action.index + 2) {
        return {
          ...item,
          baseOn: item.baseOn - 1,
        }
      } else if (item.baseOn === action.index + 2) {
        return {
          ...item,
          baseOn: 1,
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
