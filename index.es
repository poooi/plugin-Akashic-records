import { remote } from 'electron'
import fs from 'fs-extra'
import React, { Component } from 'react'
import { Grid, Row, Col, Button } from 'react-bootstrap'

const { config, APPDATA_PATH } = window

const { dialog } = remote.require('electron')

const { __ } = window.i18n['poi-plugin-akashic-records']

export const windowMode = true

export { reactClass } from './views'

export { reducer } from './views/reducers'

import { apiResolver } from './views/api-resolver'

export function pluginDidLoad() {
  apiResolver.start()
}

export function pluginWillUnload() {
  apiResolver.stop()
}

// # Parameters:
// #   label       String         The title to display
// #   configName  String         Where you store in config
// #   defaultVal  Bool           The default value for config
// #   onNewVal    Function(val)  Called when a new value is set.
class FolderPickerConfig extends Component {
  state = { myval: config.get(this.props.configName, this.props.defaultVal) }
  onDrag(e) {
    e.preventDefault()
  }
  synchronize = (callback) => {
    if (this.lock) return
    this.lock = true
    callback()
    this.lock = false
  }
  setPath = (val) => {
    if (this.props.onNewVal) {
      this.props.onNewVal(val)
    }
    config.set(this.props.configName, val)
    this.setState({ myval: val })
  }
  folderPickerOnDrop = (e) => {
    e.preventDefault()
    const droppedFiles = e.dataTransfer.files
    if (fs.statSync(droppedFiles[0].path).isDirectory()) {
      this.setPath(droppedFiles[0].path)
    }
  }
  folderPickerOnClick = () => {
    this.synchronize(() => {
      fs.ensureDirSync(this.state.myval)
      const filenames = dialog.showOpenDialog({
        title: this.props.label,
        defaultPath: this.state.myval,
        properties: ['openDirectory', 'createDirectory'],
      })
      if (filenames != null) this.setPath(filenames[0])
    })
  }
  handleReset = () => {
    config.set(this.props.configName, APPDATA_PATH)
    this.setState({ myval: APPDATA_PATH })
  }
  render() {
    return (
      <Grid>
        <Row>
          <Col xs={12}>
            {__("It will take effect after a restart")}
          </Col>
        </Row>
        <Row>
          <Col xs={9}>
            <div className="folder-picker"
              onClick={this.folderPickerOnClick}
              onDrop={this.folderPickerOnDrop}
              onDragEnter={this.onDrag}
              onDragOver={this.onDrag}
              onDragLeave={this.onDrag}>
              {this.state.myval}
            </div>
          </Col>
          <Col xs={3}>
            <Button bsStyle="warning" style={{ padding: 6 }} onClick={this.handleReset} block>{__("RESET")}</Button>
          </Col>
        </Row>
      </Grid>
    )
  }
}

export const settingsClass = () => (
  <FolderPickerConfig
    label={__('Data Folder')}
    configName="plugin.Akashic.dataPath"
    defaultVal={config.get("plugin.Akashic.dataPath", APPDATA_PATH)}/>
)
