#### sparse.Query
class sparse.Query
  __q:{}
  __include: []
  __limit: -1
  __skip: 0
  __extraOpts: {}
  #### constructor(classOrName)
  # > Class Constructor Method
  constructor:(classOrName)->
    if classOrName?
      @objectClass = if _.isString classOrName then sparse.Object._getSubclass classOrName else classOrName
      @className = @objectClass.className || sparse.getConstructorName @objectClass
    @or = @_or
    @in = @_in
  clear:->
    @__q = {}
  #### find([options])
  # > Executes query and returns all results
  find:(opts={})->
    throw 'no valid Class required' if typeof @objectClass != 'function'
    (new @objectClass).sync( sparse.CRUD_METHODS.read, [], _.extend opts, {where:@__q}
    ).then (s,r,o)=>
      _.each r.results, (v,k)=>
        (obj = if v.className then new sparse.Object v.className else new @objectClass)._finishFetch v, true
        obj
  #### first([options])
  # > Executes query and returns only the first result
  first:(opts={})->
    @find _.extend opts, {skip:0, limit:1}
  set:(col, key, val)->
    @__q[col] ?= {} if col?
    (@__q[col] || @__q)[key] = val
    @
  getParams:->
    (_.map _.pairs @__q, (v,k)=>v.join '=' ).join '&'
  toJSON:->
    JSON.stringify @__q
  equalTo:(col, value)->
    @set null, col, value
  notEqualTo:(col, value)->
    @set col, '$ne', value
  dontSelect:(query)->
    @set null, '$dontSelect', query:query
  #### exists(column)
  # > Sets condition that column must exist
  exists:(col) -> @set col, '$exists', true
  #### doesNotExist(column)
  # > Sets condition that column must not exist
  doesNotExist:(col) -> @set col, '$exists', false
  #### greaterThan(column, value)
  # > Sets condition that column value must be greater than given value
  greaterThan:(col, val)->
    @set col, '$gt', val
  #### greaterThanOrEqualTo(column, value)
  # > Sets condition that column value must be greater than or equal to the given value
  greaterThanOrEqualTo:(col, val)->
    @set col, '$gte', val
  #### lessThan(column, value)
  # > Sets condition that column value must be less than given value
  lessThan:(col, value)->
    @set col, '$lt', value
  #### lessThanOrEqualTo(column, value)
  # > Sets condition that column value must be less than or equal to the given value
  lessThanOrEqualTo:(col, value)->
    @set col, '$lte', value
  contains:(col, val)->
    @set col, '$regex', "#{sparse.Query._quote val}"
  #### containsAll(column, array)
  # > Sets condition that column value must be an array containing all items in given array
  containsAll:(col,array)->
    @set null, '$all'
  containedIn:(col, value)->
    @set col, '$in', array
  notContainedIn:(col, array)->
    @set col, '$nin', array
  select:(col, query)->
    @set col, '$select', {query:query}
  inQuery:(col,query)->
    @set col, '$inQuery', where:query
  notInQuery:(col,query)->
    @set col, '$notInQuery', where:query
  _or:(query)->
    (@__q['$or'] || (@__q.$or = {})).push query.__q
  relatedTo:(object, key)->
    throw new Error 'sparse.Query.$relatedTo required object be of Type sparse.Object' if !(object instanceof sparse.Object) and object.className?
    @set null, "$relatedTo", 
      object:
        __type: "Pointer"
        objectId: object.get 'objectId'
        className: object.className
      key:"#{key}"
  include:(value)->
    @set null, 'include', "#{value}"
  keys:(val)->
    @set null, 'keys', "#{value}"
  count:(value)->
    @set null, 'count', "#{value}"
  order:(value)->
    @set null, 'order', "#{value}"
  limit:(value)->
    @set null, 'limit', "#{value}"
  skip:(value)->
    @set null, 'skip', "#{value}"
  arrayKey:(col,value)->
    @set null, col, "#{value}"
sparse.Query.or = ->
  className = null
  _.each (Qs = _.toArray arguments), (q)=>
    throw "All queries must be for the same class" if (className ?= q.className) != q.className
  (q = new sparse.Query className)._orQuery Qs
  q
#### _quote(string)
# > Implementation of Parse _quote to create RegExp from string value
sparse.Query._quote = (s)-> "\\Q#{s}\\E"
