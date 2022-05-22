defmodule Serial.Connection.Supervisor do
  use DynamicSupervisor

  alias Serial.Connection

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @spec init([
          {:extra_arguments, list}
          | {:max_children, :infinity | non_neg_integer}
          | {:max_restarts, non_neg_integer}
          | {:max_seconds, pos_integer}
          | {:strategy, :one_for_one}
        ]) ::
          {:ok,
           %{
             extra_arguments: list,
             intensity: non_neg_integer,
             max_children: :infinity | non_neg_integer,
             period: pos_integer,
             strategy: :one_for_one
           }}
  def init(arg) do
    DynamicSupervisor.init(arg)
  end

  @spec add_usb(String) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def add_usb(usb_name) do
    child_spec = {Connection, usb_name}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @spec remove_usb(pid) :: :ok | {:error, :not_found}
  def remove_usb(usb_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, usb_pid)
  end

  @spec children :: [{:undefined, :restarting | pid, :supervisor | :worker, :dynamic | [atom]}]
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  @spec count_children :: %{
          active: non_neg_integer,
          specs: non_neg_integer,
          supervisors: non_neg_integer,
          workers: non_neg_integer
        }
  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
