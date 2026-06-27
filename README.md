# gradu-vanhempainvapaa
# Master's Thesis – Visualizations

**The Effects of the 2022 Parental Leave Reform on the Distribution of Parental Leave and Attitudes in Finland**

Turku School of Economics | Master's Thesis in Economics

---

## About This Repository

This repository contains the data visualizations produced for my Master's thesis. The thesis examines the effects of the 2022 Finnish parental leave reform on the distribution of parental leave between parents and on attitudes toward parental leave.

The visualizations are divided into two parts: an introductory visualization motivating the research topic, and a descriptive analysis supporting the empirical estimation strategy. The descriptive analysis is not intended to identify causal effects, but to provide background information on the direction of the reform's impacts.

More visualizations from the descriptive analysis will be added as the thesis progresses.

---

## Visualizations

### 1. Income Gap and First-Born Children by Age (`code/tuloerot_esikoiset.R`)

An introductory visualization motivating the research topic. The figure displays median disposable income for men and women alongside the number of firstborn children by mother's age group (Finland, 2014–2024).

The figure illustrates that the gender income gap begins to widen around the age of 28–30, which coincides with the peak in the number of firstborn children. The visualization does not establish or claim any causal relationship — it is intended solely to highlight the temporal co-occurrence of these patterns and to motivate the study of parental leave effects on labor market outcomes.

**Data sources:**
- Disposable income by age and gender: [Statistics Finland, Income Distribution Statistics](https://pxdata.stat.fi/PxWeb/pxweb/fi/StatFin/StatFin__tjt/11py.px)
- Live births by birth order and mother's age: [Statistics Finland, Births](https://pxdata.stat.fi/PxWeb/pxweb/fi/StatFin/StatFin__synt/12dm.px)

---

### 2. Average Paternity Leave Days by Region in Finland (`code/kartta_isien_vapaat.R`)

Part of the descriptive analysis. The map illustrates the regional distribution of fathers' average parental leave days across Finland's regions in 2025. The figure is intended to provide descriptive background on how paternity leave use varies geographically, supporting the empirical estimation strategy of the thesis.

**Data source:**
- Parental leave recipients and benefits paid: [Kela Open Data](https://www.avoindata.fi/data/dataset/fcecb9f8-2663-42c7-bbcd-856fd8fd603c)

---

## Methods

Data is fetched directly from open APIs and processed in R. The income and birth data are retrieved using the `pxweb` package from Statistics Finland's PxWeb API. The Kela parental leave data is downloaded programmatically as a CSV file. Municipality boundaries for the map visualization are retrieved using the `geofi` package. Visualizations are produced with `ggplot2`.

---

## Tools

R, ggplot2, pxweb, geofi, dplyr, tidyr

---

## Repository Structure

```
gradu-vanhempainvapaa/
├── code/
│   ├── tuloerot_esikoiset.R       # Income gap and firstborn children
│   └── kartta_isien_vapaat.R      # Paternity leave days by region
├── figures/
│   ├── tuloerot_esikoiset.png
│   └── kartta_isien_vapaat.png
└── README.md
```
