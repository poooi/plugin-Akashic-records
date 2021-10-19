import React, { Component, ErrorInfo } from 'react'
import { TextArea, Button } from '@blueprintjs/core'
import { clipboard } from 'electron'
import { WithTranslation, withTranslation } from 'react-i18next'

type Props = WithTranslation & {
  component: Component<any, any>;
  [propName: string]: unknown
}

interface State {
  hasError: boolean;
  error?: Error;
  info?: ErrorInfo;
}

const ErrorBoundary = withTranslation('poi-plugin-akashic-records')(
  class InnerErrorBoundary extends Component<Props, State> {
    state: State = {
      hasError: false,
    }

    componentDidCatch = (error: Error, info: ErrorInfo) => {
      this.setState({
        hasError: true,
        error,
        info,
      })
    }

    handleCopy = () => {
      const { error, info } = this.state
      const code = [error?.stack, info?.componentStack].join('\n')

      clipboard.writeText(code)
    }

    render() {
      const { hasError, error, info } = this.state
      const { component: WrappedComponent, t, ...props } = this.props
      if (hasError) {
        const code = [error?.stack, info?.componentStack].join('\n')
        return (
          <div className="error-message">
            <h1>{t('A 🐢 found')}</h1>
            <p>{t('Something went wrong in the plugin, you may report this to the poi dev team, with the code below.')}</p>
            <TextArea
              readOnly
              value={code}
            />
            <Button onClick={this.handleCopy}>{t('Copy to clipboard')}</Button>
          </div>
        )
      }
      return (
        // @ts-ignore
        <WrappedComponent {...props} />
      )
    }
  }
)

export default ErrorBoundary
