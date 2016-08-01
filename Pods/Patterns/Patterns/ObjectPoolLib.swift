//
//  ObjectPool.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
      ___  _     _        _     ___          _   _    _ _
     / _ \| |__ (_)___ __| |_  | _ \___  ___| | | |  (_) |__
    | (_) | '_ \| / -_) _|  _| |  _/ _ \/ _ \ | | |__| | '_ \
     \___/|_.__// \___\__|\__| |_| \___/\___/_| |____|_|_.__/
              |__/

    Collection of reusable pools providing basic out-of-box behavior with thread safety:
    • DefaultPool (not thread safe)
    • ThreadSafePool
    • EagerPool
    • LazyPool
*/

/**
    Default object pool.

    - This is used by all other pools.
    - FIFO ordering
    - Not thread safe. Use other pools for thread safety

    - Parameter Resource: generic type this pool will manage.
      Can be any type including non-objects. Use ObjectPoolItem if necessary.
*/
public class DefaultPool<Resource> : ObjectPool {
    
    /// Core array of resources. Always private. Use protocol methods to access.
    private var resources:[Resource]
    
    /**
        Initialize empty pool.
    */
    public init() {
        self.resources = []
    }
    
    /**
        Initialize with initial resources (eager method).
    
        - Parameter resources: Array of generic type
    */
    public convenience init(resources: [Resource]) {
        self.init()
        self.resources = resources
    }
    
    /**
        Check out a resource from the pool if one is available.
    
        - Returns: Resource if available
    */
    public func checkoutResource() -> Resource? {
        return isEmpty() ? nil : resources.removeAtIndex(0)
    }
    
    /**
        Check a resource back into the pool.
    
        - Parameter resource: generic Resource
    */
    public func checkin(resource: Resource) {
        
        // Allow objects to prepare for reuse.
        if resource is ObjectPoolItem {
            (resource as! ObjectPoolItem).prepareForReuse()
        }
        resources.append(resource)
    }
    
    /**
        Process all resources currently in the pool.
    
        Be aware the pool may change from what is passed to this method,
        if this method is called asynchronously.
    */
    public func processPool(callback: [Resource] -> Void) {
        callback(self.resources)
    }
    
    // Helper functions
    
    /**
        Is the pool empty
    
        - Returns: false if pool is empty
    */
    public func isEmpty() -> Bool {
        return resources.count == 0
    }
}

/**
    Thread safe object pool

    - This is the base class for all thread safe object pools.
    - See also specialized versions e.g. EagerPool, LazyPool, etc
    - These classes should not be used for typing -- use ObjectPool protocol instead.

    - Parameter Resource: generic type this pool will manage.
*/
public class ThreadSafePool<Resource> : ObjectPool {
    
    /**
        Dispatch queue used for checkins/checkouts
        
        - Default queue is serial for maximum safety.
        - Note: label is for debug purposes only and does not tie this queue to another with the same label.
        - Publicly settable to override
        - Use WorkQueue wrapper for all dispatch queues
    */
    public var queue:WorkQueue = WorkQueue.serialDispatchQueue("com.davidbjames.patterns.ThreadSafePool")
    
    /// Maximum time in seconds that the semaphore should wait before failing to provide Resource
    public var maxTimeOut:Double?
    
    /// The pool
    private let pool:DefaultPool<Resource>
    
    /// Semaphore used to make the pool (thread) safe,
    /// i.e. the pool will only attempt returning a resource if one is available
    private let semaphore:dispatch_semaphore_t
    
    /// Maximum time in seconds that the semaphore should wait before failing to provide Resource
    /// Default is to block forever.
    private var maxDispatchTime:dispatch_time_t {
        if let maxTimeOut = maxTimeOut {
            return dispatch_time(DISPATCH_TIME_NOW, Int64(maxTimeOut * Double(NSEC_PER_SEC)))
        } else {
            return DISPATCH_TIME_FOREVER
        }
    }
    
    /**
        Required initializer for all pools
        
        - Parameter pool: The already-loaded pool (eager) or empty pool (lazy)
        - Parameter semaphore: The initialized semaphore with num items in pool (eager) or max items (lazy)
    */
    public required init(pool:DefaultPool<Resource>, semaphore:dispatch_semaphore_t) {
        self.pool = pool
        self.semaphore = semaphore
    }
    
    /**
        Check out a resource from the pool if one is available.
        
        - This method blocks
        
        - Returns: Resource if available
    */
    public func checkoutResource() -> Resource? {
        var resource:Resource?
        if dispatch_semaphore_wait(self.semaphore, maxDispatchTime) == 0 {
            // - This ^^ function returns 0 when the semaphore value is > 0 (success). This may be true immediately if,
            //       - the pool is started with semaphore greater than 0
            //       - the semaphore is currently 0 and it has been signaled changing it's value to 1.
            //   (Note: don't confuse the 0 returned with the semaphore's value)
            // - Max dispatch time is the maximum time this code will block when semaphore == 0 (fail state).
            // - After max time elapses (assuming the semaphore is not signaled) the method fails and returns nil resource.
            // - Dispatch time of FOREVER (default) means this will block indefinitely.
            // - Each "wait" is queued FIFO, so if the semaphore is signaled, subsequent "waits" will block until
            //   the previous "waits" unblock, etc.
            // - Continuing guarantees that there is at least 1 resource available on any thread.
            // - The following code should *always* be fired synchronously to coincide with the synchronicity
            //   of semaphores.
            self.queue >+ { 
                resource = self.pool.checkoutResource()
            }
        }
        return resource
    }
    
    /**
        Check a resource back into the pool
        
        - This method does not block
        
        - Parameter resource: generic Resource
    */
    public func checkin(resource: Resource) {
        self.queue >- { [weak self] () -> Void in
            if let wself = self {
                wself.pool.checkin(resource)
                dispatch_semaphore_signal(wself.semaphore)
            }
        }
    }
    
    /**
        Process all resources currently in the pool.
        - Be aware the pool may change from what is passed to this method,
          if this method is called asynchronously.
        
        - Parameter callback: closure that takes an array of current resources
    */
    public func processPool(callback: [Resource] -> Void) {
        self.queue >|+ { () in callback(self.pool.resources) }
    }
}

/**
    Eager Object Pool

    Use this pool when:
    - the number of required objects is known in advance
    - the objects map to real-world resources or a limited set of resources
    - it is known that at least n resources will be required at some point
    - the objects are not prohibitively expensive to create

    - Parameter Resource: generic type this pool will manage.
*/
public class EagerPool<Resource> : ThreadSafePool<Resource> {
    
    /**
        Required initializer for Eager pools
        
        - Parameter pool: The already-loaded object pool (eager)
    */
    public required init(pool: DefaultPool<Resource>) {
        // Initialize the semaphore with the total resources in pool
        super.init(pool: pool, semaphore: dispatch_semaphore_create(pool.resources.count))
    }
    
    /**
        Convenience initializer with resources
        
        - Parameter resources: An array of generic resources from which to create pool
    */
    public convenience init(resources: [Resource]) {
        self.init(pool: DefaultPool<Resource>(resources: resources))
    }
}

/**
    Lazy Pool

    Use this pool when:
    - The maximum number of resources is known but may not be all needed
    - You want to defer creation of resources as much as possible

    - There are two types of resource creation patterns available:
    - factory method (default initializer)
    - anonymous prototype

    - Parameter Resource: generic type this pool will manage.
*/
public class LazyPool<Resource> : ThreadSafePool<Resource> {
    
    /// The maximum number of resources this pool can create (not necessarily hold)
    /// This should be a "reasonable" number based on application need, often
    /// determined through trial and error. As with all object pools
    /// rigorous testing is advised.
    private var maxResources:Int
    
    /// Closure that returns a newly created Resource
    private var resourceFactory:(() -> Resource)
    
    /// Counter for tracking number created for use with max value
    private var resourcesCreated = 0
    
    /**
        Required initializer with Factory method
        
        - Parameter maxResources: max num resources this pool can create
        - Parameter factory: closure to create new resources
    */
    public required init(maxResources: Int, factory: () -> Resource) {
        self.resourceFactory = factory
        self.maxResources = maxResources
        
        // Start the semaphore with the maximum number of resources that can be created.
        // This essentially allows dispatch_semaphore_wait to not block initially so that resources
        // can be created and returned to the client. This will continue to decrement until
        // 0 is reached at which point the semaphore will block, until a resource is returned
        // and the semaphore is signaled/incremented.
        let semaphore = dispatch_semaphore_create(maxResources)
        
        super.init(pool: DefaultPool<Resource>(), semaphore: semaphore)
    }
    
    /**
        Convenience initializer with Prototype resource
        
        - Alternative approach using a Prototype object for new Resources
        
        - Parameter maxResources: max num resources this pool can create
        - Parameter prototype: Anonymous Prototype instance that will be used to create new resources
        
        - Failable if Prototype does not conform to Resource type
    */
    public convenience init?<P:AnonymousPrototype>(maxResources: Int, prototype: P) {
        if prototype is Resource {
            self.init(maxResources: maxResources) { () -> Resource in
                return prototype.clone() as! Resource
            }
        } else {
            return nil
        }
    }
    
    /**
        Check out a resource from the pool if one is available.
        
        - This method blocks
        - This method overrides the parent to handle object creation if the pool is empty
        
        - Returns: Resource if available
    */
    public override func checkoutResource() -> Resource? {
        var resource:Resource?
        if dispatch_semaphore_wait(semaphore, maxDispatchTime) == 0 {
            // See EagerPool re: this condition ^^
            self.queue >+ { () -> Void in
                if self.pool.isEmpty() && self.canCreateAnotherResource() {
                    // Re this condition ^^. As long as the pool is not empty we always
                    // return one from the pool (else block). This way we're not unecessarily initializing
                    // new resources even if there are only a few resources created. i.e. It's possible
                    // that the max resources will never be reached, which can be a good thing.
                    resource = self.resourceFactory()
                    if resource != nil {
                        self.resourcesCreated += 1
                    }
                } else {
                    resource = self.pool.checkoutResource() // FIFO
                }
            }
        }
        return resource
    }
    
    // Helper functions
    
    /**
        Can we create any more resources?
        - If not, this pool will only return what exists in the pool
          and if nothing more exists, will block.
    */
    private func canCreateAnotherResource() -> Bool {
        return resourcesCreated < maxResources
    }
}
