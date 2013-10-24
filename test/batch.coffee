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
  
describe 'sparse.Batch Test Suite', ->
  @timeout 15000
  describe 'sparse.Batch Creation', =>
    @data = new (@clazz = class TestCompanies extends sparse.Collection
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
      @timeout 15000
      @batch.exec
        complete:(m,r,o)=>
          done()
        success:(m,r,o)=>
        error:(m,r,o)=>
          console.error m
  describe 'sparse.Batch Delete', =>
    @timeout 15000
    it 'Should mark items for deletion', (done)=>
      @data.reset {}
      @data.fetch
        success: (m,r,o)=>
          @batch.destroy @data.models
          done()
        error: (m,r,o)=>
          console.error r
    it 'Should have a count of Records on the Server', =>
      @data.count().should.equal 101
    it 'Should Batch Delete', (done)=>
      @timeout 15000
      @batch.exec
        complete:(m,r,o)=>
          done()
        error: (m,r,o)=>
          console.error m
    it 'Should have deleted all data records', (done)=>
      @data.reset {}
      @data.fetch
        success: (m,r,o)=>
          @data.count().should.equal 0
          done()
        error: (m,r,o)=>
          console.error r