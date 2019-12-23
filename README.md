# "Tweety" : Twitter CLone using Server- CLient Architecture with UI <br />

 Click to view setup and implementation video: <br />
 <a href= "https://youtu.be/F59tYGdZaIg" target= "_blank"> Tweety Implementation </a>
 <br />

a> SETUP <br />
   =====

 step 1: Unzip the folder and go to the path where zip has been extracted /path/directory/  <br />

 step 2: Run "make" to compile source from terminal <br />

b> GENERATE DATA <br />
   =============
 
 *step 1: On Terminal 1 run "mix phx.server" <br />

 *step 2: Go to browser and type "localhost:4000" <br />

 *step 3: check for login page <br />

 *step 4: Open terminal 2 and run "mix test"  <br />
 <Description: Running mix test seeds our ETS table with data (reference- Project 4.1),  <br />
 i.e. unique username generation, tweets, subscriptions, notifications> <br />

 *step 5: After the mix test is successful -> copy the username and password specified in terminal 2 and paste it in browser to use the web interface. <br />

 *step 6: Login from browser into "Tweety"  <br />
 <From now onwards the Twitter clone application would be referred ad "Tweety".> <br />


c> TWEETY FRONT PAGE  <br />
   =================

 *step 7: Functionalities implemented in Tweety: <br />
 a. Welcome <current user> <br />
 b. Home <br />
 c. Tweet <br />
 d. Subscribe <br />
 e. Notifications <br />
 f. Mentions <br />
 g. Explore <br />
 h. logout <br />
 <Provided detailed description of functionalities and tweet format in document.> <br />


d> CHECK FUNCTIONALITIES <br />
   =====================

 *step 8: Go to "Notifications" <br />

 a. It consists of all the tweets posted by the current user's subscribers along with <br />
 the tweets in which the current logged in user was mentioned. <br />

 b. Every tweet in "Notifications" tab having the following format- <br />
 "User <@xyz> has tweeted <-- tweet -->"  <br />
 is posted by @xyz user, who is subscribed by the current user. <br />

 c. Above (b) can be checked by navigating to the "Subscribe" tab- <br />
 the @xyz user will have "UNSUBSCRIBE" button -> which means that the current user is subscribed to @xyz. <br />

 d. Every tweet in "Notifications" tab having the following format- <br />
 "User @abc has mentioned you in tweet <-- tweet -->" <br />
 is posted by @abc user, who has mentioned the current user in their tweets. <br />
 Same tweet can be viewed under "Mentions" tab. <br />

 *step 9: Go to "Mentions" <br />

 a. It consists of all the tweets mentioning the current user, every tweet has below format- <br />
 "User @abc has mentioned you in tweet <-- tweet -->" <br />
 pick up tweet by user @abc in which the current user is mentioned, press on retweet icon <placed towards left side of every tweet> -> <br />
 you will see an alert "Successfully retweeted" and the color of the retweet icon changes to "Green". <br />

 b. Upon receiving "Successfully retweeted" alert, go to "Tweet" tab -> <br />
 The retweet is added to the current user's list and its icon's color is set to "Green" for identification. <br />
 Both the tabs display same tweet. <It can be cross checked> <br />

 c. Retweet is added to the existing activities on "Home" tab and it is represented by a "Green smiley" for identification. <It can be cross checked> <br />

 d. Go to phxserver running on Terminal 1 ->  <br />
 the retweet and corresponding username are updated on the server side and displayed on terminal 1 in the below format- <br />

 -------------------------------------------------------------RETWEET-------------------------------------------------------  <br />
 (current_user) has retweeted ----------> User <--@xyz--> has mentioned you in tweet <--tweet-->  							 <br />
 ---------------------------------------------------------------------------------------------------------------------------  <br />

 *step 10: Go to "Subscribe" <br />

 a. Click subscribe button for a random user "jfk", who has "SUBSCRIBE" box specified. <br />
 Go to phxserver running on Terminal 1 -> 
 the current user subscription is updated on the server side and displayed on terminal 1 in the below format- <br />

 ------------------------------------------------------------SUBSCRIPTION--------------------------------------------------   <br />
 (current_user) is following ----------> (jfk)																				 <br />
 --------------------------------------------------------------------------------------------------------------------------	 <br />

 b. Click on unscribe for a random user "lmn", who has "UNSUBSCRIBE" box specified. <br />
 Go to phxserver running on Terminal 1 -> <br />
 the current user unsubscription is updated on the server side and displayed on terminal 2 in the below format- <br />

 ------------------------------------------------------------UNSUBSCRIPTION------------------------------------------------	<br />
 (current_user) unsubscribed ----------> (lmn)																				<br />
 --------------------------------------------------------------------------------------------------------------------------	<br />

 *step 11: Go to "Explore" <br />

 Search for hashtags/ usernames -> all the tweets containing the specified hashtags and usernames are displayed.        <br />

 *step 12: Log out   <br />

 a. Any login credential other than the one provided by "mix test" in terminal 2, are considered INVALID -           <br />
 An alert pops up with the "Invalid Credentials" message. <br />

 b. We can check that the content and updated activities are retained even after logout. <It can be cross checked> <br />

  ````````````````````````````````````````````````````````````````````````````````````````````````````````` 
 | *All the above functionalities are mentioned in the document along with screenshots.|                    
  ````````````````````````````````````````````````````````````````````````````````````````````````````````` 




