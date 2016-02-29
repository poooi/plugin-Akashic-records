statisticsRule = (state, action) =>
  switch action.type
    when 'ADD_SEARCH_RULE'
      numeratorType: 1
      denominatorType: 1
      numerator: 0
      denominator: 1
    when 'SET_STATISTICS_RULE_NUMERATOR_TYPE'
      state.baseOn = action.val
    when 'SET_STATISTICS_RULE_DENOMINATOR_TYPE'
      state.content = action.val
    when 'SET_STATISTICS_RULE_NUMERATOR'
      state.baseOn = action.val
    when 'SET_STATISTICS_RULE_DENOMINATOR'
      state.content = action.val
    else
      state

module.exports = (state = [], action) =>
    switch action.type
      when 'ADD_STATISTICS_RULE'
        [state..., statisticsRule(undefined, action)]
      when 'SET_STATISTICS_RULE_NUMERATOR_TYPE'
        state
      when 'SET_STATISTICS_RULE_DENOMINATOR_TYPE'
        state
      when 'SET_STATISTICS_RULE_NUMERATOR'
        state
      when 'SET_STATISTICS_RULE_DENOMINATOR'
        state
      when 'DELETE_STATISTICS_RULE'
        state
      else
        state
