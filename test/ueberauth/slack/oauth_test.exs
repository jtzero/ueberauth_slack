defmodule Ueberauth.Strategy.Slack.OAuthTest do
  use ExUnit.Case
  import UeberauthSlack.TestHelpers
  alias Ueberauth.Strategy.Slack

  setup do
    bypass = Bypass.open
    url = bypass_server(bypass)
    default_client_opts = [
               site: "#{url}/api",
      authorize_url: "#{url}/oauth/authorize",
          token_url: "#{url}/api/oauth.access"
    ]
    %{url: url, bypass: bypass, default_client_opts: default_client_opts, code: "asdf" }
  end

  def oauth_client(opts) do
    if is_list(opts), do: opts = Enum.into(opts, %{})
    %OAuth2.Client{} |> Map.merge(%{
        client_id: "",
        client_secret: "",
        headers: [],
        params: %{},
        redirect_uri: "",
        ref: nil,
        request_opts: [],
        strategy: Ueberauth.Strategy.Slack.OAuth,
        token: nil,
        token_method: :post,
      }) |> Map.merge(opts)
  end

  test "client", %{url: url, default_client_opts: default_client_opts} do
    client = Slack.OAuth.client(default_client_opts)
    assert client == oauth_client(default_client_opts)
  end

  test "get_token!", %{url: url, bypass: bypass, default_client_opts: default_client_opts, code: code} do

    client_options = %{options: [client_options: default_client_opts ]}

    Bypass.expect bypass, fn conn ->
        Plug.Conn.resp(conn, 200, ~s"""
           {\"ok\":true,\"access_token\":\"test-token\",\"scope\":\"identify,users:read\",\"user_id\":\"UID\",\"team_name\":\"team_name\",\"team_id\":\"TEAMID\",\"response_metadata\":{}}
        """)
    end
    token = Slack.OAuth.get_token!([code: code], client_options)

    assert token == %OAuth2.AccessToken{
            access_token: "test-token",
            expires_at: nil,
            other_params: %{
              "ok" => true,
              "response_metadata" => %{},
              "scope" => "identify,users:read",
              "team_id" => "TEAMID",
              "team_name" => "team_name",
              "user_id" => "UID"
            },
            refresh_token: nil,
            token_type: "Bearer"
          }
  end
end
