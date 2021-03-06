# Dependency Injection in CoffeeScript

[![Build Status](https://travis-ci.org/vizio360/coffee-sweetener.png)](https://travis-ci.org/vizio360/coffee-sweetener)

**Table of Contents**

 - [coffee-sweetener](#coffee-sweetener)
 - [Installation](#installation)
 - [API](#api)
    - [Let's start with an example](#lets-start-with-an-example)
    - [Create an Injector](#create-an-injector)
    - [.map( mappingObject )](#map-mappingobject-)
        - [Map a module knowing the path](#map-a-module-knowing-the-path)
        - [Map a Class](#map-a-class)
        - [Map a Value](#map-a-value)
    - [.asSingleton()](#assingleton)
        - [Map a Class as a Singleton](#map-a-class-as-a-singleton)
    - [.as( newName )](#as-newname-)
        - [Specifing a name for a mapping](#specifing-a-name-for-a-mapping)
    - [.getInstanceOf( mappingName )](#getinstanceof-mappingname-)
    - [.getClassOf( mappingName )](#getclassof-mappingname-)
    - [.unmap( mappingName )](#unmap-mappingname-)
    - [Fluent API](#fluent-api)
- [Class Injection Points](#class-injection-points)
- [Instance initialisation](#instance-initialisation)

# coffee-sweetener
This is a small utility component that you can use in your applications to ease the management of dependencies between objects.
The idea is simple, you have a factory object (we'll call this the *injector*) where you define some mappings.
Each mapping has a unique id that you define.
From different modules you can query the *injector* to give you a new instance of a specific mapping.
Within classes you can define depenecies which will be satisfied on creation of a new instance of that class.

# Installation
You can install the latest version through npm:
`npm install coffee-sweetener`

# API
## Let's start with an example
```coffeescript
# define a class
class MyClass
    sayYeah: ->
        console.log "YEAH!"
# get the Injector
CoffeeSweetener = require "coffee-sweetener"
Injector = new CoffeeSweetener()

# map MyClass in the Injector
Injector.map
    klass: MyClass
# ask the Injector to give you a new instance of MyClass
instance = Injector.getInstanceOf "MyClass"
# use the instance
instance.sayYeah() # this print "YEAH!" to the console
```

## Create an Injector
```coffeescript
CoffeeSweetener = require "coffee-sweetener"
Injector = new CoffeeSweetener()
```
Every Injector will automatically create a mapping to itself as a Singleton called "Injector".
This is useful if you want to get hold of the injector from within a class, by just specifying it in the list of the injection points.
```coffeescript
CoffeeSweetener = require "coffee-sweetener"
Injector = new CoffeeSweetener()

class MyClass
    inject:
        injector: "Injector"
```
Every new instance of MyClass ( created through `Injector.getInstanceOf`) will have a property called injector which holds the reference to the Injector that created the class.

## `.map( mappingObject )`
### Map a module knowing the path
Just map the module by specifing the path. *Be aware that this works only for modules which exports one class*.
```coffeescript
Injector.map
    modulePath: 'src/yourModule'
```
where `yourModule` is:
```coffeescript
class YourModule

module.exports = YourModule
```
Here the name of the mapping will be inferred from the name of the class exported in the module.

### Map a Class
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
```
Here the name of the mapping will be automatically set to the name of the class.

### Map a Value
```coffeescript
user = "vizio"
Injector.map
    value: user
    name: "user"
```
A value can be anything, it can also be a function. 
When mapping a value you should always provide a name for the mapping.

## `.asSingleton()`
### Map a Class as a Singleton
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
.asSingleton()
```
Everytime you then ask the injector for an instance of the class, you'll get back always the same instance.

## `.as( newName )`
### Specifing a name for a mapping
This applies for all mapping types.

By passing the name to the mapping:
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
    name: "NewName"
```

By calling the `as()` method:
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
.as "NewName"
```

## `.getInstanceOf( mappingName )`
Once you've created your mappings you can ask the Injector for them:
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass

myInstance = Injector.getInstanceOf "MyClass"
```
For values the injector will always return that same value, it will not return a copy or a new instance of the value.

## `.getClassOf( mappingName )`
For mapped classes you can ask the Injector to get you the class definition object:
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
# getting MyClass definition object
myClass = Injector.getClassOf "MyClass"
# manually creating a new instance of MyClass
myInstance = new myClass
```

## `.unmap( mappingName )`
Unmaps a mapping.
```coffeescript
class MyClass

Injector.map
    klass: MyClass

Injector.unmap "MyClass"
Injector.getInstanceOf "MyClass" # this will throw an exception!
```

## `.destroy()`
Destroys all the mappings.

## Fluent API
You can chain the calls to the different APIs when creating a mapping.
```coffeescript
# mapping a class as a Singleton and specifying a new name for the mapping
Injector.map
    modulePath: "yourModulePath"
.asSingleton().as("MySingleton")
```

# Class Injection Points
It is possible, from within a class, to specify a list of dependencies which the Injector will try to satisfy when creating new instances of the class.

```coffeescript
# assuming Wheels and Engine have already been mapped in the Injector
class Car
    inject:
        wheels: "Wheels"
        engine: "Engine"
        
Injector.map
    klass: Car

myCar = Injector.getInstanceOf "Car"
console.log myCar.wheels # will print out an instance of the Wheels class
console.log myCar.engine # will print out an instance of the Engine class
```
This means that there is no need to require `Wheels` and `Engine` in the module file where Car is defined.

# Instance initialisation
Everytime the Injector creates new instances, it will call the `initInstance` on the new instance if that method is defined.
This is the place you want to put all your initialisation logic, because you can be sure that at that point all the dependencies have been resolved.

# References
The API is inspired by <a href="https://github.com/tschneidereit/SwiftSuspenders">SwiftSuspenders</a> which I used while developing Flashy things.
