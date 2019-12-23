// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
/*let sleep = function (ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

let demo = async function (ms){
  await sleep(ms);
}*/
// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("rooms:lobby", {})
let messagesContainer = ("#messages");
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("new_msg", payload => {

var str = payload.body;
//Parse all data to be displayed in activities tab
for(var i=0;i<str.length; i++)
{
  //Retrieve table_activities element and add every activity as a new row
  var tabAct = document.getElementById("table_activities");
  var newRow = tabAct.insertRow(0);
  var newCell=newRow.insertCell(0);
  
  //add style to the cell just added
  newCell.style="padding:5px;";
  newCell.innerHTML =str[i];

  //If payload data has 2 hyphens, it's a username that has just joined tweety
  if (str[i].split("-").length == 3)
  {

     var at = "@" 
     var strUserName = at.concat(str[i]," has joined Tweety!");
     //Use regular expressions to blue highlight and underline any username   
     var newStr = strUserName.replace(/@*[a-z]*-[\d]*/g, function(m){
                return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
            })
     
     //ADd smiley face to the added user
     newCell.innerHTML =newStr.concat("<i class='fa fa-smile-o fa-stack-1x' style='text-align:left'></i>");
     
     //add user name with word "Subscribe" for every user
     var tabAct = document.getElementById("table_subscribe");
     var newRow = tabAct.insertRow(0);
     var newCell=newRow.insertCell(0);
     newCell.style="text-align:center;"
     newCell.innerHTML =str[i]+"  " + "<input type='submit' class='subscribe' style='height:3.5rem; text-align:right; float:right; margin-right:200px; background-color:#0069d9; margin-left:20px' value='Subscribe'></input>";
     newCell.id=str[i];
  }
  
  //if it's any other activity
  else
  { 
    //Use regular expressions to blue highlight and underline any username and hashtags   
    var newStr = str[i].replace(/@*[a-z]*-[\d]*/g, function(m){
                return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
            }).replace(/#\w+/g, function(m){
                return "<span style='color: blue; text-decoration: none;'>" + m + "</span>";
            });
    
    //add bullhorn to all activities        
    newCell.innerHTML = newStr.concat("<i class='fa fa-bullhorn fa-stack-1x aria-hidden='true'' style='text-align:left'></i>");

  }
}
 
//Parse through the payload data to display to user in individual sections 
for(var i=0;i<str.length; i++){

       //Following tab code      
      if(str[i].includes('following'))
      {
        //Parse based on @. First user is logged in user and second user is the subscribee   
        var a = str[i].split("@");
        var strSubscriber = a[a.length-1];
        var arrOurUser = a[a.length-2];

        //Parse based on space to get the current logged in user
        var strOurUser = arrOurUser.split(" ");
        document.getElementById("table_notifications").setAttribute("user" , strOurUser[0]);
        document.getElementById("ourUser").style.display = "none";
        document.getElementById("ourUser").innerHTML="Welcome, <b>"+strOurUser[0]+"</b>";

        //For each subscribee change the previously created subscribe button to read unsubscribe
        document.getElementById(strSubscriber).innerHTML = strSubscriber + "<input type='submit' class='subscribe' style='height:3.5rem; text-align:right; float:right; margin-right:182px; background-color:black; margin-left:20px' value='Unsubscribe'></input>";
      };

      //Tweet tab code  
      if(str[i].includes('tweet') && !(str[i].includes('Notification')) && !(str[i].includes('mentioned')))

      {
          //Retrieve table_tweet element and add every tweet as a new row
          var tabAct = document.getElementById("table_tweet");
          var newRow = tabAct.insertRow(0);
          var newCell=newRow.insertCell(0);
          
          //Parse based on :
          var b=str[i].split(":") 
          newCell.id = "tweetedItem"+i;
          newCell.style="padding:5px;";
          
          //Return tweet into the cell and add blue highlight and underline for usernames and hashtags
          newStr =b[1].replace(/@*[a-z]*-[\d]*/g, function(m){
                return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
            }).replace(/#\w+/g, function(m){
                return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
            });
          newCell.innerHTML = newStr;

          var ul = document.getElementById("hashtaglist");
          var li = document.createElement("li");
          li.setAttribute("id", "tweet"+i);
          ul.appendChild(li); 
          document.getElementById("tweet"+i).innerHTML = newStr; 

          //Add the bird icon  
          const iTag = document.createElement("i");
          iTag.setAttribute("class","fa fa-twitter fa-stack-1x");
          iTag.setAttribute("style","text-align:left;");
          document.getElementById("tweetedItem"+i).append(iTag);
      };
                   
}

for(var i=0;i<str.length; i++)
{
  var strUser = document.getElementById("table_notifications").getAttribute("user");
  var strNotificationMsg = "Notification to @"+strUser;
  console.log(strNotificationMsg);
  
  //Notifications tab code
  if(str[i].search(strNotificationMsg)>=0)
  {   
        //Retrieve table_notifications element and add every notification as a new row
        var tabAct = document.getElementById("table_notifications");
        var newRow = tabAct.insertRow(0);
        var newCell=newRow.insertCell(0);
        newCell.style="padding:5px;";

        //Parse based on : to retrieve notification
        var d = str[i].split(": ");
        
        //Return notification to cell and add blue highlight and undeline for usernames and hashtags
        newStr = d[1].replace(/@*[a-z]*-[\d]*/g, function(m){
            return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
        }).replace(/#\w+/g, function(m){
            return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>"; 
        });

        //Add the bell icon
        newCell.innerHTML = newStr.concat("<i class='fa fa-bell-o fa-stack-1x aria-hidden='true'' style='text-align:left'></i>");        
  };

  //Mentions tab code
  if(str[i].includes('tweet') && str[i].search(strNotificationMsg)>=0 && (str[i].includes('mentioned')) )
      {
            //Parse based on :
            var d = str[i].split(": ");

            //Retrieve table_mentions element and add every mention as a new row
            var tabAct = document.getElementById("table_mentions");
            var newRow = tabAct.insertRow(0);
            var newCell=newRow.insertCell(0);
            newCell.style="padding:5px;";
            newCell.id="mention_"+i;
            
            //Return mention to cell and add blue highlight and underline for usernames and hashtags 
            var newStr = d[1].replace(/@*[a-z]*-[\d]*/g, function(m){
                return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
            }).replace(/#\w+/g, function(m){
            return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>"; 
            });

            //Add the retweet icon          
            let newStr1 = "<i val=mention_" + i + "' class='fa fa-retweet fa-stack-1x aria-hidden='true'' style='text-align:left; width:0%'></i></div>";
            newStr1 = newStr1.concat(newStr);
            newCell.innerHTML = newStr1;

      };
}

});

let create_account = document.getElementById("login")
create_account.addEventListener("click", function(){
  let username = document.getElementById("InputEmail");
  let password = document.getElementById("Password");
  let current_user = document.getElementById("table_notifications").getAttribute("user")
  let payload = {
    u: username.value,
    p: password.value
  };
  
  if (username.value == current_user && password.value == "password") {
    document.getElementById("myForm").style.display="none"; 
    document.getElementById("myMain").style.display="block";
    document.getElementById("ourUser").style.display="inline";
    document.getElementById("logout").style.display="inline";
  } else {
    alert("Invalid Credentials");
  }
  // channel.push("login_account", payload)
  // .receive("ok", resp => { console.log("Joined successfully", resp) })
  // .receive("error", resp => { console.log("Unable to join", resp) })
});


let subscription_buttons = document.getElementsByClassName("subscribe");

document.addEventListener('click', function(e){
  if (e.target && e.target.classList.contains("subscribe")) {
    if (e.target.value == "Subscribe") {
      e.target.value = "Unsubscribe"
      let payload = {
        'u2': document.getElementById("table_notifications").getAttribute("user"),
        'u1': e.target.parentElement.id
      }
      e.target.style.backgroundColor = "black"
      channel.push("subscribe", payload);
    } else {
      e.target.value = "Subscribe"
      e.target.style.backgroundColor = "#0069d9"
      let payload = {
        'u2': document.getElementById("table_notifications").getAttribute("user"),
        'u1': e.target.parentElement.id
      }
      channel.push("unsubscribe", payload);
    }
  }
  if (e.target && e.target.classList.contains("fa-retweet")) {
    // TODO: Color Change
    e.target.style.color = "green"
    let tweet = e.target.parentElement.textContent
    // tweet = tweet.substring(
    //   tweet.lastIndexOf("<") + 1, 
    //   tweet.lastIndexOf(">")
    // );
    let payload = {
      'u': document.getElementById("table_notifications").getAttribute("user"),
      'tweet': tweet
    }
    channel.push("retweet", payload)
    .receive("ok", resp => { 
      var tabAct = document.getElementById("table_tweet");
      var newRow = tabAct.insertRow(0);
      var newCell=newRow.insertCell(0);
      
      //Parse based on :
      var b=resp.message.substring(
          tweet.lastIndexOf("<") + 1, 
          tweet.lastIndexOf(">")
        ).split(":") 
      let i = tabAct.children[0].childElementCount + 1;
      newCell.id = "tweetedItem"+ i;
      newCell.style="padding:5px;";
      
      //Return tweet into the cell and add blue highlight and underline for usernames and hashtags
      let newStr =b[0].replace(/@*[a-z]*-[\d]*/g, function(m){
            return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
        }).replace(/#\w+/g, function(m){
            return "<span style='color: blue; text-decoration: underline;'>" + m + "</span>";
        });
      newCell.innerHTML = newStr;

      var ul = document.getElementById("hashtaglist");
      var li = document.createElement("li");
      li.setAttribute("id", "tweet"+i);
      ul.appendChild(li); 
      document.getElementById("tweet"+i).innerHTML = newStr; 

      //Add the bird icon  
      const iTag = document.createElement("i");
      iTag.setAttribute("class","fa fa-twitter fa-stack-1x");
      iTag.setAttribute("style","text-align:left;");
      iTag.style.color = "green";
      document.getElementById("tweetedItem"+i).append(iTag);


      var tabAct = document.getElementById("table_activities");
      var newRow = tabAct.insertRow(0);
      var newCell=newRow.insertCell(0);
      
      //add style to the cell just added
      newCell.style="padding:5px;";
      newStr = "User " + document.getElementById("table_notifications").getAttribute("user") + " has retweeted: " + newStr;
      newCell.innerHTML = newStr.concat("<i class='fa fa-smile-o fa-stack-1x' style='text-align:left; color:green; width:0%'></i>");
      alert("Successfully retweeted")
    })
    .receive("error", resp => { console.log("Unable to join", resp) })
  }
})

export default socket
