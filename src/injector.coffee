class Mapping
    constructor: (@Injector, @klassName, @klass) ->

    isSingleton: false

    create: ->
        instance = new @klass
        instance.injector = @Injector
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
        @Injector.remap(@klassName, newName)
        @

    
class Injector
    getRelativePath = (path) ->
        if process?
            # getting root folder of process
            "#{process.cwd()}/#{path}"
        else
            path

    mapping = {}

    extractFunctionName = (fn) ->
        str = fn.toString()
        tokens = /^[\s\r\n]*function[\s\r\n]*([^\(\s\r\n]*?)[\s\r\n]*\([^\)\s\r\n]*\)[\s\r\n]*\{((?:[^}]*\}?)+)\}\s*$/.exec(str)
        tokens[1]
    
    map: (pathOrClass) ->
        klass = pathOrClass
        if typeof pathOrClass is "string"
            path = getRelativePath pathOrClass
            klass = require path
        klassName = extractFunctionName klass
        mapping[klassName] or= new Mapping @, klassName, klass

    unmap: (klassName) ->
        delete mapping[klassName]

    remap: (oldName, newName) ->
        mapping[newName] = mapping[oldName]
        @unmap oldName

    getMapping = (klassName) ->
        map = mapping[klassName]
        throw new Error("#{klassName} not mapped in Injector") unless map?
        map

    getInstanceOf: (klassName) ->
        getMapping(klassName).get()
            
    getClassOf: (klassName) ->
        getMapping(klassName).getClass()

    destroy: ->
        mapping = {}
    
module.exports = new Injector()
