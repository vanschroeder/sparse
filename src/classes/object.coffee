#### sparse.Object
# > Represents a single Record Association
class sparse.Object extends Backbone.Model
  #### idAttribute
  # > maps our Backbone.Model id attribute to Parse Api's objectId attribute
  idAttribute: 'objectId'
  #### constructor(attrs, opts)
  # > Class Constructor Method
  constructor:(attrs, opts)->
    # passes `arguments` to __super__
    super attrs, opts
    # writes warning to console if the Object's `className` was not detected
    if (@className ?= sparse.getConstructorName @) == sparse.UNDEFINED_CLASSNAME
      console.warn 'sparse.Object requires className to be defined'
    # pluralizes the `className`
    else
      @className = sparse.Inflection.pluralize @className
  #### url() 
  # > generates a Parse API URL for this object based on the Class name
  url : ->
    "#{sparse.API_URI}/classes/#{@className}#{ if !@.isNew() then '/'+(@.get 'objectId') else '' }"
  #### sync(method, model, [options])
  # > Overrides `Backbone.Model.sync` to apply custom API header and data
  sync : (method, model, options={})->
    # obtains new API Header Object
    opts = sparse.apiOPTS()
    # sets the encoded request data to request header
    opts.data = JSON.stringify @.toJSON()
    # sets `options.url` to avoid duplicate test in `__super__.sync`
    sparse.validateRoute options.url ?= _.result(@, 'url') || '/'
    # calls `sync` on __super__
    Object.__super__.sync.call @, method, model, _.extend( options, opts )
  #### set(attributes, [options])
  # > Overrides `Backbone.Model.set`
  set: (attrs,opts)->
    # calls `set` on __super__
    s = Object.__super__.set.call @, attrs, opts
    # sets `__isDirty` to true if attributes have changed
    @__isDirty = true if @changedAttributes()
    s
  #### toJSON([options])
  # > Overrides `Backbone.Model.toJSON`
  toJSON : (options)->
    # calls `toJSON` on __super__
    data = Object.__super__.toJSON.call @, options
    # cleans the object
    delete data.createdAt
    delete data.updatedAt
    data
  #### toFullJSON(seenObjects)
  # > Encodes Object to Parse formatted JSON object
  _toFullJSON: (seenObjects)->
    # loops on `_.clone` of Object attributes and applies `sparse._encodes`
    _.each (json = _.clone @attributes), (v, k) -> json[key] = sparse._encode v, seenObjects
    # loops on `__op` and sets to JSON object
    _.each @__op, (v, k) -> json[v] = k
    # sets `objectId` from `id`
    json.objectId  = @id if _.has @, 'id'
    # sets `createdAt` from attributes
    json.createdAt = (if _.isDate @createdAt then @createdAt.toJSON() else @createdAt) if _.has @, 'createdAt'
    # sets `updatedAt` from attributes
    json.updatedAt = (if _.isDate @updatedAt then @updatedAt.toJSON() else @updatedAt) if _.has @, 'updatedAt'
    # sets `__type` to Object
    json.__type    = 'Object'
    # sets `className` from Object properties
    json.className = @className
    # returns the JSON object
    json
  #### __op
  # > Holder for Object operations
  __op: {}
  #### _serverData
  # > holder for data as last fetched from server
  _serverData:{}
  #### _opSetQueue
  # > Holder for Object operations Queue
  _opSetQueue: [{}]
  #### __isDirty
  # > indicates if any attribute has changed since last save
  __isDirty:false
  #### dirty()
  # > returns true if Object `attributes` have changed
  dirty:->
    @__isDirty or @hasChanged()
  #### _toPointer()
  # > Returns a `Pointer` reference of this `Object` for use by `sparse._encode`
  _toPointer: ->
    # throws an error if we try to get a`Pointer` of an item with no id
    throw new Error 'Can\'t serialize an unsaved sparse.Object' if @isNew()
    # returns the pointer
    __type: 'Pointer'
    className: @className
    objectId: @id
  #### _finishFetch(serverData, hasData)
  # > Cleans up Object properties
  _finishFetch: (serverData, hasData)->
    # resets `_opSetQueue`
    @_opSetQueue = [{}]
    # handles special attributes
    @_mergeMagicFields serverData
    # decodes `serverData`
    _.each serverData, (v, k) => @_serverData[key] = sparse._decode k, v
    # stores `hasData` to object scope
    @_hasData = hasData
    # resets `__isDirty`
    @__isDirty = false
  #### _mergeMagicFields(attrs)
  # > Returns a `Pointer` reference of this `Object` for use by `sparse._encode`
  _mergeMagicFields: (attrs)->
    # loops through field names
    _.each ['id', 'objectId', 'createdAt', 'updatedAt'], (attr)=>
        if attrs[attr]
          # switches on existing attributes
          switch attrs[attr]
            # handles `objectId`
            when 'objectId'
              @id = attrs[attr] 
            # handles `createdAt` and `updatedAt`
            when 'createdAt', 'updatedAt'
              @[attr] = if !_.isDate attrs[attr] then sparse._parseDate attrs[attr] else attrs[attr]
          # deletes the attribute
          delete attrs[attr]
          
          
  ## Atomic Operations
  # > Parse API Operation Methods
  #
         
          
  #### add(attr, object)
  # > Concats passed objects to an Array attribute
  add:(attr, objects)->
    # tests for array and applies `concat`
    @set (({})[attr] = a.concat objects), null if _.isArray (a = @get 'attr')
    # returns changedAttributes object
    @changedAttributes()
  #### addUnique(attr, object)
  # > Uniquely adds passed objects to an Array attribute
  addUnique:(attr, objects)->
    # tests for array and applies `_.union`
    @set (({})[attr] = _.union a, objects), null if _.isArray (a = @get 'attr')
    # returns changedAttributes object
    @changedAttributes()
  #### increment(attr, amount)
  # > Increments a Number to the passed value or by 1
  increment: (attr, amount)->
    # tests for Number and adds given value
    @set ({})[attr] = a + (amount ?= 1), null if _.isNumber (a = @get 'attr')
    # returns changedAttributes object
    @changedAttributes()
          
          
          
## Static Methods
# > Parse API helper methods
#
          
          
#### sparse.Object._classMap
# > holder for user defined sparse.Objects
sparse.Object._classMap    = {}
#### sparse.Object._getSubclass
# > returns reference to user defined `sparse.Object` if `className` can be addressed
sparse.Object._getSubclass = (className)->
  # throws error if className is not a string
  throw 'sparse.Object._getSubclass requires a string argument.' if !_.isString className
  # sets className on `sparse.Object._classMap` if new and returns Class 
  sparse.Object._classMap[className] ?= if (clazz = sparse.Object._classMap[className]) then clazz else sparse.Object.extend className
#### sparse.Object._create
# > Creates an instance of a subclass of sparse.Object for the given classname
sparse.Object._create = (className, attr, opts)->
  # tests for existing Class as Function
  if typeof (clazz = sparse.Object._getSubclass className) is 'function'
    # returns the found class
    return new clazz attr, opts
  else
    # throws error if no class was found
    throw "unable to create #{className}"
#### sparse.Object.saveAll
# > Batch saves a given list of sparse.Objects
sparse.Object.saveAll = (list, options)->
  # create new `sparse.Batch` with the passed list
  (new sparse.Batch list
  ).exec options
    # calls `Batch.exec` with callbacks
    complete:(m,r,o)=>
      options.success m,r,o if options.success
    error:(m,r,o)=>
      options.error m,r,o if options.error
#### sparse.Object.destroyAll
# > Batch destroys a given list of sparse.Objects
sparse.Object.destroyAll = (list, options)->
  # create new `sparse.Batch` with the passed list
  (new sparse.Batch
  ).destroy list, options
    # calls `Batch.destroy` with callbacks
    complete:(m,r,o)=>
      options.success m,r,o if options.success
    error:(m,r,o)=>
      options.error m,r,o if options.error