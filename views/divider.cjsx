{React} = window
module.exports = React.createClass
  render: ->
    <div className="divider">
      <h5>      
        {@props.text + '  '}
        {
          if @props.icon
            if @props.show
              <FontAwesome name='chevron-circle-down' />
            else 
              <FontAwesome name='chevron-circle-right' />
        }
      </h5>
      <hr />
    </div>
