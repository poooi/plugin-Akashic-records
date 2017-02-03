export default function (state = [], action) {
  switch (action.type) {
  case 'ADD_LOG':
    return [action.log, ...state]
  case 'INITIALIZE_LOGS':
    return action.logs
  default:
    return state
  }
}
