//
//  ServiceLocator.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
     ___              _          _                 _
    / __| ___ _ ___ _(_)__ ___  | |   ___  __ __ _| |_ ___ _ _
    \__ \/ -_) '_\ V / / _/ -_) | |__/ _ \/ _/ _` |  _/ _ \ '_|
    |___/\___|_|  \_/|_\__\___| |____\___/\__\__,_|\__\___/_|

    D E F I N I T I O N
    • The Service Locator pattern provides access to commonly used Services that conform to known interfaces.

    B E N E F I T S
    •

    I M P L E M E N T A T I O N
    • Consider using Dependency Injection. For example, Services could be created and injected into the Locator on app initialization.
    • Handles not only Singleton objects.
    • Can sometimes fail to "locate" the service object. Consider using Null pattern (or Swift optionals) for these cases.

    T I P S   &   C A V E A T S
    • Similar to Registry/Multiton pattern, except not only singletons are provided.
    • Use this pattern as sparingly as Singletons, because it can create the same kind of global state problems.
    • See also http://www.gameprogrammingpatterns.com/service-locator.html

*/