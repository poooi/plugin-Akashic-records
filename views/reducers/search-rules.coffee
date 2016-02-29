searchRule = (state, action) =>
  switch action.type
    when 'ADD_SEARCH_RULE'
      baseOn: 1
      content: ''
    when 'SET_SEARCH_RULE_BASE'
      state.baseOn = action.val
    when 'SET_SEARCH_RULE_KEY'
      state.content = action.val
    else
      state

module.exports = (state = [], action) =>
  switch action.type
    when 'ADD_SEARCH_RULE'
      [state..., searchRule(undefined, action)]
    when 'SET_SEARCH_RULE_BASE'
      state
    when 'SET_SEARCH_RULE_KEY'
      state
    when 'DELETE_SEARCH_RULE'
      state
    else
      state
