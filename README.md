<p>
    <img src="https://img.shields.io/badge/iOS-15.0-blue" />
    <img src="https://img.shields.io/badge/Swift-5.1-ff69b4.svg" />
    <img src="https://img.shields.io/badge/Firebase-8.0-red" />
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

Though this repo is public, I am not seeking contributors to improve Zimmr. Instead, I intend this repo to display the work I've put into Zimmr so that employers or other interested parties can get a sense of my abilities. In the rest of this `README`, I'll give a summary of the code and my thought process behind it. You can also install my app via TestFlight to see what it does for yourself. Link: https://testflight.apple.com/join/pvHUsutx

### Design

There are basically four kinds of objects I used in Zimmr:

* Views
* `Codable` `struct` data-models
* View Models
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

### Data Model

`UserCore`, similarly, is a `Codable` `struct` that is contains essential user information but can also be wrapped in other `Codable` `struct`s (like `Event`) for modularity. UserCore is defined here:

```swift
struct UserCore: Codable, Identifiable {
    
    // user info
    let userID: String
    let firstName: String
    let userName: String
    let fullName: String
    let hasImage: Bool
    
    // relational info
    var relationship: Relationship?
    var links: Int?
    
    // comforms to identifiable protocol
    var id: String { return userID }
    
    
    enum Relationship: String, Codable {
        case FRIEND
        case CONNECTION
        case SELF
    }
    
    static func interpretRelationship(_ relationship: UserCore.Relationship?, _ links: Int?) -> String {
        if relationship == nil {
            return "no relationship"
        } else if relationship == .FRIEND {
            return "friend"
        } else if relationship == .CONNECTION {
            if links! == 1 {
                return "1 mutual friend"
            } else {
                return "\(links!) mutual friends"
            }
        } else if relationship == .SELF {
            return "yourself"
        } else {
            return ""
        }
    }
}
```

Every user seen on the app--whether it's the host of an event, one of your friends, or someone who shows up in a search, is modeled by this `struct`. The `UserListCore` view we saw earlier simply displays an array of `UserCore` instances. This struct also encapsulates the related `Relationship` enum, as well as the static `interpretRelationship` function we saw earlier in the `RelationshipString` view component. 

As the name suggests, this struct is used in a modular fashion by other, more complex `Codable` data models. Take the `UserList` itself:

```swift
struct UserList: Codable, ModelEntryPoint {
    let users: [UserCore]
    
    enum functionType: String {
        case hostEvent
        case requests
    }
    
    struct FunctionHolder {
        let type: UserList.functionType
        
        var toggleInvite: ((Int) async -> Void)?
        var isInvited: ((Int) -> Bool)?
        
        var accept: ((Int) async -> Void)?
        var delete: ((Int) async -> Void)?
    }

    
    func checkEmpty() -> Bool {
        return users.isEmpty
    }
    
    func getReferences() -> Set<String> {
        return Set(users.filter({ $0.hasImage }).map({ $0.userID }))
    }
    
    static func getParams(otherID: String, type: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "otherID": otherID, "type": type]
    }
    
    static func getMutualFriendParams(otherID: String, name: String) -> [String: String] {
        return ["userID": USER_ID.instance.get()!, "type": "mutualFriends", "otherID": otherID, "otherName": name]
    }
}
```

The first thing to point out about this `struct` is that it conforms to the `ModelEntryPoint` `protocol`. This is a custom protocol that makes it possible to standardize functions in those structs which will be directly decoded from fetched `.json`. In order to comform to this protocol, objects must conform to two functions: `getReferences` and `checkEmpty`. 

The `getReferences` function returns a `Set` of strings that is used to identify and fetch images from my Firebase Cloud Storage Bucket. In the case of this `struct` the image identifiers are the `userIDs` of those users which the boolean `hasImage` is true. Note that the data structure of the `Set` is useful because it elegantly ensures uniqueness (fetching images is an expensive operation--I don't want to fetch the same image twice) and I don't need the ordering an `Array` provides.

The `checkEmpty` function returns a boolean that indicates whether the data is "empty"--i.e. there are no events coming up, or no users in a `UserList`. Since the `UserList` `struct` just contains an array of users, it is empty if the array contains zero elements, so I return `users.isEmpty`. Other data model `structs` have more complex empty conditions.

The nested `FunctionHolder` `struct` exists to provide a container for the functions I pass down the user list view hierachy. This is useful in instances where there are actions attached to each user in a `UserList`--such as accepting or deleting friend requests. How this works will be explained more later, but basically the view model that fetches and decodes the `.json` into a `UserList` will instantiate a `FunctionHolder` and save it's own methods (that make post requests) into it before passing it down the view hierachy. I prefer this approach to simply passing the view model itself down the view hierachy. It provides a more clear demarcation between the broader views in the hierachy (which should have access to the entire view model) and the components, which only need one or two functions--and should thus only have access to that.

There are other data model `Codable` `struct`s, but for the sake of brevity, we must continue to other topics.

### View Model

The view models in my project serve to fetch and decode the data that my views display. Though that are severl different types of view model used in Zimmr, they all are derived from the `View Model` super class. I won't include the entire class definition here, but here is abbreviation of it:

```swift
class ViewModel<T: Codable & ModelEntryPoint>: ObservableObject {
    @Published var result: T?
    @Published var isLoading: Bool = false
    
    let request: GetRequest

    init(request: GetRequest) {
        self.request = request
    }
    
   // ...
    
}
```

This class is generic--and can work with any result type `T` that conforms to both the `Codable` and `ModelEntryPoint` protocols. (This type could be `UserList`, for instance.) The class stores two published variables--the (optional) result, and a bool indicating if the view model is loading the data. It also stores a constant variable `request` (an instance of a custom `GetRequest` type) which contains the components and parameters of the URL used to fetch the data. 

The central method in this class is the `loadData` method, which uses the info in the `request` constant to fetch and decode the given information from my server. After the data is fetched (but before `isLoading` is set to false), this `loadData` function initializes an instance of the `ImageFetcher` class. This fetches any needed images, using `getReferences()` to parse imageIDs from the data. 

```swift
class ImageFetcher<Result> {
    
    let function: (Result)->Void
    let result: Result
    var numberReady: Int = 0
    var numberNeeded: Int?
    
    init(references: Set<String>, function: @escaping (Result)->Void, result: Result) {
        self.function = function
        self.result = result
        
        print(references.count)
        self.fetchImages(references: references)
        
    }

    func fetchImages(references: Set<String>) {
        self.numberNeeded = references.count
        if self.numberNeeded == 0 {
            self.function(self.result)
        } else {
            for imageID in references {
                fetchIndividualImage(id: imageID)
            }
        }
    }
    
    func fetchIndividualImage(id: String) {
        var useID = id
        if let newID = ImageDictionaryContainer.idDict[id] {
            useID = newID
        }
        
        
        if Cache.instance.isInCache(id: id) {
            self.increaseAndCheckReady()
            return
        } else {
            let ref = FirebaseStorageManager.instance.getUploadReference(id: useID)
            ref.getData(maxSize: 2051240) { data, error in
                if error != nil {
                    self.increaseAndCheckReady()
                    return
                }
                let image = UIImage(data: data!)
                Cache.instance.addImage(image: image!, name: id)
                self.increaseAndCheckReady()
            }
        }
    }
    
    func increaseAndCheckReady() {
        self.numberReady += 1
        if self.numberReady == self.numberNeeded {
            self.function(self.result)
        }
    }
}
```

This class is more function-like than many other classes--we can think of it as a stateful function, or a function wrapped in an object. Basically, this object, takes a `Set` of imageIDs, fetches them from Firebase, saves them to the `Cache`, and then calls the passed function when done. This function, defined in the `ViewModel` super class, toggles back the `self.isLoading` boolean to false and saves the result to `self.result`. This garuntees that the results of the fetched data are only shown when the corresponding images are saved to the local Cache. 

The act of fetching multiple images from Firebase needs to wrapped in a stateful object because we need to track the number of images already fetched to know when the process is done. In my Node.js server, I could handle this sort of thing with a `Promise.all`, but Swift doesn't provide as excellent support for Promises as Node. Additionally, Firebase itself requires the `@escaping` callback syntax. 

Because the object of an `ImageFetcher` doesn't need to be interacted with, `ImageFetcher`'s can be sensibly initialized as such:

```swift
let _ = ImageFetcher(references: decodedResponse.getReferences(), function: self.update, result: decodedResponse)
```

### Singletons

For stateful processes that aren't publishing changes directly to `View`s the singleton design pattern is quite useful, though certainly easy to abuse. It's power (and potential to be abused) comes from the fact that is essentially a global variable. 

A good example of a singleton is the image `Cache` itself, defined here:

```swift
class Cache: NSDiscardableContent {
    static let instance = Cache()
    private init() { }

    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()

    func addImage(image: UIImage, name: String) {
        imageCache.setObject(image, forKey: name as NSString)
    }

    func removeImage(name: String) {
        imageCache.removeObject(forKey: name as NSString)
    }

    func getImage(name: String) -> UIImage? {
        return imageCache.object(forKey: name as NSString)
    }

    func isInCache(id: String) -> Bool {
        if let _ = Cache.instance.getImage(name: id) {
            return true
        } else {
            return false
        }
    }

    func beginContentAccess() -> Bool {
        return true
    }

    func endContentAccess() {

    }

    func discardContentIfPossible() {

    }

    func isContentDiscarded() -> Bool {
        return false
    }
}
```

This `Cache` singleton is basically a key-value store that accepts `String`s as keys and `UIImage`s for values. The several empty methods at the end of the class are needed so I can conform to the `NSDiscardableContent` protocol. 

A set of useful singletons have to do with storing bits of essential user information on the device--things like the `userID`. Because the front-end needs to provide the backend with a `userID` to get any information, it is essential that this is persisted securely, as it can't be fetched from my server. To serve this need, I defined a `StringStorage` super class that works with the Keychain to securely save strings to the device.

```swift
class StringStorage {
    var string: String?
    let service: KeychainHelper.Services
    
    init(service: KeychainHelper.Services) {
        self.string = nil
        self.service = service
    }
    
    
    func get() -> String? {
        if let _ = self.string {
            
            
        } else if let string = KeychainHelper.standard.read(service: service) {
            self.string = string
        }
        
        return self.string
    }
    
    func ensureExists(string: String) {
        
        if self.string == nil {
            self.string = string
        }
        
        KeychainHelper.standard.ensureExists(service: self.service, value: string)
    }
    
    func set(string: String)  {
        self.string = string
        KeychainHelper.standard.save(service: self.service, value: string)
    }
    
    func update(string: String) {
        self.string = string
        KeychainHelper.standard.update(service: self.service, newValue: string)
    }
    
    func reset() {
        self.string = nil
    }
    
    func display() {
        print(service.rawValue)
        if let string = self.string {
            print(string)
        } else {
            print("Nil")
        }
    }
}
```

Though the Keychain (also encapsulated as a singleton--the `KeychainHelper`) is what actually secures information to the device, this `StringStorage` singleton is useful because it provides a high-performant, in-memory wrapper layer over the `KeychainHelper`. The `get` method of this class first checks to see if the string exists in memory before even touching the `KeychainHelper`. And if it does need to reach out to the `KeychainHelper`, it makes sure to update itself with the fetched value, so that retrieval is easier next time. Ultimately, the `get` method can't avoid returning an optional, as it could be the case that the desired information is neither in-memory or in the Keychain. This optional is usually force-unwrapped by the caller of the method, as an application crash is more appropriate than providing a useless and hard-to track default value. The reasoning is that if we really do lose a given user's `userID`, it's better to have the app crash so I can easily realize the problem than to provide a default which wouldn't be able to access any information on the backend anyway. 

### Conclusion

Though it's impossible to disucss even every important aspect about my app in this README, I hope you were able to get a sense of Zimmr's design and that my thought process could be communicated. 

















