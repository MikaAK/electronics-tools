defmodule GearMath.Gear do
  alias GearMath.Gear

  @enforce_keys [:tooth_count, :module]
  defstruct [:addendum, :dedendum, :pitch_diameter | @enforce_keys]

  def new(tooth_count, module, inner_ring \\ false) do
    pitch_diameter = GearMath.pitch_diameter(module, tooth_count)

    addendum = if inner_ring do
      GearMath.inner_ring_addendum(pitch_diameter, module)
    else
      GearMath.addendum(pitch_diameter, module)
    end

    dedendum = if inner_ring do
      GearMath.inner_ring_dedendum(pitch_diameter, module)
    else
      GearMath.dedendum(pitch_diameter, module)
    end

    %Gear{
      tooth_count: tooth_count,
      module: module,
      pitch_diameter: pitch_diameter,
      addendum: addendum,
      dedendum: dedendum
    }
  end
end
