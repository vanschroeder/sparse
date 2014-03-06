fs              = require 'fs'
(chai           = require 'chai').should()
_               = (require 'underscore')._
Backbone        = require 'backbone'
Backbone.$      = require 'jQuery'
{sparse}        = require '../lib/sparse'
jsonData        = require './data.json'
server          = true

if (typeof process.env.PARSE_APP_ID == 'undefined' or typeof process.env.PARSE_REST_KEY == 'undefined')
  console.error 'Failure: PARSE_APP_ID and PARSE_REST_KEY are required to be set in your env vars to run tests'
  process.exit 1
  
sparse.APP_ID   = process.env.PARSE_APP_ID
sparse.REST_KEY = process.env.PARSE_REST_KEY

describe 'sparse.Query Test Suite', ->
  # it 'should setup data for Queries', (done)=>
  # populate data for queries
    # (@data = new (@clazz = class TestCompanies extends sparse.Collection
      # model: class TestCompany extends sparse.Model
        # defaults:
          # name:""
          # contact_email:""
          # tagline:""
    # )).set jsonData.TestCompanies
    # @data.saveAll
      # success:(r,s,o) => done()
  # it 'sparse.Query should initialize a new Query object', (done)=>
    # test = sparse.Collection
    # q = new sparse.Query( test
    # ).greaterThanOrEqualTo( 'company_size', 300
    # ).contains( 'tagline', 'revolutionize'
    # ).equalTo( 'active', true
    # ).find
      # success:(s,r,o)=>
        # done()
      # error:(s,r,o)=>
        # console.error s
  it 'should query Relations', (done)=>
    class RelateClass extends sparse.Object
    class ParentClass extends sparse.Object
    (q = (o = new ParentClass).query()).relatedTo (new RelateClass "objectId":"fiGylUdN8m"), 'parent'
    o.fetch
      success:(m,r,o)->
        # console.log arguments
        done()
      error:->
        throw arguments[0]
        console.log arguments
  # it 'should teardown data for Queries', (done)=>
    # @data.destroyAll()