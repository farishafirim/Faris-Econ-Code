library(sf)
library(dplyr)
library(ggplot2)
library(janitor)

# Set a seed for reproducibility
set.seed(123)

# Create a fake informal transport stops dataset
transport_stops <- data.frame(
  stop_id = 1:10,
  stop_name = paste0("Stop_", LETTERS[1:10]),
  vehicle_type = sample(c("Boda", "Matatu", "Taxi"), 10, replace = TRUE),
  passenger_volume = sample(50:500, 10, replace = TRUE),
  lon = runif(10, min = 32.55, max = 32.65),  # Kampala area approx longitudes
  lat = runif(10, min = 0.25, max = 0.35)     # Kampala area approx latitudes
)

transport_stops_sf <- st_as_sf(transport_stops,coords=c("lon","lat"), crs = 4326)

# Make a fake district polygon
district_polygon <- st_as_sf(data.frame(
  district = "Central Kampala"
), geometry = st_sfc(
  st_polygon(list(rbind(
    c(32.54, 0.24),
    c(32.66, 0.24),
    c(32.66, 0.36),
    c(32.54, 0.36),
    c(32.54, 0.24)
  )))
), crs = 4326)

# Save them to variables you will use
transport_stops_sf
district_polygon


transport_stops_sf_clean <- transport_stops_sf %>%
  filter(passenger_volume >= 100)

# Run a simple linear regression
model <- lm(passenger_volume ~ vehicle_type, data = transport_stops_sf_clean)

# See the results
summary(model)


library(ggplot2)

ggplot() +
  geom_sf(data = district_polygon, fill = NA, color = "black") + # District boundary
  geom_sf(data = transport_stops_sf_clean, aes(color = vehicle_type), size = 3) + # Transport stops
  theme_minimal() +
  labs(title = "Transport Stops in Central Kampala", color = "Vehicle Type")

joined <- st_join(transport_stops_sf_clean, district_polygon, join = st_within)

# View the result
print(joined)

sum(!is.na(joined$district))


# 1. Reproject to UTM Zone 36N (fits Kampala area)
transport_stops_sf_clean_utm <- st_transform(transport_stops_sf_clean, crs = 32636) 

# 2. Create 200 meter buffers
buffers_200m <- st_buffer(transport_stops_sf_clean_utm, dist = 2000)



ggplot() +
  geom_sf(data = buffers_200m, fill = NA, color = "red") + # Buffers
  geom_sf(data = transport_stops_sf_clean_utm, aes(color = vehicle_type), size = 2) + # Stops
  theme_minimal() +
  labs(title = "200m Buffers Around Transport Stops", color = "Vehicle Type")

# Find intersections between buffers
overlaps <- st_intersects(buffers_200m)

# Check for overlaps (ignoring self-overlap)
# Each entry says which stops overlap
overlaps

# Count how many buffers each buffer intersects with (subtract 1 to ignore itself)
sapply(overlaps, length) - 1


# Stops with at least one overlap
which((sapply(overlaps, length) - 1) > 0)

# Save the cleaned transport stops
st_write(transport_stops_sf_clean, "transport_stops_clean.shp")

# Save the 200m buffers
st_write(buffers_200m, "transport_stops_buffer_200m.shp")
