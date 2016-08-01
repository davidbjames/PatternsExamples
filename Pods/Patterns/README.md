![ViewQuery](./web/PatternsProjectBanner.png) 

Patterns Project
================

What is it?
-----------

The Patterns Project is a repository of *pattern protocols*. (This is a Swift project, but could easily be ported to any language.)

*Pattern protocols* are interfaces that describe the semantics of design patterns. 

**The Patterns Project is aimed at helping developers learn and use design patterns by simply conforming to protocols**. 

Why do this?
------------

In most cases, design patterns are implicitly defined in code with no semantics describing the pattern itself, making it hard to know what pattern is being used or even if a pattern is being used at all! This is not helpful for communicating intent in programs, and has been the main blocker to learning design patterns for decades. 

The Patterns Project is all about overcoming this communication gap by simply **making design patterns explicitly named in code** via pattern protocols. 

Instead of design patterns remaining obscure, they become obvious, to implementers and maintainers. 

Examples
--------

Let's show a few patterns, and see how they become obvious for the: 

* *Implementer*, because the methods are described in the protocol, and for the
* *Maintainer*, because the class/struct is named according to the pattern.

*** 

#### Prototype Pattern

##### Protocol:

Here's a *pattern protocol*. It's just a Swift protocol with some required methods.

~~~Swift
public protocol Prototype : NSCopying, NSObjectProtocol {
    /// Copy over properties from prototype to new instance
    init(clone: Self)
    /// Copy over properties and call clone/deepClone on properties that conform to *Prototype*
    init(deepClone: Self)
}
~~~

##### Implementation:

Implementing is easier than falling off a bicycle. You just implement the required `init` methods.

~~~Swift
class HttpRequest : NSObject, Prototype { 

    var auth: Authentication 

    init(auth: Authentication) {
        self.auth = auth
    }

    required convenience init(clone: HttpRequest) {
        self.init(auth: clone.auth)
    }

    required convenience init(deepClone: HttpRequest) {
        let auth = Authentication(deepClone: deepClone.auth)
        self.init(auth: auth)
    }

    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        return HttpRequest(clone: self)
    }
    
    // .. code for handling request
}
~~~

##### Calling code:

...and *now*, the client code simple consumes that interface. The implementer is not kept in the dark. They know they're dealing with the **Prototype** pattern.

~~~Swift
let headers = ["If-None-Match" : "123"]
let auth = Authentication(headers: headers)

let request1 = HttpRequest(auth: auth)

let request2 = HttpRequest(clone: request1) // << cloning here

// change the Etag on request 2
request2.auth.headers["If-None-Match"] = "456"

// Do something with the requests
~~~

Admittedly, this is not the greatest example, but you get the idea. 

***

#### Worker Pattern

Here's another example using the **Worker** pattern:

##### Protocol:

~~~Swift
public protocol Job {
    /// Perform the work
    func perform()
}

public protocol Worker {
    /// Do work for a single job
    func doWork(job: Job)
}
~~~

##### Implementation:

~~~Swift
struct MyJob : Job {
    func perform() {
        // .. do something useful ..
    }
}

struct MyWorker : Worker {
    func doWork(job: Job) {
        job.perform()
    }
}
~~~

##### Calling code:

~~~Swift
MyWorker().doWork(MyJob())
~~~

Again, a contrived example, but hopefully the idea is sinking in. 🙂

> NOTE: There is no **Worker** pattern in the original Go4 design patterns. That's OK! The Patterns Project is about any pattern, not just the formal patterns. The project goals are essentially: cover the original patterns, update those patterns to work better with modern paradigms and create brand new patterns.

***

#### Object Pool Pattern

One more example. Something a little more powerful. 

##### Protocol:

~~~Swift
public protocol ObjectPool {

    associatedtype Resource

    func checkoutResource() -> Resource?

    func checkin(resource: Resource)
    
    func processPool(callback: [Resource] -> Void)
}

public protocol ObjectPoolItem {

    func prepareForReuse()
}
~~~

##### Implementation:

~~~Swift
public class DefaultPool<Resource> : ObjectPool {

    private var resources:[Resource]

    public init() {
        self.resources = []
    }

    public convenience init(resources: [Resource]) {
        self.init()
        self.resources = resources
    }

    public func checkoutResource() -> Resource? {
        return isEmpty() ? nil : resources.removeAtIndex(0)
    }

    public func checkin(resource: Resource) {

        if resource is ObjectPoolItem {
            (resource as! ObjectPoolItem).prepareForReuse()
        }
        resources.append(resource)
    }

    public func processPool(callback: [Resource] -> Void) {
        callback(self.resources)
    }
}
~~~

The project includes "eager" and "lazy" variations on this that use background threads and semaphores, but we'll keep it simple for now.

##### Calling code:

Notice how we can combine patterns: **Object Pool** + **Prototype**. This is something you'll see a lot in the Patterns Project.

~~~Swift
class Tool : NSObject, ObjectPoolItem, AnonymousPrototype {

    enum ToolType : String {
        case Hammer = "Hammer"
        case ScrewDriver = "Screw Driver"
        case File = "File"
    }

    typealias Prototype = Tool

    var type:ToolType
    var numberCheckouts:Int = 0

    init(type: ToolType) {
        self.type = type
    }

    func prepareForReuse() {
        // prepare prototype for re-use
    }

    func clone() -> AnonymousPrototype {
        return Tool(type: self.type)
    }

    func deepClone() -> AnonymousPrototype {
        return Tool(type: self.type)
    }
}

// Mock rental store that has *eager loaded* **Object Pools** of available tools for rental.

class ToolRentalStore {

    let hammerPool: EagerPool<Tool>
    let screwdriverPool: EagerPool<Tool>
    let filePool: EagerPool<Tool>

    init() {
        // Build a fake tool store with a limited number of each tool
        
        ...

        // Initialize the object pools
        
        ...
    }

    func rentTool(type: Tool.ToolType) -> Tool? {
        if let tool = poolByType(type).checkoutResource() {
            tool.numberCheckouts++
            return tool
        } else {
            return nil
        }
    }

    func returnTool(tool: Tool) {
        poolByType(tool.type).checkin(tool)
    }

    func poolByType(type: Tool.ToolType) -> EagerPool<Tool> {
        switch type {
        case .Hammer :
            return hammerPool
        case .ScrewDriver :
            return screwdriverPool
        case .File :
            return filePool
        }
    }
}

// Tests:

let dispatchGroup = dispatch_group_create()
let store = ToolRentalStore()

for i in 1 ... 35 { // 35 rentals
    dispatch_group_async(dispatchGroup, toolQueue, { () -> Void in
    
        // 1. Pick a random tool
        let types:[Tool.ToolType] = [.Hammer, .ScrewDriver, .File]
        let type = types[(0...2).random] as Tool.ToolType

        // 2. Rent the tool from the store -- *if* it's available
        if let tool = store.rentTool(type) {

            // 3. Create some random sleeps to make sure the order these are fired is random
            //    in order to test concurrent handling.
            NSThread.sleepForTimeInterval(Double((0...1).random))
            
            // 4. Now (after sleep period (or not)) return tool back to store.
            store.returnTool(tool)
        } else {
            // Tool was not available for rent (within the max wait time)
            print("Failed to rent \(type.rawValue)")
        }
    })
}

dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
~~~

Notice how the implementation code and the calling code (in ToolRentalStore) create and consume the Object Pool pattern via a consistent interface, `checkinResource` and `checkoutResource`. New developers to the project can easily know that the Object Pool pattern is being used because the types are named accordingly.

This makes it easier for everyone to embrace and learn patterns.

Examples to the Power of Wow
----------------------------

To really see the pattern protocols in action, visit [Patterns Examples](https://github.com/davidbjames/PatternsExamples) where you'll find Swift Playgrounds with all of the patterns found in this project.

CocoaPods Install
-----------------

Add these lines to your Podfile:

~~~Ruby
source 'https://github.com/davidbjames/CocoaPods-Specs.git'
~~~

~~~Ruby
pod 'Patterns'
~~~

***

Project Status
--------------

At this time, the project contains 90% of the [creational patterns](https://en.wikipedia.org/wiki/Creational_pattern). Due to time constraints I have been unable to finish the remaining patterns (including structural and behavioral). I hope to pick that up again soon. Honestly, I'd like the first stab at getting all the original patterns represented before opening this to contributions, but I'd be interested in hearing any feedback or proposals via the issue navigator!

David James