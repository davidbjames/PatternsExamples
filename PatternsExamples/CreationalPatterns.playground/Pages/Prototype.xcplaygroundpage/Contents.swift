//: [Table of Contents](Intro)          
//: [Previous](@previous)

import Foundation
import Patterns
import ObjectMapper

/*:
Welcome to ...
---
     ___         _       _
    | _ \_ _ ___| |_ ___| |_ _  _ _ __  ___
    |  _/ '_/ _ \  _/ _ \  _| || | '_ \/ -_)
    |_| |_| \___/\__\___/\__|\_, | .__/\___|
                             |__/|_|
     ___      _   _
    | _ \__ _| |_| |_ ___ _ _ _ _
    |  _/ _` |  _|  _/ -_) '_| ' \
    |_| \__,_|\__|\__\___|_| |_||_|
---
The prototype pattern creates new objects by copying an existing object, known as a prototype.
*/
/*:
       ___           __       __
      / _ \_______  / /____  / /___ _____  ___
     / ___/ __/ _ \/ __/ _ \/ __/ // / _ \/ -_)
    /_/  /_/  \___/\__/\___/\__/\_, / .__/\__/
                               /___/_/
---
Bare bones **Prototype** implementation. (Copy and paste to get started.)
*/

class Thing : NSObject, Prototype {

    required convenience init(clone: Thing) {
        // pass clone state to designated initializers
        self.init()
        // set additional state from clone
    }
    
    required convenience init(deepClone: Thing) {
        // pass deep clone state to designated initializers
        // including (deep) cloning properties if necessary
        self.init()
        // set additional state from clone
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        // defer copy() to copy constructor
        return Thing(clone: self)
    }
}

//: **Prototype** example using two classes to demonstrate *cloning* and *deep cloning*.


class HttpRequest : NSObject, Prototype {
    
    var auth: Authentication
    
    init(auth: Authentication) {
        self.auth = auth
    }
    
    // Required 3 methods to implement Prototype:
    
    required convenience init(clone: HttpRequest) {
        self.init(auth: clone.auth)
    }
    
    required convenience init(deepClone: HttpRequest) {
        // For deep clone create a new instance of the 
        // associated Authentication object and call it's deepClone 
        // initializer so it can further clone downwards.
        let auth = Authentication(deepClone: deepClone.auth)
        self.init(auth: auth)
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        // Override copy to use custom clone or deepClone method
        return HttpRequest(clone: self)
    }
}


class Authentication : NSObject, Prototype {
        
    var headers: [String:String]
    
    required init(headers: [String:String]) {
        self.headers = headers
    }
    
    required convenience init(clone: Authentication) {
        self.init(headers: clone.headers)
    }
    
    required convenience init(deepClone: Authentication) {
        // headers is a dictionary, which is a value type, so already copied
        self.init(headers: deepClone.headers)
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        // Override copy to use custom clone or deepClone method
        return Authentication(clone: self)
    }
    
}

/*:
    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
*/

let headers = ["If-None-Match" : "123"]
let auth = Authentication(headers: headers)
let request = HttpRequest(auth: auth)

let clonedRequest = HttpRequest(clone: request)
request.auth.headers["If-None-Match"] = "456"

// Proof #1
// Changing original request headers alters clone
clonedRequest.auth.headers

let deepClonedRequest = HttpRequest(deepClone: request)
request.auth.headers["If-None-Match"] = "789"

// Proof #2
// Changing original request headers does NOT alter "deep" clone
deepClonedRequest.auth.headers

/*:
       ___       __       ___           __       __
      / _ \___ _/ /____ _/ _ \_______  / /____  / /___ _____  ___
     / // / _ `/ __/ _ `/ ___/ __/ _ \/ __/ _ \/ __/ // / _ \/ -_)
    /____/\_,_/\__/\_,_/_/  /_/  \___/\__/\___/\__/\_, / .__/\__/
                                                  /___/_/
---
**Data prototype** example using two classes to demonstrate *cloning* and *deep cloning*.
*/

// This is nearly identical to Prototype except:
//   a. it takes a data payload instead of the object
//   b. (for this example), it extends Mappable model to be a more
//      realistic implementation.

class Message : NSObject, Mappable, DataPrototype {
        
    // Implicitly unwrapped because it will either exist via explict initialization
    // or via Map object initialization.
    var author: MessageAuthor!
        
    // Self
    // designated initializer if state is known
    init(author: MessageAuthor) {
        self.author = author
        super.init()
    }
    
    // Mappable
    // required initializer if building object from Map
    required init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }

    // DataPrototype
    required convenience init?(clone: Dictionary<String, AnyObject>) {
        let map = Map(mappingType: MappingType.FromJSON, JSONDictionary: clone)
        self.init(map)
    }
    
    // DataPrototype
    required convenience init?(deepClone: Dictionary<String, AnyObject>) {
        let map = Map(mappingType: MappingType.FromJSON, JSONDictionary: deepClone)
        self.init(map)
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        // defer copy() to copy constructor
        let json = Mapper().toJSON(self)
        return Message(clone: json)!
    }
    
    func mapping(map: Map) {
        author <- map["author"]
    }
}

class MessageAuthor : NSObject, Mappable, DataPrototype {
        
    var authorId : String!
    
    init(authorId: String) {
        self.authorId = authorId
        super.init()
    }

    required init?(_ map: Map) {
        super.init()
        self.mapping(map)
    }
    
    required convenience init?(clone: Dictionary<String, AnyObject>) {
        let map = Map(mappingType: MappingType.FromJSON, JSONDictionary: clone)
        self.init(map)
    }
    
    required convenience init?(deepClone: Dictionary<String, AnyObject>) {
        // No deep cloning for this example. See Message ^^
        self.init(clone: deepClone)
    }
    
    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        // Override copy to use custom clone or deepClone method
        let json = Mapper().toJSON(self)
        return MessageAuthor(clone: json)!
    }
    
    func mapping(map: Map) {
        authorId <- map["author_id"]
    }
}

/*:
    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
*/


// ObjectMapper example:

let messageJson = ["author" : ["author_id" : "000"]]
let serverMessage = Mapper<Message>().map(messageJson)
let serverMessageAuthor = serverMessage?.author
serverMessageAuthor?.authorId

let newMessageJson = ["author" : ["author_id" : "001"]]
let clonedServerMessage = Message(clone: newMessageJson)
let clonedServerMessageAuthor = clonedServerMessage?.author

let deepClonedServerMessage = Message(deepClone: newMessageJson)
let deepClonedServerMessageAuthor = deepClonedServerMessage?.author

serverMessageAuthor?.authorId = "002"
// ^^ Alter the deep cloned message's sender

clonedServerMessageAuthor?.authorId
deepClonedServerMessageAuthor?.authorId
// ^^ Neither (cloned or deep cloned) message's sender is affected (both remain "001")
// This is different from a true prototype (first example in this playground)
// because this implementation conforms to ObjectMapper "Mappable" protocol
// which *always* performs the equivalent of a deep clone since it creates all
// sub objects automatically from the provided JSON (which keeps state immutable)
// -- hence, clone and deepClone behave the same i.e. they both act like deepClone.

// This does not mean however that DataPrototype could not be used in a typical prototype sense.


// Example use of copy method (NSObjectProtocol + NSCopying)

let copiedMessage = serverMessage?.copy()
copiedMessage?.author!.authorId

//: [Next](@next)
