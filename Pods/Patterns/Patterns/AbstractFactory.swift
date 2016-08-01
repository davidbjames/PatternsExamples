//
//  AbstractFactory.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
       _   _       _               _     ___        _
      /_\ | |__ __| |_ _ _ __ _ __| |_  | __|_ _ __| |_ ___ _ _ _  _
     / _ \| '_ (_-<  _| '_/ _` / _|  _| | _/ _` / _|  _/ _ \ '_| || |
    /_/ \_\_.__/__/\__|_| \__,_\__|\__| |_|\__,_\__|\__\___/_|  \_, |
                                                                |__/

    D E F I N I T I O N
    • The Abstract Factory is a set of factories that share a common theme and return a family of related objects. The correct factory is chosen at run-time via a factory producer.

    B E N E F I T S
    • Keeps client-supplier relationships loosely coupled where new object families are concerned.
    • Avoids "combinatorial explosion" where many similar types are created independently without a common interface.
    • Supports run-time switching of dependencies.

    I M P L E M E N T A T I O N
    • There are generally 3 players in the Abstract Factory pattern:
        1. Factory Producer with a getFactory() method
        2. Concrete Factories with create methods
        3. Implementation Types that are returned
    • Example: FactoryProducer.getFactory().createThing() returns Thing implementation.

    T I P S   &   C A V E A T S
    • Watch for "switch" or "if/else" statements when deciding the correct abstract factory. This is generally a code smell when it exists in application code. Normally the correct factory should be injected to components that need it or by passing a context object. See also the "general rule" in Factory Method pattern.
    • Question: What is the key difference between Factory Method pattern and Abstract Factory pattern?
    • Answer: Factory Method uses inheritance, indirection is vertical. e.g. parent calls createThing(). On the other hand, Abstract Factory uses composition, indirection is horizontal e.g. FactoryProducer.getFactory().createThing().
    • Only use Abstract Factory where there are sets of related objects conforming to known interfaces (e.g. a file system) AND if it makes the architecture easier to read and maintain. The pattern is often confusing to beginners because of the levels of indirection involved.

*/

/*
       ___   __       __               __  ____         __
      / _ | / /  ___ / /________ _____/ /_/ __/__ _____/ /____  ______ __
     / __ |/ _ \(_-</ __/ __/ _ `/ __/ __/ _// _ `/ __/ __/ _ \/ __/ // /
    /_/ |_/_.__/___/\__/_/  \_,_/\__/\__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                                  /___/
*/

/**
    Abstract Factory is a factory that conforms to a common interface, usually 
    supporting multiple concrete factories which are *interchangeable* at run time.

    Empty interface. For semantic purposes. Actual implementation will have
    custom "create" methods, createThis(), createThat(), etc.
*/
public protocol AbstractFactory : Factory {
    
}


/*
       ____         __                ___              __
      / __/__ _____/ /____  ______ __/ _ \_______  ___/ /_ _________ ____
     / _// _ `/ __/ __/ _ \/ __/ // / ___/ __/ _ \/ _  / // / __/ -_) __/
    /_/  \_,_/\__/\__/\___/_/  \_, /_/  /_/  \___/\_,_/\_,_/\__/\__/_/
                              /___/
*/

/**
    Factory Producer determines the correct Abstract Factory to return
    based on provided context.
*/
public protocol FactoryProducer {
    /// Context object / tuple that provides the factory with enough
    /// information to make a decision of which concrete factory to
    /// return. See also "general rule" in Factory Method pattern
    associatedtype FactoryContext
    /// Associated Factory that is returned
    associatedtype AbstractFactory
    /// Single getFactory method for obtaining the correct concrete factory.
    /// - parameter: optional context that provides information in
    ///     the decision making process for what factory to return
    /// - return: abstract factory TODO: should this be optional?
    static func getFactory(context: FactoryContext) -> AbstractFactory
}
