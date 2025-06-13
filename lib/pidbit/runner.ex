defmodule Pidbit.Runner do
  alias Pidbit.Problems
  alias Pidbit.Problems.Submission

  @spec run_submission(Submission.t()) :: Submission.t()
  def run_submission(%Submission{id: submission_id, code: code, problem: problem} = submission) do
    job_name = "runner-job-#{submission_id}"
    {:ok, conn} = K8s.Conn.from_file(abspath("kubeconfig.yaml"))

    subdir = abspath("code/#{submission_id}")

    File.mkdir_p!(subdir)
    File.write!("#{subdir}/solution.ex", code)

    :code.priv_dir(:pidbit)
    |> Path.join("problems/#{problem.number}/test.ex")
    |> File.cp!("#{subdir}/test.ex")

    cmd = """
    cd /code
    output=$(elixirc solution.ex 2>&1 >/dev/null);
    status=$?;
    if [ $status -eq 0 ]; then
      elixir test.ex 2>/dev/null
    else
      echo "$output"
      exit $status
    fi
    """

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
                "command" => ["sh", "-c", cmd],
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
    {:ok, _} = K8s.Client.run(conn, operation)
    {:ok, exit_code, logs} = get_logs(conn, job_name)

    status = Submission.status_from_exit_code(exit_code)
    submission = Problems.put_submission_status!(submission, status)

    %{submission | output: logs}
  end

  defp get_logs(conn, job_name) do
    case get_terminated_pod(conn, job_name) do
      {:ok, exit_code, name} ->
        operation = K8s.Client.get("v1", "pods/log", namespace: "default", name: name)

        case K8s.Client.run(conn, operation) do
          {:ok, logs} -> {:ok, exit_code, logs}
          {:error, _} = error -> error
        end

      {:error, _} = error ->
        error
    end
  end

  defp get_terminated_pod(conn, job_name) do
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

    conn
    |> K8s.Client.Runner.Wait.run(operation, find: find, eval: true, timeout: 30)
    |> case do
      {:ok, %{"metadata" => %{"name" => name}} = pod} ->
        exit_code =
          pod
          |> get_in(~w(status containerStatuses))
          |> hd()
          |> get_in(~w(state terminated exitCode))

        {:ok, exit_code, name}

      {:error, _} = error ->
        error
    end
  end

  defp abspath(file) do
    :code.priv_dir(:pidbit)
    |> Path.join("k8s/#{file}")
  end
end
