/**
 * API Configuration
 * Centralized API endpoint configuration
 */

// Determine API URL based on environment
let API_BASE_URL;

if (import.meta.env.VITE_API_URL) {
  // Docker environment - use the local proxy path for same-origin API calls
  // This avoids cross-origin session cookie issues when the frontend runs on port 3000
  if (import.meta.env.DEV && typeof window !== 'undefined') {
    API_BASE_URL = '/api';
  } else {
    const envUrl = import.meta.env.VITE_API_URL;
    // If it's http://backend (Docker service name), convert to localhost for browser access
    if (envUrl === 'http://backend' && typeof window !== 'undefined') {
      API_BASE_URL = 'http://localhost:3001';
    } else {
      API_BASE_URL = envUrl;
    }
  }
} else if (import.meta.env.DEV) {
  // Development without Docker
  API_BASE_URL = 'http://localhost:3001';
} else {
  // Production - use relative path
  API_BASE_URL = './api';
}

// Fallback to ensure we always have a valid URL
if (!API_BASE_URL || API_BASE_URL === 'undefined' || API_BASE_URL === '') {
  API_BASE_URL = 'http://localhost:3001';
}

console.log('API_BASE_URL:', API_BASE_URL);

export default API_BASE_URL;
