defmodule GearMath do
  alias GearMath.Utils

  @module_num_teeth_pairs (for module <- Utils.generate_numbers_between(0.25, 5, 0.25),
                               num_teeth <- 1..1024 do
    {module, num_teeth}
  end)

  def module_teeth_possibilities(pitch_diameter) do
    Enum.filter(@module_num_teeth_pairs, fn ({module, num_teeth}) ->
      GearMath.pitch_diameter(module, num_teeth) <= pitch_diameter
    end)
  end

  def group_pitch_diameter_possibilities_by_module(mod_num_teeth_pairs) do
    Enum.group_by(
      mod_num_teeth_pairs,
      fn {module, _} -> module end,
      fn {_, num_teeth} -> num_teeth end
    )
  end

  def pitch_diameter(module, num_teeth), do: module * num_teeth

  def addendum(pitch_diameter, module), do: pitch_diameter + (1 * module)
  def dedendum(pitch_diameter, module), do: pitch_diameter - (1.25 * module)

  def distance_between_shafts(pitch_diameter_a, pitch_diameter_b) do
    (pitch_diameter_a / 2) + (pitch_diameter_b / 2)
  end

  def valid_gearset?(shaft_distance, module, teeth_a, teeth_b) do
    ((2 * shaft_distance) / module) == teeth_a + teeth_b
  end
end
