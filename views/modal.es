import React from 'react'
import ReactDOM from 'react-dom'
import { Modal, Button } from 'react-bootstrap'
const { $, __ } = window

// Notification modal
class ModalTrigger extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      isModalOpen: false,
      title: null,
      content: null,
    }
  }

  handleToggle = () => {
    window.modalLocked = false
    this.setState({ isModalOpen: false })
    window.showModal()
  }
  handleModal = (e) => {
    window.modalLocked = true
    this.setState({
      isModalOpen: true,
      title: e.detail.title,
      content: e.detail.content,
      footer: e.detail.footer,
    })
  }
  componentDidMount() {
    window.addEventListener('poi.modal', this.handleModal)
  }
  componentWillUnmount() {
    window.removeEventListener('poi.modal', this.handleModal)
  }
  renderFooter(footer) {
    if (!footer || !footer.length) return
    const self = this
    return footer.map((button, index) => (
      <Button key={index}
              onClick={(e) => {
                self.handleToggle()
                button.func()
              }}
              bsStyle={button.style}>
        {button.name}
      </Button>))
  }
  render() {
    return (
    <Modal autoFocus={true}
           animation={true}
           show={this.state.isModalOpen}
           onHide={this.handleToggle}>
      <Modal.Header closeButton>
        <Modal.Title>{this.state.title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        {this.state.content}
      </Modal.Body>
      <Modal.Footer>
        <Button onClick={this.handleToggle}>{__('Close')}</Button>
        {this.renderFooter(this.state.footer)}
      </Modal.Footer>
    </Modal>)
  }
}

export default { ModalTrigger: ModalTrigger }
ReactDOM.render(
  <ModalTrigger />,
  $('akashic-records-modal-trigger')
)
