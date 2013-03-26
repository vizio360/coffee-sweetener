describe "Injector", ->
    Injector = null
    MyClass = require "./myclass"
    
    beforeEach ->
        Injector = require "../src/injector"

    it "has a map method defined", ->
        expect(Injector.map).toBeDefined()

    it "provides a singleton of itself", ->
        newInjector = require "../src/injector"
        expect(newInjector.asSingleton()).toBe(Injector.asSingleton())
        
    it "maps itself automatically", ->
        expect(Injector.getInstanceOf("Injector")).toBe(Injector)
        
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
        
    # not so sure about this one
    it "defines an injector property on the class type", ->
        Injector.map modulePath: "test/myclass"
        expect(Injector.getClassOf("MyClass").injector).toBe(Injector)
        
    class TestInit
        initInstance: jasmine.createSpy("initInstance")

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

    it "calls the instance initInstance function, if defined, when creating it", ->
        Injector.map klass: TestInit
        instance = Injector.getInstanceOf("TestInit")
        expect(instance.initInstance).toHaveBeenCalled()
        
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
        
    class RequireInjections
        inject:
            myClass: "MyClass"
            testInit: "TestInit"
            someInt: "SomeInt"
            injector: "Injector"

    it "injects what is required by the instance", ->
        Injector.map modulePath: "test/myclass"
        Injector.map klass: TestInit
        Injector.map klass: RequireInjections
        Injector.map value: 12345, name: "SomeInt"
        instance = Injector.getInstanceOf "RequireInjections"
        expect(instance.myClass).toBeDefined()
        expect(instance.myClass instanceof Injector.getClassOf("MyClass")).toBe(true)
        expect(instance.testInit).toBeDefined()
        expect(instance.testInit instanceof Injector.getClassOf("TestInit")).toBe(true)
        expect(instance.someInt).toBe(12345)
        expect(instance.injector).toBe(Injector)
        
