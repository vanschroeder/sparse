fs              = require 'fs'
(chai           = require 'chai').should()
_               = (require 'underscore')._
Backbone        = require 'backbone'
Backbone.$      = require 'jQuery'
{sparse}          = require '../lib/sparse'
jsonData        = require './data.json'
server          = true

if (typeof process.env.PARSE_APP_ID == 'undefined' or typeof process.env.PARSE_REST_KEY == 'undefined')
  console.error 'Failure: PARSE_APP_ID and PARSE_REST_KEY are required to be set in your env vars to run tests'
  process.exit 1
  
sparse.APP_ID   = process.env.PARSE_APP_ID
sparse.REST_KEY = process.env.PARSE_REST_KEY
  
describe 'sparse.Model Test Suite', ->
  it 'sparse.Model.saveAll should be STATIC', =>
    sparse.Model.saveAll.should.be.a 'function'
  it 'Model should be extensable', =>
    (@clazz = class Test extends (sparse.Model)).should.be.a 'function'
  it 'should safely get it\'s constructor.name', =>
    (sparse.getConstructorName @testModel = new @clazz()).should.equal 'Test'
  it 'should have a pluralized Parse API Class Name', =>
    (@testModel).className.should.equal 'Tests'
  it 'should save Data to the Parse API', (done)=>
    @timeout 15000
    o = 
      name:"A Test"
      description: "Testing Object create via Parse API"
    h = 
      success:(m,r,o)=>
        done()
    @testModel.save o, h
  it 'should have an ObjectID after saving', =>
    (@testModel.get 'objectId').should.not.equal null
  it 'should update Data to the Parse API', (done)=>
    @timeout 15000
    o = 
      active:true
    h = 
      success:(m,r,o)=>
        done()
    @testModel.save o, h
  it 'should delete it\'s self from the Parse API', (done)=>
    h = 
      success:(m,r,o)=>
        done()
    @testModel.destroy h