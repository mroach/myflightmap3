defmodule Myflightmap.Repo do
  use Ecto.Repo,
    otp_app: :myflightmap,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, only: [from: 2]

  alias __MODULE__

  def paginate(query, opts \\ []) do
    page = Keyword.get(opts, :page, 0)
    page_size = Keyword.get(opts, :page_size, 100)
    offset = page * page_size

    paged_query = from(r in query,
      offset: ^offset,
      limit: ^(page_size + 1)
    )

    records = Repo.all(paged_query)

    {next_record, records} = if Enum.count(records) > page_size do
      List.pop_at(records, -1)
    else
      {nil, records}
    end

    total_record_count = Repo.aggregate(query, :count)

    {:ok, %{
      pagination: %{
        has_prev?: offset > 0,
        has_next?: !is_nil(next_record),
        total_record_count: total_record_count,
        page: page,
        page_size: page_size,
        page_count: ceil(total_record_count / page_size),
        first_record_index: 1 + offset,
        last_record_index: Enum.min([offset + page_size, total_record_count])
      },
      records: records
    }}
  end
end
