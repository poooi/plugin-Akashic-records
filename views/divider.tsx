import React from 'react'
import styled from 'styled-components'
import { Icon } from '@blueprintjs/core'
import { IconNames } from '@blueprintjs/icons'

export interface DividerT {
  text: string
  icon?: boolean
  show?: boolean
  hr?: boolean
}

const Container = styled.h5`
  margin-top: 12px;
  margin-bottom: 10px;
  user-select: none;
  display: flex;
  align-items: center;
`

const Line = styled.hr`
  margin-top: 10px;
  margin-bottom: 8px;
  display: block;
`

const Divider: React.FC<DividerT> = (props) => {
  return (
    <>
      <Container>
        {`${props.text}  `}
        {
          props.icon ? props.show ? <Icon icon={IconNames.DOUBLE_CHEVRON_DOWN} />
            : <Icon icon={IconNames.DOUBLE_CHEVRON_RIGHT} />
            : null
        }
      </Container>
      {props.hr ? <Line /> : null}
    </>
  )
}

export default Divider
