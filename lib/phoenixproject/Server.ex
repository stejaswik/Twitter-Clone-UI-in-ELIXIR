defmodule Server do
  use GenServer

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: Boss_Server)
  end

  def init(init_arg) do
    :ets.new(:hashTags, [:set, :protected, :named_table]) # tweets belonging to hashtag
    :ets.new(:tweets, [:set, :protected, :named_table]) # tweets posted by user
    :ets.new(:user_mention_tweets, [:set, :protected, :named_table]) # forward to users mentioned
    :ets.new(:subscriberList , [:set, :protected, :named_table]) # saves all the users subscribed by current user c2 -> [c1]
    :ets.new(:subscribersOf, [:set, :protected, :named_table]) # subscribers list for the given user c1 -> [c2]
    :ets.new(:user_list, [:set, :protected, :named_table]) # all the users added

    stack = init_arg
    userList = List.first(stack)
    hashtags = List.last(stack)

    serverMap = %{}
    serverMap = Map.put(serverMap, "userList", userList)
    serverMap = Map.put(serverMap, "hashtags", hashtags)
    serverMap = Map.put(serverMap, "regUsers", [])
    serverMap = Map.put(serverMap, "index", 0)

    stack = serverMap

    {:ok, stack}
  end

  def register_user(sName, user) do
    GenServer.cast(sName, {:register_user, user})
  end

  def delete_user(sName, user) do
    GenServer.call(sName, {:delete_user, user})
  end

  def subscribeTo(sName, user1, user2) do
    GenServer.call(sName, {:subscribe_to, user1, user2})
  end

  def sendTweet(sName, user, tweet, hashList, mentionList) do
    GenServer.cast(sName, {:send_tweet, user, tweet, hashList, mentionList})
  end

  def mentionedTweet(sName, user, mentionList, tweet) do
    GenServer.cast(sName, {:mentioned_tweet, user, mentionList, tweet, 1})
  end

  def forwardSubscribers(sName, user, forwardList, tweet) do
    GenServer.cast(sName, {:forwarded_tweet, user, forwardList, tweet, 0})
  end

  def hashtagTweet(sName, hashList, tweet) do
    GenServer.cast(sName, {:hashtag_tweet, hashList, tweet})
  end

  def retweet(sName, user, info) do
    GenServer.cast(sName, {:retweets, user, info})
  end

  def query_tweets_subscriber(sName, subscriber, user) do
    GenServer.cast(sName, {:querySub, subscriber, user})
  end

  def query_tweets_hashtag(sName, user, hashtag) do
    GenServer.cast(sName, {:queryHashtag, user, hashtag})
  end

  def query_tweets_mention(sName, user) do
    GenServer.cast(sName, {:queryMention, user})
  end

  def store(sName, str) do
    GenServer.cast(sName, {:store, str})
  end

  def handle_cast({:queryMention, user}, stack) do
    #add tweets to mentioned users
    l = :ets.lookup(:user_mention_tweets, user)
    if l != []  do
      l = List.first(l)
      l = Tuple.to_list(l)
      if length(l) > 0 do
        list = List.flatten(l)
        list = list -- [user]
        list = list -- [user]
        str = "User @#{user} mentioned tweets: "
        str1 = for tweet <- list do
          	"'" <> tweet <> "' \n"
        end
        str = str <> Enum.join(str1)
        IO.puts(str)
        Dispstore.save_node(str)
      end
    end
    {:noreply, stack}
  end

  def handle_cast({:queryHashtag, user, hashtag}, stack) do
    #add tweets to mentioned users
    l = :ets.lookup(:hashTags, hashtag)
    if l != []  do
      l = List.first(l)
      l = Tuple.to_list(l)
      if length(l) > 0 do
        list = List.flatten(l)
        list = list -- [hashtag]
        list = list -- [hashtag]
        str = "User @#{user} querying #{hashtag} tweets: "
        str1 = for tweet <- list do
        	"'" <> tweet <> "' \n"
        end
        str = str <> Enum.join(str1)
        IO.puts(str)
        Dispstore.save_node(str)
      end
    end
    {:noreply, stack}
  end

  def handle_cast({:querySub, subscriber, user}, stack) do
    #add tweets to mentioned users
    l = :ets.lookup(:tweets, user)
    if l != []  do
      l = List.first(l)
      l = Tuple.to_list(l)
      if length(l) > 0 do
        list = List.flatten(l)
        list = list -- [user]
        list = list -- [user]
        str = "User @#{subscriber} querying @#{user} tweets: "
        str1 = for tweet <- list do
          		"'" <> tweet <> "' \n"
        end
        str = str <> Enum.join(str1)
        IO.puts(str)
        Dispstore.save_node(str)
      end
    end
    {:noreply, stack}
  end

  def handle_cast({:send_tweet, user, tweet, hashList, mentionList}, stack) do
    #make changes to existing list
    l = :ets.lookup(:tweets, user)
    if l != [] do
      l = List.first(l)
      l = Tuple.to_list(l)
      if length(l) > 0 do
        list = List.flatten(l)
        list = list -- [user]
        list = list ++ [tweet]
        :ets.insert(:tweets, {user, list})
      end
    else
      :ets.insert(:tweets, {user, tweet})
    end

    #add tweets to mentioned users
    for userMent <- mentionList do
      l = :ets.lookup(:user_mention_tweets, userMent)
      if l != [] do
        l = List.first(l)
        l = Tuple.to_list(l)
        if length(l) > 0 do
          list = List.flatten(l)
          list = list -- [userMent]
          list = list ++ [tweet]
          :ets.insert(:user_mention_tweets, {userMent, list})
        end
      else
        :ets.insert(:user_mention_tweets, {user, tweet})
      end
      pid = Storepid.get_pid(userMent)
      Client.notification(pid, user, tweet, 1)
    end

    #add tweets to mentioned users
    for hashtag <- hashList do
      l = :ets.lookup(:hashTags, hashtag)
      if l != [] do
        l = List.first(l)
        l = Tuple.to_list(l)
        if length(l) > 0 do
          list = List.flatten(l)
          list = list -- [hashtag]
          list = list ++ [tweet]
          :ets.insert(:hashTags, {hashtag, list})
        end
      else
        :ets.insert(:hashTags, {hashtag, tweet})
      end
    end

    forwardList = :ets.lookup(:subscribersOf, user)
    if length(forwardList) > 0 do
      forwardList = List.first(forwardList)
      forwardList = List.flatten(Tuple.to_list(forwardList)) -- [user]
      #send notification to followers
      for u <- forwardList do
        pid = Storepid.get_pid(u)
        Client.notification(pid, user, tweet, 0)
      end
    end
    {:noreply, stack}
  end

  def handle_cast({:retweets, user, info}, stack) do
  	retweet = if info == 1 do
        l = :ets.lookup(:user_mention_tweets, user)
        _rt = if l != [] do
          l = List.first(l)
          l = Tuple.to_list(l)
          _rt = if length(l) > 0 do
            l = List.flatten(l)
            list = l -- [user]
            random_tweet = Enum.random(list)
            IO.puts("User @#{user} retweeting : #{random_tweet} from Mentions\n")
            random_tweet
          end
        else
          IO.puts("User @#{user} is not mentioned in any tweets\n")
          Dispstore.save_node("User @#{user} is not mentioned in any tweets\n")
          "nil"
        end
      else
        l = :ets.lookup(:subscriberList, user)
        _rt = if l != [] do
          l = List.first(l)
          l = Tuple.to_list(l)
          _rt = if length(l) > 0 do
            l = List.flatten(l)
            list = l -- [user]
            randomSub = Enum.random(list)
            l = :ets.lookup(:tweets, randomSub)
            if l != [] do
              l = List.first(l)
              l = Tuple.to_list(l)
              if length(l) > 0 do
                list = List.flatten(l)
                list = list -- [randomSub]
                random_tweet = Enum.take_random(list,1)
                IO.puts("User @#{user} retweeting : #{random_tweet} tweeted by subscriber @#{randomSub}\n")
                Dispstore.save_node("User @#{user} retweeting : #{random_tweet} tweeted by subscriber @#{randomSub}\n")
              	random_tweet
              end
            else
              IO.puts("User @#{user} doesnot have any subscriptions\n")
              "nil"
            end
          end
        end
    end
    if retweet != "nil" do
	    #make changes to existing list
	    l = :ets.lookup(:tweets, user)
	    if l != [] do
	      l = List.first(l)
	      l = Tuple.to_list(l)
	      if length(l) > 0 do
	        list = List.flatten(l)
	        list = list -- [user]
	        list = list ++ [retweet]
	        :ets.insert(:tweets, {user, list})
	      end
	    else
	      :ets.insert(:tweets, {user, retweet})
	    end
	    forwardList = :ets.lookup(:subscribersOf, user)
	    if length(forwardList) > 0 do
	      forwardList = List.first(forwardList)
	      forwardList = List.flatten(Tuple.to_list(forwardList)) -- [user]
	      for u <- forwardList do
	        pid = Storepid.get_pid(u)
	        Client.notification(pid, user, retweet, 0)
	      end
	    end
	end
    {:noreply, stack}
  end

  def handle_cast({:register_user, _node}, stack) do
    _userList = Map.get(stack, "userList")
    regList = Map.get(stack, "regList")
    :ets.insert(:user_list, {"user_list", regList})
    stack = Map.put(stack, "regUsers", regList)
    {:noreply, stack}
  end

  def handle_call({:subscribe_to, user1, user2}, _from, stack) do
    l = :ets.lookup(:subscriberList, user2)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      if length(l) > 0 do
        list = List.flatten(l)
        list = list -- [user2]
        list = list ++ [user1]
        :ets.insert(:subscriberList, {user2, list})
      end
    else
      :ets.insert(:subscriberList, {user2, user1})
    end
    l = :ets.lookup(:subscribersOf, user1)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      if length(l) > 0 do
        list = List.flatten(l)
        list = list -- [user1]
        list = list ++ [user2]
        :ets.insert(:subscribersOf, {user1, list})
      end
    else
      :ets.insert(:subscribersOf, {user1, user2})
    end
    {:reply, "done", stack}
  end

  def handle_call({:delete_user,user}, _from, stack) do
    :ets.delete(:user_list, user)
    l = :ets.lookup(:subscriberList, user)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      listSubscribers = if length(l) > 0 do
        list = List.flatten(l)
        _list = list -- [user]
      end
      for sub <- listSubscribers do
        updateSubscribeto(sub, user)
      end
    end
    :ets.delete(:subscriberList,user)

    l = :ets.lookup(:subscribersOf, user)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      listSubscribersof = if length(l) > 0 do
        list = List.flatten(l)
        _list = list -- [user]
      end
      for sub <- listSubscribersof do
        updateSubscribersOf(sub, user)
      end
    end
    :ets.delete(:subscribersOf,user)

    l = :ets.lookup(:tweets, user)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      listTweet = if length(l) > 0 do
        list = List.flatten(l)
        _list = list -- [user]
      end
      for tweet <- listTweet do
        hashtagList = get_hashtags(tweet)
        userMention = get_mentions(tweet)
        for hashtag <- hashtagList do
          updateHashtags(hashtag, tweet)
        end
        for mention <- userMention do
          updateMention(mention, tweet)
        end
      end
    end
    :ets.delete(:tweets, user)
    {:reply, "done", stack}
  end

  def updateHashtags(hashtag, tweet) do
    l = :ets.lookup(:hashTags, hashtag)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      listTweets = if length(l) > 0 do
        list = List.flatten(l)
        _list = list -- [hashtag]
      end
      listTweets = listTweets -- [tweet]
      :ets.insert(:hashTags, {hashtag, listTweets})
    end
  end

  def updateMention(mention, tweet) do
    l = :ets.lookup(:user_mention_tweets, mention)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      listTweets = if length(l) > 0 do
        list = List.flatten(l)
        _list = list -- [mention]
      end
      listTweets = listTweets -- [tweet]
      :ets.insert(:user_mention_tweets, {mention, listTweets})
    end
  end

  def get_hashtags(tweet) do
    tweetList = String.split(tweet)
    _hashlist = Enum.filter(tweetList, fn(d) -> if(String.at(d,0) == "#") do d end end)
  end

  def get_mentions(tweet) do
    tweetList = String.split(tweet)
    mentionlist = Enum.filter(tweetList, fn(d) -> if(String.at(d,0) == "@") do d
                  end end)
    _mentionlist = Enum.map(mentionlist, fn(d) -> List.last(String.split(d,"@")) end)
  end

  def updateSubscribersOf(sub, user) do
    l = :ets.lookup(:subscriberList, sub)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      listSub = if length(l) > 0 do
        list = List.flatten(l)
        _list = list -- [sub]
      end
      listSub = listSub -- [user]
      :ets.insert(:subscriberList, {sub, listSub})
    end
  end

  def updateSubscribeto(sub, user) do
    l = :ets.lookup(:subscribersOf, sub)
    if l != [] do
      l = List.flatten(l)
      l = List.first(l)
      l = Tuple.to_list(l)
      listSub = if length(l) > 0 do
        list = List.flatten(l)
        _list = list -- [sub]
      end
      listSub = listSub -- [user]
      :ets.insert(:subscribersOf, {sub, listSub})
    end
  end

end
