//: [Previous](@previous)

import Foundation
import UIKit
import Patterns

/*:
Welcome to ...
---
     ___      _ _    _
    | _ )_  _(_) |__| |___ _ _
    | _ \ || | | / _` / -_) '_|
    |___/\_,_|_|_\__,_\___|_|

     ___      _   _
    | _ \__ _| |_| |_ ___ _ _ _ _
    |  _/ _` |  _|  _/ -_) '_| ' \
    |_| \__,_|\__|\__\___|_| |_||_|

---
A **Builder** separates the configuration of an object from it's creation or use.
*/

public protocol Builder {
    typealias BuilderProduct
    func build() -> BuilderProduct?
}


public protocol DataBuilder : Builder {
    func setData(data: Dictionary<String, AnyObject>)
}

public protocol FluentBuilder : Builder {
    
}

/*:
       ___       _ __   __
      / _ )__ __(_) /__/ /__ ____
     / _  / // / / / _  / -_) __/
    /____/\_,_/_/_/\_,_/\__/_/

---
1. Example **Builder** that builds user profiles. This is often a stepped process, so the Builder is perfect for this.

Note the build method provides additional logic (around billing address) that is encapsulated away from the client. The client just feeds the builder what it's been given.

This example uses a "lazy" build style. The client adds all the stuffs, and the product is built at the end.
Alternative "eager" builder, builds the product object incrementally as the client adds data.
*/

struct ProfileBuilder: Builder {

    typealias BuilderProduct = UserProfile

    var user:User?
    var shippingAddress:Address?
    var billingAddress:Address?
    var billingSameAsShipping = false
    
    func build() -> BuilderProduct? {
        
        // must have a user
        guard let user = user else {
            print("Warning: ProfileBuilder unable to build UserProfile because User is missing.")
            return nil
        }
        
        // determine billing address
        let billing = billingSameAsShipping || billingAddress == nil ? shippingAddress : billingAddress
        
        // set a default value
        let createdOnMobileApp = true
        
        // create profile
        let profile = UserProfile(user: user, shippingAddress: shippingAddress, billingAddress: billing, createdOnMobileApp: createdOnMobileApp)
        
        return profile
    }
}

struct UserProfile  {
    let user:User
    var shippingAddress:Address?
    var billingAddress:Address?
    var createdOnMobileApp:Bool?
    func save() {
        print("Saving UserProfile:")
        user.save()
        shippingAddress?.save()
        billingAddress?.save()
    }
}

struct User {
    let givenName:String
    let familyName:String
    func save() {
        print(self)
    }
}

struct Address {
    let street:String
    let town:String
    let region:String
    let country:String
    func save() {
        print(self)
    }
}

/*:
    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
*/

var builder = ProfileBuilder()

// STEP 1

builder.user = User(givenName: "David", familyName: "James")

// STEP 2

builder.shippingAddress = Address(street: "Corso V. Emanuele", town: "Fano Adriano", region: "TE", country: "Italy")

// STEP 3
// User decides to use shipping address for billing address

builder.billingSameAsShipping = true

// Create user profile

let profile = builder.build()

// Save user profile

profile?.save()


/*:
       ___       _ __   __
      / _ )__ __(_) /__/ /__ ____
     / _  / // / / / _  / -_) __/
    /____/\_,_/_/_/\_,_/\__/_/   VIA FACTORY

---
2. Example **Builders** that are the product of **Factory Method**

----------------------> TODO <------------------------

*/




/*:
       ______              __  ___       _ __   __
      / __/ /_ _____ ___  / /_/ _ )__ __(_) /__/ /__ ____
     / _// / // / -_) _ \/ __/ _  / // / / / _  / -_) __/
    /_/ /_/\_,_/\__/_//_/\__/____/\_,_/_/_/\_,_/\__/_/

---
3. Example **FluentBuilder**.

----------------------> TODO <------------------------

*/




/*:
       ___       __       ___       _ __   __
      / _ \___ _/ /____ _/ _ )__ __(_) /__/ /__ ____
     / // / _ `/ __/ _ `/ _  / // / / / _  / -_) __/
    /____/\_,_/\__/\_,_/____/\_,_/_/_/\_,_/\__/_/

---
4. Example **DataBuilder**

----------------------> TODO <------------------------

*/

// ============================================
// vvvvvvvvvvvvv PROBABLE CRAP vvvvvvvvvvvvvvvv

protocol UserInterfaceBuilder : Builder {
    // typealias BuilderProduct (inherited)
    var disabled:Bool { get set }
    var color:UIColor { get set }
    var text:String? { get set }
}

struct Director<P:UserInterfaceBuilder> {
    
    typealias BuilderProduct = P
    
    var product:P?
    
    var disabled:Bool = false
    var color:UIColor?
    var text:String?
    
    func build() -> BuilderProduct? {
        // setup button
        return product
    }
}

struct LabelBuilder : UserInterfaceBuilder {
    
    typealias BuilderProduct = UILabel
    
    let product = UILabel()
    
    var disabled:Bool
    var color:UIColor
    var text:String?
    
    func build() -> BuilderProduct? {
        // setup label
        return product
    }
}

var director = Director<LabelBuilder>()
director.disabled = true

let result = director.build()



//: [Next](@next)
