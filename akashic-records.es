const { ROOT } = window
require(`${ROOT}/views/env`)
require(`${ROOT}/views/battle-env`)

const { config, $ } = window

import path from 'path-extra'

// i18n configure
const i18n = new (require('i18n-2'))({
  locales: ['en-US', 'ja-JP', 'zh-CN', 'zh-TW'],
  defaultLocale: 'zh-CN',
  directory: path.join(__dirname, 'i18n'),
  extension: '.json',
  devMode: false,
})

i18n.setLocale(window.language)
window.__ = i18n.__.bind(i18n)
window.translate = i18n.translate.bind(i18n)

function setTheme(theme) {
  window.theme = theme
  const cssDom = $('#bootstrap-css')
  if (cssDom != null) {
    cssDom.setAttribute('href',
      theme === '__default__'
      ? "file://" + require.resolve('bootstrap/dist/css/bootstrap.css')
      : `file://${ROOT}/assets/themes/#{theme}/css/#{theme}.css`)
  }
}
setTheme(config.get('poi.theme', '__default__'))

window.addEventListener('theme.change', (e) => setTheme(e.detail.theme))

if (window.ipc == null) {
  try {
    const { remote } = window
    window.ipc = remote.require('./lib/ipc')
  } catch (e) {
    if (process.env.DEBUG) {
      // eslint-disable-next-line
      console.log(e)
    }
  }
}

window.CONST = require(path.join(__dirname, 'lib', 'constant'))

let requirePass = false
try {
  require('iconv-lite')
  require('jschardet')
  require('react-redux')
  require('redux')
  require('reselect')
  requirePass = true
} catch (e) {
  requirePass = false
}

switch (window.language) {
case 'ja-JP':
  document.title = 'アカシックレコード'
  break
case 'zh-CN':
  document.title = '阿克夏记录'
  break
case 'zh-TW':
  document.title = '阿克夏紀錄'
  break
default:
  document.title = 'Akashic Records'
}

if (requirePass) {
  require('./views')
} else {
  require('./views/error')
}
require('./views/modal')
