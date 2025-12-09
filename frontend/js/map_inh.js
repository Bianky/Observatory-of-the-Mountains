// Global variables
let map;
let geoLayer;
let socioData;
let chart;

// these two are for the interactivness of the map
window.currentVariable = null;
let dataEnv = null;

// paths to data
const geometry = "./data/geometry.geojson";
const socioeconomy = "./data/socio-economy.json";
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
        
        //"e_GDHI_mileur",
        //"e_GDHI_mileur_pc",
        "e_GDHI_mileur_pi",
        
        //"e_rib",
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
    
    //"e_GDHI_mileur": "GDHI (million €)",
    //"e_GDHI_mileur_pc": "GDHI (per county)",
    "e_GDHI_mileur_pi": "GDHI (per inhabitant in €)",
    
    //"e_rib": "RIB (million €)",
    "e_rib_pc": "RIB (per county)",
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
    "eng_found": "Foundations (per county)",
    "eng_assoc": "Associations (per county)",

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
    readGeoJSON(geometry);
    readJSON(socioeconomy, "socio");
    readJSON(environment, "env");
});


// create the map
function createMap() {
    map = L.map('map').setView([41.6, 1.9], 7); // center on Catalunya

    L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
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
                    color: "#807768",     // border color
                    weight: 2,
                    fillColor: "#807768", // fill color
                    fillOpacity: 0.7
                };
            }

            // Default style for all other regions
            return {
                color: "#d8e0e3",
                weight: 1,
                fillColor: "#d8e0e3",
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
           // li.addEventListener("click", () => buildLineChart(v, data));
           // ul.appendChild(li);
            li.addEventListener("click", () => {
                window.currentVariable = v;
                buildLineChart(v, data);      // your existing chart
                updateChoropleth(v, +slider.value); // update map
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
                { label: "Catalunya", 
                  data: catalunyaValues, 
                  borderColor: "#d8e0e3", 
                  backgroundColor: "#d8e0e3",
                  fill: false },
                { label: "Pyrenees", 
                  data: pyreneesValues,         
                  borderColor: "#807768",     // ← your color
                  backgroundColor: "#807768", // optional (for points or filling) fill: false 
                }
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

function getDataByYear(variable, year) {
    const dataset = dataEnv; // or socioData if variable is socio
    return dataset.filter(d => d.year === year)
                  .reduce((acc, d) => {
                      acc[d.county] = d[variable];
                      return acc;
                  }, {});
}

function updateChoropleth(variable, year) {
    const yearData = getDataByYear(variable, year);

    geoLayer.eachLayer(layer => {
        const countyName = layer.feature.properties.county;
        const value = yearData[countyName];

        // Create color scale
        const color = value === undefined ? '#d8e0e3' : getColor(variable, value);

        layer.setStyle({
            fillColor: color,
            fillOpacity: 0.7,
            color: '#999',
            weight: 1
        });

        // Update popup
        layer.bindPopup(`${countyName}<br>${variableNames[variable]}: ${value ?? 'N/A'}`);
    });
}

function getColor(variable, value) {
    // Example: simple green → red gradient for forest variables
    if (["f_cleared_ha","f_reforested_ha","f_relative_reforested"].includes(variable)) {
        return value > 50 ? '#00441b' : `rgb(0,${Math.round(255*(value/50))},0)`; 
    }
    // Water consumption example
    if (["w_domestic_consump","w_total"].includes(variable)) {
        return value > 200 ? '#08306b' : `rgb(0,0,${Math.round(255*(value/200))})`;
    }
    // Fallback
    return '#d8e0e3';
}

const slider = document.getElementById("year-slider");
const yearLabel = document.getElementById("year-label");

slider.addEventListener("input", () => {
    const year = +slider.value;
    yearLabel.textContent = year;

    // Update map for currently selected variable
    if(window.currentVariable) {
        updateChoropleth(window.currentVariable, year);
    }
});

window.currentVariable = "f_cleared_ha"; // default variable
updateChoropleth(window.currentVariable, +slider.value);