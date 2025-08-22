<template>
  <div ref="mapContainer" class="map-container"></div>
</template>

<script>
import mapboxgl from "mapbox-gl";
import "mapbox-gl/dist/mapbox-gl.css";

mapboxgl.accessToken = "pk.eyJ1IjoibmF0ZTg5IiwiYSI6ImNtZW1sYmtwaTBxeWYyanFyNjVwYWg1dG8ifQ.dh_0BI7N2YRCVq15WUfaXA";

export default {
    props: ["modelValue"],

  mounted() {
    const {center, zoom} = this.modelValue;

    // create the map instance
    const map = new mapboxgl.Map({
      container: this.$refs.mapContainer,
      style: "mapbox://styles/mapbox/standard",
      center,
        zoom,
    });
    
//Listen for Map moves
    const updateLocation = () => 
      this.$emit("update:modelValue", this.getLocation());
      
      map.on("move", updateLocation);
        map.on("zoom", updateLocation); 
    
    // assign the map instance to this component's map property
    this.map = map;

    // Expose for debugging in console
    window.getRoute = this.getRoute.bind(this);

    //Click to get route
    map.on("click", (event) => {
      const coords = [event.lngLat.lng, event.lngLat.lat];
      
      // update the destination point
      map.getSource('destination-circle').setData({
        type: "FeatureCollection",
        features: [{
            type: "Feature",
            properties: {},
            geometry: {
                type: "Point",
                coordinates: coords,
            },
            },
        ],     
      });

      //Fetch and draw new route
      this.getRoute(coords);
    });

    //Call route once map is ready
    map.on("load", () => {
        const start = [-122.662323, 45.523751]; // example origin
        const end = [-122.678144, 45.522551]; // example destination
        // add origin circle to the map
  map.addLayer({
    'id': 'origin-circle',
    'type': 'circle',
    'source': {
      'type': 'geojson',
      'data': {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {},
            'geometry': {
              'type': 'Point',
              'coordinates': start
            }
          }
        ]
      }
    },
    'paint': {
      'circle-radius': 10,
      'circle-color': '#4ce05b'
    }
  });

  // add destination circle to the map
  map.addLayer({
    'id': 'destination-circle',
    'type': 'circle',
    'source': {
      'type': 'geojson',
      'data': {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {},
            'geometry': {
              'type': 'Point',
              'coordinates': end
            }
          }
        ]
      }
    },
    'paint': {
      'circle-radius': 10,
      'circle-color': '#f30'
    }
  });

  // make an initial directions request on load
        this.getRoute(end);
    });
    },

  // clean up the map instance when the component is unmounted
  unmounted() {
    this.map.remove();
    this.map = null;
  },

  //watch for changes to the modelValue prop
    watch: {
        modelValue(next) {
            const curr = this.getLocation();

            // if the center has changed, update the map center
            if (
                curr.center.lng !== next.center.lng ||
                curr.center.lat !== next.center.lat ||
                curr.zoom !== next.zoom
            ){
                this.map.flyTo({
                    center: next.center,
                    zoom: next.zoom,
                });
            }
        },
    },
    methods: {
        getLocation() {
        return {
            center: this.map.getCenter(),
            zoom: this.map.getZoom(),
        };
        },
        async getRoute(end) {
      const start = [-122.662323, 45.523751]; // fixed start

      const query = await fetch(
        `https://api.mapbox.com/directions/v5/mapbox/cycling/${start[0]},${start[1]};${end[0]},${end[1]}?steps=true&geometries=geojson&access_token=${mapboxgl.accessToken}`
      );
      const json = await query.json();
      const data = json.routes[0];
      const geojson = {
        type: "Feature",
        properties: {},
        geometry: data.geometry,
      };

      if (this.map.getSource("route")) {
        this.map.getSource("route").setData(geojson);
      } else {
        this.map.addLayer({
          id: "route",
          type: "line",
          source: {
            type: "geojson",
            data: geojson,
          },
          layout: {
            "line-join": "round",
            "line-cap": "round",
          },
          paint: {
            "line-color": "#3887be",
            "line-width": 5,
            "line-opacity": 0.75,
          },
        });
      }
      // get the sidebar and add the instructions
const instructions = document.getElementById('instructions');
const steps = data.legs[0].steps;

let tripInstructions = '';
for (const step of steps) {
  tripInstructions += `<li>${step.maneuver.instruction}</li>`;
}

instructions.innerHTML = `<p id="prompt">📍 Click the map to get directions to another destination</p><p><strong>Trip duration: ${Math.floor(
  data.duration / 60
)} min 🚴 </strong></p><ol>${tripInstructions}</ol>`;
    },
  },
};

</script>

<style>
/* make the map container fill its parent */
.map-container {
  width: 100%;
  height: 100%;
}
</style>