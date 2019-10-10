import React from 'react'
import FontAwesome from 'react-fontawesome'

const Divider = (props) => (
  <div className="divider">
    <h5>
      {`${props.text}  `}
      {
        props.icon ? props.show ? <FontAwesome name='chevron-circle-down' />
          : <FontAwesome name='chevron-circle-right' />
          : null
      }
    </h5>
    {props.hr ? <hr /> : null}
  </div>)

export default Divider
