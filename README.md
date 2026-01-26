# Observatory of the Mountains

This repository serves as a project management system dedicated to the project *Observatory of the Mountains* developed by [Centre de Recerca Ecològica i Aplicacions Forestals (CREAF)](https://www.creaf.cat/en) and [Generalitat de Catalunya](https://web.gencat.cat/en/inici/index.html).

The suggested folder structure is as follows:

```

├── frontend
│   ├── css
│       └── style.css
│   └── js
│       └── map.js
│   └── index.html
│   └── about.html
│   └── data.html
│   └── map.html
│   └── data
|       ├── data_available.xlsx
│       └── geometry.geojson
│       └── socio-economy.json
│       └── socio-economy_counties.json
│       └── environment.json
│       └── environment_counties.json
│       └── metadata.txt
├── backend
│   ├── R
│       └── functions
│           └── process.R
│           └── process_map.R
│           └── process_theil.R
│       └── scripts
│           └── 00_query.R
│           └── 01_socio-economy.R
│           └── 01_socio-economy_counties.R
│           └── 01_environment.R
│           └── 01_environment_counties.R
│           └── 02_theil.R
│           └── 03_figures.R
│   └── Python
│       └── notebooks
│           └── social foundation
|                └── Theil_index_CAT_edu.ipynb
|                └── Theil_index_CAT_gdhi.ipynb
|                └── Theil_index_CAT_gdp.ipynb
|                └── Theil_index_CAT_house_new.ipynb
|                └── Theil_index_CAT_house_old.ipynb
|                └── Theil_index_CAT_income.ipynb
|                └── Theil_index_CAT_ret.ipynb
|                └── Theil_index_CAT_rib.ipynb
|                └── Theil_index_CAT_uet.ipynb
|                └── Theil_index_CAT_unempipynb
│           └── ecological ceiling
|                └── Theil_index_CAT_land_conversion.ipynb
|                └── Theil_index_CAT_waste_municipal.ipynb
|                └── Theil_index_CAT_waste_industrial.ipynb
|                └── Theil_index_CAT_water_domestic.ipynb
|                └── Theil_index_CAT_water_industrial.ipynb
├── docs
│   └── *additional documents useful to the repository*
├── Report.pdf
└── README.md

```
