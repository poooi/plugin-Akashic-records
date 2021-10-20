import React, { useCallback } from 'react'
import { HTMLTable, Icon, InputGroup } from '@blueprintjs/core'
import { useTranslation } from 'react-i18next'
import { memoize, range } from 'lodash'
import { Selector, useDispatch, useSelector } from 'react-redux'
import { createSelector } from 'reselect'
import styled from 'styled-components'
import { shell } from 'electron'

import { DataRow, DataTable } from "lib/data-co-manager"
import { dateToString } from '../../lib/utils'
import { DataType, getTabs, TabVisibilityState } from '../reducers/tab'
import { Popover } from 'views/components/etc/overlay'
import Pagination from './pagination'
import { filterSelectors, logContentSelectorFactory } from '../selectors'
import { LogContentState } from '../reducers/log-content'
import { setActivePage, setFilterKey } from '../actions'
import { IState } from 'views/utils/selectors'

const { ipc } = window

const { openExternal } = shell

const TipContainer = styled.div`
  padding: 8px 16px;
`

const PaginationContainer = styled.div`
  display: flex;
  justify-content: center;
  margin-top: 16px;
`
const THeadCenter = styled.thead`
  text-align: center;
`

function showBattleDetail(timestamp: number, t: (o: string) => string) {
  try {
    if (window.ipc == null) {
      throw `${t("Your POI is out of date! You may need to visit http://0u0.moe/poi to get POI's latest release.")}`
    }

    const battleDetailPlugin = window.getStore('plugins').find((p: any) => p.id === 'poi-plugin-battle-detail')
    if (!battleDetailPlugin || !battleDetailPlugin.enabled) {
      throw `${t("In order to find the detailed battle log, you need to download the latest battle-detail plugin and enable it.")}`
    }

    timestamp = (new Date(timestamp)).getTime()

    const battleDetail = ipc.access('BattleDetail')
    if (battleDetail == null || battleDetail.showBattleWithTimestamp == null) {
      ipc.register("BattleDetail", {
        timestamp,
      })
    } else {
      battleDetail.showBattleWithTimestamp(timestamp, (message: string) => {
        if (message) {
          window.toggleModal("Warning", `${t('Battle Detail')}: ${message}`)
        }
      })
    }

    const mainWindow = ipc.access('MainWindow')
    if (mainWindow && mainWindow.ipcFocusPlugin) {
      mainWindow.ipcFocusPlugin('poi-plugin-battle-detail')
    }
  } catch (e) {
    window.toggleModal('Warning', e as string)
  }
}

const parseMapInfo = (mapStr: string) => {
  if (!mapStr.includes('|'))
    return mapStr

  const match = mapStr.match(/\((\d+)-\d+ /)
  if (!match)
    return mapStr

  const eventId = parseInt(match[1], 10)
  if (`${eventId}` !== match[1])
    return mapStr

  const parts =mapStr.split('|')
  const rank = parseInt(parts[1], 10) || 0
  const rankText = (eventId < 41)
    ? ['', '丙', '乙', '甲'][rank]
    : ['', '丁', '丙', '乙', '甲'][rank]

  return parts[0].trim().replace('%rank', rankText)
}

interface TbodyItemT {
  data: DataRow;
  index: number;
  contentType: DataType;
  tabVisibility: TabVisibilityState;
}

const AkashicRecordsTableTbodyItem: React.FC<TbodyItemT> = ({ data, contentType, index, tabVisibility }) => {
  const { t } = useTranslation('poi-plugin-akashic-records')
  return (
    <tr>
      <td>
        {
          (contentType === 'attack' && data[2] !== '基地防空戦') ?
            (<Icon icon="info-sign" style={{ marginRight: 3 }} onClick={() => showBattleDetail(data[0], t)}/>) : null
        }
        {index}
      </td>
      {
        data.map((item, index) => {
          if (index === 0 && tabVisibility[1]) {
            return (<td key={index}>{dateToString(new Date(+item))}</td>)
          } else if (contentType === 'attack' && index === 1) {
            return (tabVisibility[2]) ? (<td key={index}>{parseMapInfo(String(item))}</td>) : null
          } else if (contentType === 'attack' && (index === 4 || index === 5 || index === 7)) {
            return (tabVisibility[8]) ? (<td key={index} className="overflow" title={String(item)}>{item}</td>) : null
          } else {
            return (tabVisibility[index+1]) ? (<td key={index}>{item}</td>) : null
          }
        })
      }
    </tr>
  )
}

export interface AkashicRecordsTableAreaT {
  contentType: DataType;
}

type SelectorResult =
  Pick<LogContentState, 'tabVisibility' | 'activePage' | 'showAmount' | 'filterKeys' | 'configListChecked'> & {
    logs: DataTable;
    paginationItems: number;
  }

const getSelector = memoize((dataType: DataType): Selector<LogContentState, SelectorResult> => {
  return (state) => {
    const logs = filterSelectors[dataType](state)
    const len = logs.length
    return {
      tabVisibility: state.tabVisibility,
      activePage: state.activePage,
      showAmount: state.showAmount,
      filterKeys: state.filterKeys,
      configListChecked: state.configListChecked,
      logs: logs,
      paginationItems: Math.ceil(len/state.showAmount),
    }
  }
})

const AkashicRecordsTableArea: React.FC<AkashicRecordsTableAreaT> = ({ contentType }) => {
  const selector: Selector<IState, SelectorResult> = createSelector(
    logContentSelectorFactory(contentType),
    getSelector(contentType)
  )
  const { tabVisibility, activePage, showAmount, filterKeys, configListChecked, logs, paginationItems } = useSelector(selector)
  const dispatch = useDispatch()
  const { t } = useTranslation('poi-plugin-akashic-records')

  const handleKeywordChange = useCallback((index: number, keyword: string) => {
    dispatch(setFilterKey(index, keyword, contentType))
  }, [contentType])
  const handlePaginationSelect = useCallback((idx: number) => {
    dispatch(setActivePage(idx, contentType))
  }, [contentType])

  let showLabel = configListChecked[0]
  let showFilter = configListChecked[1]
  if (configListChecked[2]) {
    showFilter = true
    showLabel = showLabel || filterKeys.some((filterKey, index) =>
      tabVisibility[index + 1] && filterKey !== ''
    )
  }
  const startLogs = (activePage - 1) * showAmount
  const endLogs = Math.min(activePage * showAmount, logs.length)
  return (
    <div>
      <div>
        <HTMLTable striped bordered condensed>
          <THeadCenter>
            {
              (showLabel && !showFilter) ? (
                <tr>
                  {
                    getTabs(contentType).map((tab, index) => (
                      tabVisibility[index] ? <th key={index}>{tab}</th> : null
                    ))
                  }
                </tr>
              ) : (
                (showLabel || showFilter) ? (
                  <tr>
                    {
                      getTabs(contentType).map((tab, index) =>
                        (index === 0) ? (
                          <th key={index}>
                            <Popover>
                              <Icon icon='help' style={{ marginLeft: "3px"}}/>
                              <TipContainer>
                                <h3>
                                  {t("Tips")}
                                </h3>
                                <ul>
                                  <li>
                                    {t("Disable filtering while hiding column")}
                                  </li>
                                  <li>
                                    {t("Support the Javascript's ")}
                                    <a onClick={() => openExternal("http://www.w3school.com.cn/jsref/jsref_obj_regexp.asp")}>
                                      {"RegExp"}
                                    </a>
                                  </li>
                                </ul>
                              </TipContainer>
                            </Popover>

                          </th>
                        ) : (
                          tabVisibility[index] ? (
                            <th key={index}>
                              <InputGroup
                                type="text"
                                placeholder={t(getTabs(contentType)[index])}
                                value={filterKeys[index - 1]}
                                onChange={(e) => handleKeywordChange(index - 1, e.target.value)}
                              />
                            </th>
                          ) : null
                        )
                      )
                    }
                  </tr>
                ) : null
              )
            }
          </THeadCenter>
          <tbody>
            {
              range(endLogs - startLogs).map((_, i) => {
                const index = startLogs + i
                const item = logs[index]
                return (
                  <AkashicRecordsTableTbodyItem
                    key={item[0]}
                    index={index+1}
                    data={item}
                    tabVisibility={tabVisibility}
                    contentType={contentType}
                  />
                )
              })
            }
          </tbody>
        </HTMLTable>
      </div>
      <PaginationContainer>
        <Pagination
          max={paginationItems}
          curr={activePage}
          handlePaginationSelect={handlePaginationSelect}
        />
      </PaginationContainer>
    </div>
  )
}

export default AkashicRecordsTableArea
