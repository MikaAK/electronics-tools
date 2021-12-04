defmodule GearMath.Gear do
  alias GearMath.Gear

  @enforce_keys [:tooth_count, :module]
  defstruct [:addendum, :dedendum, :pitch_diameter | @enforce_keys]

  def new(tooth_count, module) do
    pitch_diameter = GearMath.pitch_diameter(module, tooth_count)

    %Gear{
      tooth_count: tooth_count,
      module: module,
      pitch_diameter: pitch_diameter,
      addendum: GearMath.addendum(pitch_diameter, module),
      dedendum: GearMath.dedendum(pitch_diameter, module)
    }
  end
end
