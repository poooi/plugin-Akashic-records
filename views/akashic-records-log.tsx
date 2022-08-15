import React from 'react'
import styled from 'styled-components'

import CheckboxPanel from './components/checkbox-panel'
import StatisticsPanel from './components/statistics-panel'
import VisibleTable from './components/table-area'
import { DataType } from './reducers/tab'

const Container = styled.div`
  padding: 8px 0;
`

const AkashicLog: React.FC<{ contentType: DataType }> = ({contentType}) => {
  return (
    <div>
      <Container>
        <CheckboxPanel contentType={contentType} />
      </Container>
      <Container>
        <StatisticsPanel contentType={contentType} />
      </Container>
      <Container>
        <VisibleTable contentType={contentType} />
      </Container>
    </div>
  )
}

export default AkashicLog
