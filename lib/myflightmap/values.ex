defmodule Myflightmap.Values do
  @moduledoc """
  General/common/basic values used around the app
  """

  def timezones, do: Tzdata.zone_list()

  def country_codes, do: Countries.all() |> Enum.map(& &1.alpha2)
end
