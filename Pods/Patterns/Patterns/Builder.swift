//
//  Builder.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
     ___      _ _    _
    | _ )_  _(_) |__| |___ _ _
    | _ \ || | | / _` / -_) '_|
    |___/\_,_|_|_\__,_\___|_|


    D E F I N I T I O N
    • A Builder separates the configuration of objects from their creation. It also allows the same construction process to create different concrete types.

    B E N E F I T S
    • Encapsulates the complexity of object setup.
    • Simplifies changes to the configuration of an object by putting it all in one place.
    • Supports dependency injection since an object's state is set from outside (by the Builder).
    • Supports variation of the constructed object based on configuration (i.e. the builder returns an abstract type).

    I M P L E M E N T A T I O N
    • There are 3 players in Builder pattern:
        1. Builder which configures objects
        2. Feeder/Director which passes new state to the Builder
        3. Product which is returned from the Builder

    • Object initialization that is based on configuration (e.g. plist/xml) or have default values can benefit from Builder pattern.
    • Objects that are configured over time (e.g. user provides values in steps) are good candidates for Builder pattern.

    T I P S   &   C A V E A T S
    • Tip: A variation of Builder pattern can be seen in fluent interfaces (i.e. methods that return self). e.g. Builder.setFoo().setBar().build() See https://github.com/vandadnp/swift-weekly/blob/master/issue05/README.md
    • Caveat: Builders may cause state duplication since they hold the state that ultimately is set on the Product object. This means that changes to the Product (e.g. a model) may require changes to the Builder.
    • Lazy vs. Eager builders. A "lazy" builder constructs the object in the build method, at the end of the process. An "eager" builder constructs the object incrementally, as data is added.

*/