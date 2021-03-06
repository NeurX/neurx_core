defmodule Neurx.Build do
  @moduledoc """
  Documentation for Build.
  """

  alias Neurx.{Network}

  @loss_types ["MSE"]
  @default_loss %{type: "MSE"}

  @activation_types ["Sigmoid", "Relu"]
  @default_activation "Sigmoid"

  @optim_types ["SGD"]
  @default_optim %{type: "SGD", learning_rate: 0.1}
  @default_learning_rate 0.1

  @doc """
  Builds the network.

  How to use Build:
  ### Example containing possible inputs
      activation1 = fn(x) -> x * 2 end
      activation2 = fn(x) -> x * x end
      pre1 = fn(x) -> x * 4 end
      pre2 = fn(x) -> x - 5 end
      suf1 = fn(x) -> x + 1 end

      nn = Neurx.build(%{
        input_layer: 3,
        output_layer: %{
          size: 2,
          activation: %{
            type: "Sigmoid"
          }
        },
        hidden_layers: [
          %{
            size: 5
          },
          %{
            size: 3,
            activation: %{
              type: "Sigmoid"
            }
          },
          %{
            size: 4,
            activation: %{
              func: activation1
            }
          }
          ,
          %{
            size: 7,
            activation: %{
              func: activation2
            },
            prefix_functions: [
              pre1,
              pre2
            ],
            suffix_functions: [
              suf1
            ]
          }
        ],
        loss_function: %{
          type: "MSE"
        },
        optim_function: %{
          type: "SGD",
          learning_rate: 0.3
        }
      })
  """
  def build(config) do
    if config[:input_layer] <= 0 do
      raise "[Neurx.Build] :: Invalid size of input layer."
    end

    # Sanitize the output layer config.
    output_layer =
      if config[:output_layer] != nil do
        if config[:output_layer][:size] <= 0 do
          raise "[Neurx.Build] :: Invalid size of output layer."
        end
        %{size: config[:output_layer][:size],
         activation: sanitize_activation_functions(config[:output_layer][:activation])}
      end

    # Sanitize hidden layer configs.
    hidden_layers =
      if config[:hidden_layers] != nil do
        Enum.map(config[:hidden_layers], fn hl ->
          size = hl[:size]
          if size != nil do
            if size <= 0 do
              raise "[Neurx.Build] :: Invalid size of hidden layer."
            end
            activation = sanitize_activation_functions(hl[:activation])
            prefuncs = sanitize_function_list(hl[:prefix_functions])
            suffuncs = sanitize_function_list(hl[:suffix_functions])
            %{size: size, activation: activation, prefix_functions: prefuncs,
              suffix_functions: suffuncs}
            end
          end)
      end

    # Sanitize loss function config.
    loss =
      if config[:loss_function] != nil do
        if config[:loss_function][:type] == nil do
          raise "[Neurx.Build] :: Loss type cannot be null."
        end
        if config[:loss_function][:type] not in @loss_types do
          raise "[Neurx.Build] :: Unknown loss type."
        end
        %{type: config[:loss_function][:type]}
      else
        @default_loss
      end

      # Sanitize optim function config.
    optim =
      if config[:optim_function] != nil do
        if config[:optim_function][:type] == nil do
          raise "[Neurx.Build] :: Optimization type cannot be null."
        end
        if config[:optim_function][:type] not in @optim_types do
          raise "[Neurx.Build] :: Unknown optimization type."
        end
        otype = config[:optim_function][:type]
        if config[:optim_function][:learning_rate] == nil do
          %{type: otype, learning_rate: @default_learning_rate}
        else
          if config[:optim_function][:learning_rate] > 0 and config[:optim_function][:learning_rate]/2 do
            %{type: otype, learning_rate: config[:optim_function][:learning_rate]}
          else
            raise "[Neurx.Build] :: Invalid learning rate."
          end
        end
      else
        @default_optim
      end

    # Recreating the config.
    sanitized_config = %{
      input_layer: config[:input_layer],
      output_layer: output_layer,
      hidden_layers: hidden_layers,
      loss_function: loss,
      optimization_function: optim
    }

    Network.start_link(sanitized_config)
  end

  defp sanitize_activation_functions(activ) do
    cond do
      activ == nil -> @default_activation
      activ[:func] -> %{custom: activ[:func]}
      activ[:type] != nil and activ[:type] not in @activation_types ->
        raise "[Neurx.Build] :: Invalid activation function."
      activ[:type] -> activ[:type]
      true -> @default_activation
    end
  end

  defp sanitize_function_list(funcs) do
    cond do
      funcs == nil -> []
      true -> funcs |> Enum.map(fn(f) -> if f != nil, do: f end)
    end
  end
end
