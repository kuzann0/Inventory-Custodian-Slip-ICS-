import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Use port 3000 on 127.0.0.1
    port: 3000,
    // Bind to 127.0.0.1 for local access
    host: '127.0.0.1',
    proxy: {
      '/api': {
        // API target: backend service on port 3001
        target: 'http://127.0.0.1:3001',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    },
    cors: true,
    // HMR configuration for hot module replacement
    middlewareMode: false,
    hmr: {
      host: '127.0.0.1',
      port: 3000
    }
  }
})
