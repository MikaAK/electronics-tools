defmodule GearMath.Planetary.Compound do
  alias GearMath.Planetary

  def output_module(%Planetary{
    sun_teeth: input_sun_teeth,
    planet_teeth: input_planet_teeth,
    module: input_module
  }, %Planetary{sun_teeth: output_sun_teeth, planet_teeth: output_planet_teeth}) do
    ((input_sun_teeth + input_planet_teeth) / (output_sun_teeth + output_planet_teeth)) * input_module
  end

  def ratio(%Planetary{
    ring_teeth: ring_teeth_1,
    sun_teeth: sun_teeth_1,
    planet_teeth: planet_teeth_1
  }, %Planetary{ring_teeth: ring_teeth_2, planet_teeth: planet_teeth_2}) do
    {output_rotations, input_rotations} = ((1 + (ring_teeth_1 / sun_teeth_1)) / (1 - (ring_teeth_1 * planet_teeth_2) / (ring_teeth_2 * planet_teeth_1)))
      |> Float.round(5)
      |> Float.ratio

    {output_rotations / input_rotations, 1}
  end
end
