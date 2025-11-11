var map = L.map('map').setView([42.2, 1.5], 8);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// List of Pyrenees counties
var pyreneesCounties = [
  "Aran",
  "Alta Ribagorça",
  "Pallars Jussà",
  "Pallars Sobirà",
  "Alt Urgell",
  "Solsonès",
  "Cerdanya",
  "Ripollès",
  "Berguedà"
];

// Load the comarques GeoJSON
fetch('data/counties.json')
  .then(response => response.json())
  .then(data => {
    L.geoJSON(data, {
      style: function (feature) {
        // Check if comarca is in Pyrenees list
        if (pyreneesCounties.includes(feature.properties.NOMCOMAR)) {
          return {
            color: "turquoise",
            weight: 3,
            fillOpacity: 0.4
          };
        } else {
          return {
            color: "#999",
            weight: 1,
            fillOpacity: 0.1
          };
        }
      },
      onEachFeature: function (feature, layer) {
        layer.bindPopup(`<b>${feature.properties.NOMCOMAR}</b>`);
      }
    }).addTo(map);
  });