describe "Injector", ->
    Injector = require "../src/injector"
    MyClass = require "./myclass"
    
    beforeEach ->
        Injector.destroy()

    it "has a map method defined", ->
        expect(Injector.map).toBeDefined()

    it "gets an instance of a mapped type", ->
        Injector.map
            name: "MyClass"
            modulePath: "test/myclass"
        instance = Injector.getInstanceOf("MyClass")
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "determines the mapping name from the module loaded", ->
        Injector.map
            modulePath: "test/myclass"
        instance = Injector.getInstanceOf("MyClass")
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "raises an error if both name and modulePath are not defined", ->
        expect(-> Injector.map()).toThrow()
        expect(-> Injector.map({})).toThrow()

    it "raises an error if asking for an instance of a non mapped type", ->
        expect(-> Injector.getInstanceOf("blah")).toThrow()

    it "returns the same instance for a type mapped as Singleton", ->
        Injector.map(modulePath: "test/myclass").asSingleton()
        instance = Injector.getInstanceOf("MyClass")
        instance2 = Injector.getInstanceOf("MyClass")
        expect(instance).toBe(instance2)

    it "maps a module with a specific name", ->
        Injector.map(modulePath: "test/myclass").as("IClass")
        instance = Injector.getInstanceOf("IClass")
        #checking that the default mapping is not available
        expect(-> Injector.getInstanceOf("MyClass")).toThrow()
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "maps a singleton with a specific name", ->
        Injector.map(modulePath: "test/myclass").asSingleton().as("IClass")
        instance = Injector.getInstanceOf("IClass")
        instance2 = Injector.getInstanceOf("IClass")
        expect(instance).toBe(instance2)

    it "gets a class reference of a mapped type", ->
        Injector.map(modulePath: "test/myclass")
        klass = Injector.getClassOf("MyClass")
        expect(klass).toBe(MyClass)

    it "unmaps a type", ->
        Injector.map modulePath: "test/myclass"
        Injector.unmap("MyClass")
        expect(-> Injector.getInstanceOf("MyClass")).toThrow()

    it "defines an injector property on new instances", ->
        Injector.map modulePath: "test/myclass"
        instance = Injector.getInstanceOf("MyClass")
        expect(instance.injector).toBe(Injector)
        Injector.unmap "test/myclass"
        Injector.map(modulePath: "test/myclass").asSingleton()
        instance = Injector.getInstanceOf("MyClass")
        expect(instance.injector).toBe(Injector)
        
    class TestInit
        init: jasmine.createSpy("init")

    it "can map a class", ->
        Injector.map klass: TestInit
        instance = Injector.getInstanceOf("TestInit")
        expect(instance).toBeDefined()
        expect((instance instanceof TestInit)).toBe(true)
        
    it "maps a class with a specific name", ->
        Injector.map(klass: TestInit).as("IClass")
        instance = Injector.getInstanceOf("IClass")
        #checking that the default mapping is not available
        expect(-> Injector.getInstanceOf("TestInit")).toThrow()
        expect(instance).toBeDefined()
        expect((instance instanceof TestInit)).toBe(true)

    it "calls the instance init function, if defined, when creating xit", ->
        Injector.map klass: TestInit
        instance = Injector.getInstanceOf("TestInit")
        expect(instance.init).toHaveBeenCalled()
        
    it "can map a value", ->
        Injector.map value: 12345, name: "FirstFiveNumbers"
        instance = Injector.getInstanceOf("FirstFiveNumbers")
        expect(instance).toBe(12345)

    it "raises an error if mapping a value without a name", ->
        expect(-> Injector.map value: 12345).toThrow()

    it "prints out the mappings", ->
        mapObj1 = value: 12345, name: "FirstFiveNumbers"
        Injector.map mapObj1
        mapObj2 = klass: TestInit
        Injector.map mapObj2
        expect(Injector.toString()).toMatch(JSON.stringify(mapObj1))
        expect(Injector.toString()).toMatch(JSON.stringify(mapObj2))
        
        
