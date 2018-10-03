defmodule Myflightmap.Factory do
  @moduledoc """
  Loader for ExMachina factories. This module will 'use' each factory module
  defined in "test/factories/<schema>_factory.ex"
  """
  use ExMachina.Ecto, repo: Myflightmap.Repo

  use Myflightmap.AirlineFactory
  use Myflightmap.AirportFactory
end
