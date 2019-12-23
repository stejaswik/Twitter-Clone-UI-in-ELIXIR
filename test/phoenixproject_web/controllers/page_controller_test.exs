defmodule PhoenixprojectWeb.PageControllerTest do
  use PhoenixprojectWeb.ConnCase

  test "Test1" do
	IO.puts "--------------------------------------------------------------------"
	IO.puts "| Test 1 : Testing all the functionalities together               |"
	IO.puts "|===================================================               |"
	IO.puts "| This test will test all the twitter functionalities implemented  |"
	IO.puts "--------------------------------------------------------------------"

	numUsers = 100
	numTweets = 0

	# server name
	_serverName = Boss_Server

	# Generate unique usernames
	
	usernames = Enum.map(1..100, fn(_x) -> Name.generate() end)

	# server name
	serverName = Boss_Server

	# hashtags
	hashtags = ["#runforfun", "#diedforgood", "#sleeplikeababy", "#killedbyafan", "#dodgedabullet", "#slicedbyaknife"]

	input = [usernames] ++ [hashtags] ++ [serverName] ++ [numTweets]

	Server.start_link([[usernames] ++ [hashtags]])


	Dispstore.start_link([usernames])

	# Starting twitter supervisor
	# input has usernames and servername
	{:ok, pid} = Twitter_Supervisor.start_link(input)
	c = Supervisor.which_children(pid)
	c = Enum.sort(c)

	len = length(c)-1
	map = %{}
	map = Enum.map(0..len, fn i ->
	head = Enum.at(c,i)
	h_list = Tuple.to_list(head)
	key = Enum.at(h_list,0)
	val = Enum.at(h_list,1)
	Map.put(map,key,val)
	end)

	map = Enum.reduce(map,fn(x,acc) -> Map.merge(x,acc,fn _k,v1,v2 -> [v1,v2] end) end)

	# Register Users
	Storepid.start_link(map)

	{:ok, pid1} = PhoenixChannelClient.start_link()
	{:ok, socket} = PhoenixChannelClient.connect(pid1,
	host: "localhost",
	port: 4000,
	path: "/socket/websocket",
	params: %{token: ""},
	secure: false,
	heartbeat_interval: 30_000)

	channel = PhoenixChannelClient.channel(socket, "rooms:lobby", %{name: "Ryo"})
	{:ok, _} = PhoenixChannelClient.join(channel)


	IO.puts "Creating #{numUsers} users"

	Process.sleep(1000)

	# Subscribing to users
	c1 = Enum.at(usernames, 0)
	IO.puts "User1 is @#{c1}"

	_c2 = Enum.at(usernames, 1)
	p = Storepid.get_pid(c1)

	c3 = Enum.at(usernames, 2)
	p3 = Storepid.get_pid(c3)

	c4 = Enum.at(usernames, 3)
	p4 = Storepid.get_pid(c4)

	list = usernames

	Client.subscribe(Storepid.get_pid(Enum.at(list, 2)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 3)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 4)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 5)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 6)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 7)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 8)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 9)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 10)), Enum.at(list, 0))
	Client.subscribe(Storepid.get_pid(Enum.at(list, 11)), Enum.at(list, 0))


	Process.sleep 1000

	# Generate tweets
	for x<-1..10 do
		Client.tweeting(p)
		Process.sleep(50)
		if x >= 2 && x <= 7 do
			Client.tweeting(p3)
			Client.tweeting(p4)
		end
	end

	Process.sleep 1000

	test = Dispstore.print()
	{:ok, _} = PhoenixChannelClient.push_and_receive(channel, "new_msg", %{body: test}, 5000)

	IO.puts "-----------------------LOGIN CREDENTIALS------------------------------"
	IO.puts "               Test 1 completed succesfully"
	IO.puts "               Please use username: #{c1}" 
	IO.puts "                          password: password"
	IO.puts "----------------------------------------------------------------------"
end

def get_hashtags(tweet, hashtags) do
	hashtags_tweet = []
	hashtags_tweet = for x<-0..length(hashtags)-1 do
	_hashtags_tweet = if tweet =~ Enum.at(hashtags, x) do
			_hashtags_tweet = hashtags_tweet ++ Enum.at(hashtags, x)
		end
	end
	hashtags_tweet = Enum.filter(hashtags_tweet, fn v -> v != nil end)
	hashtags_tweet
end

def get_mentions(tweet, users) do
	mentions_tweet = []
	mentions_tweet = for x<-0..length(users)-1 do
	_mentions_tweet = if tweet =~ Enum.at(users, x) do
			_mentions_tweet = mentions_tweet ++ Enum.at(users, x)
		end
	end
	mentions_tweet = Enum.filter(mentions_tweet, fn v -> v != nil end)
	mentions_tweet
end
end
