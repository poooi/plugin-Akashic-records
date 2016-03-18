{config, __, Immutable} = window

tableTab =
  attack: Immutable.List.of('No.', 'Time', 'World', "Node", "Sortie Type",
          "Battle Result", "Enemy Encounters", "Drop",
          "Heavily Damaged", "Flagship",
          "Flagship (Second Fleet)", 'MVP',
          "MVP (Second Fleet)")
  mission: Immutable.List.of('No.', "Time", "Type", "Result", "Fuel",
          "Ammo", "Steel", "Bauxite", "Item 1",
          "Number", "Item 2", "Number")
  createitem: Immutable.List.of('No.', "Time", "Result", "Development Item",
              "Type", "Fuel", "Ammo", "Steel",
              "Bauxite", "Flagship", "Headquarters Level")
  createship: Immutable.List.of('No.', "Time", "Type", "Ship", "Ship Type",
              "Fuel", "Ammo", "Steel", "Bauxite",
              "Development Material", "Empty Docks", "Flagship",
              "Headquarters Level")
  resource: Immutable.List.of('No.', "Time", "Fuel", "Ammo", "Steel",
            "Bauxite", "Fast Build Item", "Instant Repair Item",
            "Development Material", "Improvement Materials")

defaultTabVisibility = [true, true, true, true, true, true, true,
                true, true, true, true, true, true, true]

getTabs = (type) ->
  if not tableTab[type]?
    state = Immutable.List()
  else
    state = tableTab[type].map (tab) ->
      __ tab
  state

module.exports =
  tabs: (state, action) =>
    if not state?
      state = getTabs(action.dataType)
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
      state = Immutable.List(state)
    if action.type is "SET_TAB_VISIBILITY"
      state.set action.index, action.val
    else
      state
