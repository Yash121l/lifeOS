import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks(id) {
          if (!id.includes('node_modules')) return undefined
          if (id.includes('@tiptap')) return 'editor'
          if (id.includes('firebase')) return 'firebase'
          if (id.includes('date-fns')) return 'date-fns'
          if (id.includes('lucide-react')) return 'icons'
          if (id.includes('react-router')) return 'router'
          return 'vendor'
        },
      },
    },
  },
})
