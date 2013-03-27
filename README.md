# Dependency Injection in CoffeeScript

Reasons for building it:

 - bored of the list of `require` at the top of each module
 - bored of finding out the location of a module relative to another one for requiring it
 - challanging myself to build something useful
 - missing the comfort of dependecy injection components like SwiftSuspenders (ActionScript)
 - ease the maintenance of big applications

# coffeeInjector

This is a small and simple utility component that you can use in your applications to ease the management of dependencies between objects.
The idea is simple, you have a factory object (we'll call this the injector) where you define some mappings.
Each mapping has a unique id that you define.
From different modules you can query the factory to give you a new instance of a specific mapping.
Within classes you can define depenecies which will be satisfied on creation of a new instance of that class.

# API
### Let's start with an example
```coffeescript
# define a class
class MyClass
    sayYeah: ->
        console.log "YEAH!"
# get the Injector
Injector = require "coffeeInjector"
# map MyClass in the Injector
Injector.map
    klass: MyClass
# ask the Injector to give you a new instance of MyClass
instance = Injector.getInstanceOf "MyClass"
# use the instance
instance.sayYeah() # this print "YEAH!" to the console
```

### Create an Injector
```coffeescript
Injector = require 'coffeeInjector'
```
coffeeInjector alreay exports a new instance of Injector so no need to call the `new` operator.

## `.map()'
#### Map a module knowing the path
Just map the module by specifing the path. Be aware that this works only for modules which wxports one class.
```coffeescript
Injector.map
    modulePath: 'src/yourModule'
```
where `yourModule` is:
```coffeescript
class YourModule

module.exports = YourModule
```
Here the name of the mapping will be inferred by the name of the class exported in the module.

#### Map a Class
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
```
Here the name of the mapping will be automatically set to the name of the class.

## `.asSingleton()`
#### Map a Class as a Singleton
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
.asSingleton()
```
Everytime you then ask the injector for an instance of the class, you'll get back always the same instance.

#### Map a Value
```coffeescript
user = "vizio"
Injector.map
    value: user
    name: "user"
```
A value can be anything, it can also be a function. 
When mapping a value you should always provide a name for the mapping.

## `.as()`
#### Specifing a name for a mapping
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

## Fluent API
You can chain the calls to the different APIs when creating a mapping.
```coffeescript
Injector.map
    modulePath: "yourModulePath"
.asSingleton().as("MySingleton")
```

