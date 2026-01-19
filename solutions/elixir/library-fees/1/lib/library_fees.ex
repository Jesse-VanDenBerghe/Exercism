defmodule LibraryFees do
  @morning_loan_days 28
  @afternoon_loan_days 29
  @monday_discount_rate 0.5
  defp noon(), do: ~T[12:00:00]

  def datetime_from_string(string) do
    NaiveDateTime.from_iso8601!(string)
  end

  def before_noon?(datetime) do
    datetime |> NaiveDateTime.to_time() |> Time.before?(noon())
  end

  def return_date(checkout_datetime) do
    days_to_add =
      if before_noon?(checkout_datetime), do: @morning_loan_days, else: @afternoon_loan_days

    checkout_datetime
    |> NaiveDateTime.add(days_to_add, :day)
    |> NaiveDateTime.to_date()
  end

  def days_late(planned_return_date, actual_return_datetime) do
    actual_return_datetime
    |> NaiveDateTime.to_date()
    |> Date.diff(planned_return_date)
    |> max(0)
  end

  def monday?(datetime) do
    datetime
    |> NaiveDateTime.to_date()
    |> Date.day_of_week()
    |> Kernel.==(1)
  end

  def calculate_late_fee(checkout, return, rate) do
    checkout_date_time = datetime_from_string(checkout)
    return_date_time = datetime_from_string(return)
    planned_return_date = return_date(checkout_date_time)

    planned_return_date
    |> days_late(return_date_time)
    |> Kernel.*(rate)
    |> apply_monday_discount(return_date_time)
  end

  defp apply_monday_discount(fee, return_datetime) do
    if monday?(return_datetime) do
      trunc(fee * @monday_discount_rate)
    else
      fee
    end
  end
end
