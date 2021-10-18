import { Reducer } from 'redux'

export type DataRow = [number, ...(number | string)[]]

export type DataState = DataRow[]

export interface DataAction {
  type: string;
  log?: DataRow
  logs?: DataState
}

const reducer: Reducer<DataState, DataAction> = (state = [] as DataState, action) => {
  switch (action.type) {
    case '@@poi-plugin-akashic-records/ADD_LOG':
      return action.log ? [action.log, ...state] : state
    case '@@poi-plugin-akashic-records/INITIALIZE_LOGS':
      return action.logs || state
    default:
      return state
  }
}

export default reducer
