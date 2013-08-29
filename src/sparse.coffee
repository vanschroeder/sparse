## sParse
# (c)2013 Van Carney
#### A *sparse* Parse API for Backbone
#> Design Goals:
#> &bullet; Be small and compact
#> &bullet; Go wherever Backbone can go with no added dependencies or restrictions
#> &bullet; 'Drop In' to any existing Backbone Application (where Backbone source code is unadulterated)
#> &bullet; Provide complete Parse API coverage (in a future release TBD)
global = exports ? window
# include  Backbone and Underscore if we are in a Node App
if typeof exports != 'undefined'
  _         = require('underscore')._
  Backbone  = require('backbone');
(->
  # restrict our code to use less dangerous functionality
  'use strict'
  # define the 'sparse' global namespace
  if !global.sparse
    sparse = global.sparse =
      # Our current version
      VERSION:"0.0.1"
      # APP_ID stores the Parse API Application Identifier
      APP_ID:undefined
      # REST_KEY stores the Parse API REST Access Key
      REST_KEY:undefined
      # SESSION_TOKEN, stored the user session token if logged in
      SESSION_TOKEN:undefined
      # the supported version of the Parse API
      API_VERSION:"1"
      # Batch request object length (set to -1 to disable sub-batching)
      # note: changing this may cause Batch requests to fail
      MAX_BATCH_SIZE:50
      # Parse limits fetch requests to 100 records and provides no pagination
      # To circumvent this, we iverride the Fetch Limit to attempt to pull all records
      # Set this to a lower or higher amount to suit your needs
      # See also: REST API Queries
      DEFAULT_FETCH_LIMIT_OVERRIDE: 200000
      # The default ClassName to use for Models and Collections
      UNDEFINED_CLASSNAME:'__UNDEFINED_CLASSNAME__'
      # Base URI for the Parse API
      API_URI:"https://api.parse.com/1"
      # Mappings from CRUD to REST
      CRUD_METHODS:
        create: 'POST'
        read:   'GET'
        update: 'PUT'
        destroy:'DELETE'
      #### sparse.apiOPTS
      # Utility function to generate a Parse API Header
      apiOPTS: ->
        contentType: "application/json"
        processData: false
        dataType: 'json'
        data: null
        headers:
          'Content-Type'            : 'application/json'
          'X-Parse-Application-Id'  : sparse.APP_ID
          'X-Parse-REST-API-Key'    : sparse.REST_KEY
          'X-Parse-Session-Token'   : sparse.SESSION_TOKEN
      getConstructorName: (fun)->
        fun.constructor.name || if (n=fun.constructor.toString().match /function+\s{1,}([A-Z]{1}[a-zA-Z]*)/)? then n[1] else sparse.UNDEFINED_CLASSNAME
      #### sparse.Inflection
      # Basic Inflection utility used to convert Class Names
      Inflection: new (->
        __uncountable_words:['equipment', 'information', 'rice', 'money', 'species', 'series','fish', 'sheep', 'moose', 'deer', 'news']
        __plural_rules:[
          [/(m)an$/gi,                  '$1en'],
          [/(pe)rson$/gi,               '$1ople'],
          [/(child)$/gi,                '$1ren'],
          [/^(ox)$/gi,                  '$1en'],
          [/(ax|test)is$/gi,            '$1es'],
          [/(octop|vir)us$/gi,          '$1i'],
          [/(alias|status)$/gi,         '$1es'],
          [/(bu)s$/gi,                  '$1ses'],
          [/(buffal|tomat|potat)o$/gi,  '$1oes'],
          [/([ti])um$/gi,               '$1a'],
          [/sis$/gi,                    'ses'],
          [/(?:([^f])fe|([lr])f)$/gi,   '$1$2ves'],
          [/(hive)$/gi,                 '$1s'],
          [/([^aeiouy]|qu)y$/gi,        '$1ies'],
          [/(x|ch|ss|sh|lens)$/gi,      '$1es'],
          [/(matr|vert|ind)ix|ex$/gi,   '$1ices'],
          [/([m|l])ouse$/gi,            '$1ice'],
          [/(quiz)$/gi,                 '$1zes'],
          [/s$/gi,                      's'],
          [/$/gi,                       's']
        ]
        # find and apply the appropriate Regex for the given string
        apply_rules: (str, rules, skip)->
          if (skip.indexOf str.toLowerCase()) == -1
            return str.replace rx[0], rx[1] if (rx = _.find rules, (itm)=>str.match itm[0])?
          str
        # pluralizes a string
        pluralize: (str)->
          @apply_rules str, @__plural_rules, @__uncountable_words
      )
  # OP
  # class sparse.OP
  # class sparse.OP.ADD
    # objects
  #### sparse.Model
  # represents a single Parse Object Row Association
  class sparse.Model extends Backbone.Model
    # map our Backbone.Model id attribute to Parse Api's objectId attribute
    idAttribute: "objectId"
    constructor:(attributes, options)->
      super attributes, options
      @className = sparse.getConstructorName @ if typeof @className == 'undefined' or @className == null
      console.warn "sparse.Collection requires className to be defined" if @className == sparse.UNDEFINED_CLASSNAME 
      @className = sparse.Inflection.pluralize @className
    # generates a Parse API URL for this object based on the Class name
    url : ->
      "#{sparse.API_URI}/classes/#{@className}#{ if !@.isNew() then '/'+(@.get 'objectId') else '' }"
    # override native Backbone.Collection.sync to apply custom API header and data (if any)
    sync : (method, model, options={})->
      opts = sparse.apiOPTS()
      opts.data = JSON.stringify @.toJSON()
      Backbone.Model.prototype.sync.call @, method, model, _.extend( options, opts )
    # override toJSON handler
    toJSON : (options)->
      data = Model.__super__.toJSON.call @, options
      delete data.createdAt
      delete data.updatedAt
      data
    ## Sparse.Object API compat
    __ops:[]
    increment: (attr, amount)->
      
  ## sparse.Model.saveAll
  # Parse API compatability, replaces Parse.Object.saveAll
  # Sets up and executes a sparse.Batch process
  sparse.Model.saveAll = (list, options)->
    (new sparse.Batch list
    ).exec 
      complete:(m,r,o)=>
        options.success m,r,o if options.success
      error:(m,r,o)=>
        options.error m,r,o if options.error
  #### sparse.Collection
  # represents a complete Parse Object and all row associations
  class sparse.Collection extends Backbone.Collection
    __count:undefined
    count:->
      @__count || @models.length
    constructor : (attributes, options)->
      super attributes, options
      # inspects our Class for the extending Class's class name if not already set directly by user
      @className = sparse.getConstructorName @ if typeof @className == 'undefined' or @className == null
      console.warn "sparse.Collection requires className to be defined" if @className == sparse.UNDEFINED_CLASSNAME
      @className = sparse.Inflection.pluralize @className
    __params:
      limit: sparse.DEFAULT_FETCH_LIMIT_OVERRIDE
      count:1
    getParams:->
      ( _.map _.pairs( @__params || null ), (v,k)=>v.join '=' ).join '&'
    # generates a Parse API URL for this object based on the Class name
    url : ->
      encodeURI "#{sparse.API_URI}/classes/#{@className}#{if @__method == 'read' and (p=@getParams()).length then '?'+p else ''}"
    # override local Collection.parse method to handle Parse API nesting of results into a results object
    parse : (options)->
      data = Collection.__super__.parse.call @, options
      data.results || data
    # override native Backbone.Collection.sync to apply custom API header and data (if any)
    sync : (@__method, model, options={})->
      opts      = sparse.apiOPTS()
      # basic query support for order, count, limit and query    
      if @__method == 'read'
        _.each ['order','count','limit','where'], (v,k)=>
          if options[v]
            @__params[v] = JSON.stringify options[v]
            delete options[v]
      opts.success = (m,r,o)=>
        @__params =
          limit: sparse.DEFAULT_FETCH_LIMIT_OVERRIDE
          count:1
        options.success m, r, o if options.success?
      Backbone.Collection.prototype.sync.call @, @__method, model, _.extend( _.clone(options), opts )
    # convenience function to allow user to fetching with a query
    query : (query, options={})->
      @fetch _.extend(options, where:query)
    # convenience function for saving any new and changed objects in the collection
    save : (options)->
      _.each @models, (v,k)=>
        v.fetch options if v.isNew() or v.hasChanged()
  #### sparse.User
  # Model for Parse's special User Object Type
  class sparse.User extends sparse.Model
    defaults:
      username:null
      password:null
      email:null
    __action:'operate'
    urlMap:
      create:"#{sparse.API_URI}/users"
      login:"#{sparse.API_URI}/login"
      passwordReset:"#{sparse.API_URI}/requestPasswordReset"
      operate:"#{sparse.API_URI}/users"
    url:->
      @urlMap[@__action] + ( if @__action == 'operate' and !@isNew() then "/#{@get 'objectId'}" else '')
    logout:->
      sparse.SESSION_TOKEN = undefined
      @urlMap['login'] = @urlMap['login'].replace /\/login+.*/, '/login'
    login:(username, password, options)->
      @__action = 'login'
      @urlMap['login'] = encodeURI @urlMap['login'].replace /\/login+.*/, "/login?username=#{username}&password=#{password}"
      opts = {}
      opts.success = (m,r,o)=>
        sparse.SESSION_TOKEN = @get 'sessionToken'
        delete @attributes.sessionToken
        options.success m,r,o if options.success
      @fetch _.extend _.clone(options), opts
    save:(attributes, options)->
      @__action = (if @.isNew() then 'create' else 'operate')
      User.__super__.save.call @, attributes, options
    destroy:(options)->
      @__action = 'operate'
      opts = {}
      opts.success = (m,r,o)=>
        @logout()
        options.success m,r,o if options.success
      User.__super__.destroy.call @, _.extend( _.clone(options), opts )
    resetPassword:(options)->
      if (email = @get 'email') == null
        return false
      @__action = 'passwordReset'
      User.__super__.save.call @, {email:email}, options
  #### sparse.UserCollection
  # Collection to retrieve and manage Parse User Objects
  class sparse.Users extends sparse.Collection
    url:->
      "#{sparse.API_URI}/users"
  #### sparse.Batch
  # Utility Class to Create, Update and Destroy many various Parse Objects in a single request
  class sparse.Batch extends sparse.Collection
    constructor : (attributes, options)->
      super attributes, options
    # Batch uses a hardcoded url to the API_URL/batch resource
    url : ->
      "#{sparse.API_URI}/batch"
    # hold processed models by batch
    __processed:[]
    # retrieve flattened processed models
    processed:(flatten=true)->
      if flatten  then _.flatten @__processed else @__processed
    # override the local toJSON method to wrap the model into a 'requests' object
    toJSON : (options)->
      JSON.stringify requests : Batch.__super__.toJSON.call @, options
    # a safer way to check for new models in our Batch 
    _memberIsNew: (attrs)->
      # test to see if there is an isNew property, if not, see if we have an objectId and evaluate it
      (attrs.hasOwnProperty('isNew') && attrs.isNew()) || (typeof(attrs.get 'objectId')  == 'undefined' || attrs.get 'objectId' == null || attrs.get 'objectId' == "")
    # override the local _prepareModel method
    _prepareModel : (attrs, options={})->
      # we will assume this is a create or update if thedestroy param has not been set in the options
      options = _.extend(options, {destroy:false}) if !(options.hasOwnProperty 'destroy')
      # we should not attempt to destroy an object that has never been created
      if options.destroy and @_memberIsNew attrs
        obj = null 
      else
        # replace the given Model with a Sparse.Batch formatted model 
        obj =
          method  :  sparse.CRUD_METHODS[if options.destroy then 'destroy' else (if @_memberIsNew attrs then 'create' else 'update')]
          path    : "/#{sparse.API_VERSION}/classes/#{attrs.className}#{if !@_memberIsNew attrs then '/'+ attrs.get 'objectId' else ''}"
        obj.body = attrs if !options.destroy
      Backbone.Collection.prototype._prepareModel.call @, obj, options
    # override the local call to Backbone.sync
    sync : (method, model, options)->
      return if !model.models or model.models.length == 0
      # prepare to overwrite standard options with API specific headers and params
      opts      = sparse.apiOPTS()
      # grab a subset of our data to fit within Parse's Batch Operation Limit
      opts.data = JSON.stringify requests : (@__to_remove = model.slice 0, (if sparse.MAX_BATCH_SIZE >= 0 and sparse.MAX_BATCH_SIZE < model.models.length then sparse.MAX_BATCH_SIZE else model.models.length) )
      # create custom success handlerfor sequential batch operations on large datasets
      opts.success  = (m,r,o)=>
        # apply the changes to the original model and concat the processed models to the __processed array
        @__processed.push _.map m, (v,k,l) => _.chain(@__to_remove[k].get 'body').tap((_o) ->
          # deleted items will be undefined, so just pass back the success results 
          if typeof _o != 'undefined' then _o.set v.success else _o = v.success
        ).value()
        # remove data objects pending removal from the last operation
        @remove @__to_remove, {index: 0, silent:true}
        setTimeout (=>
          # if we still have data in our model, we will send it to sync
          if model.models.length  > 0
            @sync method, @, options
          else
            # if no data is left, send a complete event
            options.complete @__processed, r, o if options.complete
        ), 200
        # invoke user supplied success callback if provided
        options.success m,r,o if options.success
      opts.error    = (m,r,o)=> options.error m,r,o if options.error
      opts.complete = (m,r,o)=> options.completed m,r,o if options.completed 
      Backbone.sync method, model, _.extend( _.clone(options), opts  )
    # fetch is not supported since Batch is not for READ operations
    fetch : (options) -> console.warn 'fetch is not supported by sparse.Batch try using sparse.Collection instead'
    # execute the Batch Operation
    exec : (options) -> @sync 'create', @, options
    # add a record or records to be deleted from the Server 
    destroy : (models, options) -> @add models, _.extend _.clone(options || {}), destroy:true
    # add a record or records to be added to the Server
    save : (models, options) -> @add models, options
).call @