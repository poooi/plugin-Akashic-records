{Immutable} = window

defaultFilterKeys = Immutable.List.of('', '', '', '', '', '',
                                      '', '', '', '', '', '')

module.exports = (state = defaultFilterKeys, action) =>
  switch action.type
    when 'SET_FILTER_KEY'
      state.set(action.index, action.val)
    when 'SET_TAB_VISIBILITY'
      if action.val is false and state.get(action.index) isnt ''
        state.set(action.index, '')
    else
      state
