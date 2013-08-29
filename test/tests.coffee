fs              = require 'fs'
(chai           = require 'chai').should()
_               = (require 'underscore')._
Backbone        = require 'backbone'
Backbone.$      = require 'jQuery'
{sparse}        = require '../src/sparse.coffee'
jsonData        = require '../demo/data.json'
server          = true

if (typeof process.env.PARSE_APP_ID == 'undefined' or typeof process.env.PARSE_REST_KEY == 'undefined')
  console.error 'Failure: PARSE_APP_ID and PARSE_REST_KEY are required to be set in your env vars to run tests'
  process.exit 1

describe 'sParse Test Suite', ->
  it 'should exist', =>
    (sparse).should.be.a 'object'
    sparse.APP_ID   = process.env.PARSE_APP_ID
    sparse.REST_KEY = process.env.PARSE_REST_KEY
  describe 'sparse Inflection', =>
    it 'should have PLURALIZATION', =>
      (sparse).Inflection.pluralize('Man').should.equal 'Men'
      (sparse).Inflection.pluralize('Person').should.not.equal 'Persons'
      (sparse).Inflection.pluralize('Person').should.equal 'People'
      (sparse).Inflection.pluralize('Ox').should.equal 'Oxen'
      (sparse).Inflection.pluralize('Mouse').should.equal 'Mice'
      (sparse).Inflection.pluralize('Deer').should.equal 'Deer'
      (sparse).Inflection.pluralize('Child').should.equal 'Children'
      (sparse).Inflection.pluralize('Life').should.equal 'Lives'
      (sparse).Inflection.pluralize('Lens').should.equal 'Lenses'
      (sparse).Inflection.pluralize('Mine').should.equal 'Mines'
      (sparse).Inflection.pluralize('Business').should.equal 'Businesses'
      (sparse).Inflection.pluralize('Octopus').should.equal 'Octopi' 
  describe 'sparse.Model lifecycle', ->
    it 'sparse.Model.saveAll should be STATIC', =>
      sparse.Model.saveAll.should.be.a 'function'
    it 'Model should be extensable', =>
      (@clazz = class Test extends (sparse.Model)).should.be.a 'function'
    it 'should safely get it\'s constructor.name', =>
      (sparse.getConstructorName @testModel = new @clazz()).should.equal 'Test'
    it 'should have a pluralized Parse API Class Name', =>
      (@testModel).className.should.equal 'Tests'
    it 'should save Data to the Parse API', (done)=>
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
  describe 'sparse.User lifecycle', ->
    @timeout 15000
    it 'Should create a new user', (done)=>
      (@testUser = new sparse.User).save {username:'test.user',password:'sParseTest'},
        success:(m,r,o)=>
          done()
    it 'Should be able to login', (done)=>
      @testUser.login (@testUser.get 'username'), (@testUser.get 'password'),
        success:(m,r,o)=>
          done()
    it 'Should have set SESSION_TOKEN after login', ->
      sparse.SESSION_TOKEN.should.be.a 'string'
    it 'Should be able to update itself', (done)=>
      @testUser.save email: 'a.user+changed@email.com',
        success:(m,r,o)=>
          done()
        error:(m,r,o)=>
          console.log r
    it 'Should be able to logout', (done)=>
      @testUser.logout()
      @testUser.save email: 'a.user@email.com',
        error:(m,r,o)=>
          done()
    it 'Should be able to be destroyed', (done)=>
      @testUser.login 'test.user', 'sParseTest',
        success:(m,r,o)=>
          @testUser.destroy 
            success:(m,r,o)=>
              done()
  describe 'sparse.Batch and sparse.Collections', ->
    @timeout 15000
    @data = new (class TestCompanies extends sparse.Collection
      model: class TestCompany extends sparse.Model
        defaults:
          name:""
          contact_email:""
          tagline:""
    )
    @data.set jsonData.TestCompanies
    @batch = new sparse.Batch
    @batch.save @data.models
    it 'Should Batch Save', (done)=>
      @batch.exec
        complete:(m,r,o)=>
          done()
        success:(m,r,o)=>
        error:(m,r,o)=>
          console.log m
    it 'Should Query Records on the Server', (done)=>
      @data.reset {}
      @data.query active:true,
        success:(m,r,o)=>
          @data.models.length.should.equal 51
          done()
    it 'Should mark items for deletion', (done)=>
      @data.reset {}
      @data.fetch
        success: (m,r,o)=>
          @batch.destroy @data.models
          done()
        error: (m,r,o)=>
          console.log r
    it 'Should have a count of Records on the Server', =>
      @data.count().should.equal 101
    it 'Should Batch Delete', (done)=>
      @batch.exec
        complete:(m,r,o)=>
          done()
        error: (m,r,o)=>
          console.log m
    it 'Should have deleted all data records', (done)=>
      @data.reset {}
      @data.fetch
        success: (m,r,o)=>
          @data.count().should.equal 0
          done()
        error: (m,r,o)=>
          console.log r