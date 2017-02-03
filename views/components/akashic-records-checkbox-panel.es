import React from 'react'
import {
  Col,
  FormControl,
  Checkbox,
  Grid,
  Row,
  ButtonGroup,
  DropdownButton,
  MenuItem,
  Collapse,
} from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
import Divider from '../divider'

const { config, __ } = window

class AkashicRecordsCheckboxPanel extends React.Component {
  constructor(props) {
    super(props)
    this.lastClick = 1
  }

  componentDidUpdate() {
    this.lastClick = -1
  }

  handlePanelShow = () => {
    const show = !this.props.show
    config.set(`plugin.Akashic.${this.props.contentType}.checkboxPanelShow`,
               show)
    this.props.setPanelVisibilitiy(show)
  }

  handleClickCheckbox = (index) => {
    const {tabVisibility} = this.props
    const tmp = [
      ...tabVisibility.slice(0, index),
      !tabVisibility[index],
      ...tabVisibility.slice(index + 1),
    ]
    config.set (`plugin.Akashic.${this.props.contentType}.checkbox`, JSON.stringify(tmp))
    this.props.onCheckboxClick(index, tmp[index])
  }

  handleClickConfigCheckbox = (index) => {
    if (index !== this.lastClick) {
      this.props.onConfigListSet(index)
      this.lastClick = index
    }
  }

  handleShowAmountSelect = (eventKey) => {
    config.set(`plugin.Akashic.${this.props.contentType}.showAmount`, eventKey)
    this.props.onShowAmountSet(eventKey)
  }

  handleShowPageSelect = () => {
    let val = parseInt(findDOMNode(this.pageSelected).value)
    if (!val || val < 1) {
      val = 1
    }
    this.props.onActivePageSet(val)
  }

  render() {
    return (
      <Grid>
        <Row>
          <Col xs={12}>
            <div onClick={this.handlePanelShow}>
              <Divider text={__("Filter")} icon={true} hr={true} show={this.props.show}/>
            </div>
          </Col>
        </Row>
        <Collapse className='akashic-records-checkbox-panel' in={this.props.show}>
          <div>
            <Row>
            {
              this.props.tableTab.map((checkedVal, index) =>
                (index) ? (
                  <Col key={index} xs={2}>
                    <Checkbox
                      value={index}
                      onChange={this.handleClickCheckbox.bind(this, index)}
                      checked={this.props.tabVisibility[index]}
                      style={{ verticalAlign: 'middle' }}>
                      {checkedVal}
                    </Checkbox>
                  </Col>
                ) : null
              )
            }
            </Row>
            <hr/>
            <Row>
              <Col xs={2}>
                <ButtonGroup justified>
                  <DropdownButton bsSize='xsmall' id="dropdown-showOption-selector" eventKey={4} title={__("Newer %s", this.props.showAmount)}>
                    <MenuItem eventKey={10} onSelect={this.handleShowAmountSelect}>{__("Newer %s", "10")}</MenuItem>
                    <MenuItem eventKey={20} onSelect={this.handleShowAmountSelect}>{__("Newer %s", "20")}</MenuItem>
                    <MenuItem eventKey={50} onSelect={this.handleShowAmountSelect}>{__("Newer %s", "50")}</MenuItem>
                    <MenuItem divider />
                    <MenuItem eventKey={999999} onSelect={this.handleShowAmountSelect}>{__("View All")}</MenuItem>
                  </DropdownButton>
                </ButtonGroup>
              </Col>
              <Col xs={2} style={{ display: 'flex', textAlign: 'right' }}>
                <div style={{ flex: 1, paddingRight: 10, paddingTop: 2 }}>
                  {__("Jump to")}
                </div>
                <div style={{ flex: 1, minWidth: 64 }}>
                  <FormControl
                    type='number'
                    placeholder={__("Page %s", this.props.activePage)}
                    value={this.props.activePage}
                    ref={(ref) => this.pageSelected = ref}
                    groupClassName='select-area'
                    onChange={this.handleShowPageSelect}/>
                </div>
              </Col>
              <Col xs={5}>
              {
                Array(3).fill().map((_, index) => {
                  const checkedVal = this.props.configList[index]
                  return (
                    <Col key={index} xs={4}>
                      <Checkbox
                        value={index}
                        onChange={this.handleClickConfigCheckbox.bind(this, index)}
                        checked={this.props.configListChecked[index]} style={{ verticalAlign: 'middle' }}
                      >
                        {checkedVal}
                      </Checkbox>
                    </Col>
                  )
                })
              }
              </Col>
              <Col xs={3}>
                <Checkbox
                value={3}
                onChange={this.handleClickConfigCheckbox.bind(this, 3)}
                checked={this.props.configListChecked[3]}
                style={{ verticalAlign: 'middle' }}>
                  {this.props.configList[3]}
                </Checkbox>
              </Col>
            </Row>
          </div>
        </Collapse>
      </Grid>
    )
  }
}

export default AkashicRecordsCheckboxPanel
