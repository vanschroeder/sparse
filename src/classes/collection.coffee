#### sparse.Collection
# > Implementation of Parse API `Collection`
class sparse.Collection extends Backbone.Collection
  #### __count
  # > holder for the current `models` length
  __count:undefined
  #### count()
  # > Returns current `models` length
  count:->
    @__count || @models.length
  #### __params
  # > Holder for default Query Arguments
  __params:
    limit: sparse.DEFAULT_FETCH_LIMIT_OVERRIDE
    count:1
  #### url()
  # > Overrides `Backbone.Collection.url`
  url : ->
    # returns uri encoded Query String
    encodeURI "#{sparse.API_URI}/classes/#{@className}#{if @__method == 'read' and (p=sparse.querify @__params).length then '?'+p else ''}"
  #### parse([options])
  # > Overrides `Backbone.Collection.parse`
  parse : (options)->
    # returns parsed or raw data from call to `parse` on __super__
    (data = Collection.__super__.parse.call @, options).results || data
  #### sync(method, model, [options])
  # > Override `Backbone.Collection.sync`
  sync : (@__method, model, options={})->
    # gets Parse API Header
    opts = sparse.apiOPTS()
    # detects if `__method` is type 'read'   
    if @__method == sparse.CRUD_METHODS.read
      # loops on basic query types
      _.each ['order','count','limit','where'], (v,k)=>
        if options[v]
          # sets query type to `__params`
          @__params[v] = (JSON.stringify options[v]).replace /\\{2}/g, '\\'
          # deletes param from `options`
          delete options[v]
    # sets the encoded request data to request header
    opts.data = if !@__query then JSON.stringify @.toJSON() else "where=#{@__query.toJSON()}"
    console.log opts.data
    # sets internal success callback on `options`
    opts.success = (m,r,o)=>
      # resets `__params` object
      @__params =
        limit: sparse.DEFAULT_FETCH_LIMIT_OVERRIDE
        count:1
      @__query.clear()
      # invokes user defined success callback if present
      options.success m, r, o if options.success?
    opts.error = (m,r,o)=>
      options.error m, r, o if options.error
    # calls `sync` on __super__
    Collection.__super__.sync.call @, @__method, @, _.extend _.clone(options), opts, if @__query then where:@__query.toJSON() else {}
  #### query(query, [options])
  # > Applies `Query` to collection and fetches result
  # query : (query, options={})->
    # @fetch _.extend(options, where:query)
  query : ->
    @__query ?= new sparse.Query @className
    @__query
  findAll : ->
    @query().limit()
  #### save([options])
  # > Batch saves Objects that are new or need updating
  save : (options)->
    # loops on `models` and maps array of items that need to be saved
    (new sparse.Batch _.compact _.map @models, (v,k) -> v if v.isNew() or v.dirty()
    ).exec options
      # calls `Batch.exec` with callbacks
      complete:(m,r,o)=>
        options.success m,r,o if options.success
      error:(m,r,o)=>
        options.error m,r,o if options.error
  #### constructor(attributes, options)
  # > Class Constructor Method
  constructor:(attrs, opts)->
    # passes `arguments` to __super__
    super attrs, opts
    # writes warning to console if the Object's `className` was not detected
    if (@className ?= sparse.getConstructorName @) == sparse.UNDEFINED_CLASSNAME
      console.warn 'sparse.Collection requires className to be defined'
    # pluralizes the `className`
    else
      @className = sparse.Inflection.pluralize @className
    @
  ## Query Methods
  #### equalTo:(col, value)
  equalTo:(col, value)->
    (if !@__query then @query() else @__query).equalTo col, value
    @
  #### equalTo:(col, value)
  notEqualTo:(col, value)->
    (if !@__query then @query() else @__query).notEqualTo col, value
    @
  #### greaterThan:(col, value)
  greaterThan:(col, value)->
    (if !@__query then @query() else @__query).greaterThan col, value
    @
  #### greaterThanOrEqualTo:(col, value)
  greaterThanOrEqualTo:(col, value)->
    (if !@__query then @query() else @__query).greaterThanOrEqualTo col, value
    @
  #### greaterThan:(col, value)
  lessThan:(col, value)->
    (if !@__query then @query() else @__query).greaterThan col, value
    @
  #### greaterThanOrEqualTo:(col, value)
  lessThanOrEqualTo:(col, value)->
    (if !@__query then @query() else @__query).greaterThanOrEqualTo col, value
    @
  #### contains:(col, value)
  contains:(col, value)->
    (if !@__query then @query() else @__query).contains col, value
    @
  #### containsAll(column, array)
  # > Sets condition that column value must be an array containing all items in given array
  containsAll:(col,array)->
    (if !@__query then @query() else @__query).containsAll col, array
    @
  #### containedIn(column, array)
  # > Sets condition that column value must be an array containing any of the items in given array
  containedIn:(col, array)->
    (if !@__query then @query() else @__query).containedIn col, array
    @
  #### containedIn(column, array)
  # > Sets condition that column value must be an array containing none of the items in given array
  notContainedIn:(col, array)->
    (if !@__query then @query() else @__query).notContainedIn col, array
    @
  #### inQuery(column, query)
  inQuery:(col, query)->
    (if !@__query then @query() else @__query).inQuery col, query
    @
  #### notInQuery(column, query)
  notInQuery:(col, query)->
    (if !@__query then @query() else @__query).notInQuery col, query
    @
  #### include(className)
  include:(value)->
    return throw new Error "limit requires String value was {typeof value}" if !(value instanceof String)
    @__params.include = "#{value}"
  #### keys(array)
  keys:(value)->
    return throw new Error "keys requires Array value was {typeof value}" if !(value instanceof Array)
    @__params.keys =  "#{value}"
  #### count(boolean)
  count:(value)->
    return throw new Error "count requires Boolean value was {typeof value}" if !(value instanceof Boolean)
    @__params.count =  value || true 
  #### order(value)
  order:(value)->
    @__params.order = "#{value}"
  #### limit(value)
  limit:(value)->
    return throw new Error "limit requires Number value was {typeof value}" if !(value instanceof Number)
    @__params.limit = value
  #### skip(value)
  skip:(value)->
    return throw new Error "skip requires Number value was {typeof value}" if !(value instanceof Number)
    @__params.skip = value
## Static (ActiveRecord Style) Query Methods
#### equalTo:(col, value)
sparse.Collection.equalTo = (col, value)-> 
  (new @).equalTo col, value
#### equalTo:(col, value)
sparse.Collection.notEqualTo = (col, value)-> 
  (new @).notEqualTo col, value
#### greaterThan:(col, value)
sparse.Collection.greaterThan = (col, value)-> 
  (new @).greaterThan col, value
#### greaterThanOrEqualTo:(col, value)
sparse.Collection.greaterThanOrEqualTo = (col, value)-> 
  (new @).greaterThanOrEqualTo col, value
#### greaterThan:(col, value)
sparse.Collection.lessThan = (col, value)-> 
  (new @).lessThan col, value
#### greaterThanOrEqualTo:(col, value)
sparse.Collection.lessThanOrEqualTo = (col, value)-> 
  (new @).lessThanOrEqualTo col, value
#### contains:(col, value)
sparse.Collection.contains = (col, value)->
  (new @).contains col, value
#### contains:(col, array)
sparse.Collection.containsAll = (col, array)->
  (new @).containsAll col, array
#### containedIn:(col, array)
sparse.Collection.containedIn = (col, array)->
  (new @).containedIn col, array
#### notContainedIn:(col, array)
sparse.Collection.notContainedIn = (col, array)->
  (new @).notContainedIn col, array
#### contains:(col, value)
sparse.Collection.inQuery = (col,query)->
  (new @).inQuery col, query
#### contains:(col, value)
sparse.Collection.notInQuery = (col,query)->
  (new @).notInQuery col, query
#### or:(queries...)
sparse.Collection.or = (queries...)->
  (new @).or queries
#### include(value)
sparse.Collection.include = (value)->
  (new @).include = value
#### keys(value)
sparse.Collection.keys = (array)->
  (new @).keys =  value
#### count(bool)
sparse.Collection.count = (bool)->
  (new @).count =  bool
#### order(value)
sparse.Collection.order = (value)->
  (new @).order = value
#### limit(value)
sparse.Collection.limit = (value)->
  (new @).limit = value
#### skip(value)
sparse.Collection.skip = (value)->
  (new @).skip = value