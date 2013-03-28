describe "injector", ->
    Injector = require "../src/injector"
    MyClass = require "./assets/myclass"
    injector = null
    
    beforeEach ->
        injector = new Injector()

    it "has a map method defined", ->
        expect(injector.map).toBeDefined()

    it "provides a singleton of itself", ->
        newInjector = new Injector()
        expect(newInjector.asSingleton()).toBe(injector.asSingleton())
        
    it "maps itself automatically", ->
        expect(injector.getInstanceOf("Injector")).toBe(injector)
        
    it "gets an instance of a mapped type", ->
        injector.map
            name: "MyClass"
            modulePath: "test/assets/myclass"
        instance = injector.getInstanceOf("MyClass")
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "determines the mapping name from the module loaded", ->
        injector.map
            modulePath: "test/assets/myclass"
        instance = injector.getInstanceOf("MyClass")
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "raises an error if both name and modulePath are not defined", ->
        expect(-> injector.map()).toThrow()
        expect(-> injector.map({})).toThrow()

    it "raises an error if asking for an instance of a non mapped type", ->
        expect(-> injector.getInstanceOf("blah")).toThrow()

    it "returns the same instance for a type mapped as Singleton", ->
        injector.map(modulePath: "test/assets/myclass").asSingleton()
        instance = injector.getInstanceOf("MyClass")
        instance2 = injector.getInstanceOf("MyClass")
        expect(instance).toBe(instance2)

    it "maps a module with a specific name", ->
        injector.map(modulePath: "test/assets/myclass").as("IClass")
        instance = injector.getInstanceOf("IClass")
        #checking that the default mapping is not available
        expect(-> injector.getInstanceOf("MyClass")).toThrow()
        expect(instance).toBeDefined()
        expect((instance instanceof MyClass)).toBe(true)

    it "maps a singleton with a specific name", ->
        injector.map(modulePath: "test/assets/myclass").asSingleton().as("IClass")
        instance = injector.getInstanceOf("IClass")
        instance2 = injector.getInstanceOf("IClass")
        expect(instance).toBe(instance2)

    it "gets a class reference of a mapped type", ->
        injector.map(modulePath: "test/assets/myclass")
        klass = injector.getClassOf("MyClass")
        expect(klass).toBe(MyClass)

    it "unmaps a type", ->
        injector.map modulePath: "test/assets/myclass"
        injector.unmap("MyClass")
        expect(-> injector.getInstanceOf("MyClass")).toThrow()
        
    # not so sure about this one
    it "defines an injector property on the class type", ->
        injector.map modulePath: "test/assets/myclass"
        expect(injector.getClassOf("MyClass").injector).toBe(injector)
        
    class TestInit
        initInstance: jasmine.createSpy("initInstance")

    it "can map a class", ->
        injector.map klass: TestInit
        instance = injector.getInstanceOf("TestInit")
        expect(instance).toBeDefined()
        expect((instance instanceof TestInit)).toBe(true)
        
    it "maps a class with a specific name", ->
        injector.map(klass: TestInit).as("IClass")
        instance = injector.getInstanceOf("IClass")
        #checking that the default mapping is not available
        expect(-> injector.getInstanceOf("TestInit")).toThrow()
        expect(instance).toBeDefined()
        expect((instance instanceof TestInit)).toBe(true)

    it "calls the instance initInstance function, if defined, when creating it", ->
        injector.map klass: TestInit
        instance = injector.getInstanceOf("TestInit")
        expect(instance.initInstance).toHaveBeenCalled()
        
    it "can map a value", ->
        injector.map value: 12345, name: "FirstFiveNumbers"
        instance = injector.getInstanceOf("FirstFiveNumbers")
        expect(instance).toBe(12345)

    it "raises an error if mapping a value without a name", ->
        expect(-> injector.map value: 12345).toThrow()

    it "prints out the mappings", ->
        mapObj1 = value: 12345, name: "FirstFiveNumbers"
        injector.map mapObj1
        mapObj2 = klass: TestInit
        injector.map mapObj2
        expect(injector.toString()).toMatch(JSON.stringify(mapObj1))
        expect(injector.toString()).toMatch(JSON.stringify(mapObj2))
        
    class RequireInjections
        inject:
            myClass: "MyClass"
            testInit: "TestInit"
            someInt: "SomeInt"
            injector: "Injector"

    it "injects what is required by the instance", ->
        injector.map modulePath: "test/assets/myclass"
        injector.map klass: TestInit
        injector.map klass: RequireInjections
        injector.map value: 12345, name: "SomeInt"
        instance = injector.getInstanceOf "RequireInjections"
        expect(instance.myClass).toBeDefined()
        expect(instance.myClass instanceof injector.getClassOf("MyClass")).toBe(true)
        expect(instance.testInit).toBeDefined()
        expect(instance.testInit instanceof injector.getClassOf("TestInit")).toBe(true)
        expect(instance.someInt).toBe(12345)
        expect(instance.injector).toBe(injector)

    class ChildRequire
        inject:
            myClass: "MyClass"
            testInit: "TestInit"
            parent: "ParentRequire"

    class ParentRequire
        inject:
            testInit: "TestInit"

    it "injects injections recursively", ->
        injector.map modulePath: "test/assets/myclass"
        injector.map klass: TestInit
        injector.map klass: ChildRequire
        injector.map klass: ParentRequire
        instance = injector.getInstanceOf "ChildRequire"
        expect(instance.parent.testInit).toBeDefined()
        expect(instance.parent.testInit instanceof injector.getClassOf("TestInit")).toBe(true)
        
    it "raises an error if trying to create a mapping called Injector", ->
        expect(-> injector.map klass:TestInit, name: "Injector").toThrow()
