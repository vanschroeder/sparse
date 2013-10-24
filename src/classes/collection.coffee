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
  #### getParams()
  # > Returns `__params` object as Key/Value paired string
  getParams:->
    # returns stringified mapped object 
    ( _.map _.pairs( @__params || null ), (v,k)=>v.join '=' ).join '&'
  #### url()
  # > Overrides `Backbone.Collection.url`
  url : ->
    # returns uri encoded Query String
    encodeURI "#{sparse.API_URI}/classes/#{@className}#{if @__method == 'read' and (p=@getParams()).length then '?'+p else ''}"
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
    console.log @__params
    # sets internal success callback on `options`
    opts.success = (m,r,o)=>
      # resets `__params` object
      @__params =
        limit: sparse.DEFAULT_FETCH_LIMIT_OVERRIDE
        count:1
      # invokes user defined success callback if present
      options.success m, r, o if options.success?
    opts.error = (m,r,o)=>
      options.error m, r, o if options.error
    # calls `sync` on __super__
    Collection.__super__.sync.call @, @__method, @, _.extend( _.clone(options), opts )
  #### query(query, [options])
  # > Applies `Query` to collection and fetches result
  query : (query, options={})->
    @fetch _.extend(options, where:query)
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