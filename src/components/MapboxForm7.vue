<template>
  <div class="floating-form">
    <mapbox-address-autofill @suggestionselect="onSelect">
      <input
        type="text"
        placeholder="Shipping Address"
        autocomplete="shipping address-line1"
      />
    </mapbox-address-autofill>

    <mapbox-address-autofill @suggestionselect="onSelect">
      <input
        type="text"
        placeholder="Billing Address"
        autocomplete="billing address-line1"
      />
    </mapbox-address-autofill>
  </div>
</template>

<script>
export default {
  mounted() {
    const ACCESS_TOKEN = "pk.eyJ1IjoibmF0ZTg5IiwiYSI6ImNtZW1sYmtwaTBxeWYyanFyNjVwYWg1dG8ifQ.dh_0BI7N2YRCVq15WUfaXA";

    const autofillElements = this.$el.querySelectorAll("mapbox-address-autofill");
    autofillElements.forEach(el => el.accessToken = ACCESS_TOKEN);
  },
  methods: {
    onSelect(e) {
      // Mapbox returns coordinates of the selected suggestion
      const coords = e.features[0].geometry.coordinates;
      this.$emit("select-address", coords);
    }
  }
};
</script>

<style scoped>
.floating-form {
  position: absolute;
  top: 10px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  background: rgba(255,255,255,0.9);
  padding: 1rem;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.2);
  z-index: 3;
  min-width: 250px;
}
.floating-form input {
  padding: 0.5rem;
  border-radius: 4px;
  border: 1px solid #ccc;
}
</style>
