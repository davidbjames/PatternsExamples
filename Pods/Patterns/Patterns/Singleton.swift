//
//  Singleton.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
     ___ _           _     _
    / __(_)_ _  __ _| |___| |_ ___ _ _
    \__ \ | ' \/ _` | / -_)  _/ _ \ ' \
    |___/_|_||_\__, |_\___|\__\___/_||_|
               |___/

    D E F I N I T I O N
    • The singleton pattern ensures that only one object of a given type exists in the application

    B E N E F I T S
    • Encapsulates shared and global resources (such as logging, analytics or app preferences) that should be handled consistently throughout the app.
    • Mimics a resource (such as a server, printer or current device) that could not exist apart from it's real-world counterpart.

    I M P L E M E N T A T I O N
    • Conform to the Singleton protocol even though it doesn't do anything right now.
    • Examples can be found in the PatternsExample project.

    T I P S   &   C A V E A T S
    • Keep singletons thread-safe so that they can be used efficiently.
    • Singletons should not be copyable.
    • Be careful how tightly coupled singletons are to application logic, which includes conditional logic
      based on global state. Consider the possibility of abstracting out this logic into a service layer.
*/

/**
    Standard Swift singleton

    Implementations should use a constant instead of a variable
    and designated initializer should be private.
*/
public protocol Singleton {
    /// Single instance
    static var instance:Self { get }
    // in practice this s/b a constant (i.e. let)
}
