# Zimmr

## Premise

Zimmr is a social media app I built with Swift, Node.js, Neo4j, and Firebase. This repo in particular holds the code for the Swift frontend of the app. Another repo in my profile contains the javascript code for my Node.js server.

Zimmr was originally intended to be a startup, not just a programming project. The idea was for Zimmr to be a platform for people to post about fun activities they're hosting and to see what activities they've been invited to. 

Here's the description I used for the app when I submitted it to the App Store:

>HOST <br> With Zimmr, you can post about parties, game nights, or other events you are hosting and invite your friends. You can choose who’s invited, when the event is happening, and write a description about what you’ll be doing. <br><br> INVITATIONS <br>
On the main feed of the app, you can see all the events you’ve been invited to and when they’re happening. You can see who’s invited, who’s attending, and can decide whether or not you want to attend. <br><br> CHAT <br> Inside each event is a group chat with everyone who’s invited or attending. This is the perfect place to ask questions about the event—like where to meet or what to bring. <br><br> PROFILE <br>
Your profile is super simple at Zimmr—just your name, nickname, and profile picture. There are no metrics—no follower counts or friend counts. Zimmr is not about maximizing the number of followers you have, but about helping you have more fun in real life with your real friends. <br><br> FRIENDS & CONNECTIONS <br>
Like Facebook and other social media apps, Zimmr has a friend request feature so you and your friends can meet up on the app. In addition to your friends, Zimmr also tracks your “connections.” This is our word for the friends of your friends. In our experience, friend groups often grow through people meeting the friends of their friends, or their “connections.” Zimmr makes this easy—not only can you invite your friends to any events you host, you can also invite your connections!

I decided to turn Zimmr into a programming project because I realized (after building it) that the vision and many of the supposedly unique features of Zimmr were already captured by another startup--[IRL](https://www.irl.com/). Because they already have an established user base and a more mature app, I decided that trying to directly compete was not worth it.

## Design Patterns And Structure

The structure of the Swift frontend can be divided into four parts:

* View Hierachy
* View Models
* Codable Struct data-types
* Miscellaneous Singletons


### View Hierachy


