import json
import os

files = [
    "app_flutter/assets/ntt_exchanges_japan_763.json",
    "app_flutter/assets/cable_landing_stations_japan.json"
]

for file_path in files:
    if not os.path.exists(file_path):
        continue
    
    with open(file_path, "r") as f:
        data = json.load(f)
    
    modified = False
    for item in data:
        if "latitude" in item and "longitude" in item:
            lat = item.pop("latitude")
            lon = item.pop("longitude")
            item["position"] = {"dim_0": lat, "dim_1": lon}
            modified = True
    
    if modified:
        with open(file_path, "w") as f:
            json.dump(data, f, indent=2)
