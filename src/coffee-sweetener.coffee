getRelativePath = (path) ->
    if process?
        # getting root folder of process
        "#{process.cwd()}/#{path}"
    else
        path

extractFunctionName  = (fn) ->
    str = fn.toString()
    tokens = /^[\s\r\n]*function[\s\r\n]*([^\(\s\r\n]*?)[\s\r\n]*\([^\)\s\r\n]*\)[\s\r\n]*\{((?:[^}]*\}?)+)\}\s*$/.exec(str)
    tokens[1]

requireClass = (path) ->
    path = getRelativePath path
    require path

class Mapping
    constructor: (@injector, @mappingObject) ->
        @klass = requireClass @mappingObject.modulePath if @mappingObject.modulePath?
        @klass = @mappingObject.klass if @mappingObject.klass?
        @klass.injector = @injector if @klass?
        @asValue @mappingObject.value if @mappingObject.value?

    isSingleton: false

    create: ->
        instance = new @klass
        @inject(instance)
        instance.initInstance?()
        instance

    inject: (instance) ->
        return unless instance.inject?
        instance[key] = @injector.getInstanceOf(value) for own key, value of instance.inject

    get: ->
        if @isSingleton
            @singleton or= @create()
        else
            @create()

    getClass: ->
        @klass

    asSingleton: ->
        @isSingleton = true
        @

    as: (newName) ->
        @injector.remap(@mappingObject.name, newName)
        @

    asValue: (value) ->
        @create = ->
            value
        @

    
class Injector

    constructor: ->
        @_mappings = {}
        @map(value: @, name: "Injector")
        @checkReservedMappings = (mappingObject) ->
            if mappingObject?.name? and mappingObject.name is "Injector"
                throw new Error("Cannot create mappings called Injector because it is a reserved mapping")

    validateObjectField: (object, field, type) ->
        throw new Error "#{field} should be a #{type}" if object[field]? and typeof object[field] isnt type
    
    map: (mappingObject) ->
        @checkReservedMappings?(mappingObject)
        {klass, name, modulePath, value} = mappingObject
        @validateObjectField mappingObject, "name", "string"
        @validateObjectField mappingObject, "klass", "function"
        @validateObjectField mappingObject, "modulePath", "string"
        if klass?
            mappingObject.name = extractFunctionName mappingObject.klass unless mappingObject.name?
        else if modulePath?
            mappingObject.name = extractFunctionName(requireClass(mappingObject.modulePath)) unless mappingObject.name?
        else if value?
            throw new Error "For value mappings you need to provide a name" unless name?
        else
            throw new Error "You need to provide a klass or a modulePath or a value with optionally a name for a mappings"
        @_mappings[mappingObject.name] or= new Mapping @, mappingObject

    unmap: (klassName) ->
        delete @_mappings[klassName]

    remap: (oldName, newName) ->
        @_mappings[newName] = @_mappings[oldName]
        @unmap oldName

    _getMapping: (klassName) ->
        map = @_mappings[klassName]
        throw new Error("#{klassName} not mapped in Injector") unless map?
        map

    getInstanceOf: (mappedName) ->
        @_getMapping(mappedName).get()
            
    getClassOf: (klassName) ->
        @_getMapping(klassName).getClass()

    destroy: ->
        @_mappings = {}

    toString: ->
        replacer = (key, value) =>
            # avoiding circular references to break
            # JSON.stringify method.
            return "Reference to itself" if value is @
            value
        JSON.stringify @_mappings, replacer

    @InjectorSingleton: undefined
    @asSingleton: ->
        @InjectorSingleton or @InjectorSingleton = new Injector()

module.exports = Injector
