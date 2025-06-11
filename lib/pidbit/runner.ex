defmodule Pidbit.Runner do
  alias Pidbit.Problems.Submission

  def run_submission(%Submission{id: submission_id, code: code}) do
    job_name = "runner-job-#{submission_id}"
    {:ok, conn} = K8s.Conn.from_file(abspath("kubeconfig.yaml"))

    File.mkdir_p!(abspath("code/#{submission_id}"))
    File.write!(abspath("code/#{submission_id}/solution.ex"), code)

    resource = %{
      "apiVersion" => "batch/v1",
      "kind" => "Job",
      "metadata" => %{
        "name" => job_name,
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
                "command" => ["sh", "-c", "elixir /code/solution.ex 2>/dev/null"],
                "volumeMounts" => [
                  %{"mountPath" => "/code", "name" => "code", "subPath" => submission_id}
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

    case K8s.Client.run(conn, operation) do
      {:ok, _} -> get_logs(conn, job_name)
      error -> error
    end
  end

  def get_logs(conn, job_name) do
    case wait_until_terminated(conn, job_name) do
      {:ok, %{"metadata" => %{"name" => name}}} ->
        operation =
          K8s.Client.get("v1", "pods/log",
            namespace: "default",
            name: name,
            container: "elixir-runner"
          )

        K8s.Client.run(conn, operation)

      error ->
        error
    end
  end

  defp wait_until_terminated(conn, job_name) do
    # Get pod
    find = fn pods ->
      with %{"items" => [%{"metadata" => %{"name" => _}}]} <- pods do
        true
      end
    end

    operation =
      K8s.Client.list("v1", "pods", namespace: "default")
      |> K8s.Operation.put_selector(K8s.Selector.label({"job-name", job_name}))

    {:ok, %{"items" => [%{"metadata" => %{"name" => name}}]}} =
      K8s.Client.Runner.Wait.run(conn, operation, find: find, eval: true, timeout: 5)

    # Get status
    operation = K8s.Client.get("v1", "pods", namespace: "default", name: name)

    find = fn pod ->
      with %{"status" => %{"containerStatuses" => [%{"state" => state}]}} <- pod,
           %{"terminated" => _} <- state do
        true
      end
    end

    K8s.Client.Runner.Wait.run(conn, operation, find: find, eval: true, timeout: 30)
  end

  defp abspath(file) do
    :code.priv_dir(:pidbit)
    |> Path.join("k8s/#{file}")
  end
end
