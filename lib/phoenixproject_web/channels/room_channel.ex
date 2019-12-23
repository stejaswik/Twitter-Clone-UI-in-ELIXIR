defmodule PhoenixprojectWeb.RoomChannel do
	use Phoenix.Channel

		def join("rooms:lobby", _message, socket) do
		{:ok, socket}
		end

		def join(_room, _params, _socket) do
		{:error, %{reason: "you can only join lobby"}}
		end

		def handle_in("new_msg", b, socket) do
			broadcast! socket, "new_msg", b
		{:reply, {:ok, %{}}, socket}
  		end

		def handle_in("login_account", payload, socket) do
			IO.inspect("-----------------------------------------------------------ACCOUNT LOGIN-----------------------------------------------------------")
			IO.inspect(payload["u"], label: "user account request details  ---------->")
			IO.inspect("-----------------------------------------------------------------------------------------------------------------------------------")
			{:reply, {:ok, %{message: "OK"}}, socket}
		end

		def handle_in("subscribe", payload, socket) do
			#IO.inspect(payload["u1"], label: "User 1")
			user1 = payload["u1"]
			user2 = payload["u2"]
			IO.puts("--------------------------------------------------------------SUBSCRIPTION---------------------------------------------------------------")
			IO.puts"#{user2} is following ----------> #{user1}"
			IO.puts("------------------------------------------------------------------------------------------------------------------------------------------")
			{:reply, {:ok, %{message: "Success"}}, socket}
		end

		def handle_in("unsubscribe", payload, socket) do
			#IO.inspect(payload["u1"], label: "User 1")
			user1 = payload["u1"]
			user2 = payload["u2"]
			IO.puts("--------------------------------------------------------------UNSUBSCRIPTION-------------------------------------------------------------")
			IO.puts"#{user2} unsubscribed ----------> #{user1}"
			IO.puts("-----------------------------------------------------------------------------------------------------------------------------------------")
			{:reply, {:ok, %{message: "Success"}}, socket}
		end

		def handle_in("retweet", payload, socket) do
			user = payload["u"]
			retweet = payload["tweet"]
			IO.puts("--------------------------------------------------------------RETWEET--------------------------------------------------------------")
			IO.puts("#{user} has retweeted ----------> #{retweet}")
			IO.puts("-----------------------------------------------------------------------------------------------------------------------------------")
			{:reply, {:ok, %{message: payload["tweet"]}}, socket}
		end

		def handle_info({"phx_reply", payload: _payload}, socket) do
	  	{:noreply, socket}
		end
end
