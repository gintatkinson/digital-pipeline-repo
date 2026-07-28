import os

path = '/Users/perkunas/jail/digital-pipeline-repo/app_flutter/test/domain/cesium_3d/viewport_math_test.dart'
with open(path, 'r') as f:
    content = f.read()

content = content.replace('toAbsoluteWgs84', 'toAbsoluteSpherical')
content = content.replace('projectWgs84ToScreen', 'projectSphericalToScreen')

with open(path, 'w') as f:
    f.write(content)
