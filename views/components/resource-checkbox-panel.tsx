import React, { useCallback } from 'react'
import { Checkbox } from '@blueprintjs/core'
import styled from 'styled-components'

import { DataType, getTabs, TabVisibilityState } from '../reducers/tab'
import { useTranslation } from 'react-i18next'
import { Selector, useDispatch, useSelector } from 'react-redux'
import { setTabVisibility } from 'views/actions'
import { logContentSelectorFactory } from 'views/selectors'
import { LogContentState } from 'views/reducers/log-content'
import { createSelector } from 'reselect'

const { config } = window

const CheckboxContainer = styled.div`
  display: flex;
  flex-wrap: wrap;
`

const CheckboxItem = styled.div`
  flex: 0 0 calc(100% / 8);
  vertical-align: middle;
`

type SelectorResult =
  Pick<LogContentState, 'tabVisibility'>

const checkboxStateSelector: Selector<LogContentState, SelectorResult> = (state) => {
  return {
    tabVisibility: state.tabVisibility,
  }
}

interface AkashicResourceCheckboxAreaT {
  contentType: DataType;
}

const AkashicResourceCheckboxArea: React.FC<AkashicResourceCheckboxAreaT> = ({ contentType }) => {
  const selector = createSelector(
    logContentSelectorFactory(contentType),
    checkboxStateSelector
  )
  const { tabVisibility } = useSelector(selector)
  const { t } = useTranslation('poi-plugin-akashic-records')
  const dispatch = useDispatch()

  const handleClickCheckbox = useCallback((index: number) => {
    const tmp = [
      ...tabVisibility.slice(0, index),
      !tabVisibility[index],
      ...tabVisibility.slice(index + 1),
    ]
    config.set(`plugin.Akashic.${contentType}.checkbox`, JSON.stringify(tmp))
    dispatch(setTabVisibility(index, tmp[index], contentType))
  }, [tabVisibility, contentType])

  return (
    <CheckboxContainer>
      {
        getTabs(contentType).map((checkedVal, index) => index < 2
          ? null
          : (
            <CheckboxItem>
              <Checkbox
                value={index}
                onChange={() => handleClickCheckbox(index)}
                checked={tabVisibility[index]}>
                {t(checkedVal)}
              </Checkbox>
            </CheckboxItem>
          )
        )
      }
    </CheckboxContainer>
  )
}

export default AkashicResourceCheckboxArea
