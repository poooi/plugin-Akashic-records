{config} = window

configList = ["Show Headings", "Show Filter-box",
            "Auto-selected", "Disable filtering while hiding filter-box"]

getTabs = () =>
  configList.map (tab) ->
    __ tab

module.exports =
  configList: (state, action) =>
    if not state?
      state = getTabs()
    if action.type is 'SET_LANGUAGE'
      getTabs()
    else
      state

  configListChecked: (state, action) =>
    if not state?
      state = JSON.parse config.get "plugin.Akashic.#{action.dataType}.configChecked",
        JSON.stringify [true, true, false, false]
    switch action.type
      when 'SET_CONFIG_LIST'
        tmp = [state...]
        tmp[action.index] = not state[action.index]
      else
        state

  checkboxVisible: (state, action) =>
    if not state?
      state = config.get "plugin.Akashic.#{action.dataType}.checkboxPanelShow", true
    switch action.type
      when 'SHOW_CHECKBOX_PANEL'
        true
      when 'HIDDEN_CHECKBOX_PANEL'
        false
      else
        state

  statisticsVisible: (state, action) =>
    if not state?
      state = config.get "plugin.Akashic.#{action.dataType}.statisticsPanelShow", true
    switch action.type
      when 'SHOW_STATISTICS_PANEL'
        true
      when 'HIDDEN_STATICTICS_PANEL'
        false
      else
        state
