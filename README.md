<p>
    <img src="https://img.shields.io/badge/iOS-13.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-5.1-ff69b4.svg" />
</p>


# Zimmr

Zimmr is a social media app I built with Swift, Node.js, Neo4j, and Firebase. This repo in particular holds the code for the Swift frontend of the app. Another repo in my profile contains the javascript code for my Node.js server.



### Premise

Zimmr was originally intended to be a startup, not just a programming project. The idea was for Zimmr to be a platform for people to post about fun activities they're hosting and to see what activities they've been invited to.

Here's the description I used for the app when I submitted it to the App Store:

>HOST <br> With Zimmr, you can post about parties, game nights, or other events you are hosting and invite your friends. You can choose who’s invited, when the event is happening, and write a description about what you’ll be doing. <br><br> INVITATIONS <br>
On the main feed of the app, you can see all the events you’ve been invited to and when they’re happening. You can see who’s invited, who’s attending, and can decide whether or not you want to attend. <br><br> CHAT <br> Inside each event is a group chat with everyone who’s invited or attending. This is the perfect place to ask questions about the event—like where to meet or what to bring. <br><br> PROFILE <br>
Your profile is super simple at Zimmr—just your name, nickname, and profile picture. There are no metrics—no follower counts or friend counts. Zimmr is not about maximizing the number of followers you have, but about helping you have more fun in real life with your real friends. <br><br> FRIENDS & CONNECTIONS <br>
Like Facebook and other social media apps, Zimmr has a friend request feature so you and your friends can meet up on the app. In addition to your friends, Zimmr also tracks your “connections.” This is our word for the friends of your friends. In our experience, friend groups often grow through people meeting the friends of their friends, or their “connections.” Zimmr makes this easy—not only can you invite your friends to any events you host, you can also invite your connections!
<br>

I decided to turn Zimmr into a programming project because I realized (after building it) that the vision and many of the supposedly unique features of Zimmr were already captured by another startup--[IRL](https://www.irl.com/). Because they already have an established user base and a more mature app, I decided that trying to directly compete with IRL was not worth it.

### Purpose of Repo

Though this repo is public, I am not seeking contributors to improve Zimmr. Instead, I intend this repo to display the work I've put into Zimmr so that employers or other interested parties can get a sense of my abilities. In the rest of this `README`, I'll give a summary of the code and my thought process behind it.

### Design

There are basically four kinds of objects I used in Zimmr:

* Views
* View Models
* Codable Struct data-types
* Miscellaneous Singletons


#### Views

Like all other front end projects, the view structure of Zimmr is both hierachical and modular. To get a sense of Zimmr's hierachy, I've sketched a rough diagram of the view hierachy that goes into Zimmr's main page:

<p align="center">
  <img src="https://github.com/sorensenj50/zimmrApp/blob/9336aac77d6889cd68d0142ed7cb0d3132dee9b9/readmedocs/Screen%20Shot%202022-01-31%20at%2012.59.51%20PM.png" alt="drawing" width="500"/>
</p>

Like every other app, each user is directed straight to the `App Content` unless they need to be authenticated. The next layer in the `View` hierachy is a Menu layer--where users can switch between tabs to see different content. (The default is `Events`).

While the Menu layer is driven by user decision, the next layer has to do with the state of the fetched data. If Zimmr is loading data, the loading view is shown. If data has been loaded, but there is none of it--for instance if a user is not invited to any events--then a graphic will be shown that describes what is ordinarily shown here. Finally, the events view is of course shown once events are fetched.

Finally, displayed in each `EventView` is the final list of elements shown--the event date, for instance, as well as information about the host. 

Here is a screenshot of the main page. Interestingly, the complexity of the view hierachy may not be obvious from the screenshot. 

<p align="center">
  <img src="https://github.com/sorensenj50/zimmrApp/blob/a8ca441261a967d30c73a6cea68a59d1514d67a0/readmedocs/IMG_0132.PNG" alt="drawing" width="300"/>
</p>

To get a sense of Zimmr's modularity, take note of the grey subtitle text underneath each host's name. In Zimmr, this text always indicates a relationship between the viewer and the user they're viewing. To ensure UI consistency, even this minor of an element as its own dedicated `View` `struct`.

That `View` is given here:

```swift
struct RelationshipString: View {
    static let normal: CGFloat = 16
    static let profile: CGFloat = 18
    
    let interpretedRelationship: String
    let size: CGFloat
    
    init(rel: UserCore.Relationship?, links: Int?) {
        self.interpretedRelationship = UserCore.interpretRelationship(rel, links)
        self.size = ConnectionString.normal
    }
    
    init(rel: UserCore.Relationship?, links: Int?, size: CGFloat) {
        self.interpretedRelationship = UserCore.interpretRelationship(rel, links)
        self.size = size
    }
    
    init(interpretedRelationship: String, size: CGFloat) {
        self.interpretedRelationship = interpretedRelationship
        self.size = size
    }
    
    init(interpretedRelationship: String) {
        self.interpretedRelationship = interpretedRelationship
        self.size = ConnectionString.normal
    }
    
    var body: some View {
        Text(interpretedRelationship)
            .font(.system(size: size))
            .fontWeight(.medium)
            .foregroundColor(Color.gray)
            .frame(alignment: .leading)
    }
}

```

This `View` has multiple `init`s to allow for flexibility, but it also encapulates the flexible logic to ensure consistency. The two sizes, for instance, are encapsulated as `static variables`.

Just as common as this `RelationshipString View` is the design pattern of the profile picture horizontally adjacent to the user's name stacked on top of this `RelationshipString`. This design pattern is found in the `Event` view, but also in a more common component--the `UserList`.

An example of a `UserList` is the list of users who are attending an event:

<p align="center">
  <img src="https://github.com/sorensenj50/zimmrApp/blob/181a9e0d176ba2fa7afa48c2a5c9bfcff585a4c5/readmedocs/IMG_0134.PNG" alt="drawing" width="300"/>
</p>

The central component involved is called `UserListCore`.

```swift
struct UserListCore: View {
    let users: [UserCore]
    
    func getPadding(index: Int) -> CGFloat {
        return index == 0 ? 13: 7
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<users.count, id: \.self) { index in
                    if let user = users[index] {
                        VStack(alignment: .leading) {
                            RelationshipHeader(user: user, size: 65)
                            .padding(.top, getPadding(index: index))
                            .padding(.bottom, 7)

                            Divider()
                                
                        }
                    }
                }
            }
        }
    }
}
```

"Core" is helpful as an identifier here because the `UserListCore` is wrapped in other view layers that instantiate the view model that fetches the relevant data and handles the logic of only showing the loading view when necessary.
`UserCore`, similarly, is a `Codable` `struct` that is contains essential user information but can also be wrapped in other `Codable` `struct`s (like `Event`) for modularity. This will discussed more when we turn to the data architecture of Zimmr.





