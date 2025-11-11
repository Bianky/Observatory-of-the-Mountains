var map = L.map('map').setView([41.9, 2.2], 8);


L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
	attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

var marker = L.marker([41.3851, 2.1734]).addTo(map)
	.bindPopup('Hola! You are in Catalonia 🇪🇸')
	.openPopup();