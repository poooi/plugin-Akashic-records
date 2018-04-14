export default function (state = [], action) {
  switch (action.type) {
  case '@@poi-plugin-akashic-records/ADD_LOG':
    return [action.log, ...state]
  case '@@poi-plugin-akashic-records/INITIALIZE_LOGS':
    return action.logs
  default:
    return state
  }
}
