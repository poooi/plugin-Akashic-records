const statisticsRule = (state, action) => {
  switch (action.type) {
  case 'ADD_STATISTICS_RULE':
    return {
      numeratorType: 1,
      denominatorType: 1,
      numerator: 0,
      denominator: 1,
    }
  case 'SET_STATISTICS_RULE_NUMERATOR_TYPE':
    return {
      ...state,
      numeratorType: action.val,
    }
  case 'SET_STATISTICS_RULE_DENOMINATOR_TYPE':
    return {
      ...state,
      denominatorType: action.val,
    }
  case 'SET_STATISTICS_RULE_NUMERATOR':
    return {
      ...state,
      numerator: action.val,
    }
  case 'SET_STATISTICS_RULE_DENOMINATOR':
    return {
      ...state,
      denominator: action.val,
    }
  default:
    return state

  }
}

function deleteIndex(old, del) {
  if (old > del + 2) {
    return old - 1;
  } else if (old === del + 2) {
    return 1;
  }
  return old;
}

export default (state, action) => {
  if (state == null) {
    state = [statisticsRule(undefined, {type: 'ADD_STATISTICS_RULE'})]
  }
  switch (action.type) {
  case 'ADD_STATISTICS_RULE':
    return [...state, statisticsRule(undefined, action)]
  case 'SET_STATISTICS_RULE_NUMERATOR_TYPE':
  case 'SET_STATISTICS_RULE_DENOMINATOR_TYPE':
  case 'SET_STATISTICS_RULE_NUMERATOR':
  case 'SET_STATISTICS_RULE_DENOMINATOR':
    return [
      ...state.slice(0, action.index),
      statisticsRule(state[action.index], action),
      ...state.slice(action.index + 1),
    ]
  case 'DELETE_STATISTICS_RULE':
    return [
      ...state.slice(0, action.index),
      ...state.slice(action.index + 1),
    ]
  case 'DELETE_SEARCH_RULE':
    return state.map((item) => {
      let { numeratorType, denominatorType } = item
      const { index } = action
      return {
        ...item,
        numeratorType: deleteIndex(numeratorType, index),
        denominatorType: deleteIndex(denominatorType, index),
      }
    })
  default:
    return state
  }
}
