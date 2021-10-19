import React, { useCallback } from 'react'
import styled from 'styled-components'
import { useDispatch, useSelector } from 'react-redux'
import { useTranslation } from 'react-i18next'
import { memoize, range } from 'lodash'
import { createSelector, Selector } from 'reselect'

import { DataType, getTabs, TabVisibilityState } from '../reducers/tab'
import { dateToString } from '../../lib/utils'
import Pagination from './pagination'
import { DataRow, DataState } from 'views/reducers/data'
import { LogContentState } from 'views/reducers/log-content'
import { filterSelectors, logContentSelectorFactory, resourceFilter } from 'views/selectors'
import { setActivePage, setFilterKey, setShowAmount, setTimeScale } from 'views/actions'
import { HTMLSelect, HTMLTable, InputGroup } from '@blueprintjs/core'

const { config } = window

const THeadCenter = styled.thead`
  text-align: center;
`

const PaginationContainer = styled.div`
  display: flex;
  justify-content: center;
  margin-top: 16px;
`

const Flex = styled.div`
  display: flex;
`

interface TbodyItemT {
  data: DataRow;
  nextdata: DataRow;
  lastFlag: boolean;
  index: number;
  tabVisibility: TabVisibilityState;
}

const AkashicResourceTableTbodyItem: React.FC<TbodyItemT> = ({ data, nextdata, tabVisibility, lastFlag, index }) => (
  <tr>
    <td>{index}</td>
    {
      data.map((item, index) => {
        if (index === 0 && tabVisibility[1]) {
          return (<td key={index}>{dateToString(new Date(item))}</td>)
        } else {
          if (tabVisibility[index + 1]) {
            if (lastFlag) {
              return (  <td key={index}>{item}</td>)
            } else {
              let diff = Number(item) - Number(nextdata[index])
              return (
                <td key={index}>
                  {`${item}(${diff > 0 ? '+' : ''}${diff})`}
                </td>
              )
            }
          }
        }
        return null
      })
    }
  </tr>
)

type SelectorResult =
  Pick<LogContentState, 'tabVisibility' | 'activePage' | 'showAmount' | 'filterKeys' | 'showTimeScale'> & {
    logs: DataState;
    paginationItems: number;
  }

const resourceSelector: Selector<LogContentState, SelectorResult> = (state) => {
  const logs = resourceFilter(state)
  const len = logs.length
  return {
    tabVisibility: state.tabVisibility,
    activePage: state.activePage,
    showAmount: state.showAmount,
    filterKeys: state.filterKeys,
    configListChecked: state.configListChecked,
    logs: logs,
    paginationItems: Math.ceil(len/state.showAmount),
    showTimeScale: state.showTimeScale,
  }
}

export interface AkashicResourceTableAreaT {
  contentType: DataType;
}

const AkashicResourceTableArea: React.FC<AkashicResourceTableAreaT> = ({ contentType }) => {
  const selector: Selector<any, SelectorResult> = createSelector(
    logContentSelectorFactory(contentType),
    resourceSelector
  )
  const { tabVisibility, activePage, showAmount, showTimeScale, filterKeys, logs, paginationItems } = useSelector(selector)
  const dispatch = useDispatch()
  const { t } = useTranslation('poi-plugin-akashic-records')

  const handleKeywordChange = useCallback((keyword: string) => {
    dispatch(setFilterKey(0, keyword, contentType))
  }, [contentType])

  const handleShowAmountSelect = useCallback((showAmount: number) => {
    config.set("plugin.Akashic.resource.showAmount", showAmount)
    dispatch(setShowAmount(showAmount, contentType))
  }, [contentType])

  const handleActivePageSet = useCallback((activePage) => {
    dispatch(setActivePage(activePage, contentType))
  }, [contentType])

  const handleTimeScaleSelect = useCallback((timeScale: number) => {
    config.set("plugin.Akashic.resource.table.showTimeScale", timeScale)
    dispatch(setTimeScale(timeScale, contentType))
  }, [contentType])

  return (
    <div>
      <Flex>
        <div>
          <HTMLSelect
            minimal
            value={showTimeScale}
            onChange={(e) => handleTimeScaleSelect(parseInt(e.target.value))}>
            <option key={0} value={0}>
              {t("Show by {{scale}}", { scale: t("Hour") })}
            </option>
            <option key={1} value={1}>
              {t("Show by {{scale}}", { scale: t("Day") })}
            </option>
          </HTMLSelect>
        </div>
        <div>
          <HTMLSelect
            minimal
            value={showAmount}
            onChange={(e) => handleShowAmountSelect(parseInt(e.target.value))}>
            <option value={10}>{t('Newer {{count}}', { count: 10 })}</option>
            <option value={20}>{t('Newer {{count}}', { count: 20 })}</option>
            <option value={50}>{t('Newer {{count}}', { count: 50 })}</option>
          </HTMLSelect>
        </div>
      </Flex>
      <div>
        <div>
          <HTMLTable striped bordered condensed>
            <THeadCenter>
              <tr>
                {
                  getTabs(contentType).map((tab, index) => (
                    tabVisibility[index] ?
                      index === 1 ?
                      <th>
                        <InputGroup
                          type="text"
                          placeholder={t(getTabs(contentType)[index])}
                          value={filterKeys[0]}
                          onChange={(e) => handleKeywordChange(e.target.value)}
                        />
                      </th>  :
                      <th key={index}>{tab}</th>
                    : null
                  ))
                }
              </tr>
            </THeadCenter>
            <tbody>
              {
                range(Math.min(activePage * showAmount, logs.length) - (activePage - 1) * showAmount).map((_, i) => {
                  const index = (activePage - 1) * showAmount + i
                  const item = logs[index]
                  const opt = (index + 1 < logs.length) ? {
                    lastFlag: false,
                    nextItem: logs[index + 1],
                  } : {
                    lastFlag: true,
                    nextItem: [0] as DataRow,
                  }
                  return (
                    <AkashicResourceTableTbodyItem
                      key = {item[0]}
                      index = {index + 1}
                      data={item}
                      nextdata={opt.nextItem}
                      lastFlag={opt.lastFlag}
                      tabVisibility={tabVisibility}
                    />
                  )
                })
              }
            </tbody>
          </HTMLTable>
        </div>
      </div>
      <PaginationContainer>
          <Pagination
            max={paginationItems}
            curr={activePage}
            handlePaginationSelect={handleActivePageSet}
          />
        </PaginationContainer>
    </div>
  )
}

export default AkashicResourceTableArea
