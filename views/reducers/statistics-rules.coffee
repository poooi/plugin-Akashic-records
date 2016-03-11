{Immutable} = window

statisticsRule = (state, action) =>
  switch action.type
    when 'ADD_SEARCH_RULE'
      Immutable.Map
        numeratorType: 1
        denominatorType: 1
        numerator: 0
        denominator: 1
    when 'SET_STATISTICS_RULE_NUMERATOR_TYPE'
      state.set 'numeratorType', action.val
    when 'SET_STATISTICS_RULE_DENOMINATOR_TYPE'
      state.set 'denominatorType', action.val
    when 'SET_STATISTICS_RULE_NUMERATOR'
      state.set 'numerator', action.val
    when 'SET_STATISTICS_RULE_DENOMINATOR'
      state.set 'denominator', action.val
    else
      state

module.exports = (state = Immutable.List(), action) =>
    switch action.type
      when 'ADD_STATISTICS_RULE'
        state.push statisticsRule undefined, action
      when 'SET_STATISTICS_RULE_NUMERATOR_TYPE',\
           'SET_STATISTICS_RULE_DENOMINATOR_TYPE',\
           'SET_STATISTICS_RULE_NUMERATOR',\
           'SET_STATISTICS_RULE_DENOMINATOR'
        state.set action.index statisticsRule state.get action.index, action
      when 'DELETE_STATISTICS_RULE'
        state.delete action.index
      when 'DELETE_SEARCH_RULE'
        state.map (item) ->
          if item.get('numeratorType') > action.index + 1
            item = item.set('numeratorType', item.get('numeratorType') - 1)
          if item.get('denominatorType') > action.index + 1
            item = item.set('denominatorType', item.get('denominatorType') - 1)
          item
      else
        state
