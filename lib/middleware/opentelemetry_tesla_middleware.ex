defmodule Tesla.Middleware.OpenTelemetry do
  @moduledoc """
  Injects tracing header to external requests and configures some
  span's behaviours.

  ## Options

    * `:span_name` - appends the given string to the generated span's name of
      _HTTP + verb_.
    * `:non_error_statuses` - configures expected HTTP response status errors,
      usually >= 400, to not mark spans as errors. E.g., fetching location
      coordinates.

  ## Examples

      middlewares = [
        ...,
        {Tesla.Middleware.OpenTelemetry, span_name: "my-external-service"}
      ]


      middlewares = [
        ...,
        {Tesla.Middleware.OpenTelemetry, non_error_statuses: [404]}
      ]
  """
  @behaviour Tesla.Middleware

  def call(env, next, options \\ []) do
    env
    |> maybe_put_span_name(options[:span_name])
    |> maybe_put_non_error_statuses(options[:non_error_statuses])
    |> Tesla.put_headers(:otel_propagator_text_map.inject([]))
    |> Tesla.run(next)
  end

  defp maybe_put_span_name(env, nil), do: env

  defp maybe_put_span_name(env, span_name) when is_binary(span_name) do
    case env.opts[:span_name] do
      nil ->
        Tesla.put_opt(env, :span_name, span_name)

      _ ->
        env
    end
  end

  defp maybe_put_non_error_statuses(env, nil), do: env

  defp maybe_put_non_error_statuses(env, non_error_statuses) when is_list(non_error_statuses) do
    case env.opts[:non_error_statuses] do
      nil ->
        Tesla.put_opt(env, :non_error_statuses, non_error_statuses)

      _ ->
        env
    end
  end
end
