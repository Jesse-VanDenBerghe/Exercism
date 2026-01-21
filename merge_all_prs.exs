#!/usr/bin/env elixir

defmodule PRMerger do
  @moduledoc """
  Script to list and merge all open PRs in the current repository
  using GitHub CLI with rebase and delete branch options.
  """

  def run do
    IO.puts("Fetching all open PRs...")

    # Get PR numbers only using plain format
    case System.cmd("gh", ["pr", "list", "--limit", "1000"]) do
      {output, 0} ->
        prs = parse_pr_list(output)

        if length(prs) > 0 do
          IO.puts("\nFound #{length(prs)} open PR(s):\n")

          Enum.each(prs, fn {number, title} ->
            IO.puts("  ##{number}: #{title}")
          end)

          IO.puts("\n" <> String.duplicate("=", 60))
          IO.puts("Starting to merge PRs...")
          IO.puts(String.duplicate("=", 60) <> "\n")

          merge_prs(prs)
        else
          IO.puts("No open PRs found.")
        end

      {error, code} ->
        IO.puts("Error fetching PRs (exit code #{code}): #{error}")
        System.halt(1)
    end
  end

  defp parse_pr_list(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      # Format: "NUMBER\tTITLE\tBRANCH"
      case String.split(line, "\t", parts: 3) do
        [number, title | _] -> {String.trim(number), String.trim(title)}
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp merge_prs([]), do: IO.puts("\n✓ All PRs processed!")

  defp merge_prs([{pr_number, pr_title} | rest]) do
    IO.puts("Merging PR ##{pr_number}: #{pr_title}")

    case System.cmd("gh", ["pr", "merge", pr_number, "-r", "-d"], stderr_to_stdout: true) do
      {output, 0} ->
        IO.puts("  ✓ Successfully merged PR ##{pr_number}")
        IO.puts("  " <> String.trim(output))

      {error, code} ->
        IO.puts("  ✗ Failed to merge PR ##{pr_number} (exit code #{code})")
        IO.puts("  Error: #{String.trim(error)}")
    end

    IO.puts("")
    merge_prs(rest)
  end
end

PRMerger.run()
