defmodule Serial.Connection.Supervisor do
  use DynamicSupervisor

  alias Serial.Connection

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec add_connection(any) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def add_connection(usb_name) do
    child_spec = {Connection, usb_name}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def remove_connection(usb_pid) do
    DynamicSupervisor.terminate_child(__MODULE__, usb_pid)
  end

  # Nice utility method to check which processes are under supervision
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  # Nice utility method to check which processes are under supervision
  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
