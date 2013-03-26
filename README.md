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

# API

## create an Injector

```coffeescript
    Injector = require 'nodeInjector'
```

## Map a module knowing the path
```coffeescript
    Injector.map
```
