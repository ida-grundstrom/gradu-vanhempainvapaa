# =============================================================================
# Average paternity leave days by region in Finland (2025)
# Data: Kela open data, Statistics Finland (municipality boundaries)
# Author: Ida Grundström
# =============================================================================

# Run this script from the project root directory (gradu-vanhempainvapaa/)
# so that the figures/ folder is created in the correct location

library(dplyr)
library(ggplot2)
library(geofi)

# -----------------------------------------------------------------------------
# 1. FETCH DATA: Kela parental leave data
# -----------------------------------------------------------------------------

kela_url  <- "https://www.avoindata.fi/data/dataset/fcecb9f8-2663-42c7-bbcd-856fd8fd603c/resource/9f437329-b63a-4ac0-8a01-1ab2aa172a93/download/data.csv"
kela_file <- tempfile(fileext = ".csv")

download.file(kela_url, destfile = kela_file, mode = "wb")
data_raw <- read.csv(kela_file, encoding = "UTF-8")

# -----------------------------------------------------------------------------
# 2. FETCH MAP DATA: Municipality boundaries with region codes
# -----------------------------------------------------------------------------

kunnat <- get_municipalities(year = 2025, scale = 4500, codes_as_character = FALSE)

# -----------------------------------------------------------------------------
# 3. PROCESS DATA
# -----------------------------------------------------------------------------

data_yhd <- data_raw |>
  mutate(kunta_nro = as.integer(kunta_nro)) |>
  left_join(kunnat, by = c("kunta_nro" = "kunta"))

data_ehdot <- data_yhd |>
  select(aikatyyppi, kuukausi_nro, vuosi.x, kunta_nro, kunta_nimi,
         ikaryhma, sukupuoli, etuus, saaja_lkm, korvattu_paiva_lkm,
         maakunta_code, maakunta_name_fi) |>
  filter(
    vuosi.x        == 2025,
    sukupuoli      == "Mies",
    etuus          == "Yhteensä",
    aikatyyppi     == "Vuosikertymä",
    kuukausi_nro   == 12,
    !is.na(maakunta_code),
    saaja_lkm      > 0
  )

keskiarvot <- data_ehdot |>
  mutate(
    korvattu_paiva_lkm = as.numeric(korvattu_paiva_lkm),
    saaja_lkm          = as.numeric(saaja_lkm)
  ) |>
  group_by(maakunta_code, maakunta_name_fi) |>
  summarise(
    isa_keskiarvo = sum(korvattu_paiva_lkm, na.rm = TRUE) /
                    sum(saaja_lkm,          na.rm = TRUE),
    .groups = "drop"
  )

# -----------------------------------------------------------------------------
# 4. PREPARE MAP DATA
# -----------------------------------------------------------------------------

kartta_luokka <- kunnat |>
  left_join(keskiarvot, by = "maakunta_code") |>
  select(id, kunta, vuosi, nimi, year, maakunta_code, maakunta_name_fi.x, isa_keskiarvo) |>
  mutate(
    isa_luokka = cut(
      isa_keskiarvo,
      breaks = c(40.4, 43.5, 44.5, 45.5, 49),
      labels = c("40,5–43,5", "43,5–44,5", "44,5–45,5", "45,5–48,8"),
      right          = FALSE,
      include.lowest = TRUE
    )
  )

# -----------------------------------------------------------------------------
# 5. VISUALIZE
# -----------------------------------------------------------------------------

palette_full <- c(
  pink       = "#D4A5B5",
  rose_light = "#E8C7D2",
  navy       = "#2F3E46",
  blue_grey  = "#5F737C",
  grey       = "#A0A0A0"
)

p2 <- ggplot(kartta_luokka) +
  geom_sf(
    aes(fill = isa_luokka),
    color     = "black",
    linewidth = 0.2
  ) +
  scale_fill_manual(
    values = c(
      "40,5–43,5" = unname(palette_full["rose_light"]),
      "43,5–44,5" = unname(palette_full["pink"]),
      "44,5–45,5" = unname(palette_full["blue_grey"]),
      "45,5–48,8" = unname(palette_full["navy"])
    ),
    na.value = unname(palette_full["grey"]),
    name     = "Paternity Leave Days (average)"
  ) +
  theme_minimal() +
  theme(
    axis.text          = element_blank(),
    axis.ticks         = element_blank(),
    panel.grid         = element_blank(),
    legend.key.height  = unit(0.6, "cm"),
    legend.key.width   = unit(0.6, "cm"),
    legend.spacing.y   = unit(2, "cm"),
    plot.title         = element_text(size = 11, face = "bold"),
    plot.subtitle      = element_text(size = 9),
    legend.title       = element_text(size = 9, face = "bold"),
    legend.text        = element_text(size = 9)
  ) +
  labs(
    title    = "Average Paternity Leave Days by Region in Finland",
    subtitle = "2025 | Data: Kela"
  ) +
  guides(fill = guide_legend(nrow = 4))

print(p2)

dir.create("figures", showWarnings = FALSE)
ggsave("figures/kartta_isien_vapaat.png", plot = p2,
       width = 6, height = 8, dpi = 300)

message("Kuva tallennettu figures/-kansioon.")
