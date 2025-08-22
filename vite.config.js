import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [
    vue({
      template: {
        compilerOptions: {
          // Tell Vue to ignore Mapbox Web Components
          isCustomElement: (tag) => tag === 'mapbox-address-autofill'
        }
      }
    })
  ],
  server: {
    port: 5174, // or whatever you prefer
  }
})
