//
//  Worker.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
    __      __       _
    \ \    / /__ _ _| |_____ _ _
     \ \/\/ / _ \ '_| / / -_) '_|
      \_/\_/\___/_| |_\_\___|_|

    D E F I N I T I O N
    • Encapsulate discrete units of work in "jobs" and allow "workers" to perform those jobs.
    • Workers only do jobs that are handed to it. They never do their own work.

    B E N E F I T S
    • Keeps common or repeatable units of work encapsulated and hidden from the application.
    • Provides a consistent interface for dispatching work.
    • Encapsulates state in Job and Worker objects.

    I M P L E M E N T A T I O N
    • 

    T I P S   &   C A V E A T S
    • Jobs should not reference outside state.
    • Jobs are similar to Command pattern in that they use composite types to enapsulate "functions".
    • This pattern was created by David James based on similar patterns:
        • Thread Pool pattern
        • Gearman http://gearman.org/
        • NSOperation (job) + NSOperationQueue (worker)
    • NOTE: Worker pattern is not identical to any of these ^^. Worker pattern has a simpler design.
*/

/*
          __     __
      __ / /__  / /
     / // / _ \/ _ \
     \___/\___/_.__/
*/

/**
    A unit of work.

    Holds the minimum state required to peform work.
    Generally implemented as a value type (struct or enum)
    Should have all state passed/stored, and have no knowledge outside of the job
        or how/when it is dispatched.
*/
public protocol Job {
    /// Perform the work
    func perform()
}

/**
    A unit of work, with additional state tracking which supports
    idempotency, repeatability, max repetitions, etc.
*/
public protocol StatefulJob : Job {
    /// Job state tracks things like done'ness and repeatability
    /// Implementation should make this a constant (let)
    var state:JobState { get }
}

/**
    Extension to StatefulJob
*/
public extension StatefulJob {
    /// Can the job be performed?
    var canPerform:Bool {
        if state.repeatable {
            if let maxRepetitions = state.maxRepetitions {
                return state.numTimesPerformed < maxRepetitions
            } else {
                return true // repeatable, no limit
            }
        } else {
            return state.numTimesPerformed < 1
        }
    }
    /**
        Internal perform method wraps whether it's possible to perform + augments state.
        This extended method also serves to hide state manipulation from the Jobs themselves.
        
        - Parameter perform: closure containing the original Job's perform code.
    */
    func internalPerform(perform:()->Void) {
        if canPerform {
            perform()
            state.numTimesPerformed += 1
        }
    }
}

/*
          __     __   ______       __
      __ / /__  / /  / __/ /____ _/ /____
     / // / _ \/ _ \_\ \/ __/ _ `/ __/ -_)
     \___/\___/_.__/___/\__/\_,_/\__/\__/
*/

/**
    Reusable Job State class

    This helper class is optional and need only be used
    in more advanced use-cases. Consider also using NSOperations.
*/
public class JobState {
    /// Determines if a job can be performed more than once
    var repeatable:Bool
    /// If repeatable, maximum number of times it can be repeated
    /// If not specified the job will be indefinitely repeatable.
    var maxRepetitions:Int?
    /// Number of times the job has been performed
    var numTimesPerformed:Int = 0
    /**
        Create a new JobState
        
        - Parameter repeatable: is job repeatable?
        - if this is false, subsequent calls to perform() are no-op
    */
    public init(repeatable:Bool = false) {
        self.repeatable = repeatable
    }
    /**
        Create new JobState with specific max repititions
        
        - Parameter maxRepetitions: max number of performances
        - Parameter repeatable: is job repeatable?
    */
    public convenience init(maxRepetitions:Int) {
        self.init(repeatable: true)
        self.maxRepetitions = maxRepetitions
    }
}

/*
      _      __         __
     | | /| / /__  ____/ /_____ ____
     | |/ |/ / _ \/ __/  '_/ -_) __/
     |__/|__/\___/_/ /_/\_\\__/_/

*/

/**
    Worker capable of doing one job at a time

    The worker is responsible for how a job is dispatched.
*/
public protocol Worker {
    /**
        Do work for a single job
    */
    func doWork(job: Job)
}

/*
       ____                       ___      __         __
      / __ \__ _____ __ _____ ___/ / | /| / /__  ____/ /_____ ____
     / /_/ / // / -_) // / -_) _  /| |/ |/ / _ \/ __/  '_/ -_) __/
     \___\_\_,_/\__/\_,_/\__/\_,_/ |__/|__/\___/_/ /_/\_\\__/_/
*/

/**
    Worker capable of doing several jobs
*/
public protocol QueuedWorker {
    /**
        Add a job to the queue
    */
    func addJob(job: Job)
    /**
        Cancel all jobs
    */
    func cancelJobs()
    /**
        Delete processed jobs
    */
    func flushJobs()
    /**
        Do work for all jobs queued
    */
    func doWork()
}


/**
    Worker extension provides a basic implementation.
 
    Use this vanilla implementation if the goal is solely to reap the benefits
    of encapsulation and better design without any need for custom dispatching.
 
    Provide your own overrides using dispatch or operation queues as necessary.
 */
public extension Worker {
    /**
        Do work for a single job on the current thread
        with no dispatch queues or operations.
     */
    func doWork(job: Job) {
        job.perform()
    }
}

