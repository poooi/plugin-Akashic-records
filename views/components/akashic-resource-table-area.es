import React from 'react'
import {
  Col,
  FormControl,
  Grid,
  Row,
  Table,
  ButtonGroup,
  DropdownButton,
  MenuItem,
} from 'react-bootstrap'
import { findDOMNode } from 'react-dom'
import { getTabs } from '../reducers/tab'

const { config } = window

const { __ } = window.i18n['poi-plugin-akashic-records']

import { dateToString } from '../../lib/utils'
// # import i18n from '../node_modules/i18n'
// # {__} = i18n

import Pagination from './pagination'

const AkashicResourceTableTbodyItem = (props) => (
  <tr>
    <td>{props.index}</td>
    {
      props.data.map((item, index) => {
        if (index === 0 && props.rowChooseChecked[1]) {
          return (<td key={index}>{dateToString(new Date(item))}</td>)
        } else {
          if (props.rowChooseChecked[index + 1]) {
            if (props.lastFlag) {
              return (  <td key={index}>{item}</td>)
            } else {
              let diff = item - props.nextdata[index]
              if (diff > 0)
                diff = `+${diff}`
              return (<td key={index}>{`${item}(${diff})`}</td>)
            }
          }
        }
        return null
      })
    }
  </tr>
)

class AkashicResourceTableArea extends React.Component {
  constructor(props) {
    super(props)
  }
  handleKeyWordChange = () =>
    this.props.onFilterKeySet(findDOMNode(this.input).value)
  handleShowAmountSelect = (eventKey, selectedKey) => {
    config.set("plugin.Akashic.resource.showAmount", eventKey)
    this.props.onShowAmountSet(eventKey)
  }
  handleShowPageSelect = (eventKey, selectedKey) =>
    this.props.onActivePageSet(eventKey)
  handleTimeScaleSelect = (eventKey, selectedKey) => {
    config.set("plugin.Akashic.resource.table.showTimeScale", eventKey)
    this.props.onTimeScaleSet(eventKey)
  }
  handlePaginationSelect = (eventKey) =>
    this.props.onActivePageSet(eventKey)

  render() {
    return (
      <div>
        <Grid>
          <Row>
            <Col xs={3}>
              <ButtonGroup justified>
                <DropdownButton
                  id="dropdown-showScale-selector"
                  center
                  eventKey={4}
                  title={__("Show by %s", `${this.props.timeScale ? __('Day') : __('Hour')}`)}
                >
                  <MenuItem center eventKey={0} onSelect={this.handleTimeScaleSelect}>{__("Show by %s", __("Hour"))}</MenuItem>
                  <MenuItem eventKey={1} onSelect={this.handleTimeScaleSelect}>{__("Show by %s", __("Day"))}</MenuItem>
                </DropdownButton>
              </ButtonGroup>
            </Col>
            <Col xs={3}>
              <ButtonGroup justified>
                <DropdownButton center  id="dropdown-showOption-selector" eventKey={4} title={__("Newer %s", `${this.props.showAmount}`)}>
                  <MenuItem center eventKey={10} onSelect={this.handleShowAmountSelect}>{__("Newer %s", "10")}</MenuItem>
                  <MenuItem eventKey={20} onSelect={this.handleShowAmountSelect}>{__("Newer %s", "20")}</MenuItem>
                  <MenuItem eventKey={50} onSelect={this.handleShowAmountSelect}>{__("Newer %s", "50")}</MenuItem>
                  <MenuItem divider />
                  <MenuItem eventKey={999999} onSelect={this.handleShowAmountSelect}>{__("View All")}</MenuItem>
                </DropdownButton>
              </ButtonGroup>
            </Col>
            <Col xs={3}>
              <ButtonGroup justified>
                <DropdownButton eventKey={4}  id="dropdown-page-selector" title={__("Page %s", `${this.props.activePage}`)}>
                  {
                    this.props.logs.length > 0 ? Array(this.props.paginationItems).fill().map((_, index) => (
                      <MenuItem key={index}
                        eventKey={index}
                        onSelect={this.handleShowPageSelect}>
                        {__("Page %s", `${index + 1}`)}
                      </MenuItem>
                    )) : null
                  }
                </DropdownButton>
              </ButtonGroup>
            </Col>
            <Col xs={3}>
              <FormControl
                type='text'
                value={this.props.filterKey}
                placeholder={__("Keywords")}
                hasFeedback
                ref={(ref) => this.input = ref}
                onChange={this.handleKeyWordChange} />
            </Col>
          </Row>
          <Row>
            <Col xs={12}>
              <Table striped bordered condensed hover Responsive>
                <thead>
                  <tr>
                    {
                      getTabs(this.props.contentType).map((tab, index) => (
                        this.props.tabVisibility[index]
                          ? <th key={index}>{tab}</th>
                          : null
                      ))
                    }
                  </tr>
                </thead>
                <tbody>
                  {
                    Array(Math.min(this.props.activePage * this.props.showAmount, this.props.logs.length) - (this.props.activePage - 1) * this.props.showAmount).fill().map((_, i) => {
                      const index = (this.props.activePage - 1) * this.props.showAmount + i
                      const item = this.props.logs[index]
                      const opt = (index + 1 < this.props.logs.length) ? {
                        lastFlag: false,
                        nextItem: this.props.logs[index + 1],
                      } : {
                        lastFlag: true,
                        nextItem: [],
                      }
                      return (
                        <AkashicResourceTableTbodyItem
                          key = {item[0]}
                          index = {index+1}
                          data={item}
                          nextdata={opt.nextItem}
                          lastFlag={opt.lastFlag}
                          rowChooseChecked={this.props.tabVisibility}
                        />
                      )
                    })
                  }
                </tbody>
              </Table>
            </Col>
          </Row>
          <Row>
            <Col xs={12}>
              <Pagination className='akashic-table-pagination'
                max={this.props.paginationItems}
                curr={this.props.activePage}
                handlePaginationSelect={this.handlePaginationSelect}
              />
            </Col>
          </Row>
        </Grid>
      </div>
    )
  }
}
export default AkashicResourceTableArea
