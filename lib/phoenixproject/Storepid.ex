# Stores map containing nodes as keys and their PIDs as values in its state
defmodule Storepid do
  use GenServer

  def start_link(nodePid) do
    GenServer.start_link(__MODULE__, nodePid, name: __MODULE__)
  end

  def init(nodePid) do
    {:ok, nodePid}
  end

  def get_pid(node) do
    GenServer.call(__MODULE__, {:getpid, node})
  end

  def handle_call({:getpid, node}, _from, nodePid) do
    pid = Map.get(nodePid, node)
    {:reply, pid, nodePid}
  end

end
