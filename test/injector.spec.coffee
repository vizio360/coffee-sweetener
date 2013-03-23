describe "Injector", ->
    Injector = require "../src/injector"
    MyClass = require "./myclass"
    
    beforeEach ->
        Injector.destroy()

    it "has a map method defined", ->
        expect(Injector.map).toBeDefined()

    it "gets an instance of a mapped type", ->
        Injector.map("test/myclass")
        instance = Injector.getInstanceOf("MyClass")
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "raises an error if asking for an instance of a non mapped type", ->
        expect(-> Injector.getInstanceOf("blah")).toThrow()

    it "returns the same instance for a type mapped as Singleton", ->
        Injector.map("test/myclass").asSingleton()
        instance = Injector.getInstanceOf("MyClass")
        instance2 = Injector.getInstanceOf("MyClass")
        expect(instance).toBe(instance2)

    it "maps a type with a specific name", ->
        Injector.map("test/myclass").as("IClass")
        instance = Injector.getInstanceOf("IClass")
        #checking that the default mapping is not available
        expect(-> Injector.getInstanceOf("MyClass")).toThrow()
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "maps a singleton with a specific name", ->
        Injector.map("test/myclass").asSingleton().as("IClass")
        instance = Injector.getInstanceOf("IClass")
        instance2 = Injector.getInstanceOf("IClass")
        expect(instance).toBe(instance2)

    it "gets a class reference of a mapped type", ->
        Injector.map("test/myclass")
        klass = Injector.getClassOf("MyClass")
        expect(klass).toBe(MyClass)

    it "unmaps a type", ->
        Injector.map("test/myclass")
        Injector.unmap("MyClass")
        expect(-> Injector.getInstanceOf("MyClass")).toThrow()

    it "defines an injector property on new instances", ->
        Injector.map("test/myclass")
        instance = Injector.getInstanceOf("MyClass")
        expect(instance.injector).toBe(Injector)
        Injector.unmap "test/myclass"
        Injector.map("test/myclass").asSingleton()
        instance = Injector.getInstanceOf("MyClass")
        expect(instance.injector).toBe(Injector)
        
    class TestInit
        init: jasmine.createSpy("init")

    it "can map a class object", ->
        Injector.map TestInit
        instance = Injector.getInstanceOf("TestInit")
        expect(instance).toBeDefined()
        expect((instance instanceof TestInit)).toBe(true)
        
    it "calls the instance init function, if defined, when creating it", ->
        Injector.map TestInit
        instance = Injector.getInstanceOf("TestInit")
        expect(instance.init).toHaveBeenCalled()
        
