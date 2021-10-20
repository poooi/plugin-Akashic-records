export const windowMode = true

export { reactClass } from './views'

export { settingsClass } from './views/setting'

export { reducer } from './views/reducers'

import { apiResolver } from './views/api-resolver'

export function pluginDidLoad() {
  apiResolver.start()
}

export function pluginWillUnload() {
  apiResolver.stop()
}
