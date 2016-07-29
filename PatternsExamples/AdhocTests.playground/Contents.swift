
import Patterns

//: Basic struct copying/equality test

struct Foo {
    var string:String
    func clone() -> Foo {
        return self
    }
}

extension Foo : Equatable {}
func == (lhs: Foo, rhs: Foo) -> Bool {
    return lhs.string == rhs.string
}

let foo = Foo(string: "hello")
var bar = foo
// Proof #1 - Copy has same internal values, so is equal
foo == bar
// Proof #2 - Change string makes original and copy unequal
bar.string = "goodbye"
foo == bar
// Proof #3 - These are not references! Original not changed. Duh.
foo.string
// Proof #4 - Returning self returns copy
var baz = foo.clone()
baz.string = "ciao"
foo == baz


//: Test equivalence of dispatch queues and WorkQueues

let test1 = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT)
let test2 = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT)

// Proof #1
// Label means nothing, these are separate queues.
test1 === test2


let test3 = test1

// Proof #2
// Assignment is the same queue
test1 === test3


let queue = WorkQueue.concurrentDispatchQueue("name")
    >- { () in print("halo") }
    >- { () in print("goodbye") }

let sameQueue = queue >- { () in print("again!") }

// these are the same
queue
sameQueue

// Proof #3
// Assignment of WorkQueue is the same (and uses the same underlying queue)
// (Uses overloaded identity operator)
queue === sameQueue


