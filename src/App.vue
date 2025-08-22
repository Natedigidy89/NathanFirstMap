<template>
  <div id="app">
    <!-- Sidebar with map coordinates and reset -->
    <div id="sidebar">
      Longitude: {{ location.center.lng.toFixed(4) }} | Latitude: {{ location.center.lat.toFixed(4) }} | Zoom: {{ location.zoom.toFixed(2) }}
    </div>

    <!-- Map component -->
    <Map 
      v-model="location"
      @mounted="mapMounted"
    />

    <!-- Floating instructions box over map -->
    <div id="instructions"></div>
  </div>
</template>

<script>
import Map from "./components/Map.vue";

export default {
  components: { Map },
  data() {
    return {
      location: {
        center: { lng: -122.662323, lat: 45.523751 },
        zoom: 12,
      },
      mapInstance: null,
    };
  },
  methods: {
    resetMap() {
      this.location = {
        center: { lng: -122.662323, lat: 45.523751 },
        zoom: 12,
      };
      if (this.mapInstance) {
        this.mapInstance.flyTo({
          center: this.location.center,
          zoom: this.location.zoom,
        });
      }
    },
    mapMounted(map) {
      this.mapInstance = map;
    },
  },
};
</script>

<style>
#app {
  position: relative;
  height: 100vh;
  width: 100%;
}

#sidebar {
  position: absolute;
  top: 10px;
  left: 10px;
  background: rgba(35,55,75,0.9);
  color: #fff;
  padding: 8px 12px;
  border-radius: 4px;
  font-family: monospace;
  z-index: 3;
}

#instructions {
  position: absolute;
  top: 70px; /* below sidebar */
  left: 10px;
  max-width: 300px;
  background: rgba(255,255,255,0.95);
  padding: 10px;
  border-radius: 6px;
  font-family: sans-serif;
  font-size: 0.9rem;
  line-height: 1.3rem;
  z-index: 2;
  overflow-y: auto;
  max-height: 300px;
}
</style>
