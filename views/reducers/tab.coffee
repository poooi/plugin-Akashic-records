{config, __} = window

tableTab =
  attack: ['No.', 'Time', 'World', "Node", "Sortie Type",
          "Battle Result", "Enemy Encounters", "Drop",
          "Heavily Damaged", "Flagship",
          "Flagship (Second Fleet)", 'MVP',
          "MVP (Second Fleet)"]
  mission: ['No.', "Time", "Type", "Result", "Fuel",
          "Ammo", "Steel", "Bauxite", "Item 1",
          "Number", "Item 2", "Number"]
  createitem: ['No.', "Time", "Result", "Development Item",
              "Type", "Fuel", "Ammo", "Steel",
              "Bauxite", "Flagship", "Headquarters Level"]
  createship: ['No.', "Time", "Type", "Ship", "Ship Type",
              "Fuel", "Ammo", "Steel", "Bauxite",
              "Development Material", "Empty Docks", "Flagship",
              "Headquarters Level"]
  resource: ['No.', "Time", "Fuel", "Ammo", "Steel",
            "Bauxite", "Fast Build Item", "Instant Repair Item",
            "Development Material", "Improvement Materials"]

defaultTabVisibility = [true, true, true, true, true, true, true,
                true, true, true, true, true, true, true]

getTabs = (type) =>
  state = tableTab[type].map (tab) ->
    __ tab

module.exports =
  tabs: (state, action) =>
    if not state? and tableTab[action.dataType]
      getTabs(action.dataType)
    if action.type is 'SET_LANGUAGE'
      getTabs(action.dataType)
    else
      state

  language: (state = window.language, action) =>
    if action.type is "SET_LANGUAGE"
      action.language
    else
      state

  tabVisibility: (state, action) =>
    if not state?
      state = JSON.parse config.get "plugin.Akashic.#{action.dataType}.checkbox",
        JSON.stringify defaultTabVisibility
    if action.type is "SET_TAB_VISIBILITY"
      tmp = [state...]
      tmp[action.index] = not state[action.index]
    else
      state
