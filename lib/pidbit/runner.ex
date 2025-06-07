defmodule Pidbit.Runner do
  alias Pidbit.Accounts.User
  alias __MODULE__.Counter

  def run_code(%User{} = user, code) do
    job_id = Counter.get()
    {:ok, conn} = K8s.Conn.from_file(abspath("kubeconfig.yaml"))

    File.mkdir_p!(abspath("code/#{user.id}"))
    File.write!(abspath("code/#{user.id}/#{job_id}.exs"), code)

    resource = %{
      "apiVersion" => "batch/v1",
      "kind" => "Job",
      "metadata" => %{
        "name" => "runner-job-#{job_id}",
        "namespace" => "default"
      },
      "spec" => %{
        "backoffLimit" => 0,
        "ttlSecondsAfterFinished" => 10,
        "template" => %{
          "metadata" => %{
            "labels" => %{"app" => "pidbit-runner"}
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => "elixir-runner",
                "image" => "elixir:1.18.4-otp-27-alpine",
                "command" => ["sh", "-c", "elixir /code/#{job_id}.exs"],
                "volumeMounts" => [
                  %{"mountPath" => "/code", "name" => "code", "subPath" => user.id}
                ]
              }
            ],
            "volumes" => [
              %{
                "name" => "code",
                "hostPath" => %{
                  "path" => abspath("code"),
                  "type" => "Directory"
                }
              }
            ],
            "restartPolicy" => "Never"
          }
        }
      }
    }

    operation = K8s.Client.create(resource)
    {:ok, job} = K8s.Client.run(conn, operation)
    job
  end

  defp abspath(file) do
    :code.priv_dir(:pidbit)
    |> Path.join("k8s/#{file}")
  end
end
