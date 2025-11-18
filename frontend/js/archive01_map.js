// 1. Create the map first
var map = L.map('map').setView([42.2, 1.5], 8);

L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

// 2. Define your marker data
let data = [
  {title: 'Barcelona', lat: 41.38879, long: 2.15899},
  {title: 'Girona', lat: 41.98311, long: 2.82493},
  {title: 'Tarragona', lat: 41.11866, long: 1.24533}
];

// 3. Create a feature group
let myMarkers = L.featureGroup();

// 4. Loop through data and add markers
data.forEach(function(item){
  let marker = L.marker([item.lat, item.long]).bindPopup(item.title); // use item.long
  myMarkers.addLayer(marker);
  // add data to sidebar
	$('.sidebar').append('<div class="sidebar-item">'+item.title+'</div>')
});

// 5. Add markers to map
myMarkers.addTo(map);

// 6. Zoom map to fit all markers
map.fitBounds(myMarkers.getBounds());