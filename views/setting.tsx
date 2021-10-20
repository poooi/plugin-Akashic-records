import { Button, ControlGroup, FormGroup, InputGroup } from '@blueprintjs/core'
import { remote } from 'electron'
import fs from 'fs-extra'
import { get } from 'lodash'
import React, { useRef } from 'react'
import { useTranslation } from 'react-i18next'
import { Selector, useSelector } from 'react-redux'
import { IState } from 'views/utils/selectors'

const { config, APPDATA_PATH } = window

const { dialog } = remote

const CONFIG_PATH = 'plugin.Akashic.dataPath'

const dataPathSelector: Selector<IState, string> = state => get(state.config, CONFIG_PATH, APPDATA_PATH) as string

export const settingsClass: React.FC = () => {
  const lock = useRef(false)

  const { t } = useTranslation('poi-plugin-akashic-records')

  const configPath = useSelector(dataPathSelector)

  const handleFilePickerOpen = async () => {
    if (lock.current) {
      return
    }
    fs.ensureDirSync(configPath)
    lock.current = true
    const { filePaths } = await dialog.showOpenDialog({
      title: t("Choose Folder"),
      defaultPath: configPath,
      properties: ['openDirectory', 'createDirectory'],
    })
    lock.current = false
    if (filePaths != null && filePaths[0]) {
      config.set(CONFIG_PATH, filePaths[0])
    }
  }

  return (
    <div>
      <FormGroup label={t("Data Folder")} helperText={t("It will take effect after a restart")}>
        <ControlGroup>
          <InputGroup value={configPath} fill disabled />
          <Button intent="primary" onClick={handleFilePickerOpen}>{t("Choose Folder")}</Button>
          <Button intent="warning" onClick={() => config.set(CONFIG_PATH, APPDATA_PATH)} >
            {t("RESET")}
          </Button>
        </ControlGroup>
      </FormGroup>
    </div>
  )
}
