/**
 * API Configuration
 * Centralized API endpoint configuration
 */

// Use environment variable or default based on environment
const API_BASE_URL = import.meta.env.VITE_API_URL || 
                     (import.meta.env.DEV 
                       ? 'http://localhost:3001' 
                       : '/api');

export default API_BASE_URL;
