//: [Table of Contents](Intro)          
//: [Previous](@previous)

import Foundation
import Patterns

/*:
Welcome to ...
---
     ___ _           _     _
    / __(_)_ _  __ _| |___| |_ ___ _ _
    \__ \ | ' \/ _` | / -_)  _/ _ \ ' \
    |___/_|_||_\__, |_\___|\__\___/_||_|
               |___/
     ___      _   _
    | _ \__ _| |_| |_ ___ _ _ _ _
    |  _/ _` |  _|  _/ -_) '_| ' \
    |_| \__,_|\__|\__\___|_| |_||_|
---
The singleton pattern ensures that only one object of a given type exists in the application.
*/

//: Standard **Singleton** implementation

final class OnlyOne : Singleton {
    
    static let instance = OnlyOne()
    
    private init() {
        
    }    
}

//: **Singleton** that implements **Worker** protocol

final class Analytics : Singleton, Worker {
    
    static let instance = Analytics()
    
    private init() {
        
    }
    
    lazy private var concurrentQueue:dispatch_queue_t = {
        return dispatch_queue_create("com.davidbjames.queues.analytics.concurrent", DISPATCH_QUEUE_CONCURRENT)
    }()
    
    func doWork(job: Job) {
        dispatch_barrier_async(concurrentQueue) { () -> Void in
            job.perform()
        }
    }
    
    func trackPageView(pageName: String) {
        doWork(AnalyticsPageViewTracker(name: pageName, data: ["foo": "bar"]))
    }
}

private struct AnalyticsPageViewTracker : StatefulJob {
    
    let state:JobState = JobState(repeatable: false)
    
    let name:String
    
    let data:Dictionary<String,String>
    
    func perform() {
        internalPerform { () -> Void in
            print("Tracking page view: \"\(self.name)\"")
        }
    }
}

//: Thread-safe **Singleton**

final class Logger : Singleton {
    
    static let instance = Logger()
    
    var items: Array<String>
    
    var dispatchQueue = dispatch_queue_create("com.davidbjames.logger.queues.concurrent", DISPATCH_QUEUE_CONCURRENT)
    
    private init() {
        self.items = []
    }

    func log(item: String) {
        // For read/write safety, we use barrier here to make sure application does
        // not crash if the array is changed while output items is iterating.
        dispatch_barrier_async(dispatchQueue) { () -> Void in
            self.items.append(item)
        }
    }
    
    func outputItems() {
        dispatch_barrier_async(dispatchQueue) { () -> Void in
            for item:String in self.items {
                print("Logging item: \(item)")
            }
        }
    }
}

/*:
    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
*/

let analytics = Analytics.instance
analytics.trackPageView("Main Page")
analytics.trackPageView("Detail Page")

let logger = Logger.instance
logger.log("one")
logger.log("two")
logger.outputItems()

//dispatch_barrier_async(logger.dispatchQueue) { () -> Void in
//    print(logger.items)
//}


//: [Next](@next)
