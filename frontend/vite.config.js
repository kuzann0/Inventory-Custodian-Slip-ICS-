import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Use port 3000 for stable local development
    port: process.env.VITE_PORT || 3000,
    host: '127.0.0.1',
    proxy: {
      '/api': {
        // API target: http://localhost:8080 for local dev, http://backend:80 for Docker
        target: process.env.VITE_API_URL || 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    },
    cors: true,
    // Enable HMR for proper hot module replacement
    hmr: {
      host: 'localhost',
      port: 3000,
      protocol: 'http'
    }
  }
})
