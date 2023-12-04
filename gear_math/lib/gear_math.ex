defmodule GearMath do
  alias GearMath.Utils

  @module_num_teeth_pairs (for module <- Utils.generate_numbers_between(0.5, 10, 0.1),
                               num_teeth <- 1..2048 do
    {module, num_teeth}
  end)

  def module_teeth_possibilities(pitch_diameter, pressure_angle \\ 20) do
    Enum.filter(@module_num_teeth_pairs, fn ({module, num_teeth}) ->
      GearMath.pitch_diameter(module, num_teeth) <= pitch_diameter
      # Enabled for accurate with minimum tooth count
      # and num_teeth >= minimum_tooth_count(module, pressure_angle)
    end)
  end

  def group_pitch_diameter_possibilities_by_module(mod_num_teeth_pairs, pressure_angle \\ 20) do
    Enum.group_by(
      mod_num_teeth_pairs,
      fn {module, _} -> {module, minimum_tooth_count(module, pressure_angle)} end,
      fn {_, num_teeth} -> num_teeth end
    )
  end

  def pitch_diameter(module, num_teeth), do: module * num_teeth

  def minimum_tooth_count(module, pressure_angle) do
    addendum = 1 * module

    ceil((2 * addendum) / :math.pow(GearMath.Utils.sin_deg(pressure_angle), 2))
  end

  def addendum(pitch_diameter, module), do: pitch_diameter + (1 * module)
  def dedendum(pitch_diameter, module), do: pitch_diameter - (1.25 * module)
  def inner_ring_dedendum(pitch_diameter, module), do: pitch_diameter - (1 * module * 2)
  def inner_ring_addendum(pitch_diameter, module), do: pitch_diameter + (1.25 * module * 2)

  def distance_between_shafts(pitch_diameter_a, pitch_diameter_b) do
    (pitch_diameter_a / 2) + (pitch_diameter_b / 2)
  end

  def valid_gearset?(shaft_distance, module, teeth_a, teeth_b) do
    ((2 * shaft_distance) / module) == teeth_a + teeth_b
  end

  def gear_ratio(input_gear_teeth, output_gear_teeth) do
    output_gear_teeth / input_gear_teeth
  end
end
