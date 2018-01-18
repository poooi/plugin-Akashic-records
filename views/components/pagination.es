import React from 'react'
import _ from 'lodash'

import {
  Pagination,
} from 'react-bootstrap'

export default ({max, curr, className, handlePaginationSelect}) => {
  const start = Math.max(1, curr - 2)
  return max > 0 ? (  
    <Pagination className={className}>
      <Pagination.First onClick={() => handlePaginationSelect(1)}/>
      {
        curr - 2 > 1 ? (
          <Pagination.Ellipsis />
        ) : null
      }
      {
        _.range(start, _.min([curr + 2, start + 4, max]) + 1).map(idx => (
          <Pagination.Item key={idx} active={idx === curr} onClick={() => handlePaginationSelect(idx)}>
            {idx}
          </Pagination.Item>
        ))
      }
      {
        curr + 2 < max ? (
          <Pagination.Ellipsis />
        ) : null
      }
      <Pagination.Last onClick={() => handlePaginationSelect(max)}/>
    </Pagination>
  ) : null
}
