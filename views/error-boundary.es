import React, { Component } from 'react'
import { FormControl, Button } from 'react-bootstrap'
import { clipboard } from 'electron'

const { __ } = window.i18n['poi-plugin-akashic-records']

class ErrorBoundary extends Component {
  state = {
    hasError: false,
    error: null,
    info: null,
  }

  componentDidCatch = (error, info) => {
    this.setState({
      hasError: true,
      error,
      info,
    })
  }

  handleCopy = () => {
    const { error, info } = this.state
    const code = [error.stack, info.componentStack].join('\n')

    clipboard.writeText(code)
  }

  render() {
    const { hasError, error, info } = this.state
    const { component: WrappedComponent, ...props } = this.props
    if (hasError) {
      const code = [error.stack, info.componentStack].join('\n')
      return (
        <div className="error-message">
          <h1>{__('A 🐢 found')}</h1>
          <p>{__('Something went wrong in the plugin, you may report this to the poi dev team, with the code below.')}</p>
          <FormControl
            componentClass="textarea"
            readOnly
            value={code}
          />
          <Button bsStyle="primary" onClick={this.handleCopy}>{__('Copy to clipboard')}</Button>
        </div>
      )
    }
    return (
      <WrappedComponent {...props} />
    )
  }
}

export default ErrorBoundary
