export default function (state = [], action) {
  switch (action.type) {
  case 'ADD_LOG':
    return [...state, action.log]
  case 'INITIALIZE_LOGS':
    return action.logs
  default:
    return state
  }
}
