fs              = require 'fs'
(chai           = require 'chai').should()
_               = (require 'underscore')._
Backbone        = require 'backbone'
Backbone.$      = require 'jQuery'
{sparse}        = require '../lib/sparse'
#jsonData        = require './data.json'
server          = true

if (typeof process.env.PARSE_APP_ID == 'undefined' or typeof process.env.PARSE_REST_KEY == 'undefined')
  console.error 'Failure: PARSE_APP_ID and PARSE_REST_KEY are required to be set in your env vars to run tests'
  process.exit 1
  
sparse.initialize process.env.PARSE_APP_ID, process.env.PARSE_REST_KEY

describe 'sparse.Relation Test Suite', ->
  class RelateClass extends sparse.Object
  class ParentClass extends sparse.Object
  # it 'sparse.Relation create a parent Relation', (done)=>
    # @parentClass = new ParentClass
    # @parentClass.set {myValue:'A Value'}
    # @parentClass.save null,
      # success:(s,r,o)=>
        # done()
      # error:(s,r,o)=>
        # console.error s
  # it 'sparse.Relation create a second parent Relation', (done)=>
    # @parentClass2 = new ParentClass
    # @parentClass2.set {myValue:'A Second Value'}
    # @parentClass2.save null,
      # success:(s,r,o)=>
        # done()
      # error:(s,r,o)=>
        # console.error s
        
  # it 'sparse.Relation should create a new Relation', (done)=>
    # @parentClass = new ParentClass
    # @parentClass.set {myValue:'A Value'}
    # @relateClass = new RelateClass 
    # @relateClass.set {myName:'relation 1'}
    # # rel = @relateClass.relation 'parent'
    # # rel.add @parentClass
    # # console.log @parentClass._toPointer()
    # @relateClass.set parent:@parentClass # parent:{__op:"AddRelation", objects:[@parentClass._toPointer(), @parentClass2._toPointer()]}
    # # console.log @relateClass.attributes
    # @relateClass.save null,
      # success:(s,r,o)=>
        # # done()
      # completed:(s,r,o)=>
        # @object_id = @relateClass.get 'objectId'
        # done()
      # error:(s,r,o)=>
        # console.error r
  it 'sparse.Relation should fetch a  Relation', (done)=>
    @fetchClass = new RelateClass objectId:'fiGylUdN8m'
    @fetchClass.fetch
      success:(m,r,o)=>
        console.log arguments
        done()
      error:(s,r,o)=>
        console.error r   
  # it 'should teardown data for Queries', (done)=>
    # @data.destroyAll()