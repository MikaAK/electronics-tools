defmodule GearMath.Planetary do
  alias GearMath.{Planetary, Utils, Gear}

  defstruct [
    :planet,
    :ring,
    :sun,
    :module,
    :num_planets,
    :planet_to_sun_shaft_distance,
    :sun_input_ring_output_ratio,
    :sun_input_planet_output_ratio,
    :planet_input_ring_output_ratio,
    :planet_input_sun_output_ratio
  ]

  @min_gear_teeth 4
  @planet_range 2..20

  def new(sun_teeth, planet_teeth, module, num_planets) do
    ring_teeth = ring_teeth(sun_teeth, planet_teeth)
    %Planetary{
      module: module,
      num_planets: num_planets,
      planet: Gear.new(planet_teeth, module),
      sun: Gear.new(sun_teeth, module),
      sun_input_ring_output_ratio: GearMath.gear_ratio(sun_teeth, ring_teeth),
      sun_input_planet_output_ratio: GearMath.gear_ratio(sun_teeth, planet_teeth),
      planet_input_ring_output_ratio: GearMath.gear_ratio(planet_teeth, ring_teeth),
      planet_input_sun_output_ratio: GearMath.gear_ratio(planet_teeth, sun_teeth),
      ring: Gear.new(ring_teeth, module, true),
      planet_to_sun_shaft_distance: GearMath.distance_between_shafts(
        GearMath.pitch_diameter(module, planet_teeth),
        GearMath.pitch_diameter(module, sun_teeth)
      )
    }
  end

  def possibilities(pitch_diameter, {module_min, module_max} \\ {0, 0}) do
    mod_num_teeth_pairs = GearMath.module_teeth_possibilities(pitch_diameter)

    Enum.flat_map(mod_num_teeth_pairs, fn {module, num_teeth} ->
      if module >= module_min and module <= module_max do
        possibilities_for_ring(module, num_teeth)
      else
        []
      end
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

  def ring_pitch_diameter(%Planetary{module: module, ring: %Gear{tooth_count: ring_teeth}}) do
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
    planet: %Gear{tooth_count: planet_teeth},
    sun: %Gear{tooth_count: sun_teeth},
    ring: %Gear{tooth_count: ring_teeth},
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
