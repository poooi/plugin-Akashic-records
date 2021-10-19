import { join } from 'path'
import React, { ErrorInfo } from 'react'
import { Tabs, Tab } from '@blueprintjs/core'
import styled from 'styled-components'
import { WithTranslation, withTranslation } from 'react-i18next'

import CONST from '../lib/constant'

import AkashicLog from './akashic-records-log'
import AkashicResourceLog from './akashic-resource-log'
import AkashicAdvancedModule from './components/advanced-module'

import ErrorBoundary from './error-boundary'

const Container = styled.div`
  padding-left: 16px;
  padding-right: 16px;
`

// getUseItem: (id)->
//   switch id
//     when 10
//       "家具箱（小）"
//     when 11
//       "家具箱（中）"
//     when 12
//       "家具箱（大）"
//     when 50
//       "応急修理要員"
//     when 51
//       "応急修理女神"
//     when 54
//       "給糧艦「間宮」"
//     when 56
//       "艦娘からのチョコ"
//     when 57
//       "勲章"
//     when 59
//       "給糧艦「伊良湖」"
//     when 62
//       "菱餅"
//     else
//       "特殊的东西"

interface State {
  selectedKey: number;
}

export const reactClass = withTranslation('poi-plugin-akashic-records')(
  class innerReactClass extends React.Component<WithTranslation, State> {
    state = {
      selectedKey: 0,
    }

    handleSelectTab = (selectedKey: number) => {
      this.setState({
        selectedKey: selectedKey,
      })
    }

    componentDidCatch = (error: Error, info: ErrorInfo) => {
      // eslint-disable-next-line
      console.log(error, info)
    }

    render() {
      const { t } = this.props

      return (
        <div id='akashic-records-main-wrapper'>
          <link rel="stylesheet" href={join(__dirname, '..', 'assets', 'main.css')} />
          <Tabs id="" selectedTabId={this.state.selectedKey} animate={false} onChange={this.handleSelectTab}>
            <Tab id={0} title={t("Sortie")} panel={
              <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.attack}/>
            } />
            <Tab id={1} title={t("Expedition")} panel={
              <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.mission}/>
            } />
            <Tab id={2} title={t("Construction")} panel={
              <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.createShip}/>
            } />
            <Tab id={3} title={t("Development")} panel={
              <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.createItem}/>
            } />
            <Tab id={4} title={t("Retirement")} panel={
              <ErrorBoundary component={AkashicLog} contentType={CONST.typeList.retirement}/>
            } />
            <Tab id={5} title={t("Resource")} panel={
              <ErrorBoundary component={AkashicResourceLog} />
            } />
            <Tab id={6} title={t("Others")} panel={
              <ErrorBoundary component={AkashicAdvancedModule} />
            } />
          </Tabs>
        </div>
      )
    }
  }
)
