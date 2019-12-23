# Stores generated tweets in Genserver state
defmodule Dispstore do
  use GenServer

  def start_link(stack) do
    GenServer.start_link(__MODULE__, stack, name: __MODULE__)
  end

  def init(stack) do
    {:ok, stack}
  end

  def save_node(val) do
    GenServer.cast(__MODULE__, {:savenode, [val]})
  end

  def print() do
    GenServer.call(__MODULE__, :printval) 
  end


  def handle_cast({:savenode, list}, stack) do
    stack = List.flatten([list] ++ [stack])
    {:noreply, stack}
  end

  def handle_call(:printval, _from, stack) do
    {:reply, stack, stack}
  end
end