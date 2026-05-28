import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Use port 5173 - accessible from all interfaces
    port: 5173,
    // Bind to 0.0.0.0 to be accessible from all machines
    host: '0.0.0.0',
    proxy: {
      '/api': {
        // API target: backend service on port 3001
        target: 'http://backend:80',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    },
    cors: true,
    middlewareMode: false,
    // HMR configuration for development
    hmr: {
      host: process.env.VITE_HMR_HOST || 'localhost',
      port: parseInt(process.env.VITE_HMR_PORT || '5173'),
      protocol: process.env.VITE_HMR_PROTOCOL || 'ws'
    }
  }
})
