defmodule CommonValueFactory do
  @moduledoc """
  Factories for common values needed by other factories
  """

  require ExUnitProperties

  def iata_code do
    [?A..?Z, ?0..?9]
    |> Enum.concat()
    |> StreamData.string(min_length: 2, max_length: 2)
    |> Enum.at(0)
  end

  def icao_code do
    ?A..?Z
    |> StreamData.string(min_length: 3, max_length: 3)
    |> Enum.at(0)
  end

  def country_code do
    Countries.all() |> Enum.random() |> Map.get(:alpha2)
  end

  def timezone do
    Tzdata.canonical_zone_list() |> Enum.random()
  end

  def email_address do
    domains = ~w[example.com example.org example.net example.edu]

    generator =
      ExUnitProperties.gen all(
                             name <- StreamData.string(:alphanumeric),
                             name != "",
                             domain <- StreamData.member_of(domains)
                           ) do
        name <> "@" <> domain
      end

    generator
    |> StreamData.resize(20)
    |> Enum.at(0)
  end
end
