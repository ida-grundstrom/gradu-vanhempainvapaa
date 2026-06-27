# =============================================================================
# Gender Income Gap and First Births by Age
# Data: Statistics Finland API (pxweb)
# Author: Ida Grundström
# =============================================================================

# Run this script from the project root directory (gradu-vanhempainvapaa/)
# so that the figures/ folder is created in the correct location

library(pxweb)
library(dplyr)
library(tidyr)
library(ggplot2)

# -----------------------------------------------------------------------------
# 1. FETCH DATA: Disposable income by age and gender (Tulonjakotilasto)
# -----------------------------------------------------------------------------

ika_koodit <- sprintf("%03d", 18:54)

income_query <- list(
  "ikaryhma_22_20191201" = ika_koodit,
  "contentscode"         = "hkturaha_med",
  "timeperiod_y"         = as.character(2014:2024),
  "sukupuoli_9_20180101" = c("1", "2")
)

income_raw <- pxweb_get(
  url   = "https://pxdata.stat.fi/PxWeb/api/v1/fi/StatFin/tjt/11py.px",
  query = income_query
)

income_df <- as.data.frame(income_raw, column.name.type = "text", variable.value.type = "text")

income_clean <- income_df |>
  rename(
    ika       = `Henkilön ikä`,
    vuosi     = Vuosi,
    sukupuoli = Sukupuoli,
    arvo      = `Henkilökohtainen käytettävissä oleva rahatulo, mediaani (kotitalouskohtaisia tuloeriä ei jaettu henkilöille)`
  ) |>
  mutate(
    ika   = as.integer(ika),
    vuosi = as.integer(vuosi),
    arvo  = as.numeric(arvo)
  )

income_wide <- income_clean |>
  select(ika, vuosi, sukupuoli, arvo) |>
  pivot_wider(names_from = sukupuoli, values_from = arvo) |>
  rename(tulo_miehet = Miehet, tulo_naiset = Naiset)

# -----------------------------------------------------------------------------
# 2. FETCH DATA: Live births by birth order and mother's age (Syntyneet)
# -----------------------------------------------------------------------------

births_query <- list(
  "timeperiod_y"              = as.character(2014:2024),
  "ikaryhma_10_20180101"      = ika_koodit,
  "sukupuoli_9_20180101"      = "SSS",
  "lapsen_jarjnro_1_20190101" = "1",
  "contentscode"              = "synt-vm01"
)

births_raw <- pxweb_get(
  url   = "https://pxdata.stat.fi/PxWeb/api/v1/fi/StatFin/synt/12dm.px",
  query = births_query
)

births_df <- as.data.frame(births_raw, column.name.type = "text", variable.value.type = "text")

births_clean <- births_df |>
  rename(
    vuosi = Vuosi,
    ika   = `Äidin ikä`,
    maara = `Elävänä syntyneet`
  ) |>
  mutate(
    ika   = as.integer(ika),
    vuosi = as.integer(vuosi),
    maara = as.numeric(maara)
  ) |>
  group_by(vuosi, ika) |>
  summarise(esikoiset = sum(maara, na.rm = TRUE), .groups = "drop")

# -----------------------------------------------------------------------------
# 3. MERGE AND AGGREGATION
# -----------------------------------------------------------------------------

data_combined <- income_wide |>
  left_join(births_clean, by = c("vuosi", "ika"))

data_plot <- data_combined |>
  group_by(vuosi, ika) |>
  summarise(
    tulo_miehet = mean(tulo_miehet, na.rm = TRUE),
    tulo_naiset = mean(tulo_naiset, na.rm = TRUE),
    esikoiset   = sum(esikoiset,    na.rm = TRUE),
    .groups = "drop"
  ) |>
  group_by(ika) |>
  summarise(
    tulo_miehet = mean(tulo_miehet),
    tulo_naiset = mean(tulo_naiset),
    esikoiset   = mean(esikoiset)
  )

# -----------------------------------------------------------------------------
# 4. VISUALIZE
# -----------------------------------------------------------------------------

palette_full <- c(
  pink       = "#D4A5B5",
  rose_light = "#E8C7D2",
  navy       = "#2F3E46",
  blue_grey  = "#5F737C",
  grey       = "#A0A0A0"
)

p <- ggplot(data_plot) +
  geom_bar(
    aes(x = ika, y = 12 * esikoiset, fill = "First-born children"),
    stat = "identity", colour = palette_full["pink"]
  ) +
  geom_line(
    aes(x = ika, y = tulo_miehet, colour = "Men"),
    linewidth = 0.8
  ) +
  geom_line(
    aes(x = ika, y = tulo_naiset, colour = "Women"),
    linewidth = 0.8
  ) +
  scale_fill_manual(
    name   = "",
    values = c("First-born children" = unname(palette_full["rose_light"]))
  ) +
  scale_color_manual(
    name   = "",
    values = c("Men" = unname(palette_full["navy"]), "Women" = unname(palette_full["pink"]))
  ) +
  scale_x_continuous(
    limits = c(18, 54),
    breaks = seq(18, 54, 2)
  ) +
  scale_y_continuous(
    sec.axis = sec_axis(
      transform = ~ . / 12,
      name   = "First-born children",
      breaks = seq(0, 4000, 500)
    ),
    limits = c(0, 45000),
    breaks = seq(0, 45000, 5000)
  ) +
  labs(
    title    = "Gender Income Gap and First Births by Age",
    subtitle = "Finland 2014-2024 | Data: Statistics Finland",
    x        = "Age",
    y        = "Median net income (EUR)"
  ) +
  theme_minimal() +
  theme(
    legend.position  = "top",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(size = 12, face = "bold"),  
    plot.subtitle    = element_text(size = 10),  
    axis.title       = element_text(size = 10),  
    axis.text        = element_text(size = 9)
  )

print(p)

dir.create("figures", showWarnings = FALSE)
ggsave("figures/tuloerot_esikoiset.png", plot = p,
       width = 10, height = 6, dpi = 300)

message("Kuva tallennettu figures/-kansioon.")
