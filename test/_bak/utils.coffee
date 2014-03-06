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

describe 'sparse Utils Test Suite', ->
  class AClass extends sparse.Object
  it 'sparse Utils create a encode a Relation', (done)=>
    @aClass = new AClass
    @aClass.set {myValue:'A Value'}
    @aClass.save null,
      success:(s,r,o)=>
        sparse._encode( @aClass ).__type.should.equal 'Pointer'
        done()
      error:(s,r,o)=>
        console.error s
    