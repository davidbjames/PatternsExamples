//
//  DependencyInjection.swift
//  Patterns
//
//  Copyright © 2016 David James. All rights reserved.
//

import Foundation

/*
     ___                        _
    |   \ ___ _ __  ___ _ _  __| |___ _ _  __ _  _
    | |) / -_) '_ \/ -_) ' \/ _` / -_) ' \/ _| || |
    |___/\___| .__/\___|_||_\__,_\___|_||_\__|\_, |
             |_|                              |__/
     ___       _        _   _
    |_ _|_ _  (_)___ __| |_(_)___ _ _
     | || ' \ | / -_) _|  _| / _ \ ' \
    |___|_||_|/ \___\__|\__|_\___/_||_|
            |__/

    D E F I N I T I O N
    • Dependency Injection provides that object dependencies (aka properties) are injected onto the objects that need them. Objects do not create their own dependencies.

    B E N E F I T S
    • Decouples an object's use of a known API from the creation of the object that conforms to that API.

    I M P L E M E N T A T I O N
    • DI can be implemented via environment specific configuration. DI containers follow this pattern often using XML files which hold the dependency graph.
    • DI objects can be lazy loaded or eager loaded depending on the need.

    T I P S   &   C A V E A T S
    • Also known as Inversion of Control (SOLID), or Holywood pattern ("Don't call us, we'll call you.").

*/