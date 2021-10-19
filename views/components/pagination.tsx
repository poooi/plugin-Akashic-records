import React from 'react'
import _ from 'lodash'

import { ButtonGroup, Button } from '@blueprintjs/core'

export interface PaginationT {
  max: number;
  curr: number;
  handlePaginationSelect: (idx: number) => void;
}

const Ellipsis = <Button disabled icon="more" />

const Pagination: React.FC<PaginationT> = ({max, curr, handlePaginationSelect}) => {
  const start = Math.max(1, curr - 2)
  return max > 0 ? (
    <ButtonGroup>
      <Button icon='chevron-left' onClick={() => handlePaginationSelect(1)}/>
      {
        curr - 2 > 1 ? (
          Ellipsis
        ) : null
      }
      {
        _.range(start, Math.min(curr + 2, start + 4, max) + 1).map(idx => (
          <Button key={idx} active={idx === curr} onClick={() => handlePaginationSelect(idx)}>
            {idx}
          </Button>
        ))
      }
      {
        curr + 2 < max ? (
          Ellipsis
        ) : null
      }
      <Button icon='chevron-right' onClick={() => handlePaginationSelect(max)}/>
    </ButtonGroup>
  ) : null
}

export default Pagination
