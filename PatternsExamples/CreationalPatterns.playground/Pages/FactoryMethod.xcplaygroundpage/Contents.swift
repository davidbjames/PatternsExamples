//: [Previous](@previous)

import Foundation
import Patterns

/*:
Welcome to ...
---
     ___        _                  __  __     _   _            _
    | __|_ _ __| |_ ___ _ _ _  _  |  \/  |___| |_| |_  ___  __| |
    | _/ _` / _|  _/ _ \ '_| || | | |\/| / -_)  _| ' \/ _ \/ _` |
    |_|\__,_\__|\__\___/_|  \_, | |_|  |_\___|\__|_||_\___/\__,_|
                            |__/
     ___      _   _
    | _ \__ _| |_| |_ ___ _ _ _ _
    |  _/ _` |  _|  _/ -_) '_| ' \
    |_| \__,_|\__|\__\___|_| |_||_|

---
The **Factory Method** selects and returns a concrete implementation that satisfies a known interface without the client knowing how the decision was made or what concrete class was used.
*/

/*:
       ______       __  _     ____         __
      / __/ /____ _/ /_(_)___/ __/__ _____/ /____  ______ __
     _\ \/ __/ _ `/ __/ / __/ _// _ `/ __/ __/ _ \/ __/ // /
    /___/\__/\_,_/\__/_/\__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                     /___/
---
1. Example **Factory Method** using a *static wrapper*. This is the most basic type of factory.
*/

struct WorkerFactory : StaticFactory {
    
    // Required type aliases that tie the client expected types to protocol conformance.
    // (This Swift feature is essential in many cases for consuming design patterns via protocols.)
    
    typealias FactoryContext = DispatchType
    typealias KnownInterface = Worker

    /**
        The Factory method. Takes a context object and returns
        the correct worker type.
     */
    static func create(context: FactoryContext) -> KnownInterface? {
        if context == .Sync {
            return SyncWorker()
        } else if context == .Async {
            return AsyncWorker()
        } else {
            return nil
        }
    }
}

class AsyncWorker : Worker {
    let queue:WorkQueue = WorkQueue.concurrentDispatchQueue("com.davidbjames.queues.worker")
    func doWork(job: Job) {
        queue >- {
            job.perform()
        }
    }
}

class SyncWorker : Worker {
    let queue:WorkQueue = WorkQueue.concurrentDispatchQueue("com.davidbjames.queues.worker")
    func doWork(job: Job) {
        queue >+ {
            job.perform()
        }
    }
}

// The context object. Not a good example. See "general rule" in protocol file.

enum DispatchType {
    case Sync 
    case Async 
}


class SimpleJob : Job {
    func perform() {
        print("Performing a simple job...")
    }
}

/*:

    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
---
Test Worker Factory returns the correct type.
*/


if let worker = WorkerFactory.create(DispatchType.Sync) {
    // Factory returns a synchronous Worker
    worker.doWork(SimpleJob())
}

if let worker = WorkerFactory.create(DispatchType.Async) {
    // Factory returns an asynchronous Worker
    worker.doWork(SimpleJob())
}

// The weakness in this ^^ implementation (see "general rule") is that the client knows
// which concrete type it wants (sync vs. async). Ideally, the client should not have this knowledge.

/*:
       ______       __  _     ____         __
      / __/ /____ _/ /_(_)___/ __/__ _____/ /____  ______ __
     _\ \/ __/ _ `/ __/ / __/ _// _ `/ __/ __/ _ \/ __/ // /
    /___/\__/\_,_/\__/_/\__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                     /___/ (again)
---
2. Example **Factory Method** using a *static hierarchy*. Supports delegation of object construction to child classes instead of relying solely on a single factory method.
*/
/*
In this example, we have Charts that display analytic data. Each Chart requires Data Sets of certain types in order to translate that data into a visual form (i.e. different chart styles require different data structures). The factory takes the desired Chart and the end-point for the data and returns the correct Data Set.
*/

class DataSet : StaticFactory, CustomStringConvertible {
    
    typealias FactoryContext = (chart: Chart, request: DataRequest)
    typealias KnownInterface = DataSet
    
    let rawData:Dictionary<String,AnyObject>
    
    var description:String {
        return "\(self.rawData)"
    }
    
    internal class func create(context: FactoryContext) -> KnownInterface? {
        if context.chart is PieChart {
            return DataSetPercentSummary.create(context)
        } else if context.chart is ScatterChart {
            return DataSetScatterPeriods.create(context)
        } else {
            return nil 
        }
    }
    
    init(rawData: [String:AnyObject]) {
        self.rawData = rawData
    }

    // ... other methods for consuming and exposing the data set for the chart
}

class DataSetPercentSummary : DataSet {
    
    override class func create(context: FactoryContext) -> KnownInterface? {
        
        // Make sure the request data provided is the correct type for this DataSet type
        // and that the correct type or sub-type is returned.
        
        if let outerData = context.request.data {
            if outerData.indexForKey("percent_based") != nil {
                if let data = outerData["percent_based"] {
                    // Use current class
                    return DataSetPercentSummary(rawData: data as! Dictionary<String,AnyObject>)
                }
            } else if outerData.indexForKey("percent_based_special") != nil {
                if let data = outerData["percent_based_special"] {
                    // Use child class
                    return DataSetPercentSpecialSummary(rawData: data as! Dictionary<String,AnyObject>)
                }
            }
        }
        return nil
    }

    // ... other methods for consuming and exposing the data set for the chart
}

class DataSetPercentSpecialSummary : DataSetPercentSummary {
    
}

class DataSetScatterPeriods : DataSet {
    
    override class func create(context: FactoryContext) -> KnownInterface? {
        if let data = context.request.data?["scatter_data"] {
            return DataSetScatterPeriods(rawData: data as! Dictionary<String,AnyObject>)
        }
        return nil
    }
    
    // ... other methods for consuming and exposing the data set for the chart
    
}

protocol Chart {
    func render(data: DataSet)
}

struct PieChart : Chart {
    func render(data: DataSet) {
        print("Rendering Pie Chart with data \(data).")
    }
}

struct ScatterChart : Chart {
    func render(data: DataSet) {
        print("Rendering Scatter Chart with data \(data).")
    }
}

struct DataRequest {
    let url:String
    var data:Dictionary<String,AnyObject>?
}
/*:
    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
---
Test DataSet Factory returns the correct DataSet types depending on Chart provided.
*/

// Get the correct Data Set ("percent summary") to render a Pie Chart

var pieChart = PieChart()

var pieData = DataRequest(url: "http://my.api.com/endpoint", data: nil)
pieData.data = ["percent_based" : ["some" : "data"]]

if let dataSet = DataSet.create((pieChart, pieData)) {
    pieChart.render(dataSet)
}

// Get the correct Data Set ("scatter periods") to render a Scatter Chart

var scatterChart = ScatterChart()

var scatterData = DataRequest(url: "http://my.api.com/another_endpoint", data: nil)
scatterData.data = ["scatter_data" : ["some" : ["other", "data"]]]

if let dataSet = DataSet.create((scatterChart, scatterData)) {
    scatterChart.render(dataSet)
}

/*:
       ___               ____         __
      / _ \__ _________ / __/__ _____/ /____  ______ __
     / ___/ // / __/ -_) _// _ `/ __/ __/ _ \/ __/ // /
    /_/   \_,_/_/  \__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                /___/
---
3. Example **Factory Method** using a *pure factory*. This is original intent of Factory Method -- i.e. the class would call it's own non-static factory method.
*/
/* 
Note, this example and pattern were created back when class hierarchies were the principle type system. These days, it's generally considered better to use composition instead of inheritance. (The following example ported from Java example on Wikipedia.)
*/

class MazeGame : PureFactory {
    
    var rooms:[Room] = []
    
    init() {
        rooms = [makeRoom()]
    }

    // A true factory method
    func makeRoom() -> Room  {
        // Swift equivalent of an abstract method
        preconditionFailure()
    }
}

class OrdinaryMaze : MazeGame {
    override func makeRoom() -> Room {
        return OrdinaryRoom()
    }
}

class MagicalMaze : MazeGame {
    override func makeRoom() -> Room {
        return MagicRoom()
    }
}

class Room {
    var name:String = ""
}

class OrdinaryRoom : Room {
    override init() {
        super.init()
        self.name = "Ordinary Room 🐶"
    }
}

class MagicRoom : Room {
    override init() {
        super.init()
        self.name = "Magic Room 🐰"
    }
}

/*:
    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
---
Test that mazes use the correct room types.
*/

let ordinaryMaze = OrdinaryMaze()
if let room:Room = ordinaryMaze.rooms[0] {
    print(room.name) // ordinary room
}

let magicalMaze = MagicalMaze()
if let room:Room = magicalMaze.rooms[0] {
    print(room.name) // magic room
}



//: [Next](@next)
