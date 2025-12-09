
// Global variables
let map;
let socioData;
let dataEnv;
let chart;
let socioMapData;

let mapData = {};  // { year: { countyName: value, ... } }
let currentVariable = null;

let regionLayer;
let countyLayer;

// paths to data
const geometry = "./data/geometry.geojson";
const geometry_counties = "./data/geometry_counties.geojson";

const socioeconomy = "./data/socio-economy.json";
const socioeconomy_counties = "./data/socio-economy_counties.json";

const environment = "./data/environment.json";

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
        //"e_GDP_mileur",
        //"e_GDP_mileur_pc",
        "e_GDP_pi",
        
        //"e_gva_agri",
        //"e_gva_agri_pc",
        "e_gva_agri_pi",
        
        //"e_gva_industry",
        //"e_gva_industry_pc",
        "e_gva_industry_pi",
        
        //"e_gva_construction",
        //"e_gva_construction_pc",
        "e_gva_construction_pi",
        
        //"e_gva_servis",
        //"e_gva_servis_pc",
        "e_gva_servis_pi",
        
        //"e_GDHI",
        "e_GDHI_pc",
        "e_GDHI_pi",
        
        "e_rib",
        "e_rib_pc",
        "e_rib_pi"
    ],

    work: [
        "w_unemp",
        "w_unemp_men",
        "w_unemp_women",
        "w_active",
        "w_active_men",
        "w_active_women",
        "w_inactive_men",
        "w_inactive_women",
        "w_inactive"
    ],

    engagement: [
        "eng_found",
        "eng_assoc",
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
        "f_reforested_ha",
        "f_relative_reforested"

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
    "p_growthrate": "Population growth rate (‰)",

    // ECONOMY
    //"e_GDP_mileur": "GDP (million €)",
    //"e_GDP_mileur_pc": "GDP (per county)",
    "e_GDP_pi": "GDP (per inhabitant in €)",
    
    //"e_gva_agri": "GVA Agriculture (million €)",
    //"e_gva_agri_pc": "GVA Agriculture (per county)",
    "e_gva_agri_pi": "GVA Agriculture (per inhabitant in €)",
    
    //"e_gva_industry": "GVA Industry (million €)",
    //"e_gva_industry_pc": "GVA Industry (per county)",
    "e_gva_industry_pi": "GVA Industry (per inhabitant in €)",
    
    //"e_gva_construction": "GVA Construction (million €)",
    //"e_gva_construction_pc": "GVA Construction (per county)",
    "e_gva_construction_pi": "GVA Construction (per inhabitant in €)",
    
    //"e_gva_servis": "GVA Services (million €)",
    //"e_gva_servis_pc": "GVA Services (per county)",
    "e_gva_servis_pi": "GVA Services (per inhabitant in €)",
    
    //"e_GDHI": "GDHI (thousand €)",
    "e_GDHI_pc": "GDHI (thousand €)",
    "e_GDHI_pi": "GDHI (per inhabitant in €)",
    
    "e_rib": "RIB (million €)",
    "e_rib_pc": "RIB (per county in million €)",
    "e_rib_pi": "RIB (per inhabitant in €)",

    // WORK
    "w_unemp": "Unemployment (%)",
    "w_unemp_men": "Unemployment of men(%)",
    "w_unemp_women": "Unemployment of women(%)",
    "w_active": "Active population (%)",
    "w_active_men": "Active population of men (%)",
    "w_active_women": "Active population of women (%)",
    "w_inactive": "Inactive population (%)",
    "w_inactive_men": "Inactive population of men (%)",
    "w_inactive_women": "Inactive population of women (%)",

    // ENGAGEMENT
    "eng_found": "Foundations",
    "eng_assoc": "Associations",

    // CLIMATE
    "c_preci_mm": "Precipitation (mm)",
    "c_wspeed_ms": "Wind speed (m/s)",
    "c_temp_ave": "Mean temperature (°C)",
    "c_temp_avemax": "Mean max temperature (°C)",
    "c_temp_avemin": "Mean min temperature (°C)",

    // WATER
    "w_domestic_consump": "Domestic water consumption (m³/inhabitant)",
    "w_industry_consump": "Industry water consumption (m³/inhabitant)",
    "w_total_network": "Total network water consumption (m³/inhabitant)",
    "w_own_sources": "Own water sources (m³/inhabitant)",
    "w_total": "Total water consumption (m³/inhabitant)",


    // FOREST
    "f_cleared_ha": "Cleared forest (%)",
    "f_reforested_ha": "Reforested area (%)",
    "f_relative_reforested": "Relative reforested area (%)",


    // LAND
    "l_forests": "Forest area (%)",
    "l_bushes": "Bushes area (%)",
    "l_others": "Other land area (%)",
    "l_novege": "No vegetation (%)",
    "l_crop_dry": "Dry crop land (%)",
    "l_crop_irri": "Irrigated crop land (%)",
    "l_urban": "Urban area (%)"
};


// initialize map and load data
$(document).ready(function() {
    createMap();
    readGeoJSON(geometry, "regions");
    readGeoJSON(geometry_counties, "counties");
    readJSON(socioeconomy, "socio-chart");
    readJSON(socioeconomy_counties, "socio-map");
    readJSON(environment, "env-chart");
});


// create the map
function createMap() {
    if (map) {  
        console.warn("Map already initialized, skipping createMap()");
        return;
    }

    map = L.map('map').setView([41.6, 1.9], 7);

    L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);

    legend.addTo(map);  // ← move legend here (VERY IMPORTANT)
}

// function to read GeoJSON data
function readGeoJSON(path, type) {
    fetch(path)
        .then(response => response.json())
        .then(data => {
            console.log(data); // inspect your GeoJSON
            mapGeoJSON(data, type); // pass type!
        })
        .catch(error => console.error("Error loading GeoJSON:", error));
}

// function to map GeoJSON data
function mapGeoJSON(data, type) {
    const layer = L.geoJson(data, {
        style: function(feature) {
            if (type === "regions" && feature.properties.region === "Pyrenees") {
                return { color: "#807768", weight: 2, fillColor: "#807768", fillOpacity: 0.7 };
            }
            return { color: "#d8e0e3", weight: 1, fillColor: "#d8e0e3", fillOpacity: 0.5 };
        }
    }).addTo(map);

    if(type === "regions") regionLayer = layer;
    else if(type === "counties") countyLayer = layer;

    if(type === "counties") map.fitBounds(layer.getBounds());  // optional
}

// read json files
function readJSON(path, type) {
    fetch(path)
        .then(response => response.json())
        .then(data => {

            switch(type) {
                case "socio-chart":
                    socioData = data;
                    break;

                case "socio-map":
                    socioMapData = data;

                    // build mapData for choropleth
                    data.forEach(row => {
                        if (!mapData[row.year]) mapData[row.year] = {};
                        mapData[row.year][row.county] = row;
                    });
                    break;

                case "counties":
                    // this is the GeoJSON for county shapes
                    countyLayer = L.geoJson(data, {
                        style: function(feature) {
                            return { color: "#d8e0e3", weight: 1, fillColor: "#d8e0e3", fillOpacity: 0.5 };
                        }
                    }).addTo(map);
                    map.fitBounds(countyLayer.getBounds());
                    break;

                case "env-chart":
                    dataEnv = data;
                    break;

                default:
                    console.warn("Unknown JSON type:", type);
            }

            // populate sidebar only when all three datasets are loaded
            if (socioData && dataEnv && socioMapData) {
                populateSidebarTabs();
            }

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
    tabSocio.addEventListener("click", () => showCategory("socio-chart"));
    tabEnv.addEventListener("click", () => showCategory("env-chart"));

    // initially show socioeconomy
    showCategory("socio-chart");
}

function showCategory(type) {
    const container = document.getElementById("categories-container");
    const chartContainer = document.getElementById("chart-container");

    const activeTab = document.querySelector(".tab-btn.active");
    const clickedTabId = type === "socio-chart" ? "tab-socio" : "tab-env";

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

    let categories = (type === "socio-chart") ? categories_socioeconomy : categories_environment;
    let data = (type === "socio-chart") ? socioData : dataEnv;

    for(const [cat, vars] of Object.entries(categories)) {
        const catDiv = document.createElement("div");
        const catHeader = document.createElement("h4");
        catHeader.textContent = cat.charAt(0).toUpperCase() + cat.slice(1);
        catDiv.appendChild(catHeader);

        const ul = document.createElement("ul");
        vars.forEach(v => {
            const li = document.createElement("li");
            li.textContent = variableNames[v] || v;

            // Click listener: update chart and choropleth
            li.addEventListener("click", () => {
                currentVariable = v;                    // store selected variable
                buildLineChart(v, data);                // update chart
                updateChoropleth(
                    document.getElementById("year-slider").value,  // current year
                    v
                );
            });

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
                { 
                    label: "Catalunya", 
                    data: catalunyaValues, 
                    borderColor: "#d8e0e3", 
                    backgroundColor: "#d8e0e3",
                    fill: false 
                },
                { 
                    label: "Pyrenees", 
                    data: pyreneesValues,         
                    borderColor: "#807768",     
                    backgroundColor: "#807768", 
                    fill: false
                }
            ]
        },
        options: {
            responsive: true,
            plugins: { 
                legend: { position: 'top' },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            let value = context.raw;
                            return `${context.dataset.label}: ${formatNumber(value)}`;
                        }
                    }
                }
            },
            scales: {
                x: { title: { display: true, text: "Year" } },
                y: { 
                    title: { display: true, text: variableNames[variable] || variable },
                    ticks: {
                        callback: function(value) {
                            return formatNumber(value);
                        }
                    }
                }
            }
        }
    });
}

function getColorScale(values) {
    const min = Math.min(...values);
    const max = Math.max(...values);

    // If all values are the same → return flat color
    if (min === max) {
        return {
            min,
            max,
            scale: () => "#807768"
        };
    }

    // Convert hex #807768 to HSL
    const baseColor = { h: 36, s: 9, l: 46 };  
    // (#807768 converted → hsl(36, 9%, 46%))

    return {
        min,
        max,
        scale: (v) => {
            const t = (v - min) / (max - min);  // 0 → low, 1 → high

            // Lighten for low values, darken for high values
            const lightness = 70 - (t * 40);   
            // → low values → 70%
            // → high values → 30%

            return `hsl(${baseColor.h}, ${baseColor.s}%, ${lightness}%)`;
        }
    };
}

// LEGEND
// helper formatter -> "12345" → "12 345"
function formatNumber(num) {
    return new Intl.NumberFormat("fr-FR").format(num);
}

let legend = L.control({position: "bottomright"});

legend.onAdd = function () {
    this._div = L.DomUtil.create("div", "info legend");
    this.update();
    return this._div;
};

legend.update = function (min = 0, max = 1, scale = () => "#ccc") {
    const steps = 5;
    const range = [...Array(steps).keys()].map(
        i => min + i * (max - min) / (steps - 1)
    );

    this._div.innerHTML = `<strong>${variableNames[currentVariable] || currentVariable}</strong><br>`;

    range.forEach(v => {
        this._div.innerHTML += `
            <i style="background:${scale(v)}"></i>
            ${formatNumber(v.toFixed(0))}<br>
        `;
    });
};


function updateChoropleth(year, variable) {
    if (!mapData[year]) return;

    currentVariable = variable;
    const rows = Object.values(mapData[year]);
    const values = rows.map(r => r[variable]).filter(v => typeof v === "number");

    const { min, max, scale } = getColorScale(values);

    // Update legend
    legend.update(min, max, scale);

    // Only update counties
    countyLayer.eachLayer(layer => {
        const county = layer.feature.properties.county;
        const row = mapData[year][county];
        const value = row ? row[variable] : null;

        layer.setStyle({
            fillColor: scale(value),
            fillOpacity: 0.5,
            color: "#666",
            weight: 1
        });

        layer.bindPopup(`
        <strong>${county}</strong><br>
        ${variableNames[variable]}: ${value != null ? formatNumber(value) : "N/A"}
    `);
    });
}

// hook up year slider
const yearSlider = document.getElementById("year-slider");
const yearLabel = document.getElementById("year-label");

yearSlider.addEventListener("input", () => {
    const year = yearSlider.value;
    yearLabel.textContent = year;

    if(currentVariable) {
        updateChoropleth(year, currentVariable);
    }
});