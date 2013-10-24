#### sparse.Batch
# > Utility Class to Create, Update and Destroy many various Parse Objects in a single request
class sparse.Batch extends sparse.Collection
  #### constructor(attributes, [options])
  # > Class Constructor Method
  constructor : (attrs, opts)->
    super attrs, opts
  #### url()
  # > provides route to Parse API batch resource
  url : ->
    "#{sparse.API_URI}/batch"
  #### __processed
  # holder for processed `sparse.Object`
  __processed:[]
  #### processed( [flatten] )
  # > retrieves processed `sparse.Object` array
  # > `_.flatten` is applied by default
  processed:(flatten=true)->
    # returns array with `_.flatten` optionally applied
    if flatten then _.flatten @__processed else @__processed
  #### toJSON( [options] )
  # > Overrides `Backbone.Collection.toJSON` method to 
  toJSON : (options)->
    # returns the `sparse.Objects` as a Parse compatible JSON object
    JSON.stringify requests : Batch.__super__.toJSON.call @, options
  #### _memberIsNew(attributes)
  # > Performs check for new `sparse.Objects` 
  _memberIsNew: (attrs)->
    # returns test for `isNew` and `objectId` properties
    (attrs.hasOwnProperty('isNew') && attrs.isNew()) || (typeof(attrs.get 'objectId')  == 'undefined' || attrs.get 'objectId' == null || attrs.get 'objectId' == "")
  #### _prepareModel(attrs, [options])
  # > Overrides `Backbone.Collection._prepareModel`
  _prepareModel : (attrs, options={})->
    # sets options (assumes a create or update if the `destroy` param has not been set)
    options = _.extend(options, {destroy:false}) if !(options.hasOwnProperty 'destroy')
    # nulls any object slated for `destroy` that has never been created
    if options.destroy and @_memberIsNew attrs
      obj = null 
    else
      # replaces the given Model with a Sparse.Batch formatted model 
      obj =
        method  :  sparse.CRUD_METHODS[if options.destroy then 'destroy' else (if @_memberIsNew attrs then 'create' else 'update')]
        path    : "/#{sparse.API_VERSION}/classes/#{attrs.className}#{if !@_memberIsNew attrs then '/'+ attrs.get 'objectId' else ''}"
      obj.body = attrs if !options.destroy
    # calls `_prepareModel` on __super__
    Batch.__super__._prepareModel.call @, obj, options
  #### sync(method, model, [options])
  # > Overrides `Backbone.Collection.sync`
  sync : (method, model, options)->
    # returns of no Objects were passed
    return if !model.models or model.models.length == 0
    # prepares to overwrite standard options with API specific headers and params
    opts      = sparse.apiOPTS()
    # grabs a subset of our data to fit within Parse's Batch Operation Limit
    opts.data = JSON.stringify requests : (@__to_remove = model.slice 0, (if sparse.MAX_BATCH_SIZE >= 0 and sparse.MAX_BATCH_SIZE < model.models.length then sparse.MAX_BATCH_SIZE else model.models.length) )
    # creates custom success handler for sequential batch operations on large datasets
    opts.success  = (m,r,o)=>
      # applies changes to the referenced `sparse.Object`, adding the processed objects to the `__processed` array
      @__processed.push _.map m, (v,k,l) => _.chain(@__to_remove[k].get 'body').tap((_o) ->
        # passes back the success results if deleted (undefined) or `sets` values on referenced `sparse.Object`
        if typeof _o != 'undefined' then _o.set v.success else _o = v.success
      ).value()
      # removes data objects marked for removal during the last operation
      @remove @__to_remove, {index: 0, silent:true}
      setTimeout (=>
        # calls sync while data is still present on the model
        if model.models.length  > 0
          @sync method, @, options
        else
          # sends a complete event when the model is empty
          options.complete @__processed, r, o if options.complete
      ), 200
      # invokes user supplied success callback if provided
      options.success m,r,o if options.success
    opts.error    = (m,r,o)=> options.error m,r,o if options.error
    opts.complete = (m,r,o)=> options.completed m,r,o if options.completed
    # calls Backbone.sync to initiate batch processing
    Backbone.sync method, model, _.extend( _.clone(options), opts  )
  #### fetch([options])
  # > Non-Supported `Backbone.Collection` Feature
  fetch : (options) -> console.warn 'Method: "fetch" is not supported by sparse.Batch. Use sparse.Collection instead'
  #### exec([options])
  # > Executes the Batch Operation with current Collection
  exec : (options) -> @sync 'create', @, options
  #### destroy(models, [options])
  # > Adds a Collection of `sparse.Objects` to be removed from the Parse Service
  destroy : (models, options) -> @add models, _.extend _.clone(options || {}), destroy:true
  #### save(models, [options])
  # > Adds a Collection of `sparse.Objects` to be added to the Parse Service
  save : (models, options) -> @add models, options