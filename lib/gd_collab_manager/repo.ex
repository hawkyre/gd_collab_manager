defmodule GdCollabManager.Repo do
  use Ecto.Repo,
    otp_app: :gd_collab_manager,
    adapter: Ecto.Adapters.Postgres
end
