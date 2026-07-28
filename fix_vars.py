import os
import re

def fix_topographical_view():
    path = '/Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/topographical_view.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Rename double latitude/longitude to double dim_1/dim_0
    content = content.replace('double latitude;', 'double dim_1;')
    content = content.replace('double longitude;', 'double dim_0;')
    
    # Replace assignment
    content = content.replace('latitude = 35.6074;', 'dim_1 = 35.6074;')
    content = content.replace('longitude = 140.1063;', 'dim_0 = 140.1063;')
    content = content.replace('latitude = latVal;', 'dim_1 = latVal;')
    content = content.replace('longitude = lngVal;', 'dim_0 = lngVal;')
    
    # Replace clamp
    content = content.replace('latitude = latitude.clamp(-90.0, 90.0);', 'dim_1 = dim_1.clamp(-90.0, 90.0);')
    content = content.replace('longitude = longitude.clamp(-180.0, 180.0);', 'dim_0 = dim_0.clamp(-180.0, 180.0);')
    
    # Replace print
    content = content.replace('print("TopographicalView: final camera lat=$latitude, lng=$longitude");', 'print("TopographicalView: final camera lat=$dim_1, lng=$dim_0");')
    
    # Replace VirtualCamera instantiation
    content = content.replace('latitude: latitude,', 'latitude: dim_1,')
    content = content.replace('longitude: longitude,', 'longitude: dim_0,')

    with open(path, 'w') as f:
        f.write(content)


def fix_scene_3d_viewport():
    path = '/Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/scene_3d_viewport.dart'
    with open(path, 'r') as f:
        content = f.read()

    # projectWgs84ToScreen -> projectSphericalToScreen
    content = content.replace('projectWgs84ToScreen', 'projectSphericalToScreen')
    
    # earthRadius -> referenceRadius
    content = content.replace('earthRadius', 'referenceRadius')
    
    # Text labels: 'Latitude:' -> 'Dim_1:', 'Longitude:' -> 'Dim_0:'
    content = content.replace("'Latitude: ", "'Dim_1: ")
    content = content.replace("'Longitude: ", "'Dim_0: ")
    
    # Rename variables in CameraStatsPanel
    # Note: cam.latitude is API, so we keep cam.latitude. We just change the text label.

    with open(path, 'w') as f:
        f.write(content)

def fix_scene_3d_viewport_classes():
    path = '/Users/perkunas/jail/digital-pipeline-repo/app_flutter/lib/features/topology/scene_3d_viewport_classes.dart'
    with open(path, 'r') as f:
        content = f.read()

    content = content.replace('projectWgs84ToScreen', 'projectSphericalToScreen')
    content = content.replace('toAbsoluteWgs84', 'toAbsoluteSpherical')
    
    with open(path, 'w') as f:
        f.write(content)

fix_topographical_view()
fix_scene_3d_viewport()
fix_scene_3d_viewport_classes()
