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
  it 'should setup test collections', (done)=>
    return done()
    class TestClasses extends sparse.Collection
      model:class TestClass extends sparse.Object
        defaults:
          valueA:""
          valueB:""
    col = new TestClasses
    col.create
      valueA:"foo"
      valueB:1
    col.create
      valueA:"foo"
      valueB:2
    col.create
      valueA:"foo"
      valueB:3
    col.create
      valueA:"bar"
      valueB:1
    col.create
      valueA:"bar"
      valueB:2
    col.create
      valueA:"bar"
      valueB:3
    col.create
      valueA:"baz"
      valueB:1
    col.create
      valueA:"baz"
      valueB:2
    col.create
      valueA:"baz"
      valueB:3
    sparse.Object.saveAll col.models, {completed:(s,r,o) => done()}
  it 'should query Relations', (done)=>
    done()
    # class RelateClass extends sparse.Object
    # class ParentClass extends sparse.Object
    # (q = (o = new ParentClass).query()).relatedTo (new RelateClass "objectId":"fiGylUdN8m"), 'parent'
    # o.fetch
      # success:(m,r,o)->
        # done()
      # error:->
        # throw arguments[0]
        # console.log arguments
  it 'should match equalTo', (done)=> 
    # return done()
    class TestClass extends sparse.Object
      defaults:
        valueA:""
        valueB:"" 
    class TestClasses extends sparse.Collection
      model:TestClass
    TestClasses.equalTo('valueA','foo').fetch success:(s,r,o)=>
      _.each r.results, (v)=> v.valueA.should.equal 'foo'
      done()
  it 'should match notEqualTo', (done)=> 
    class TestClass extends sparse.Object
      defaults:
        valueA:""
        valueB:"" 
    class TestClasses extends sparse.Collection
      model:TestClass
    TestClasses.notEqualTo('valueA','foo').fetch success:(s,r,o)=>
      _.each r.results, (v)=> v.valueA.should.not.equal 'foo'
      done()
  it 'should match greaterThan', (done)=> 
    class TestClass extends sparse.Object
      defaults:
        valueA:""
        valueB:"" 
    class TestClasses extends sparse.Collection
      model:TestClass
    TestClasses.greaterThan('valueB',2).fetch 
      success:(s,r,o)=>
        _.each r.results, (v)=> v.valueB.should.equal 3
        done()
      error:(s,r,o)=>
        console.log r
  it 'should match greaterThanOrEqualTo', (done)=> 
    class TestClass extends sparse.Object
      defaults:
        valueA:""
        valueB:"" 
    class TestClasses extends sparse.Collection
      model:TestClass
    TestClasses.greaterThanOrEqualTo('valueB',2).fetch 
      success:(s,r,o)=>
        _.each r.results, (v)=> v.valueB.should.be.within 2,3
        done()
      error:(s,r,o)=>
        console.log r
  it 'should match equalTo AND greaterThan', (done)=> 
    class TestClass extends sparse.Object
      defaults:
        valueA:""
        valueB:"" 
    class TestClasses extends sparse.Collection
      model:TestClass
    TestClasses.equalTo('valueA','foo').greaterThan('valueB',2).fetch 
      success:(s,r,o)=>
        _.each r.results, (v)=> 
          v.valueA.should.equal 'foo'
          v.valueB.should.equal 3
        done()
      error:(s,r,o)=>
        console.log r
  it 'should match contains', (done)=> 
    class TestClass extends sparse.Object
      defaults:
        valueA:""
        valueB:"" 
    class TestClasses extends sparse.Collection
      model:TestClass
    TestClasses.contains('valueA','az').fetch 
      success:(s,r,o)=>
        _.each r.results, (v)=>
          v.valueA.should.equal 'baz'
        done()
      error:(s,r,o)=>
        console.log r       
  # it 'should teardown data for Queries', (done)=>
    # @data.destroyAll()