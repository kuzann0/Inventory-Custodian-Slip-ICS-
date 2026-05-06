import React from 'react';
import './ErrorBoundary.css';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
      errorCount: 0
    };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // Log error details
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    
    // Update state with error details
    this.setState(prevState => ({
      error,
      errorInfo,
      errorCount: prevState.errorCount + 1
    }));

    // Log to backend for monitoring
    this.logErrorToBackend(error, errorInfo);
  }

  logErrorToBackend = async (error, errorInfo) => {
    try {
      // Fetch API_BASE_URL dynamically
      const API_BASE_URL = import.meta.env.VITE_API_URL || 
                          (import.meta.env.DEV 
                            ? 'http://localhost:3001' 
                            : '/api');

      await fetch(`${API_BASE_URL}/log-error`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({
          message: error.toString(),
          stack: error.stack,
          componentStack: errorInfo.componentStack,
          timestamp: new Date().toISOString(),
          userAgent: navigator.userAgent
        })
      });
    } catch (e) {
      console.error('Failed to log error to backend:', e);
    }
  };

  handleReset = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null
    });
  };

  render() {
    const { hasError, error, errorInfo, errorCount } = this.state;

    if (hasError) {
      return (
        <div className="error-boundary-container">
          <div className="error-boundary-content">
            <h1 className="error-boundary-title">⚠️ Something went wrong</h1>
            <p className="error-boundary-message">
              An unexpected error occurred. Please try refreshing the page.
            </p>

            {import.meta.env.DEV && error && (
              <details className="error-boundary-details">
                <summary>Error details (Development)</summary>
                <div className="error-boundary-stack">
                  <p className="error-message">{error.toString()}</p>
                  <pre className="error-stack">{errorInfo?.componentStack}</pre>
                </div>
              </details>
            )}

            <div className="error-boundary-actions">
              <button
                className="error-boundary-btn error-boundary-btn-primary"
                onClick={this.handleReset}
              >
                Try Again
              </button>
              <button
                className="error-boundary-btn error-boundary-btn-secondary"
                onClick={() => (window.location.href = '/')}
              >
                Go Home
              </button>
              {errorCount > 3 && (
                <button
                  className="error-boundary-btn error-boundary-btn-secondary"
                  onClick={() => {
                    sessionStorage.clear();
                    window.location.href = '/login';
                  }}
                >
                  Clear Session & Login
                </button>
              )}
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
