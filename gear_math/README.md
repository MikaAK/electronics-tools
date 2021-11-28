# GearMath

Utilized for doing basic gear math as well as generating possibilities
for gears fitting within a specific pitch diameter

### Usage
```
GearMath.module_teeth_possibilities(pitch_diameter)
[{1, 24}] # {module, num_teeth}

GearMath.Planetary.possibilities(pitch_diameter)
[%GearMath.Planetary{}]

GearMath.Planetary.possibilities_for_ring(module, num_teeth)
[%GearMath.Planetary{}]

GearMath.Planetary.Compound.possibilities(pitch_diameter)
GearMath.Planetary.Compound.possibilities(%GearMath.Planetary{})
```

