defmodule GearMath.Planetary do
  alias GearMath.{Planetary, Utils}

  defstruct [:planet_teeth, :ring_teeth, :sun_teeth, :module, :num_planets]

  @min_gear_teeth 4
  @planet_range 2..20

  def possibilities(pitch_diameter) do
    mod_num_teeth_pairs = GearMath.module_teeth_possibilities(pitch_diameter)

    Enum.flat_map(mod_num_teeth_pairs, fn {module, num_teeth} ->
      possibilities_for_ring(module, num_teeth)
    end)
  end

  def possibilities_for_ring(module, num_teeth) do
    possibilities = for sun_teeth when sun_teeth >= @min_gear_teeth <- 1..num_teeth,
                        planet_teeth when planet_teeth >= @min_gear_teeth <- num_teeth..1,
                        num_planets <- @planet_range,
                        ring_teeth(sun_teeth, planet_teeth) === num_teeth do
      new(sun_teeth, planet_teeth, module, num_planets)
    end

    Enum.filter(possibilities, &validate_gearset?/1)
  end

  def new(sun_teeth, planet_teeth, module, num_planets) do
    %Planetary{
      planet_teeth: planet_teeth,
      sun_teeth: sun_teeth,
      ring_teeth: ring_teeth(sun_teeth, planet_teeth),
      module: module,
      num_planets: num_planets
    }
  end

  def ring_pitch_diameter(%Planetary{module: module, ring_teeth: ring_teeth}) do
    GearMath.pitch_diameter(module, ring_teeth)
  end

  def ring_teeth(sun_teeth, planet_teeth) do
    sun_teeth + 2 * planet_teeth
  end

  def ring_pitch_diameter(sun_pitch_diameter, planet_pitch_diameter) do
    planet_pitch_diameter * 2 + sun_pitch_diameter
  end

  def validate_gearset?(%Planetary{} = gear), do: validate_gearset(gear).fully_valid?

  def validate_gearset(%Planetary{
    planet_teeth: planet_teeth,
    sun_teeth: sun_teeth,
    ring_teeth: ring_teeth,
    module: module,
    num_planets: num_planets
  }) do
    real_number_valid? = Utils.real_number?(((ring_teeth + sun_teeth) / num_planets))

    ring_balanced? = Utils.real_number?(ring_teeth / num_planets)
    sun_balanced? = Utils.real_number?(sun_teeth / num_planets)

    sun_pitch_diameter = GearMath.pitch_diameter(module, sun_teeth)
    planet_pitch_diameter = GearMath.pitch_diameter(module, planet_teeth)
    space_constraint_a = module * (planet_teeth + 2)
    space_constraint_b = (sun_pitch_diameter + planet_pitch_diameter) * :math.sin(:math.pi() / num_planets)

    space_constraint_valid? = space_constraint_a < space_constraint_b

    %{
      fully_valid?: real_number_valid? and space_constraint_valid? and sun_balanced? and ring_balanced?,
      sun_balanced?: sun_balanced?,
      ring_balanced?: ring_balanced?,
      real_number_valid?: real_number_valid?,
      space_constraint_valid?: space_constraint_valid?
    }
  end
end
