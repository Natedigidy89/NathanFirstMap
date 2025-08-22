<template>
  <div class="map-wrapper">
    <!-- Map container -->
    <div ref="mapContainer" class="map-container"></div>

    <!-- Floating shipping/billing forms -->
    <div class="floating-form">
      <mapbox-address-autofill>
        <input
          type="text"
          placeholder="Shipping Address"
          autocomplete="shipping address-line1"
        />
      </mapbox-address-autofill>

      <mapbox-address-autofill>
        <input
          type="text"
          placeholder="Billing Address"
          autocomplete="billing address-line1"
        />
      </mapbox-address-autofill>

      <!-- Reset Map Button -->
      <button @click="resetMap">Reset Map</button>
    </div>
  </div>
</template>

<script>
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";

// Mapbox access token
mapboxgl.accessToken =
  "pk.eyJ1IjoibmF0ZTg5IiwiYSI6ImNtZW1sYmtwaTBxeWYyanFyNjVwYWg1dG8ifQ.dh_0BI7N2YRCVq15WUfaXA";

export default {
  props: ["modelValue"],
  data() {
    return {
      map: null,
      start: [-122.662323, 45.523751],
      end: [-122.678144, 45.522551],
    };
  },
  mounted() {
    // Enable Mapbox Autofill on floating inputs
    const autofillElements = this.$el.querySelectorAll("mapbox-address-autofill");
    autofillElements.forEach((el) => (el.accessToken = mapboxgl.accessToken));

    // Initialize map
    const { center, zoom } = this.modelValue;
    const map = new mapboxgl.Map({
      container: this.$refs.mapContainer,
      style: "mapbox://styles/mapbox/streets-v11",
      center,
      zoom,
    });

    this.map = map;
    this.$emit("mounted", map);

    // Add start & end points and initial route when map loads
    map.on("load", () => {
      this.addCircle("origin-circle", this.start, "#4ce05b");
      this.addCircle("destination-circle", this.end, "#f30");
      this.getRoute(this.end);
    });

    // Click map to set new destination
    map.on("click", (event) => {
      const coords = [event.lngLat.lng, event.lngLat.lat];
      if (this.map.getSource("destination-circle")) {
        this.map.getSource("destination-circle").setData({
          type: "FeatureCollection",
          features: [{ type: "Feature", properties: {}, geometry: { type: "Point", coordinates: coords } }],
        });
      }
      this.getRoute(coords);
    });

    // Update modelValue on move/zoom
    map.on("move", () => this.$emit("update:modelValue", this.getLocation()));
    map.on("zoom", () => this.$emit("update:modelValue", this.getLocation()));
  },
  methods: {
    resetMap() {
      // Fly to original center
      this.map.flyTo({ center: this.start, zoom: 12 });

      // Reset destination circle and route
      if (this.map.getSource("destination-circle")) {
        this.map.getSource("destination-circle").setData({
          type: "FeatureCollection",
          features: [{ type: "Feature", properties: {}, geometry: { type: "Point", coordinates: this.end } }],
        });
      }
      this.getRoute(this.end);
    },
    getLocation() {
      return { center: this.map.getCenter(), zoom: this.map.getZoom() };
    },
    addCircle(id, coords, color) {
      this.map.addLayer({
        id,
        type: "circle",
        source: {
          type: "geojson",
          data: {
            type: "FeatureCollection",
            features: [{ type: "Feature", properties: {}, geometry: { type: "Point", coordinates: coords } }],
          },
        },
        paint: { "circle-radius": 10, "circle-color": color },
      });
    },
    async getRoute(end) {
      const start = this.start;
      const query = await fetch(
        `https://api.mapbox.com/directions/v5/mapbox/cycling/${start[0]},${start[1]};${end[0]},${end[1]}?steps=true&geometries=geojson&access_token=${mapboxgl.accessToken}`
      );
      const json = await query.json();
      const data = json.routes[0];

      const geojson = { type: "Feature", properties: {}, geometry: data.geometry };
      if (this.map.getSource("route")) {
        this.map.getSource("route").setData(geojson);
      } else {
        this.map.addLayer({
          id: "route",
          type: "line",
          source: { type: "geojson", data: geojson },
          layout: { "line-join": "round", "line-cap": "round" },
          paint: { "line-color": "#3887be", "line-width": 5, "line-opacity": 0.75 },
        });
      }

      // Update instructions
      const instructions = document.getElementById("instructions");
      if (instructions) {
        const steps = data.legs[0].steps;
        let tripInstructions = "";
        steps.forEach((step) => (tripInstructions += `<li>${step.maneuver.instruction}</li>`));
        instructions.innerHTML = `<p><strong>Trip duration: ${Math.floor(data.duration / 60)} min 🚴</strong></p><ol>${tripInstructions}</ol>`;
      }
    },
  },
};
</script>

<style scoped>
.map-wrapper {
  position: relative;
  width: 100%;
  height: 100vh;
}

.map-container {
  width: 100%;
  height: 100%;
}

.floating-form {
  position: absolute;
  top: 10px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  background: rgba(255, 255, 255, 0.85);
  padding: 1rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  min-width: 250px;
  z-index: 10;
}

.floating-form input {
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  width: 100%;
  font-size: 1rem;
}

.floating-form button {
  margin-top: 0.5rem;
  padding: 0.5rem;
  background: #3887be;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.floating-form button:hover {
  background: #2a6a96;
}
</style>
