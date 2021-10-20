import { DataRow, DataTable } from '../../lib/data-co-manager'
import { Reducer } from 'redux'


export interface DataAction {
  type: string;
  log?: DataRow;
  logs?: DataTable;
}

const reducer: Reducer<DataTable, DataAction> = (state = [], action) => {
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
