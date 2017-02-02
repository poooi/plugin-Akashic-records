import React from 'react'
import {
  Col,
  Checkbox,
  Grid,
  Row,
} from 'react-bootstrap'

const { config } = window
const AkashicResourceCheckboxArea = (props) => {
  const handleClickCheckbox = (index) => {
    const { tabVisibility } = props
    const tmp = [
      ...tabVisibility.slice(0, index),
      !tabVisibility[index],
      ...tabVisibility.slice(index + 1),
    ]
    config.set(`plugin.Akashic.${props.contentType}.checkbox`, JSON.stringify(tmp))
    props.onCheckboxClick(index, tmp[index])
  }
  return (
    <div className='akashic-records-settings'>
      <Grid className='akashic-records-filter'>
        <Row>
        {
          props.tableTab.map((checkedVal, index) => index < 2
            ? null
            : (
              <Col key={index} xs={2}>
                <Checkbox
                  value={index}
                  onChange={handleClickCheckbox.bind(this, index)}
                  checked={props.tabVisibility[index]}
                  style={{ verticalAlign: 'middle' }}>
                  {checkedVal}
                </Checkbox>
              </Col>
            )
          )
        }
        </Row>
      </Grid>
    </div>
  )
}

export default AkashicResourceCheckboxArea
