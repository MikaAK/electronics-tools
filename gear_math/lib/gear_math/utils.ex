defmodule GearMath.Utils do
  @rad_in_deg 180 / :math.pi()

  def sin_deg(degree), do: :math.sin(degree / @rad_in_deg)

  def real_number?(value) do
    value
      |> to_string
      |> Decimal.new
      |> Decimal.rem(1)
      |> Decimal.eq?(0)
  end

  def generate_numbers_between(first, last, step) do
    if real_number?(step) do
      Enum.to_list(first..last//step)
    else
      generate_numbers_between(first, last, step, [first / 1])
    end
  end

  defp generate_numbers_between(current, last, step, acc) when current + step > last do
    Enum.reverse(acc)
  end

  defp generate_numbers_between(current, last, step, acc) do
    current = current + step
    generate_numbers_between(current, last, step, [current | acc])
  end
end
