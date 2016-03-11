{config, Immutable} = window

configList = Immutable.List.of("Show Headings", "Show Filter-box",
            "Auto-selected", "Disable filtering while hiding filter-box")

getTabs = () ->
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
      state = Immutable.List(state)
    switch action.type
      when 'SET_CONFIG_LIST'
        if state.get(action.index)
          state.set(action.index, false)
        else
          if action.index < 2
            state.set(action.index, true).set(2, false)
          else if action.index is 2
            state.set(0, false).set(1, false).set(2, true)
          else
            state.set(action.index, true)
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
