{Immutable} = window

searchRule = (state, action) =>
  switch action.type
    when 'ADD_SEARCH_RULE'
      Immutable.Map
        baseOn: 1
        content: ''
    when 'SET_SEARCH_RULE_BASE'
      state.set 'baseOn', action.val
    when 'SET_SEARCH_RULE_KEY'
      state.set 'content', action.val
    else
      state

module.exports = (state, action) =>
  if not state?
    state = Immutable.List.of(searchRule(undefined, {type: 'ADD_SEARCH_RULE'}))
  switch action.type
    when 'ADD_SEARCH_RULE'
      state.push searchRule(undefined, action)
    when 'SET_SEARCH_RULE_BASE', 'SET_SEARCH_RULE_KEY'
      console.log state
      console.log action
      state.set action.index, searchRule(state.get(action.index), action)
    when 'DELETE_SEARCH_RULE'
      tmp = state.delete(action.index)
      tmp.map (item) ->
        if item.get('baseOn') > action.index + 1
          item.set('baseOn', item.get('baseOn') - 1)
        else
          item
    else
      state
