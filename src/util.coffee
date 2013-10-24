#### sparse.apiOPTS
# > Generates a Parse compatible API Header
sparse.apiOPTS = ->
  contentType: "application/json"
  processData: false
  dataType: 'json'
  data: null
  headers:
    'Content-Type'            : 'application/json'
    'X-Parse-Application-Id'  : sparse.APP_ID
    'X-Parse-REST-API-Key'    : sparse.REST_KEY
    'X-Parse-Session-Token'   : sparse.SESSION_TOKEN
#### sparse.regEscape(string)
# > Returns string as RegExp string literal
sparse.regEscape = (string) -> string.replace /([\^\/\.\-\+\*\[\]\{\}\|\(\)\?\$]+)/g,'\\$1'
#### sparse.validateRoute(route)
# > Validates a given route
sparse.validateRoute = (route)->
  # throws error if route does not pass validation
  throw "Bad route: #{route}" if !route.match new RegExp "^(#{sparse.regEscape sparse.API_URI}\/)?(batch|classes|events|files|functions|login|push|requestPasswordReset|users|jobs)+"
  # returns true if no error thrown
  true
#### sparse._parseDate(iso8601)
# > Implementation of Parse._parseDate used to parse iso8601 UTC formatted `datetime`
sparse._parseDate = (iso8601)->
  # returns null if `iso8601` argument fails `RegExp`
  return null if (t = iso8601.match /^([0-9]{1,4})\-([0-9]{1,2})\-([0-9]{1,2})T+([0-9]{1,2}):+([0-9]{1,2}):?([0-9]{1,2})?(.([0-9]+))?Z+$/) == null
  # returns new `Date` from matched value
  new Date Date.UTC t[1] || 0, (t[2] || 1) - 1, t[3] || 0, t[4] || 0, t[5] || 0, t[6] || 0, t[8] || 0
#### sparse.getConstructorName
# > Attempts to safely determine name of the Class Constructor returns sparse.UNDEFINED_CLASSNAME as fallback
sparse.getConstructorName = (fun)->
  fun.constructor.name || if (n=fun.constructor.toString().match /function+\s{1,}([A-Z]{1}[a-zA-Z]*)/)? then n[1] else sparse.UNDEFINED_CLASSNAME
#### sparse._encode
# > Attempts to JSON encode a given Object
sparse._encode = (value, seenObjects, disallowObjects)->
  # throws error if sparse.Model is passed while disallowed
  throw "sparse.Models not allowed here" if value instanceof sparse.Model and disallowObjects 
  # returns pointer value
  return value._toPointer() if !seenObjects or _.include(seenObjects, value) or value.attributes != value.defaults
  # returns encoded sparse.Model
  return sparse._encode value._toFullJSON(seenObjects = seenObjects.concat value), seenObjects, disallowObjects if !value.dirty()
  # throws error if the object was new/unsaved
  throw 'Tried to save Model with a Pointer to an new or unsaved Object.'
  # returns Data type as iso encoded object
  return __type:Date, iso: value.toJSON() if _.isDate value
  # returns map of encoded Arrays if value is Array
  return _.map value, ((v)-> sparse._encode v, seenObjects, disallowObjects) if _.isArray value
  # returns source of RegExp if value is RegExp
  return value.source if _.isRegExp value
  # returns sparse.Relation as JSON
  return value.toJSON() if (sparse.Relation and value instanceof sparse.Relation) or (sparse.Op and value instanceof sparse.Op) or (sparse.GeoPoint and value instanceof sparse.GeoPoint)
  # returns a File Object as a Pointer
  if sparse.File and value instanceof sparse.File
    throw 'Tried to save an object containing an unsaved file.' if !value.url()
    return (
      __type: "File"
      name: value.name()
      url: value.url()
    )
  # encodes an arbitrary object
  if _.isObject value
    o = {}
    _.each value, (v, k) -> o[k] = sparse._encode v, seenObjects, disallowObjects
    return o
  # returns raw object as fallback
  value
#### sparse._decode
# > Attempts to JSON decode a given Object
sparse._decode = (key, value)->
  # returns passed value if not an Object
  return value if !_.isObject value
  # handles Array values
  if _.isArray value
    _.each value, (v,k)->
      # recurses each Array value
      value[k] = sparse._decode k, v
    # returns array if sucessfully decoded
    return value
  # returns raw value if is `sparse.Object` 
  return value if (value instanceof sparse.Object) or (sparse.File and value instanceof sparse.File) or (sparse.OP and value instanceof sparse.Op)
  # returns decoded `sparse.OP` objects
  return sparse.OP._decode value if value.__op
  # recreates from Pointer
  if value.__type and value.__type == 'Pointer'
    p = sparse.Object._create value.className
    p._finishFetch {objectId: value.objectId}, false
    return p
  # recreates from Object
  if value.__type and value.__type == 'Object'
    cN = value.className
    delete value.__type
    delete value.className
    o = sparse.Object._create cN
    o._finishFetch value, true
    return o
  # returns `Date` value
  return sparse._parseDate value.iso if value.__type == 'Date'
  # recreates from `sparse.GeoPoint` reference
  if sparse.GeoPoint and value.__type == 'GeoPoint'
    return (new sparse.GeoPoint
      latitude: value.latitude
      longitude: value.longitude
    )
  # recreates from `sparse.Relation` reference
  if sparse.Relation and value.__type == 'Relation'
    (r = new sparse.Relation null, key).targetClassName = value.className
    return r
  # recreates from `sparse.File` reference
  if sparse.File and value.__type == 'File'
    (f = new sarse.File value.name).url = value.url
    return f
  # loops on and decodes and arbitrary object
  _.each value, (v, k) -> value[k] = sparse._decode k, v
  # returns the decoded object
  value