defmodule GearMath.Planetary.Compound do
  alias GearMath.Planetary

  defstruct [:input_planetary, :output_planetary, :ratio]

  def possibilities(pitch_diameter) when is_number(pitch_diameter) do
    planetary_possibilities = Planetary.possibilities(pitch_diameter)

    planetary_possibilities
      |> Task.async_stream(fn input_planetary ->
        planetary_possibilities
          |> Stream.map(&new(input_planetary, &1))
          |> Stream.filter(fn {res, _} -> res === :ok end)
          |> Stream.map(fn {:ok, planetary} -> planetary end)
          |> Enum.filter(&valid_gearset?/1)
      end, max_concurrency: 50)
      |> Enum.reduce([], fn ({:ok, valid_compounds}, acc) -> Enum.concat(acc, valid_compounds) end)
  end

  def possibilities(%Planetary{} = input_planetary) do
    possibilities(Planetary.ring_pitch_diameter(input_planetary))
  end

  def new!(%Planetary{} = input_planetary, %Planetary{} = output_planetary) do
    %Planetary.Compound{
      input_planetary: input_planetary,
      output_planetary: Map.put(output_planetary, :module, output_module(input_planetary, output_planetary)),
      ratio: ratio(input_planetary, output_planetary)
    }
  end

  def new(%Planetary{} = input_planetary, %Planetary{} = output_planetary) do
    {:ok, new!(input_planetary, output_planetary)}

    rescue
      ArithmeticError -> {:error, ErrorMessage.bad_request("invalid ratio", %{detailed_code: :invalid_ratio})}
  end

  def valid_gearset?(%Planetary.Compound{input_planetary: input_planetary, output_planetary: output_planetary}) do
    input_planetary.num_planets === output_planetary.num_planets
  end

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
