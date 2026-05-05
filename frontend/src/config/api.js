/**
 * API Configuration
 * Centralized API endpoint configuration
 */

// Determine API URL based on environment
let API_BASE_URL;

if (import.meta.env.VITE_API_URL) {
  // Docker environment - use VITE_API_URL
  // Try to detect if we're in a browser and need to resolve the service
  const envUrl = import.meta.env.VITE_API_URL;
  
  // If it's http://backend (Docker service name), convert to localhost for browser
  if (envUrl === 'http://backend' && typeof window !== 'undefined') {
    API_BASE_URL = 'http://localhost:3001';
  } else {
    API_BASE_URL = envUrl;
  }
} else if (import.meta.env.DEV) {
  // Development without Docker
  API_BASE_URL = 'http://localhost:3001';
} else {
  // Production - use relative path
  API_BASE_URL = '/api';
}

// Fallback to ensure we always have a valid URL
if (!API_BASE_URL || API_BASE_URL === 'undefined' || API_BASE_URL === '') {
  API_BASE_URL = 'http://localhost:3001';
}

console.log('API_BASE_URL:', API_BASE_URL);

export default API_BASE_URL;
