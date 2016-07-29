//: [Previous](@previous)

import Foundation
import Patterns

/*:
Welcome to ...
---
       _   _       _               _     ___        _
      /_\ | |__ __| |_ _ _ __ _ __| |_  | __|_ _ __| |_ ___ _ _ _  _
     / _ \| '_ (_-<  _| '_/ _` / _|  _| | _/ _` / _|  _/ _ \ '_| || |
    /_/ \_\_.__/__/\__|_| \__,_\__|\__| |_|\__,_\__|\__\___/_|  \_, |
                                                                |__/
     ___      _   _
    | _ \__ _| |_| |_ ___ _ _ _ _
    |  _/ _` |  _|  _/ -_) '_| ' \
    |_| \__,_|\__|\__\___|_| |_||_|
                                                                         
---
The **Abstract Factory** is a set of factories that share a common theme and return a family of related objects. The correct factory is chosen at run-time via a **Factory Producer**.
*/

/*:
       ____         __                ___              __
      / __/__ _____/ /____  ______ __/ _ \_______  ___/ /_ _________ ____
     / _// _ `/ __/ __/ _ \/ __/ // / ___/ __/ _ \/ _  / // / __/ -_) __/
    /_/  \_,_/\__/\__/\___/_/  \_, /_/  /_/  \___/\_,_/\_,_/\__/\__/_/
                              /___/
---
Example **Factory Producer** with a static **getFactory** method.
*/

/*
    In this example, we have an app that allows the user to save documents, photos etc to either a local file system or a connected remote file system like Box, DropBox, Google Drive, etc. The user can configure the app to use either type of file system. An abstract file factory returns the correct concrete factory for the type of file system. For local file system it returns a concrete factory capable of handling local files and directories. For remote (in this case Box) it returns a concrete factory that can handle remote files and directories. The application file system then interacts with the generic interfaces without ever knowing whether the file system is local or remote.
*/

//: Context object. In this example, a view model. 

struct FileSystemViewModel : FactoryContext {
    var isRemoteFileSystem:Bool
}
//: Factory Producer

struct FileFactoryProducer : FactoryProducer {
    typealias FactoryContext = FileSystemViewModel
    typealias AbstractFactory = FileFactory
    static func getFactory(context: FactoryContext) -> AbstractFactory {
        if context.isRemoteFileSystem {
            return BoxFileFactory()
        } else {
            return LocalFileFactory()
        }
    }
}

/*:
       ___   __       __               __  ____         __
      / _ | / /  ___ / /________ _____/ /_/ __/__ _____/ /____  ______ __
     / __ |/ _ \(_-</ __/ __/ _ `/ __/ __/ _// _ `/ __/ __/ _ \/ __/ // /
    /_/ |_/_.__/___/\__/_/  \_,_/\__/\__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                                  /___/
---
Example **Abstract Factory**. The concrete factories are returned from the **Factory Producer** and provide an interface of **Factory Methods** that the client can use to get implementation types.
*/

//: Context object. Some file meta data.

struct FileMeta : FactoryContext {
    var name:String
    var parent:Directory?
}

//: Abstract Factory:

// Protocol for the concrete factories.
// Each 'create' method return protocols for the types the client needs.

protocol FileFactory : AbstractFactory {
    
    func createFile(context: FileMeta) -> File
    func createDirectory(context: FileMeta) -> Directory
    
    func createFileTree() -> Directory
}

// Concrete factory for local files..

struct LocalFileFactory : FileFactory {
    
    func createFile(var context: FileMeta) -> File {
        let file = LocalFile(name: context.name, parent: context.parent)
        context.parent?.addChild(file)
        return file
    }
    
    func createDirectory(var context: FileMeta) -> Directory {
        let directory = LocalDirectory(name: context.name, parent: context.parent)
        context.parent?.addChild(directory)
        return directory
    }
    
    func createFileTree() -> Directory {
        // Walk the local file system, build out nodes and return the root directory
        // ...
        
        // Fake file system:
        let root = LocalDirectory(name: "Local Root", parent: nil)
        createFile(FileMeta(name: "File 1", parent: root))
        createFile(FileMeta(name: "File 2", parent: root))
        
        let subDirectory = createDirectory(FileMeta(name: "Local Sub Folder", parent: root))
        createFile(FileMeta(name: "File 3", parent: subDirectory))
        
        return root
    }
}

// .. and remote files.

struct BoxFileFactory : FileFactory {
    
    func createFile(var context: FileMeta) -> File {
        let file = BoxFile(name: context.name, parent: context.parent)
        context.parent?.addChild(file)
        return file
    }
    
    func createDirectory(var context: FileMeta) -> Directory {
        let directory = BoxDirectory(name: context.name, parent: context.parent)
        context.parent?.addChild(directory)
        return directory
    }
    
    func createFileTree() -> Directory {
        // Retreive Box file system meta data from server, build out nodes and return root
        // ...
        
        // Fake file system:
        let root = BoxDirectory(name: "Box Root", parent: nil)
        createFile(FileMeta(name: "Box File", parent: root))
        
        let subDirectory = createDirectory(FileMeta(name: "Box Folder", parent: root))
        createFile(FileMeta(name: "Other Box File", parent: subDirectory))

        return root
    }
}

//: Concrete Types, files and directories, local and remote.

// Generic file.

protocol File : CustomStringConvertible {
    var name:String { get set }
    var parent:Directory? { get set }
    init(name: String, parent: Directory?)
}

// (debug purposes only)

extension File {
    var description:String {
        if self is Directory {
            var names = "\n'\(name)' >"
            for child:File in (self as! Directory).children {
                if child is Directory {
                    names = "\(names)\n"
                }
                names = "\(names) \(child)"
            }
            return names
        } else {
            return "'\(name)'" //'
        }
    }
}

// Generic directory.

protocol Directory : File {
    var children:Array<File> { get set }
    mutating func addChild(child: File)
}

extension Directory {
    mutating func addChild(child: File) {
        children.append(child)
    }
}

// Some concrete types representing a file system.
// These are the actual types returned from the concrete factories.

class BaseFile : File {
    var name:String = "Untitled"
    var parent:Directory?
    required init(name: String, parent: Directory?) {
        self.name = name
        self.parent = parent
    }
}

class LocalFile : BaseFile {
    
}

class BoxFile : BaseFile {
    
}

class LocalDirectory : LocalFile, Directory {
    // Use Directory protocol ^^ instead of weasel property isDirectory:Bool.
    // The language lets us ask: "if myFile is Directory" which is much better.
    var children:Array<File> = []
}

class BoxDirectory : BoxFile, Directory {
    var children:Array<File> = []
}

/*:
    --.--          |
      |  ,---.,---.|--- ,---.
      |  |---'`---.|    `---.
      `  `---'`---'`---'`---'
---
Test file system using the correct abstract file factory.
*/

// Struct representing a file system that is agnostic to local
// or remote files because it only interfaces with the abstract 
// file factory and the file/directory protocols.

struct FileSystem {
    
    typealias FactoryContext = FileSystemViewModel
    
    let root:Directory
    
    init(factory: FileFactory) {
        root = factory.createFileTree()
        print(root)
    }
    
    // useful file system methods go here
}

// Create some file systems.


// Approach #1. Using dependency injection.
// Factory might be determined from configuration.

print("Test local file factory:")
// 
// let fileFactory = AbstractFileFactory.getFactory(Configuration.instance)
let localFiles = FileSystem(factory: LocalFileFactory())


// Approach #2. Using context object (view model in this example).
// Factory is determined based on current view.

print("\n\nTest remote file factory:")

let viewModel = FileSystemViewModel(isRemoteFileSystem: true)

let fileFactory = FileFactoryProducer.getFactory(viewModel)

let boxFiles = FileSystem(factory: fileFactory)
// ^ Note, even though the variable is called "boxFiles" nowhere here
// is it implied that we are going to interact with Box files. It could be
// local files, or DropBox, or Google Drive, or whatever.


/*:
       ___   __       __               __  ____         __
      / _ | / /  ___ / /________ _____/ /_/ __/__ _____/ /____  ______ __
     / __ |/ _ \(_-</ __/ __/ _ `/ __/ __/ _// _ `/ __/ __/ _ \/ __/ // /
    /_/ |_/_.__/___/\__/_/  \_,_/\__/\__/_/  \_,_/\__/\__/\___/_/  \_, /
                                                                  /___/
        __     ___           __       __
     __/ /_   / _ \_______  / /____  / /___ _____  ___
    /_  __/  / ___/ __/ _ \/ __/ _ \/ __/ // / _ \/ -_)
     /_/    /_/  /_/  \___/\__/\___/\__/\_, / .__/\__/
                                       /___/_/
---
Example **Abstract Factory** combined with **Prototype** pattern.
*/

/*
    In this example we have a diagramming application that is capable of making circles and squares. Of course, in real life there would be many other shapes. (In fact, it is the very potential for explosion of new types that demands a reusable solution.) These shapes can be selected from one of three pallettes. Plain shapes, filled shapes and shapes with shadows. Each of these "decorated" types represents a family of objects, which suits the Abstract Factory pattern. The application code would then interact with the generic shapes without needing to concern itself with which ones are decorated or how.
    This example further demonstrates Prototype pattern by initializing a tool box for each pallette, preloaded with the correctly decorated shape prototypes. The user can then select (drag) a shape onto the canvas, which will create a copy (prototype) of that shape including whatever decoration it has.
    Exercise for the reader: what pattern could be used to simplify how shapes are decorated? Hint: the answer is in the question. ;)
*/

//: Context Object. The tool box of decorated shapes.

struct ToolboxViewModel : FactoryContext {
    enum Decoration {
        case None, Filled, FilledAndShadowed
    }
    let decoration:Decoration
    var prototypes:[Shape] = []
    init(decoration: Decoration) {
        self.decoration = decoration
        let factory = ShapeFactoryProducer.getFactory(self)
        self.prototypes.append(factory.createCircle())
        self.prototypes.append(factory.createSquare())
    }
}

//: The Abstract Factory.

struct ShapeFactoryProducer : FactoryProducer {
    typealias FactoryContext = ToolboxViewModel
    typealias AbstractFactory = ShapeFactory
    static func getFactory(context: FactoryContext) -> AbstractFactory {
        switch context.decoration {
        case .None :
            return EmptyShapeFactory()
        case .Filled :
            return FilledShapeFactory()
        case .FilledAndShadowed :
            return FilledAndShadowedShapeFactory()
        }
    }
}

//: Abstract Factory

protocol ShapeFactory : AbstractFactory {
    func createCircle() -> Circle
    func createSquare() -> Square
}

//: Concrete factories

struct EmptyShapeFactory : ShapeFactory {
    func createCircle() -> Circle {
        return Circle()
    }
    func createSquare() -> Square {
        return Square()
    }
}

struct FilledShapeFactory : ShapeFactory {
    func createCircle() -> Circle {
        return Circle().fillShape() // <-- note decoration
    }
    func createSquare() -> Square {
        return Square().fillShape()
    }
}

struct FilledAndShadowedShapeFactory : ShapeFactory {
    func createCircle() -> Circle {
        return Circle().fillShapeWithShadow()
    }
    func createSquare() -> Square {
        return Square().fillShapeWithShadow()
    }
}

//: Concrete Types. Shapes that can be decorated.

protocol Shape : AnonymousPrototype {
    func fillShape() -> Self
    func fillShapeWithShadow() -> Self
}

extension Shape {
    func fillShape() -> Self {
        // .. fill the shape ..
        return self
    }
    func fillShapeWithShadow() -> Self {
        // .. fill the shape and apply shadow ..
        return self
    }
}

struct Circle : Shape {
    func clone() -> Circle {
        return self
    }
    func deepClone() -> Circle {
        return self
    }
}

struct Square : Shape {
    func clone() -> Square {
        return self
    }
    func deepClone() -> Square {
        return self
    }
}

//: Client code. The diagram which creates the shape pallettes.

// Note how the diagram can easily load the shape pallettes without concerning
// itself with what prototype shapes are created or how they are decorated.
// (If you're wondering where are the factory calls, see the view model ^^)

struct Diagram {
    let emptyShapes:ToolboxViewModel = ToolboxViewModel(decoration: .None)
    let filledShapes:ToolboxViewModel = ToolboxViewModel(decoration: .Filled)
    let shadowedShapes:ToolboxViewModel = ToolboxViewModel(decoration: .FilledAndShadowed)
    init() {
        
    }
    // .. handle user interaction with the diagram ..
}

//: [Next](@next)
