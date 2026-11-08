"""Generate a conservative PTV09A-6030U enclosure envelope; requires cadquery.
Run: python build_pot_envelope.py
See PTV09A-6030U_envelope.md for datums and simplifications.
"""
from pathlib import Path
import cadquery as cq

out = Path(__file__).resolve().parent
# KiCad model coordinates: footprint pin 1 is origin; KiCad board Y is inverted.
# Shaft centre matches the existing PTV09A-1 footprint: board (7, -2.5).
axis_x, axis_y = 7.0, 2.5
housing = cq.Workplane('XY').box(12, 10, 8.4, centered=(False, False, False)).translate((0.5, -2.5, 0))
bushing = cq.Workplane('XY').center(axis_x, axis_y).circle(4.5).extrude(5).translate((0, 0, 8.4))
shaft = cq.Workplane('XY').center(axis_x, axis_y).circle(3).extrude(16.6).translate((0, 0, 13.4))
model = cq.Assembly(name='PTV09A_6030U_envelope')
for name, shape, color in [
    ('Housing_conservative_envelope', housing, (0.18, 0.18, 0.18)),
    ('M9_bushing_envelope', bushing, (0.7, 0.7, 0.7)),
    ('6mm_shaft_envelope', shaft, (0.12, 0.12, 0.12)),
]:
    assert shape.val().isValid(), name
    model.add(shape, name=name, color=cq.Color(*color))
model.export(str(out / 'PTV09A-6030U_envelope.step'))
shape = cq.importers.importStep(str(out / 'PTV09A-6030U_envelope.step'))
bb = shape.val().BoundingBox()
assert abs(bb.xlen - 12) < 1e-5
assert abs(bb.ylen - 10) < 1e-5
assert abs(bb.zmin) < 1e-5 and abs(bb.zmax - 30) < 1e-5
assert len(shape.solids().vals()) == 3
print('STEP verified: 3 solids; envelope 12 x 10 x 30 mm; shaft axis (7, 2.5).')
