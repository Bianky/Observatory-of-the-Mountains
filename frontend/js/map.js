// Global variables
let map;
let geoLayer;
let socioData;
let chart;

// paths to data
const geometry = "data/geometry.geojson";
const socioeconomy = "data/socio-economy.json";

const categories = {
    population: ["population", "density_h/km2", "0-24_%", "25-64_%", "65 i més_%", "pop_growthrate"],
    economy: ["GDP_mileur", "GDP_percapita_eur", "agriculture_gva", "industry_gva", "construction_gva", "servis_gva", "GDHI_mileur", "GDHI_percapita_eur", "rib"],
    work: ["unemp", "active", "inactive"]
};

const variableNames = {
    "population": "Population",
    "density_h/km2": "Population density (h/km²)",
    "0-24_%": "Age 0-24 (%)",
    "25-64_%": "Age 25-64 (%)",
    "65 i més_%": "Age 65+ (%)",
    "pop_growthrate": "Population growth rate",
    "GDP_mileur": "GDP (million €)",
    "GDP_percapita_eur": "GDP per capita (€)",
    "agriculture_gva": "GVA Agriculture (million €)",
    "industry_gva": "GVA Industry (million €)",
    "construction_gva": "GVA Construction (million €)",
    "servis_gva": "GVA Services (million €)",
    "GDHI_mileur": "GDHI (million €)",
    "GDHI_percapita_eur": "GDHI per capita (€)",
    "rib": "Real Investment Budget (million €)",
    "unemp": "Unemployment (%)",
    "active": "Active population (%)",
    "inactive": "Inactive population (%)"
};

// initialize map and load data
$(document).ready(function() {
    createMap();
    readGeoJSON(geometry);
    readJSON(socioeconomy);
});

// create the map
function createMap() {
    map = L.map('map').setView([41.6, 1.9], 7); // center on Catalunya

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
}

// function to read GeoJSON data
function readGeoJSON(path) {
    fetch(path)
        .then(response => response.json())
        .then(data => {
            console.log(data); // inspect your GeoJSON
            mapGeoJSON(data); // call mapping function 
        })
        .catch(error => console.error("Error loading GeoJSON:", error));
}

// function to map GeoJSON data
function mapGeoJSON(data) {
    geoLayer = L.geoJson(data).addTo(map);
    map.fitBounds(geoLayer.getBounds()); // Auto zoom
}

// function to read JSON data
function readJSON(path) {
    fetch(path)
        .then(response => response.json())
        .then(data => {
            socioData = data;
            populateSidebarByCategory();
        })
        .catch(error => console.error("Error loading socio-economy JSON:", error));
}

// populate sidebar with categories
function populateSidebarByCategory() {
    for (const [cat, variables] of Object.entries(categories)) {
        const listEl = document.getElementById(`${cat}-list`);
        variables.forEach(variable => {
            const li = document.createElement("li");
            li.textContent = variableNames[variable] || variable;

            // attach click event
            li.addEventListener("click", () => {
                buildLineChart(variable); // draw the chart
            });

            listEl.appendChild(li);
        });
    }
}

// build line chart
function buildLineChart(variable) {
    // filter for each region
    const catalunyaData = socioData.filter(d => d.region === "Catalunya");
    const pyreneesData = socioData.filter(d => d.region === "Pyrenees");

    // sort by year
    catalunyaData.sort((a, b) => a.year - b.year);
    pyreneesData.sort((a, b) => a.year - b.year);

    // get x-axis labels (years)
    const years = catalunyaData.map(d => d.year);

    // get y-axis values
    const catalunyaValues = catalunyaData.map(d => d[variable]);
    const pyreneesValues = pyreneesData.map(d => d[variable]);

    const ctx = document.getElementById("variableChart").getContext("2d");

    // destroy previous chart if exists
    if (chart) chart.destroy();

    chart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: years,
            datasets: [
                {
                    label: "Catalunya",
                    data: catalunyaValues,
                    borderColor: "blue",
                    fill: false
                },
                {
                    label: "Pyrenees",
                    data: pyreneesValues,
                    borderColor: "green",
                    fill: false
                }
            ]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { position: 'top' }
            },
            scales: {
                x: {
                    title: { display: true, text: "Year" }
                },
                y: {
                    title: { display: true, text: variableNames[variable] || variable } 
                }
            }
        }
    });
}