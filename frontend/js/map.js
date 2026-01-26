
// Global variables
let map;
let socioData;
let dataEnv;
let chart;
let socioMapData;
let envMapData;

let currentMapType = "socio";  

let mapDataSocio = {}; // for socioeconomic choropleth
let mapDataEnv = {};   // for environment choropleth
let currentVariable = null;

let regionLayer;
let countyLayer;

// paths to data
const geometry = "./data/geometry_regions.geojson";
const geometry_counties = "./data/geometry_counties.geojson";

const socioeconomy = "./data/socio-economy.json";
const socioeconomy_counties = "./data/socio-economy_counties.json";

const environment = "./data/environment.json";
const environment_counties = "./data/environment_counties.json";

const categories_socioeconomy = {
    population: [
        "p_population",
        "p_density_hkm2",
        "p_men_pct",
        "p_women_pct",
        "p_0_24_pct",
        "p_25_64_pct",
        "p_65imes_pct",
        "p_growthrate"
    ],

    housing: [
        "h_value_new",
        "h_value_old"
    ],

    "income and work": [
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
        "e_rib_pi",

        "e_pit_taxablebase_percontributor",
        "e_ret_taxable_base",
        "e_uet_taxable_base",

        "w_unemp",
        "w_unemp_men",
        "w_unemp_women",
        "w_active",
        "w_active_men",
        "w_active_women",
        "w_inactive",
        "w_inactive_men",
        "w_inactive_women"

    ],

    education: [
        "edu_illiterate_pct", 
        "edu_primary_pct", 
        "edu_secondary_pct", 
        "edu_university_pct"

    ],

    engagement: [
        "eng_found",
      "eng_assoc"
   ]
};

const categories_environment = {
    "climate change": [
        "c_preci_mm",
        "c_wspeed_ms",
        "c_temp_ave",
        "c_temp_avemax",
        "c_temp_avemin"
    ],
    "freshwater withdrawals": [
        "w_domestic_consump",
        "w_industry_consump",
        "w_total_network",
        "w_own_sources",
        "w_total"
    ],
    "biodiversity loss": [
        "f_cleared_ha",
        "f_reforested_ha",
        "f_relative_reforested", 
        "f_fire"

    ],
    "land conversion": [
        "l_forests",
        "l_bushes",
        "l_others",
        "l_novege",
        "l_agri",
        "l_urban",
        "org_pct",
        "lc_sum"
    ],
    pollution: [
    "w_mun",
    "w_ind"
]

};

const variableNames = {
    // POPULATION
    "p_population": "Population",
    "p_density_hkm2": "Population density (h/km²)",
    "p_men_pct": "Men (%)",
    "p_women_pct": "Women (%)",
    "p_0_24_pct": "Age 0–24 (%)",
    "p_25_64_pct": "Age 25–64 (%)",
    "p_65imes_pct": "Age 65+ (%)",
    "p_growthrate": "Population growth rate (‰)",

    "h_value_new": "Average price of newly-built housing (€/m² built)",
    "h_value_old": "Average price of second-hand housing (€/m² built)",

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

    "e_pit_taxablebase_percontributor": "Personal income tax (€)",
    "e_ret_taxable_base": "Rural Estate tax (thousand €)",
    "e_uet_taxable_base": "Urban Estate tax (thousand €)",


    // WORK
    "w_unemp": "Unemployment (%)",
    "w_unemp_men": "Unemployment of men (%)",
    "w_unemp_women": "Unemployment of women (%)",
    "w_active": "Active population (%)",
    "w_active_men": "Active population of men (%)",
    "w_active_women": "Active population of women (%)",
    "w_inactive": "Inactive population (%)",
    "w_inactive_men": "Inactive population of men (%)",
    "w_inactive_women": "Inactive population of women (%)",

    //EDUCAION
    "edu_illiterate_pct": "Illiterate (%)", 
    "edu_primary_pct": "Primary education (%)",
    "edu_secondary_pct": "Secondary education (%)", 
    "edu_university_pct": "University education (%)",

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
    "f_relative_reforested": "Relative reforested area",
    "f_fire": "Forest fire (%)",


    // LAND
    "l_forests": "Forest area (%)",
    "l_bushes": "Bushes area (%)",
    "l_others": "Other land area (%)",
    "l_novege": "No vegetation (%)",
    "l_agri": "Crop land (%)",
    "l_urban": "Urban area (%)",
    "lc_sum": "Land conversion (%)",

    // FARM
    "org_pct": "Organic farms (%)",

    "w_mun": "Municipal waste (kg/per inhabitant)",
    "w_ind": "Industrial waste (kg/per inhabitant)"
};


// initialize map and load data
$(document).ready(function() {
    createMap();
    readGeoJSON(geometry, "regions");
    readGeoJSON(geometry_counties, "counties");
    readJSON(socioeconomy, "socio-chart");
    readJSON(socioeconomy_counties, "socio-map");
    readJSON(environment, "env-chart");
    readJSON(environment_counties, "env-map");
});


// create the map
function createMap() {
    if (map) {  
        console.warn("Map already initialized, skipping createMap()");
        return;
    }

    map = L.map('map').setView([41.6, 1.9], 8);

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
            if (type === "regions" && feature.properties.region === "Catalunya") {
                return { color: "#807768", weight: 2, fillColor: "#807768", fillOpacity: 1 };
            }
            return { color: "#d8e0e3", weight: 1, fillColor: "#d8e0e3", fillOpacity: 1 };
        }
    }).addTo(map);

    if(type === "regions") regionLayer = layer;
    else if(type === "counties") {
    // Split Catalunya out
    const catalunyaFeature = data.features.find(f => f.properties.county === "Catalunya");
    const otherCounties = data.features.filter(f => f.properties.county !== "Catalunya");

    // Layer for other counties
    countyLayer = L.geoJson({ ...data, features: otherCounties }, {
        style: { color: "#d8e0e3", weight: 1, fillColor: "#d8e0e3", fillOpacity: 1 }
    }).addTo(map);

    // Layer for Catalunya separately
    if(catalunyaFeature) {
        catalunyaLayer = L.geoJson(catalunyaFeature, {
            style: { color: "#807768", weight: 2, fillColor: "#807768", fillOpacity: 1 }
        }).addTo(map);
    }

    // Fix z-order: region at bottom, counties in middle, Catalunya on top
    if(regionLayer) regionLayer.bringToBack();
    countyLayer.bringToFront();
    if(catalunyaLayer) catalunyaLayer.bringToFront();
}
    if (regionLayer && countyLayer) {
        regionLayer.bringToBack();
        countyLayer.bringToFront();
    }
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
                    data.forEach(row => {
                        if (!mapDataSocio[row.year]) mapDataSocio[row.year] = {};
                        mapDataSocio[row.year][row.county] = row;
                    });
                    break;


                case "env-chart":
                    dataEnv = data;
                    break;

                case "env-map":
                    envMapData = data;
                    data.forEach(row => {
                        if (!mapDataEnv[row.year]) mapDataEnv[row.year] = {};
                        mapDataEnv[row.year][row.county] = row;
                    });
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
        <button id="tab-socio" class="tab-btn active">Social foundation</button>
        <button id="tab-env" class="tab-btn">Ecological ceiling</button>
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
                    currentVariable = v;
                    currentMapType = (type === "socio-chart") ? "socio" : "env";  // <- store type
                    buildLineChart(v, data);
                    updateChoropleth(document.getElementById("year-slider").value, v, currentMapType);

                    container.querySelectorAll("li").forEach(i => i.classList.remove("active"));
                    li.classList.add("active");
                });

                ul.appendChild(li);  // <- must be inside the forEach
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
                x: { title: { display: true, text: "Year", font: {size: 17, weight: 'bold', family: "monospace" } } },
                y: { 
                    title: { display: true, text: variableNames[variable], font: {size: 17, weight: 'bold', family: "monospace" }  || variable },

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
            ${formatNumber(v.toFixed(2))}<br>
        `;
    });
};


function updateChoropleth(year, variable, type = "socio") {
    const dataMap = type === "socio" ? mapDataSocio : mapDataEnv;
    if (!dataMap[year]) return;

    currentVariable = variable;
    const rows = Object.values(dataMap[year]);
    const values = rows.map(r => r[variable]).filter(v => typeof v === "number");

    const { min, max, scale } = getColorScale(values);

    legend.update(min, max, scale);

    // Update counties
    countyLayer.eachLayer(layer => {
        const county = layer.feature.properties.county;
        const row = dataMap[year][county];
        const value = row ? row[variable] : null;

        layer.setStyle({
            fillColor: scale(value),
            fillOpacity: 1,
            color: "#666",
            weight: 1
        });

        layer.bindPopup(`
        <strong>${county}</strong><br>
        ${variableNames[variable]}: ${value != null ? formatNumber(value) : "N/A"}
        `);
    });

    // Update Catalunya (now also using color scale)
    if(catalunyaLayer) {
        catalunyaLayer.eachLayer(layer => {
            const row = dataMap[year]["Catalunya"];
            const value = row ? row[variable] : null;

            layer.setStyle({
                fillColor: scale(value),
                fillOpacity: 1,
                color: "#666",
                weight: 2   // you can keep it thicker if you like
            });

            layer.bindPopup(`
                <strong>Non Pyrenees Catalunya</strong><br>
                ${variableNames[variable]}: ${value != null ? formatNumber(value) : "N/A"}
            `);
        });
    }
}

// hook up year slider
const yearSlider = document.getElementById("year-slider");
const yearLabel = document.getElementById("year-label");

yearSlider.addEventListener("input", () => {
    const year = yearSlider.value;
    yearLabel.textContent = year;

    if(currentVariable) {
        updateChoropleth(year, currentVariable, currentMapType);  // <- pass type
    }
});