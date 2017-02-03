
const defaultFilterKeys = ['', '', '', '', '', '',
                           '', '', '', '', '', '']

export default function (state = defaultFilterKeys, action) {
  switch (action.type) {
  case 'SET_FILTER_KEY':
    return [
      ...state.slice(0, action.index),
      action.val,
      ...state.slice(action.index + 1),
    ]
  case 'SET_TAB_VISIBILITY':
    if (action.val === false && state[action.val - 1] !== '') {
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
