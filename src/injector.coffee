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
    injectorRef = undefined
    constructor: (injector, @mappingObject) ->
        injectorRef = injector
        @klass = requireClass @mappingObject.modulePath if @mappingObject.modulePath?
        @klass = @mappingObject.klass if @mappingObject.klass?
        @asValue @mappingObject.value if @mappingObject.value?

    isSingleton: false

    create: ->
        instance = new @klass
        instance.injector = injectorRef
        instance.init?()
        instance

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
        injectorRef.remap(@mappingObject.name, newName)
        @

    asValue: (value) ->
        @create = ->
            value
        @

    
class Injector
    mapping = {}

    validateObjectField: (object, field, type) ->
        throw new Error "#{field} should be a #{type}" if object[field]? and typeof object[field] isnt type
    
    map: (mappingObject) ->
        {klass, name, modulePath, value} = mappingObject
        @validateObjectField mappingObject, "name", "string"
        @validateObjectField mappingObject, "klass", "function"
        @validateObjectField mappingObject, "modulePath", "string"
        if klass?
            mappingObject.name = extractFunctionName mappingObject.klass unless mappingObject.name?
        else if modulePath?
            mappingObject.name = extractFunctionName(requireClass(mappingObject.modulePath)) unless mappingObject.name?
        else if value?
            throw new Error "For value mapping you need to provide a name" unless name?
        else
            throw new Error "You need to provide a klass or a modulePath or a value with optionally a name for a mapping"
        mapping[mappingObject.name] or= new Mapping @, mappingObject

    unmap: (klassName) ->
        delete mapping[klassName]

    remap: (oldName, newName) ->
        mapping[newName] = mapping[oldName]
        @unmap oldName

    getMapping = (klassName) ->
        map = mapping[klassName]
        throw new Error("#{klassName} not mapped in Injector") unless map?
        map

    getInstanceOf: (mappedName) ->
        getMapping(mappedName).get()
            
    getClassOf: (klassName) ->
        getMapping(klassName).getClass()

    destroy: ->
        mapping = {}

    toString: ->
        JSON.stringify mapping
    
module.exports = new Injector()
