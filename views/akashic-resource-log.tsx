import React, { useCallback, useState } from 'react'
import { Tabs, Tab } from '@blueprintjs/core'
import styled from 'styled-components'

import ResourceChart from './components/resource-chart'

import ResourceCP from './components/resource-checkbox-panel'
import TableArea from './components/resource-table-area'
import { useTranslation } from 'react-i18next'

type TabId = 'chart' | 'table'

const Container = styled.div`
  padding: 8px 16px;
`

const AkashicResourceTable = () => (
  <div>
    <Container>
      <ResourceCP contentType='resource'/>
    </Container>
    <Container>
      <TableArea contentType='resource'/>
    </Container>
  </div>
)

const AkashicResourceLog: React.FC = () => {
  const [activeTab, setActiveTab] = useState<TabId>('table')
  const { t } = useTranslation('poi-plugin-akashic-records')
  const handleSelectTab = useCallback((newTabId: TabId) => setActiveTab(newTabId), [])
  return (
    <div>
      <Tabs selectedTabId={activeTab} onChange={handleSelectTab} large>
        <Tab id='table' title={t("Table")} panel={<AkashicResourceTable />} />
        <Tab id='chart' title={t("Chart")} panel={<Container><ResourceChart /></Container>} />
      </Tabs>
    </div>
  )
}

export default AkashicResourceLog
