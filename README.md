# Dependency Injection in Node

Reasons for building it:

 - bored of the list of `require` at the top of each module
 - bored of finding out the location of a module relative to another one for requiring it
 - challanging myself to build something useful
 - missing the comfort of dependecy injection components like SwiftSuspenders (ActionScript)
 - ease the maintenance of big applications

# nodeInjector

This is a small and simple utility component that you can use in your applications to ease the management of dependencies between objects.
The idea is simple, you have a factory object where you define some mappings.
Each mapping has a unique id that you define.
From different modules you can query the bucket to give you a new instance of a specific mapping.
Within functions you can define depenecies which will be satisfied on creation of a new object.

* auto-gen TOC:
{:toc}

# API
### Let's start with an example
```coffeescript
class MyClass
    sayYeah: ->
        console.log "YEAH!"

Injector = require "nodeInjector"

Injector.map
    klass: MyClass

instance = Injector.getInstanceOf "MyClass"

instance.sayYeah() # this print "YEAH!" to the console
```

### Create an Injector
```coffeescript
Injector = require 'nodeInjector'
```
nodeInjector alreay exports a new instance of Injector so no need to call the `new` operator.

### Map a module knowing the path
Just map the module by specifing the path. Be aware that this works only for modules which only export one class.
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

### Map a Class
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
```
Here the name of the mapping will be automatically set to the name of the class.

### Map a Class as a Singleton
```coffeescript
class MyClass
    
Injector.map
    klass: MyClass
.asSingleton()
```

### Map a Value
```coffeescript
user = "vizio"
Injector.map
    value: user
    name: "user"
```
A value can be anything, it can also be a function. 
When mapping a value you should always provide a name for the mapping.


## Specifing a name for a mapping
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


