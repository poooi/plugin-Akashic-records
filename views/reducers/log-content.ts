import { combineReducers } from 'redux'

import data from './data'
import { tabVisibility, DataType } from './tab'
import { activePage, showAmount } from './page'
import {
  configListChecked,
  checkboxVisible,
  statisticsVisible,
  showTimeScale,
} from './view-control'
import searchRules from './search-rules'
import statisticsRules from './statistics-rules'
import filterKeys from './filter-keys'

export const logContent = combineReducers({
  data,
  tabVisibility,
  activePage,
  showAmount,
  configListChecked,
  checkboxVisible,
  statisticsVisible,
  searchRules,
  statisticsRules,
  filterKeys,
  showTimeScale,
})

export type LogContentState = ReturnType<typeof logContent>

export interface LogContentAction {
  type: string;
  dataType: DataType;
}
