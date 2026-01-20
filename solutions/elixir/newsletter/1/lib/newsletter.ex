defmodule Newsletter do
  def read_emails(path) do
    File.read!(path)
    |> String.split("\n", trim: true)
  end

  def open_log(path) do
    {:ok, pid} = File.open(path, [:write])
    pid
  end

  def log_sent_email(pid, email) do
    IO.write(pid, email <> "\n")
  end

  def close_log(pid) do
    File.close(pid)
  end

  def send_newsletter(emails_path, log_path, send_fun) do
    log_pid = open_log(log_path)

    emails_path
    |> read_emails()
    |> Enum.each(&send_and_log_on_success(&1, send_fun, log_pid))

    close_log(log_pid)
  end

  defp send_and_log_on_success(email, send_fun, log_pid) do
    result = send_fun.(email)

    if result == :ok do
      log_sent_email(log_pid, email)
    end
  end
end
