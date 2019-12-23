# Twitter Supervisor 
defmodule Twitter_Supervisor do
  use Supervisor

  def start_link(input) do
    Supervisor.start_link(__MODULE__, input)
  end

  def init(input) do
    serverName = Enum.at(input, 2)
    userNames = Enum.at(input, 0)
    hashtags = Enum.at(input, 1)
    numMsg = Enum.at(input, 3)

    children = Enum.map(userNames, fn(worker_id) ->
      worker(Client, [[worker_id] ++ [serverName] ++ [userNames] ++ [hashtags] ++ [numMsg]], [id: worker_id, restart: :permanent])
    end)

    supervise(children, strategy: :one_for_one, name: Supervise_topology)
  end
end

# Twitter Client
defmodule Client do
  use GenServer

  def start_link(list) do
    GenServer.start_link(__MODULE__, list)
  end

  def init(stack) do
    serverName = Enum.at(stack, 1)
    userName = Enum.at(stack, 0)
    userNames = Enum.at(stack, 2)
    hashtags = Enum.at(stack, 3)
    numMsg = Enum.at(stack, 4)

    # Initialize the client map
    userMap = %{}
    userMap = Map.put(userMap, "user", userName)
    userMap = Map.put(userMap, "server", serverName)
    userMap = Map.put(userMap, "userList", userNames)
    userMap = Map.put(userMap, "hashtags", hashtags)
    userMap = Map.put(userMap, "login", 1)
    userMap = Map.put(userMap, "num", numMsg)
    userMap = Map.put(userMap, "subscribers", [])

    stack = userMap

    Server.register_user(Map.get(stack, "server"),Map.get(stack, "user"))
    {:ok, stack}
  end

  def deleteAccount(user) do
    GenServer.call(Storepid.get_pid(user), {:delete, user})
  end

  def tweeting(pid) do
    GenServer.cast(pid, {:tweet})
  end

  def subscribe(pid, c2) do
    GenServer.call(pid, {:subscribe, c2})
  end

  def notification(pid, user, tweet, info) do
    GenServer.cast(pid, {:notification, user, tweet, info})
  end

  def retweet(pid, info) do 
  #info "0" subscriber, "1" mentioned
    GenServer.cast(pid, {:retweet, info})
  end

  def query_tweets_subscriber(pid, subscriber) do
    GenServer.cast(pid, {:querytweet, subscriber})
  end

  def query_tweets_hashtag(pid, hashtag) do
    GenServer.cast(pid, {:queryhashtag, hashtag})
  end

  def query_tweets_mention(pid) do
    GenServer.cast(pid, {:querymention})
  end

  def update_userList(pid, newList) do
    GenServer.cast(pid, {:update, newList})
  end

  def handle_cast({:update, newList}, stack) do
    stack = Map.put(stack, "userList", newList)
    {:noreply, stack}
  end

  def handle_cast({:querymention}, stack) do
    user = Map.get(stack, "user")
    Server.query_tweets_mention(Map.get(stack, "server"), user)
    {:noreply, stack}
  end

  def handle_cast({:queryhashtag, hashtag}, stack) do
    user = Map.get(stack, "user")
    Server.query_tweets_hashtag(Map.get(stack, "server"), user, hashtag)
    {:noreply, stack}
  end

  def handle_cast({:querytweet, user}, stack) do
    subscriber = Map.get(stack, "user")
    Server.query_tweets_subscriber(Map.get(stack, "server"), subscriber, user)
    {:noreply, stack}
  end

  def handle_cast({:retweet, info}, stack) do
    login = Map.get(stack, "login")
    user = Map.get(stack, "user")

    if login == 1 do
      Server.retweet(Map.get(stack, "server"), user, info)
    end
    {:noreply, stack}
  end 

  def handle_cast({:notification, user_generating, tweet, info}, stack) do
    user = Map.get(stack, "user")
    login = Map.get(stack, "login")
    if login == 1 do
      if info == 1 do
        IO.puts("Notification to @#{user}: User @#{user_generating} has mentioned you in tweet < #{tweet} >\n")
        Dispstore.save_node("Notification to @#{user}: User @#{user_generating} has mentioned you in tweet < #{tweet} >")
      else
        IO.puts("Notification to @#{user}: User @#{user_generating} has tweeted < #{tweet} >\n")
        Dispstore.save_node("Notification to @#{user}: User @#{user_generating} has tweeted < #{tweet} >")
      end
    end
    {:noreply, stack}
  end 

  def handle_cast({:tweet}, stack) do
    login = Map.get(stack, "login")
    stack = if login == 1 do
      hashtags = Map.get(stack, "hashtags")
      usernames = Map.get(stack, "userList")

      nouns = ["bird", "clock", "boy", "plastic", "duck", "teacher", "old lady", "professor", "hamster", "dog"];
      verbs = ["kicked", "ran", "flew", "dodged", "sliced", "rolled", "died", "breathed", "slept", "killed"];
      adjectives = ["beautiful", "lazy", "professional", "lovely", "dumb", "rough", "soft", "hot", "vibrating", "slimy"];
      adverbs = ["slowly", "elegantly", "precisely", "quickly", "sadly", "humbly", "proudly", "shockingly", "calmly", "passionately"];
      preposition = ["down", "into", "up", "on", "upon", "below", "above", "through", "across", "towards"];

      user = Map.get(stack, "user")
      tweetLength = List.first(Enum.take_random(5..6, 1))
      hashLength = List.first(Enum.take_random(0..tweetLength-2, 1))
      mentionLength = tweetLength-hashLength
  
      hashList = Enum.take_random(hashtags, hashLength)
      mentionList = Enum.take_random(usernames, mentionLength)
      mentionList = mentionList ++ [Enum.at(usernames, 0)]
      noun = Enum.take_random(nouns, 1)
      verb = Enum.take_random(verbs, 1)
      adjective = Enum.take_random(adjectives, 1)
      adverb = Enum.take_random(adverbs, 1)
      _prep = Enum.take_random(preposition, 1)
      mentionListNew = Enum.map(mentionList, fn(x) -> "@"<>x end)

      t = ["The"] ++  noun ++ adjective ++ noun ++ adverb ++ verb ++ ["because some"] ++ noun ++ adverb ++ verb ++ preposition ++ ["a"] ++ adjective ++ noun ++ ["which, became a"] ++ adjective ++ noun
      t = Enum.join(t, " ")
      tweet = Enum.shuffle(hashList ++ mentionListNew ++ [t])
      tweet = Enum.join(tweet, " ")
      IO.puts("User @#{user} tweet: #{tweet}\n")
      Dispstore.save_node("User @#{user} tweet: #{tweet}")
      Server.sendTweet(Map.get(stack, "server"), user, tweet,  hashList, mentionList)
      msgReq = Map.get(stack, "num")
      msgReq = msgReq - 1
      Map.put(stack, "num", msgReq)
    else
      stack
    end
    if (login == 1) do
      msgReq = Map.get(stack, "num")
      if msgReq > 0 do
        tweeting(self())
      end
    end
    {:noreply, stack}
  end

  def handle_call({:subscribe, user2}, _from, stack) do
    sub = Map.get(stack, "subscribers")
    user1 = Map.get(stack, "user")
    list = sub ++ [user2]
    list = List.flatten(list)
    stack = Map.put(stack, "subscribers", list) 
    IO.puts("User @#{user2} is following User @#{user1}\n")
    Dispstore.save_node("User @#{user2} is following User @#{user1}")
    val = Server.subscribeTo(Map.get(stack, "server"),user1,user2)
    {:reply, val ,stack}
  end

  def handle_call({:delete, user}, _from, stack) do
    _channel = Map.get(stack, "channel")  
    stack = Map.put(stack, "login", 0)
    userList = Map.get(stack, "userList")
    newList = userList -- [user]
    for u <- newList do
      update_userList(Storepid.get_pid(u), newList)
    end
    val = Server.delete_user(Map.get(stack, "server"), user)
    IO.puts("User @#{user} is successfully deleted")
    Dispstore.save_node("User @#{user} is successfully deleted")
    {:reply, val, stack}
  end

end

# Unique user names 
defmodule Name do
@adjectives ~w(
    autumn hidden bitter misty silent empty dry dark summer
    icy delicate quiet white cool spring winter patient
    twilight dawn crimson wispy weathered blue billowing
    broken cold damp falling frosty green long late lingering
    bold little morning muddy old red rough still small
    sparkling throbbing shy wandering withered wild black
    young holy solitary fragrant aged snowy proud floral
    restless divine polished ancient purple lively nameless
  )
@nouns ~w(
    waterfall river breeze moon rain wind sea morning
    snow lake sunset pine shadow leaf dawn glitter forest
    hill cloud meadow sun glade bird brook butterfly
    bush dew dust field fire flower firefly feather grass
    haze mountain night pond darkness snowflake silence
    sound sky shape surf thunder violet water wildflower
    wave water resonance sun wood dream cherry tree fog
    frost voice paper frog smoke star hamster
  )
def generate(max_id \\ 9999) do
    adjective = @adjectives |> Enum.random
    noun = @nouns |> Enum.random
    id = :rand.uniform(max_id)
    [adjective, noun, id] |> Enum.join("-") |> to_string()
end
end