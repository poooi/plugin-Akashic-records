import path from 'path-extra'
import CSON from 'cson'
module.exports = CSON.parseCSONFile path.join(__dirname, '..', 'assets', 'data', 'constant.cson')
