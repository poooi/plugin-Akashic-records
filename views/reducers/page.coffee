{config} = window

module.exports =
  activePage: (state = 1, action) =>
    switch action.type
      when 'SET_ACTIVE_PAGE'
        parseInt action.val
      when 'RESET_ACTIVE_PAGE'
        1
      else
        state

  showAmount: (state, action) =>
    if not state?
      state = parseInt config.get "plugin.Akashic.#{action.dataType}.showAmount", 20
    if action.type is "SET_SHOW_AMOUNT"
      parseInt action.val
    else
      state
