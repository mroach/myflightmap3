defmodule Myflightmap.Factory do
  @moduledoc """
  Loader for ExMachina factories. This module will 'use' each factory module
  defined in "test/factories/<schema>_factory.ex"
  """
  use ExMachina.Ecto, repo: Myflightmap.Repo

  # Transport
  use Myflightmap.AirlineFactory
  use Myflightmap.AirportFactory

  # Accounts
  use Myflightmap.UserFactory

  # Travel
  use Myflightmap.TripFactory
end
