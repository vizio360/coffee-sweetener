var Injector, InjectorSingleton, Mapping, extractFunctionName, getRelativePath, requireClass;

getRelativePath = function(path) {
  if (typeof process !== "undefined" && process !== null) {
    return "" + (process.cwd()) + "/" + path;
  } else {
    return path;
  }
};

extractFunctionName = function(fn) {
  var str, tokens;
  str = fn.toString();
  tokens = /^[\s\r\n]*function[\s\r\n]*([^\(\s\r\n]*?)[\s\r\n]*\([^\)\s\r\n]*\)[\s\r\n]*\{((?:[^}]*\}?)+)\}\s*$/.exec(str);
  return tokens[1];
};

requireClass = function(path) {
  path = getRelativePath(path);
  return require(path);
};

Mapping = (function() {
  var injectorRef;

  injectorRef = void 0;

  function Mapping(injector, mappingObject) {
    this.mappingObject = mappingObject;
    injectorRef = injector;
    if (this.mappingObject.modulePath != null) {
      this.klass = requireClass(this.mappingObject.modulePath);
    }
    if (this.mappingObject.klass != null) this.klass = this.mappingObject.klass;
    if (this.klass != null) this.klass.injector = injector;
    if (this.mappingObject.value != null) this.asValue(this.mappingObject.value);
  }

  Mapping.prototype.isSingleton = false;

  Mapping.prototype.create = function() {
    var instance;
    instance = new this.klass;
    instance.injector = injectorRef;
    if (typeof instance.initInstance === "function") instance.initInstance();
    return instance;
  };

  Mapping.prototype.get = function() {
    if (this.isSingleton) {
      return this.singleton || (this.singleton = this.create());
    } else {
      return this.create();
    }
  };

  Mapping.prototype.getClass = function() {
    return this.klass;
  };

  Mapping.prototype.asSingleton = function() {
    this.isSingleton = true;
    return this;
  };

  Mapping.prototype.as = function(newName) {
    injectorRef.remap(this.mappingObject.name, newName);
    return this;
  };

  Mapping.prototype.asValue = function(value) {
    this.create = function() {
      return value;
    };
    return this;
  };

  return Mapping;

})();

Injector = (function() {
  var getMapping, mapping;

  function Injector() {}

  mapping = {};

  Injector.prototype.validateObjectField = function(object, field, type) {
    if ((object[field] != null) && typeof object[field] !== type) {
      throw new Error("" + field + " should be a " + type);
    }
  };

  Injector.prototype.map = function(mappingObject) {
    var klass, modulePath, name, value, _name;
    klass = mappingObject.klass, name = mappingObject.name, modulePath = mappingObject.modulePath, value = mappingObject.value;
    this.validateObjectField(mappingObject, "name", "string");
    this.validateObjectField(mappingObject, "klass", "function");
    this.validateObjectField(mappingObject, "modulePath", "string");
    if (klass != null) {
      if (mappingObject.name == null) {
        mappingObject.name = extractFunctionName(mappingObject.klass);
      }
    } else if (modulePath != null) {
      if (mappingObject.name == null) {
        mappingObject.name = extractFunctionName(requireClass(mappingObject.modulePath));
      }
    } else if (value != null) {
      if (name == null) {
        throw new Error("For value mapping you need to provide a name");
      }
    } else {
      throw new Error("You need to provide a klass or a modulePath or a value with optionally a name for a mapping");
    }
    return mapping[_name = mappingObject.name] || (mapping[_name] = new Mapping(this, mappingObject));
  };

  Injector.prototype.unmap = function(klassName) {
    return delete mapping[klassName];
  };

  Injector.prototype.remap = function(oldName, newName) {
    mapping[newName] = mapping[oldName];
    return this.unmap(oldName);
  };

  getMapping = function(klassName) {
    var map;
    map = mapping[klassName];
    if (map == null) throw new Error("" + klassName + " not mapped in Injector");
    return map;
  };

  Injector.prototype.getInstanceOf = function(mappedName) {
    return getMapping(mappedName).get();
  };

  Injector.prototype.getClassOf = function(klassName) {
    return getMapping(klassName).getClass();
  };

  Injector.prototype.destroy = function() {
    return mapping = {};
  };

  Injector.prototype.toString = function() {
    return JSON.stringify(mapping);
  };

  Injector.prototype.asSingleton = function() {
    return InjectorSingleton;
  };

  return Injector;

})();

InjectorSingleton = new Injector();

module.exports = new Injector();
