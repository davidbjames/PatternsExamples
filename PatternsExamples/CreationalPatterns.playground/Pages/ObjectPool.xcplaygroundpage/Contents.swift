//: [Previous](@previous)

import Foundation
import Patterns

/*:
Welcome to ...
---

      ___  _     _        _     ___          _
     / _ \| |__ (_)___ __| |_  | _ \___  ___| |
    | (_) | '_ \| / -_) _|  _| |  _/ _ \/ _ \ |
     \___/|_.__// \___\__|\__| |_| \___/\___/_|
              |__/
     ___      _   _
    | _ \__ _| |_| |_ ___ _ _ _ _
    |  _/ _` |  _|  _/ -_) '_| ' \
    |_| \__,_|\__|\__\___|_| |_||_|

---
The object pool pattern manages a collection of reusable objects that are provided to calling components.
*/
//: Example **Object Pool Item**, which is also a **Prototype** object for reuse

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
        
    // ObjectPoolItem
    
    func prepareForReuse() {
        
    }
    
    // AnonymousPrototype
    
    func clone() -> AnonymousPrototype {
        return Tool(type: self.type)
    }
    
    func deepClone() -> AnonymousPrototype {
        return Tool(type: self.type)
    }
}

//: Mock rental store that has *eager loaded* **Object Pools** of available tools for rental.

class ToolRentalStore {

    let hammerPool: EagerPool<Tool>
    let screwdriverPool: EagerPool<Tool>
    let filePool: EagerPool<Tool>
    
    init() {
        // build up a fake tool store with a limited number of each tool
        var hammers = [Tool]()
        var screwdrivers = [Tool]()
        var files = [Tool]()
        
        let hammer = Tool(type: .Hammer)
        let screwdriver = Tool(type: .ScrewDriver)
        let file = Tool(type: .File)
        
        for var i = 0; i < 3; i++ {
            // example use of Prototype pattern!
            hammers.append(Tool(clone: hammer))
            screwdrivers.append(Tool(clone: screwdriver))
            files.append(Tool(clone: file))
        }
        
        // Initialize the pools
        self.hammerPool = EagerPool<Tool>(resources: hammers)
        self.hammerPool.maxTimeOut = 2.0
        
        self.screwdriverPool = EagerPool<Tool>(resources: screwdrivers)
        self.screwdriverPool.maxTimeOut = 2.0
        
        self.filePool = EagerPool<Tool>(resources: files)
        self.filePool.maxTimeOut = 2.0
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

    func debug() {
        debugToolRentals(hammerPool, screwdriverPool: screwdriverPool, filePool: filePool)
    }

}

//: Mock rental store that has *lazy loaded* **Object Pools** that create tools based on demand.

class ToolRentalStore2 {
    
    let hammerPool: LazyPool<Tool>
    let screwdriverPool: LazyPool<Tool>
    let filePool: LazyPool<Tool>
    
    init() {
        // demonstrates two approaches to Lazy pool, anonymous prototype and factory:
        self.hammerPool = LazyPool<Tool>(maxResources: 3, prototype: Tool(type: .Hammer))!
        self.screwdriverPool = LazyPool<Tool>(maxResources: 3, factory: { () -> Tool in
            ToolRentalStore2.fetchTool(.ScrewDriver)
        })
        self.filePool = LazyPool<Tool>(maxResources: 3, factory: { () -> Tool in
            ToolRentalStore2.fetchTool(.File)
        })
    }
    
    func poolByType(type: Tool.ToolType) -> LazyPool<Tool> {
        switch type {
        case .Hammer :
            return hammerPool
        case .ScrewDriver :
            return screwdriverPool
        case .File :
            return filePool
        }
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
    
    internal static func fetchTool(type: Tool.ToolType) -> Tool {
        // Swift tip. ^^ this must be static (or an independent function) in order for
        // init() to compile because the LazyPool creation cannot contain a closure that
        // has reference to self because self is not initialized at that point.
        switch type {
        case .Hammer :
            return Tool(type: .Hammer)
        case .ScrewDriver :
            return Tool(type: .ScrewDriver)
        case .File :
            return Tool(type: .File)
        }
    }
    
    func debug() {
        debugToolRentals(hammerPool, screwdriverPool: screwdriverPool, filePool: filePool)
    }
}

func debugToolRentals<P:ObjectPool>(hammerPool:P, screwdriverPool:P, filePool:P) {
    print("Report:")
    // print out the number of times each tool was rented
    hammerPool.processPool { (hammers) -> Void in
        var i = 0
        for hammer in hammers {
            print("Hammer #\(++i) rented \((hammer as! Tool).numberCheckouts) times")
        }
    }
    screwdriverPool.processPool { (screwdrivers) -> Void in
        var i = 0
        for screwdriver in screwdrivers {
            print("Screw driver #\(++i) rented \((screwdriver as! Tool).numberCheckouts) times")
        }
    }
    filePool.processPool { (files) -> Void in
        var i = 0
        for file in files {
            print("File #\(++i) rented \((file as! Tool).numberCheckouts) times")
        }
    }
}


// Move this into a library
// c/o Stack Overflow:
extension Range {
    var random: Int {
        get {
            var offset = 0
            let start = startIndex as! Int
            let end = endIndex as! Int
            if start < 0 {  // allow negative ranges
                offset = abs(start)
            }
            let min = UInt32(start + offset)
            let max = UInt32(end + offset)
            return Int(min + arc4random_uniform(max - min)) - offset
        }
    }
}

/*:

    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
---
Test concurrent access to pool.
*/
let toolQueue = dispatch_queue_create("com.davidbjames.toolrental.queues.concurrent", DISPATCH_QUEUE_CONCURRENT)
let debugQueue = dispatch_queue_create("com.davidbjames.toolrental.queues.serial", DISPATCH_QUEUE_CONCURRENT)

let dispatchGroup = dispatch_group_create()
let store = ToolRentalStore()

print("\nStarting rental frenzy (eager load)...")

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

print("Rental frenzy now over. 35 rentals.")

store.debug()

///////////

let dispatchGroup2 = dispatch_group_create()
let store2 = ToolRentalStore2()

print("\n\nStarting rental frenzy (lazy load)...")

for i in 1 ... 35 { // 35 rentals
    dispatch_group_async(dispatchGroup2, toolQueue, { () -> Void in
        // 1. Pick a random tool
        let types:[Tool.ToolType] = [.Hammer, .ScrewDriver, .File]
        let type = types[(0...2).random] as Tool.ToolType
        
        // 2. Rent the tool from the store -- *if* it's available
        if let tool = store2.rentTool(type) {
            
            // 3. Create some random sleeps to make sure the order these are fired is random
            //    in order to test concurrent handling.
            NSThread.sleepForTimeInterval(Double(rand() % 2))
            // 4. Now (after sleep period (or not)) return tool back to store.
            store2.returnTool(tool)
        }
    })
}

dispatch_group_wait(dispatchGroup2, DISPATCH_TIME_FOREVER)

print("Rental frenzy now over. 35 rentals.")

store2.debug()

/*
Example output:
Notice that the total number of rentals is correct (sum of times rented),
and more importantly that the number of each tool rented sometimes exceeds the
actual number of tools in stock (there is only 3 of each), showing that the
object pool is reusing items correctly, and safely, even if it involves making
calling code wait for a tool to become available.

Starting rental frenzy...
Rental frenzy now over. 35 rentals.

Hammer #1 rented 2 times
Hammer #2 rented 5 times
Hammer #3 rented 4 times
Screw driver #1 rented 8 times
Screw driver #2 rented 0 times
Screw driver #3 rented 6 times
File #1 rented 3 times
File #2 rented 3 times
File #3 rented 4 times
*/

//: [Next](@next)
