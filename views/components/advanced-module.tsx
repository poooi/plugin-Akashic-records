import React, { useState, useCallback } from 'react'
import styled from 'styled-components'
import { Icon, HTMLSelect, PopoverInteractionKind, ControlGroup, Button } from '@blueprintjs/core'
import { Popover } from 'views/components/etc/overlay'
import { IconNames } from '@blueprintjs/icons'
import { remote, shell } from 'electron'
import { useTranslation } from 'react-i18next'
import { useDispatch } from 'react-redux'
import { saveLog, importLog } from '../utils/advanced-module'
import { DataType } from 'views/reducers/tab'
import { initializeLogs } from '../actions'

const { dialog } = remote.require('electron')
const { openExternal } = shell

const Container = styled.div`
  padding: 8px 16px;
`

const Title = styled.div`
  display: flex;
  font-size: 18px;
  padding: 0.5em 0;
`

const PopoverTitle = styled.div`
  display: flex;
  font-size: 18px;
`

const PopoverContent = styled.div`
  padding: 1em;
`

const Content = styled.div`
  display: flex;
`

const ImportExportBtn = styled.div`
  margin-right: 2em;
`

const AdvancedModule: React.FC<{}> = () => {
  const { t } = useTranslation('poi-plugin-akashic-records')
  const [typeChoosed, setTypeChoosed] = useState<DataType>('attack')

  const dispatch = useDispatch()

  const onLogsReset = useCallback((logs, type) => dispatch(initializeLogs(logs, type)), [dispatch])

  const showMessage = (message: string) => {
    dialog.showMessageBox({
      type: 'info',
      buttons: ['OK'],
      title: 'Warning',
      message: message,
    })
  }

  const saveLogHandle = useCallback(() => saveLog(typeChoosed, showMessage, t), [typeChoosed, t])

  const importLogHandle = useCallback(() => importLog(onLogsReset, showMessage, t), [onLogsReset, t])

  const popoverContent = (
    <PopoverContent>
      <PopoverTitle>{t("Exporting")}</PopoverTitle>
      <ul>
        <li>{t("Choose the data you want to export")}</li>
        <li>{t("The file's encoding is UTF-8")}</li>
      </ul>
      <PopoverTitle>{t("Importing")}</PopoverTitle>
      <ul>
        <li>{t("Support List")}
          <ul>
            <li>航海日誌 拡張版</li>
            <li>KCV-yuyuvn</li>
          </ul>
        </li>
      </ul>
      <PopoverTitle>{t("Need more?")}</PopoverTitle>
      <ul>
        <li>
          <a onClick={() => openExternal("https://github.com/poooi/plugin-Akashic-records/issues/new")}>
            {t("open a new issue on github")}
          </a>
        </li>
        <li>
          {t("or email")} <a onClick={() => openExternal("mailto:jenningswu@gmail.com")}>jenningswu@gmail.com</a>
        </li>
      </ul>
    </PopoverContent>
  )

  return (
    <Container>
      <Title>
        {t('Importing/Exporting')}
        <Popover
          content={popoverContent}
          interactionKind={PopoverInteractionKind.CLICK}
          hasBackdrop
        >
          <Icon icon={IconNames.HELP} iconSize={18} />
        </Popover>
      </Title>
      <Content>
        <ImportExportBtn>
          <ControlGroup>
            <HTMLSelect
              value={typeChoosed}
              onChange={(event: React.FormEvent<HTMLSelectElement>) => setTypeChoosed(event.currentTarget.value as DataType)}
            >
              <option key={0} value="attack">{t("Sortie")}</option>
              <option key={1} value="mission">{t("Expedition")}</option>
              <option key={2} value="createitem">{t("Construction")}</option>
              <option key={3} value="createship">{t("Development")}</option>
              <option key={4} value="retirement">{t("Retirement")}</option>
              <option key={5} value="resource">{t("Resource")}</option>
            </HTMLSelect>
            <Button onClick={saveLogHandle}>{t("Export")}</Button>
          </ControlGroup>
        </ImportExportBtn>
        <ImportExportBtn>
          <Button onClick={importLogHandle}>{t("Import")}</Button>
        </ImportExportBtn>
      </Content>
      <Title />
      <Content>
        <Button onClick={() => openExternal('https://github.com/yudachi/plugin-Akashic-records')}>
          {t('Bug Report & Suggestion')}
        </Button>
      </Content>
    </Container>
  )
}

export default AdvancedModule
