<template>
  <div class="map-wrapper">
    <!-- Map container -->
    <div ref="mapContainer" class="map-container"></div>

    <!-- Floating form -->
    <div class="floating-form">
      <form id="shipping-form">
        <h3>Shipping Address</h3>
        <div class="field-group">
          <div>
            <label for="address">Address</label>
            <input id="address" name="address" type="text" autocomplete="address-line1" />
          </div>
        </div>
        <div class="field-group">
          <div>
            <label for="city">City</label>
            <input id="city" name="city" type="text" autocomplete="address-level2" />
          </div>
          <div>
            <label for="state">State</label>
            <input id="state" name="state" type="text" autocomplete="address-level1" />
          </div>
          <div>
            <label for="postcode">Postcode</label>
            <input id="postcode" name="postcode" type="text" autocomplete="postal-code" />
          </div>
        </div>
      </form>

      <!-- Reset Map Button -->
      <button @click="resetMap">Reset Map</button>
    </div>
  </div>
</template>

<script>
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";

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

    // Setup Autofill once Mapbox Search script loads
    const script = document.createElement("script");
    script.src = "https://api.mapbox.com/search-js/v1.2.0/web.js";
    script.defer = true;
    script.onload = () => {
      mapboxsearch.autofill({
        accessToken: mapboxgl.accessToken,
        // Attach to your form
        input: document.getElementById("address"),
      });
    };
    document.head.appendChild(script);

    // Map load setup
    map.on("load", () => {
      this.addCircle("origin-circle", this.start, "#4ce05b");
      this.addCircle("destination-circle", this.end, "#f30");
      this.getRoute(this.end);
    });

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

    map.on("move", () => this.$emit("update:modelValue", this.getLocation()));
    map.on("zoom", () => this.$emit("update:modelValue", this.getLocation()));
  },
  methods: {
    resetMap() {
      this.map.flyTo({ center: this.start, zoom: 12 });
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
  background: #fff;
  padding: 1rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  max-width: 800px;
  z-index: 10;
}

form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.field-group {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.field-group > div {
  flex: 1;
  min-width: 100px;
}

label {
  font-weight: 500;
  margin-bottom: 0.3rem;
}

input {
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  width: 100%;
}
</style>
