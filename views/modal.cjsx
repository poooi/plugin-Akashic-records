{React, ReactDOM, ReactBootstrap, $} = window
{Modal, Button} = ReactBootstrap

# Notification modal
ModalTrigger = React.createClass
  getInitialState: ->
    isModalOpen: false
    title: null
    content: null
  handleToggle: ->
    window.modalLocked = false
    @setState
      isModalOpen: false
    window.showModal()
  handleModal: (e) ->
    window.modalLocked = true
    @setState
      isModalOpen: true
      title: e.detail.title
      content: e.detail.content
      footer: e.detail.footer
  componentDidMount: ->
    window.addEventListener 'poi.modal', @handleModal
  componentWillUnmount: ->
    window.removeEventListener 'poi.modal', @handleModal
  renderFooter: (footer) ->
    return unless footer? and footer.length? and footer.length > 0
    self = @
    footer.map (button, index) ->
      <Button key={index} onClick={
        (e) ->
          self.handleToggle()
          button.func()
      } bsStyle={button.style}>{button.name}</Button>
  render: ->
    <Modal autoFocus={true}
           animation={true}
           show={@state.isModalOpen}
           onHide={@handleToggle}>
      <Modal.Header closeButton>
        <Modal.Title>{@state.title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        {@state.content}
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={@handleToggle}>{__ 'Close'}</Button>
        {@renderFooter @state.footer}
      </Modal.Footer>
    </Modal>

module.exports = 
  ModalTrigger: ModalTrigger

ReactDOM.render <ModalTrigger />, $('akashic-records-modal-trigger')
