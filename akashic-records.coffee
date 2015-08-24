require 'coffee-react/register'
require '../../views/env'

i18n = require './node_modules/i18n'
{join} = require 'path-extra'

i18n.configure
  locales: ['en_US', 'ja_JP', 'zh_CN']
  defaultLocale: 'zh_CN'
  directory: join(__dirname, 'i18n')
  updateFiles: false
  indent: '\t'
  extension: '.json'

window.language = config.get 'poi.language', 'en_US'
i18n.setLocale(window.language)
window.__ = i18n.__


require './views'
