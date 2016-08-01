//
//  Prototype.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
     ___         _       _
    | _ \_ _ ___| |_ ___| |_ _  _ _ __  ___
    |  _/ '_/ _ \  _/ _ \  _| || | '_ \/ -_)
    |_| |_| \___/\__\___/\__|\_, | .__/\___|
                             |__/|_|

    D E F I N I T I O N
    • The prototype pattern creates new objects by copying an existing object, known as a prototype.

    B E N E F I T S
    • Avoids expensive initialization
    • Encapsulates object creation in the best place, in the source class itself.

    I M P L E M E N T A T I O N
    • Conform to one of the Prototype protocols.
    • Be sure to create the typealias and copy over the NSCopying snippet. See below.
    • Initializers should be implemented as 'required convenience' for clases and 'required' for structs/enums.
    • Examples can be found in the PatternsExample project.

    T I P S   &   C A V E A T S
    • Be consistent with architecture that requires prototypes. It's better to make all objects of a hierarchy/type conform to prototype instead of only part of the hierarchy, so as not to unecessarily limit the benefits of prototyping. This is particularly true with respect to deep clones.
    • Be aware of the limitations of shallow clones where associated references are not cloned. Consider deep cloning strategy in this case.
    • Be aware of performance impact of deep cloning.
    • Be aware of copy behavior of collection types like Array or NSArray. Just remember to keep knowledge of object construction encapsulated in the class that holds it's properties.
    • For general compatibility, be sure that all prototypes include conformance to NSCopying and that the  implementation calls your own prototype initializers.

    • Prototype requires NSCopying and NSObjectProtocol for general compatibility.
    • Example:

    @objc func copyWithZone(zone: NSZone) -> AnyObject {
        // Override to use custom clone or deepClone method
        return Prototype(clone: self)
    }

*/

/*
     ___       __           _ _
    |   \ ___ / _|__ _ _  _| | |_
    | |) / -_)  _/ _` | || | |  _|
    |___/\___|_| \__,_|\_,_|_|\__|
       ___           __       __
      / _ \_______  / /____  / /___ _____  ___
     / ___/ __/ _ \/ __/ _ \/ __/ // / _ \/ -_)
    /_/  /_/  \___/\__/\___/\__/\_, / .__/\__/
                               /___/_/
*/

/**
    Default prototype is the most basic type of prototype.
    Initializers can copy state and/or change state to default values.

    Pros: Basic out-of-box copying, with advantage of deep copying when needed.
    Cons: Little control over the state of the copied objects
*/
public protocol Prototype : NSCopying, NSObjectProtocol {
    /// Copy over properties from prototype to new instance
    init(clone: Self)
    /// Copy over properties and call clone/deepClone on properties that conform to *Prototype*
    init(deepClone: Self)
}


/*
       ___                                           ___           __       __
      / _ | ___  ___  ___  __ ____ _  ___  __ _____ / _ \_______  / /____  / /___ _____  ___
     / __ |/ _ \/ _ \/ _ \/ // /  ' \/ _ \/ // (_-</ ___/ __/ _ \/ __/ _ \/ __/ // / _ \/ -_)
    /_/ |_/_//_/\___/_//_/\_, /_/_/_/\___/\_,_/___/_/  /_/  \___/\__/\___/\__/\_, / .__/\__/
                         /___/                                               /___/_/
*/

/**
    Anonymous prototype is used when the concrete type is not known, 
    for example, when passing to a class that accepts a generic prototype
    which can't be initialized since the concrete type is not known.

    Pros: More abstract and therefore more flexible for loosely coupled systems.
    Cons: Not the "correct" way of making a copy i.e. does not use copy constructor.
*/
public protocol AnonymousPrototype {
    // Clone method. Use this when the concrete type is not known.
    func clone() -> Self
    // Deep clone method. Use this when the concrete type is not know.
    func deepClone() -> Self
}

/*
       ___       __       ___           __       __
      / _ \___ _/ /____ _/ _ \_______  / /____  / /___ _____  ___
     / // / _ `/ __/ _ `/ ___/ __/ _ \/ __/ _ \/ __/ // / _ \/ -_)
    /____/\_,_/\__/\_,_/_/  /_/  \___/\__/\___/\__/\_, / .__/\__/
                                                  /___/_/
*/

/** 
    Data prototype supports adhoc data in the form of key value pairs.
    Initializers can populate state on copies based on this data.

    Pros: Provides more control over mutation of clones. Plays nicely
    with model libraries like ObjectMapper which handle state restoration.
    Cons: If not using a mapping strategy, can create a dependency between 
    calling code <-> instances on the properties/keys and values required 
    to create state.
*/
public protocol DataPrototype : NSCopying, NSObjectProtocol  {
    // Copy over properties from prototype to new instance
    // Failable if data cannot be converted over to prototype
    init?(clone: Dictionary<String, AnyObject>)
    // Copy over properties and call clone/deepClone on properties that conform to *Prototype
    // Failable if data cannot be converted over to prototype
    init?(deepClone: Dictionary<String, AnyObject>)
}

/** 
    Interpreted/mapped prototype. Conceptual. 
    The idea is to use an "interpreter" to map adhoc data to properties.
    public protocol InterpreterPrototype
*/
