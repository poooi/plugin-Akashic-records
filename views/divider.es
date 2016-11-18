import React from 'react'
import FontAwesome from 'react-fontawesome'

const Divider = () => (
  <div className="divider">
    <h5>
      {`${this.props.text}  `}
      {
        this.props.icon ? this.props.show ? <FontAwesome name='chevron-circle-down' />
                                          : <FontAwesome name='chevron-circle-right' />
                        : null
      }
    </h5>
    {this.props.hr ? <hr /> : null}
  </div>)

export default Divider
