// Global variables
let map;
let geoLayer;
let socioData;
let chart;

// paths to data
const geometry = "../data/geometry.geojson";
const socioeconomy = "../data/socio-economy.json";
const environment = "../data/environment.json";

const categories_socioeconomy = {
    population: [
        "p_population",
        "p_density_hkm2",
        "p_0_24_pct",
        "p_25_64_pct",
        "p_65imes_pct",
        "p_growthrate"
    ],
    economy: [
        "e_GDP_mileur",
        "e_gva_agri",
        "e_gva_industry",
        "e_gva_construction",
        "e_gva_servis",
        "e_GDHI_mileur",
        "e_rib"
    ],
    work: [
        "w_unemp",
        "w_active",
        "w_inactive"
    ]
};

const categories_environment = {
    climate: [
        "c_preci_mm",
        "c_wspeed_ms",
        "c_temp_ave",
        "c_temp_avemax",
        "c_temp_avemin"
    ],
    water: [
        "w_domestic_consump",
        "w_industry_consump",
        "w_total_network",
        "w_own_sources",
        "w_total"
    ],
    forest: [
        "f_cleared_ha",
        "f_reforested_ha"
    ],
    land: [
        "l_forests",
        "l_bushes",
        "l_others",
        "l_novege",
        "l_crop_dry",
        "l_crop_irri",
        "l_urban"
    ]
};

const variableNames = {
    // POPULATION
    "p_population": "Population",
    "p_density_hkm2": "Population density (h/km²)",
    "p_0_24_pct": "Age 0–24 (%)",
    "p_25_64_pct": "Age 25–64 (%)",
    "p_65imes_pct": "Age 65+ (%)",
    "p_growthrate": "Population growth rate",

    // ECONOMY
    "e_GDP_mileur": "GDP (million €)",
    "e_gva_agri": "GVA Agriculture (million €)",
    "e_gva_industry": "GVA Industry (million €)",
    "e_gva_construction": "GVA Construction (million €)",
    "e_gva_servis": "GVA Services (million €)",
    "e_GDHI_mileur": "GDHI (million €)",
    "e_rib": "Real Investment Budget (million €)",

    // WORK
    "w_unemp": "Unemployment (%)",
    "w_active": "Active population (%)",
    "w_inactive": "Inactive population (%)",

    // CLIMATE
    "c_preci_mm": "Precipitation (mm)",
    "c_wspeed_ms": "Wind speed (m/s)",
    "c_temp_ave": "Mean temperature (°C)",
    "c_temp_avemax": "Mean max temperature (°C)",
    "c_temp_avemin": "Mean min temperature (°C)",

    // WATER
    "w_domestic_consump": "Domestic water consumption (thousand m³)",
    "w_industry_consump": "Industry water consumption (thousand m³)",
    "w_total_network": "Total network water consumption (thousand m³)",
    "w_own_sources": "Own water sources (thousand m³)",
    "w_total": "Total water consumption (m³)",

    // FOREST
    "f_cleared_ha": "Cleared forest (ha)",
    "f_reforested_ha": "Reforested area (ha)",

    // LAND
    "l_forests": "Forest area (ha)",
    "l_bushes": "Bushes area (ha)",
    "l_others": "Other land area (ha)",
    "l_novege": "No vegetation (ha)",
    "l_crop_dry": "Dry crop land (ha)",
    "l_crop_irri": "Irrigated crop land (ha)",
    "l_urban": "Urban area (ha)"
};




// initialize map and load data
$(document).ready(function() {
    createMap();
    readGeoJSON(geometry);
    readJSON(socioeconomy, "socio");
    readJSON(environment, "env");
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
    geoLayer = L.geoJson(data, {
        style: function(feature) {
            // If this feature is part of the Pyrenees region → make it green
            if (feature.properties.region === "Pyrenees") {
                return {
                    color: "#1f8a3b",     // border color
                    weight: 2,
                    fillColor: "#3cc46e", // fill color
                    fillOpacity: 0.7
                };
            }

            // Default style for all other regions
            return {
                color: "#444",
                weight: 1,
                fillColor: "#cccccc",
                fillOpacity: 0.5
            };
        }
    }).addTo(map);

    map.fitBounds(geoLayer.getBounds());
}

// function read json data
function readJSON(path, type) {
    fetch(path)
        .then(response => response.json())
        .then(data => {
            if(type === "socio") socioData = data;
            else dataEnv = data;

            // Populate sidebar tabs after both datasets are loaded
            if(socioData && dataEnv) populateSidebarTabs();
        })
        .catch(error => console.error("Error loading JSON:", error));
}

// populate sidebar with two tabs
function populateSidebarTabs() {
    const tabs = document.getElementById("tabs");
    const container = document.getElementById("categories-container");

    if(!tabs || !container) return;

    // create tab buttons
    tabs.innerHTML = `
        <button id="tab-socio" class="tab-btn active">Socioeconomy</button>
        <button id="tab-env" class="tab-btn">Environment</button>
    `;

    const tabSocio = document.getElementById("tab-socio");
    const tabEnv = document.getElementById("tab-env");

    // event listeners for tabs
    tabSocio.addEventListener("click", () => showCategory("socio"));
    tabEnv.addEventListener("click", () => showCategory("env"));

    // initially show socioeconomy
    showCategory("socio");
}

function showCategory(type) {
    const container = document.getElementById("categories-container");
    const chartContainer = document.getElementById("chart-container");

    const activeTab = document.querySelector(".tab-btn.active");
    const clickedTabId = type === "socio" ? "tab-socio" : "tab-env";

    // If the clicked tab is already active → collapse
    if (activeTab && activeTab.id === clickedTabId) {
        container.innerHTML = "";
        if(chart) {
            chart.destroy();
            chart = null;
        }
        chartContainer.style.display = "none";
        activeTab.classList.remove("active");
        return;
    }

    // Otherwise, show the selected tab
    container.innerHTML = ""; // clear previous
    chartContainer.style.display = "block";

    let categories = (type === "socio") ? categories_socioeconomy : categories_environment;
    let data = (type === "socio") ? socioData : dataEnv;

    for(const [cat, vars] of Object.entries(categories)) {
        const catDiv = document.createElement("div");
        const catHeader = document.createElement("h4");
        catHeader.textContent = cat.charAt(0).toUpperCase() + cat.slice(1);
        catDiv.appendChild(catHeader);

        const ul = document.createElement("ul");
        vars.forEach(v => {
            const li = document.createElement("li");
            li.textContent = variableNames[v] || v;
            li.addEventListener("click", () => buildLineChart(v, data));
            ul.appendChild(li);
        });
        catDiv.appendChild(ul);
        container.appendChild(catDiv);
    }

    // Highlight the active tab
    document.querySelectorAll(".tab-btn").forEach(b => b.classList.remove("active"));
    document.getElementById(clickedTabId).classList.add("active");
}

// build line chart for selected variable
function buildLineChart(variable, dataset) {
    const catalunyaData = dataset.filter(d => d.region === "Catalunya").sort((a,b) => a.year - b.year);
    const pyreneesData = dataset.filter(d => d.region === "Pyrenees").sort((a,b) => a.year - b.year);

    const years = catalunyaData.map(d => d.year);
    const catalunyaValues = catalunyaData.map(d => d[variable]);
    const pyreneesValues = pyreneesData.map(d => d[variable]);

    const ctx = document.getElementById("variableChart").getContext("2d");

    if(chart) chart.destroy();

    chart = new Chart(ctx, {
        type: "line",
        data: {
            labels: years,
            datasets: [
                { label: "Catalunya", data: catalunyaValues, borderColor: "blue", fill: false },
                { label: "Pyrenees", data: pyreneesValues, borderColor: "green", fill: false }
            ]
        },
        options: {
            responsive: true,
            plugins: { legend: { position: 'top' } },
            scales: {
                x: { title: { display: true, text: "Year" } },
                y: { title: { display: true, text: variableNames[variable] || variable } }
            }
        }
    });
}