/**
 * API Utility Functions with Timeout and Error Handling
 * Handles network errors, timeouts, and error responses
 */

import API_BASE_URL from '../config/api.js';

// Default timeout: 30 seconds
const DEFAULT_TIMEOUT = 30000;

/**
 * Make an API call with timeout and error handling
 * @param {string} endpoint - API endpoint path
 * @param {Object} options - Fetch options (method, headers, body, etc.)
 * @param {number} timeout - Request timeout in milliseconds
 * @returns {Promise} - Response data or error
 */
export const apiCall = async (endpoint, options = {}, timeout = DEFAULT_TIMEOUT) => {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const url = `${API_BASE_URL}${endpoint}`;
    
    const response = await fetch(url, {
      ...options,
      signal: controller.signal,
      credentials: 'include', // Send cookies with request
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    });

    clearTimeout(timeoutId);

    // Handle non-2xx responses
    if (!response.ok) {
      let errorData;
      try {
        errorData = await response.json();
      } catch {
        errorData = { error: response.statusText };
      }

      const error = new Error(errorData.error || `HTTP ${response.status}`);
      error.status = response.status;
      error.data = errorData;
      throw error;
    }

    // Parse response
    const data = await response.json();
    return { success: true, data };

  } catch (error) {
    clearTimeout(timeoutId);

    // Handle timeout
    if (error.name === 'AbortError') {
      console.error(`Request timeout after ${timeout}ms to ${endpoint}`);
      return {
        success: false,
        error: 'Request timeout. Please try again.',
        details: error.message
      };
    }

    // Handle network errors
    if (!navigator.onLine) {
      console.error('Network error - no internet connection');
      return {
        success: false,
        error: 'No internet connection',
        offline: true
      };
    }

    // Handle other errors
    console.error(`API error for ${endpoint}:`, error);
    return {
      success: false,
      error: error.message || 'An error occurred',
      status: error.status,
      details: error.data
    };
  }
};

/**
 * GET request helper
 */
export const apiGet = (endpoint, options = {}, timeout = DEFAULT_TIMEOUT) => {
  return apiCall(endpoint, { method: 'GET', ...options }, timeout);
};

/**
 * POST request helper
 */
export const apiPost = (endpoint, body = {}, options = {}, timeout = DEFAULT_TIMEOUT) => {
  return apiCall(
    endpoint,
    {
      method: 'POST',
      body: JSON.stringify(body),
      ...options
    },
    timeout
  );
};

/**
 * PUT request helper
 */
export const apiPut = (endpoint, body = {}, options = {}, timeout = DEFAULT_TIMEOUT) => {
  return apiCall(
    endpoint,
    {
      method: 'PUT',
      body: JSON.stringify(body),
      ...options
    },
    timeout
  );
};

/**
 * DELETE request helper
 */
export const apiDelete = (endpoint, options = {}, timeout = DEFAULT_TIMEOUT) => {
  return apiCall(endpoint, { method: 'DELETE', ...options }, timeout);
};

/**
 * Retry promise N times with exponential backoff
 * @param {Function} fn - Function to retry
 * @param {number} retries - Number of retries
 * @param {number} delay - Initial delay in milliseconds
 */
export const retryAsync = async (fn, retries = 3, delay = 1000) => {
  for (let i = 0; i < retries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === retries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)));
    }
  }
};

export default {
  apiCall,
  apiGet,
  apiPost,
  apiPut,
  apiDelete,
  retryAsync
};
