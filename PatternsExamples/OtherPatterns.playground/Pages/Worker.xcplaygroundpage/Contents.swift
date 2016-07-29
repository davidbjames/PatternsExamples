//: [Previous](@previous)

import Foundation
import Patterns

/*:
Welcome to ...
---
     __      __       _
     \ \    / /__ _ _| |_____ _ _
      \ \/\/ / _ \ '_| / / -_) '_|
       \_/\_/\___/_| |_\_\___|_|

      ___      _   _
     | _ \__ _| |_| |_ ___ _ _ _ _
     |  _/ _` |  _|  _/ -_) '_| ' \
     |_| \__,_|\__|\__\___|_| |_||_|

---
The worker pattern encapsulates units of work ("jobs") and how that work is dispatched ("workers").
*/

//: Bare-bones **Worker** and **Job**

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

MyWorker().doWork(MyJob())

//: Basic **Workers** and **Jobs**: A Printer that does print jobs, and an Adder that prints numbers to the Printer.

class PrintJob : Job {
    var messageToPrint:String?
    init(message: String) {
        self.messageToPrint = message
    }
    func perform() {
        if let message = self.messageToPrint {
            print("Print: \(message)")
        } else {
            print("Print: <no message>")
        }
    }
}

class Printer : Worker {
    let queue:WorkQueue = WorkQueue.concurrentDispatchQueue("com.choaticmoon.patterns.worker.printer")
    func doWork(job: PrintJob) {
        queue >- {  // printing is asynchronous
            job.perform()
        }
    }
}

let printer = Printer()

printer.doWork(PrintJob(message: "Test message"))

class AddOneJob : StatefulJob {
    let state:JobState = JobState(maxRepetitions: 5)
    var num = 0
    func perform() {
        // use internal perform to manage repititions
        internalPerform { [weak self] () -> Void in
            if let wself = self {
                wself.num++
                printer.doWork(PrintJob(message: "\(wself.num)"))
            }
        }
    }
}

class Adder : Worker {
    let queue:WorkQueue = WorkQueue.concurrentDispatchQueue("com.choaticmoon.patterns.worker.adder")
    func doWork(job: Job) {
        queue >+ { // adding is syncronous
            job.perform()
        }
    }
}

let adder = Adder()
let adderJob = AddOneJob()

for var i = 0; i < 10; i++ {
    // Job will only execute 5 times due to JobState max repetitions
    adder.doWork(adderJob)
}

//: **QueuedWorker** and **StatefulJob**. A queue of network workers and network jobs that are guaranteed to only fire once (idempotent)

class IdempotentNetworkJob : StatefulJob, CustomStringConvertible {
    let state:JobState = JobState(repeatable: false)
    let url:NSURL
    var data:NSDictionary?
    var description:String {
        get {
            return url.absoluteString
        }
    }
    init(url: NSURL) {
        self.url = url
    }
    func perform() {
        internalPerform { () -> Void in
            // perform some network operation and store the response in data
            print("Performing: \(self)")
        }
    }
}

class SafeNetworkWorker : QueuedWorker {

    var jobs:[Job] = []
    
    let queue:WorkQueue = WorkQueue.concurrentDispatchQueue("com.davidbjames.patterns.worker.SafeNetworkWorker")

    func addJob(job: Job) {
        jobs.append(job)
    }
    
    func cancelJobs() {
        jobs = []
    }
    
    func flushJobs() {
        jobs = jobs.filter { (job: Job) -> Bool in
            // keep jobs that have not been performed
            return (job as! StatefulJob).canPerform
        }
    }
    
    func doWork() {
        queue >+ { [weak self] in
            if let wself = self {
                for job in wself.jobs {
                    job.perform()
                }
            }
        }
    }
}

let networkWorker = SafeNetworkWorker()

networkWorker.addJob(IdempotentNetworkJob(url: NSURL(string: "http://foo.com")!))
networkWorker.addJob(IdempotentNetworkJob(url: NSURL(string: "http://bar.com")!))

// ... At some point in the code, do the work ...
networkWorker.doWork()

// Add another job
networkWorker.addJob(IdempotentNetworkJob(url: NSURL(string: "http://baz.com")!))

// .. oops, at some other point (i.e. we don't control when), it fires again ...
// Only "baz" will run.
networkWorker.doWork()


// TODO: Add example using NSOperationQueue
/*
struct MyQueuedWorker : QueuedWorker {
    var jobs:[Job] = []
    
}

struct MyJob : Job {
    let state:JobState? = JobState(repeatable: true)
    func perform() {
        internalPerform { () -> Void in
            print("MyJob")
        }
    }
}

struct MyOtherJob : Job {
    let state:JobState? = JobState(maxRepetitions: 2)
    func perform() {
        internalPerform { () -> Void in
            print("MyOtherJob")
        }
    }
}

var worker = MyQueuedWorker()
worker.addJob(MyJob())
worker.doWork()
worker.doWork()
// ^^ since MyJob is repeatable, this will fire the job twice.


var otherWorker = MyQueuedWorker()
otherWorker.addJob(MyOtherJob())
otherWorker.doWork()
otherWorker.doWork()
otherWorker.doWork()
// ^^ since MyOtherJob is max 2 repetitions, the third job will not fire.


*/

//: [Next](@next)
