//
//  ObjectPool.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
      ___  _     _        _     ___          _
     / _ \| |__ (_)___ __| |_  | _ \___  ___| |
    | (_) | '_ \| / -_) _|  _| |  _/ _ \/ _ \ |
     \___/|_.__// \___\__|\__| |_| \___/\___/_|
              |__/

    D E F I N I T I O N
    • The object pool pattern manages a collection of reusable objects that are provided to calling components. 
    • A component obtains an object from the pool, uses it to perform work, and returns it to the pool so that it can be allocated to satisfy future requests. 
    • An object that has been allocated to a caller is not available for use by other components until it has been returned to the pool.

    B E N E F I T S
    • When many similar objects are needed or initialization is expensive, object pool pattern:
        • Reduces memory footprint
        • Optimizes initialization
        • Improves app performance
    • Object pool also encapsulates object construction.

    I M P L E M E N T A T I O N
    • 
    • Examples can be found in the PatternsExample project.

    T I P S   &   C A V E A T S
    • Cocoa tables and collection views use object pools for cell reuse.
    • Keep object pools as simple as possible and prefer safety over performance.
    • If concurrency is being used then: test, test, test.
    • Concurrency should be used in most cases

*/

/**
    Object Pool protocol.

    All object pools should implement at least this interface.
    Implementing types should be generic with <Resource> as the generic type.
*/
public protocol ObjectPool {
    /// Generic type. Can be any type (not only objects). Use ObjectPoolItem as necessary.
    associatedtype Resource
    /// Check out a resource from the pool if one is available.
    /// This is usually blocking (sync) but doesn't have to be.
    func checkoutResource() -> Resource?
    /// Return a resource back to the pool.
    /// This is usually non-blocking (async).
    func checkin(resource: Resource)
    /// Process all resources currently in the pool.
    /// Be aware the pool may change from what is passed to this method,
    /// if this method is called asynchronously.
    func processPool(callback: [Resource] -> Void)
}

/**
    Object Pool Item protocol.

    Allows items to receive callbacks at specific points in the pool life cycle.
*/
public protocol ObjectPoolItem {
    /// Reset object state so it can be reused
    func prepareForReuse()
}


