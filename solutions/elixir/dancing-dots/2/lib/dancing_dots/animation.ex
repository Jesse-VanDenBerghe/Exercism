defmodule DancingDots.Animation do
  @type dot :: DancingDots.Dot.t()
  @type opts :: keyword
  @type error :: any
  @type frame_number :: pos_integer

  @callback init(opts :: opts()) :: {:ok, opts()} | {:error, error()}
  @callback handle_frame(dot :: dot(), frame_number :: frame_number(), opts :: opts()) :: dot()

  defmacro __using__(_opts) do
    quote do
      @behaviour DancingDots.Animation
      def init(opts), do: {:ok, opts}
      defoverridable init: 1
    end
  end
end

defmodule DancingDots.Flicker do
  use DancingDots.Animation

  @impl DancingDots.Animation
  def handle_frame(%DancingDots.Dot{} = dot, frame_number, _opts)
      when rem(frame_number, 4) == 0 do
    %DancingDots.Dot{dot | opacity: dot.opacity * 0.5}
  end

  @impl DancingDots.Animation
  def handle_frame(dot, _, _), do: dot
end

defmodule DancingDots.Zoom do
  use DancingDots.Animation

  @impl DancingDots.Animation
  def init(opts) do
    velocity = Keyword.get(opts, :velocity)

    if velocity |> is_number() do
      {:ok, opts}
    else
      {:error,
       "The :velocity option is required, and its value must be a number. Got: #{inspect(velocity)}"}
    end
  end

  @impl DancingDots.Animation
  def handle_frame(%DancingDots.Dot{} = dot, frame, opts) when frame >= 1 do
    velocity = Keyword.get(opts, :velocity, 0)
    %DancingDots.Dot{dot | radius: dot.radius + (frame - 1) * velocity}
  end
end
