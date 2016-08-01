//
//  Factory.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
     ___        _                  __  __     _   _            _
    | __|_ _ __| |_ ___ _ _ _  _  |  \/  |___| |_| |_  ___  __| |
    | _/ _` / _|  _/ _ \ '_| || | | |\/| / -_)  _| ' \/ _ \/ _` |
    |_|\__,_\__|\__\___/_|  \_, | |_|  |_\___|\__|_||_\___/\__,_|
                            |__/
    
    D E F I N I T I O N
    • The Factory Method creates objects that satisfy a known interface, without calling code knowing what concrete types were used or the process by which they were selected
    • "Purist" definition: The factory method defines an interface for creating objects, but let subclasses decide which classes to instantiate. The factory method lets a class defer instantiation to subclasses.

    B E N E F I T S
    • Keeps client-supplier relationships loosely coupled where new objects are concerned, particularly objects that conform to a known interface.
    • Simplifies creational logic for many sub-types by consolidating it in a single method.

    I M P L E M E N T A T I O N
    • The four main types of Factory Method pattern:
      1. "Static wrapper" uses a simple class or struct with a static method to create the desired object. It takes context parameters to support "decision logic" (i.e. what concrete type to return).
      2. "Static hierarchy" uses a class hierarchy with static methods where the parent class defers actual creation to child sub-classes (static methods) that create their own type and initialize. It takes context parameters to support "decision logic".
      3. "Stateful wrapper" uses a class or struct with a non-static create method. The state of the wrapper (i.e. it's properties) provide the context to support "decision logic" (i.e. what concrete type to return).
      3. "Pure factory" uses an abstract class with abstract methods that return the correct sub-types for the parent class to use. There are no static methods in this pattern and generally no "decision logic".

    T I P S   &   C A V E A T S
    • "Class cluster" is similar to Factory Method pattern -- concrete classes are hidden and clients work only with a common interface.
    • General rule: the client should have no knowledge of which implementation it wants, i.e. the parameters passed to the Factory Method should not imply knowledge of the concrete type that is returned. For example, imagine a factory that returns a synchronous or asynchronous dispatch queue via a method called dispatchFactory. Using a call such as dispatchFactory("async") would contradict the general rule, because the argument implies knowledge of what kind of dispatch queue the client needs i.e. asynchronous. Deciding this is the factory's job. The argument should provide only the "context" by which the factory method can make a logical decision. This keeps client code type-agnostic and free from messy decision logic. On the other hand, making adhoc factory methods that only centralize object creation and nothing else is really just "functional decomposition" -- an anti-pattern.

*/

/*
       ____         __
      / __/__ _____/ /____  ______ __
     / _// _ `/ __/ __/ _ \/ __/ // /
    /_/  \_,_/\__/\__/\___/_/  \_, /
                              /___/
*/

/**
    For future compatibility, do not use. Use sub-types instead.
*/
public protocol Factory {

}


/*
       ______       __  _     ____         __
      / __/ /____ _/ /_(_)___/ __/__ _____/ /____  ______ __
     _\ \/ __/ _ `/ __/ / __/ _// _ `/ __/ __/ _ \/ __/ // /
    /___/\__/\_,_/\__/_/\__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                     /___/

*/

/**
    A static factory uses only static or class methods and supports either
    a "static wrapper" (one struct / method) or a "static hierarchy" of factories, 
    Use the hiearchy approach if sub types have specific initialization requirements
    OR if those sub types have their own sub-types which must be handled.
*/
public protocol StaticFactory : Factory {
    /// Some context object / tuple that provides the factory with 
    /// enough information to make a decision without being explicit.
    /// See also "general rule" above.
    associatedtype FactoryContext
    /// Some known interface
    associatedtype KnownInterface
    /// Single create method which takes context and returns the known interface
    static func create(context: FactoryContext) -> KnownInterface?
}


/*
       ______       __      ___     ______         __
      / __/ /____ _/ /____ / _/_ __/ / __/__ _____/ /____  ______ __
     _\ \/ __/ _ `/ __/ -_) _/ // / / _// _ `/ __/ __/ _ \/ __/ // /
    /___/\__/\_,_/\__/\__/_/ \_,_/_/_/  \_,_/\__/\__/\___/_/  \_, /
                                                             /___/

*/

/**
    A stateful factory is a wrapper object that holds enough state
    to enable it's create method to return the correct concrete object.
    Therefore, no FactoryContext is used -- the object is the context.
    This is an alternative to the static factory. Stateful factory logic is
    usually more complex.

*/
public protocol StatefulFactory : Factory {
    /// Some known interface
    associatedtype KnownInterface
    /// Single create method which returns the known interface
    func create() -> KnownInterface?
}


/*
       ___               ____         __
      / _ \__ _________ / __/__ _____/ /____  ______ __
     / ___/ // / __/ -_) _// _ `/ __/ __/ _ \/ __/ // /
    /_/   \_,_/_/  \__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                /___/

*/

/**
    A pure factory uses non-static methods to return sub-types (via inheritance)
    required by the current type. This is the traditional Factory Method.

    The "class" requirement means this only works with classes/inheritance.

    There is no interface to this as it returns specific sub-types known
    to the factory class, e.g. createFile, createDirectory.
    For semantic purposes only.
*/
public protocol PureFactory : class, Factory {
    
}


/**
    Context object that enables the factory to make a decision
    as to what concrete type to return.
 
    Empty interface. Used for semantic purposes only.
*/
public protocol FactoryContext {
    
}
