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
  
describe 'sparse.User and sparse.Users Test Suite', ->
  @timeout 15000
  it 'Should create a new user', (done)=>
    (@testUser = new sparse.User username:'test.user',password:'sParseTest').signUp null,
      success:(m,r,o)=>
        done()
  it 'Should be able to login', (done)=>
    @testUser.logIn (@testUser.get 'username'), (@testUser.get 'password'),
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
    @testUser.logOut()
    @testUser.save email: 'a.user@email.com',
      error:(m,r,o)=>
        done()
  it 'Should be able to be destroyed', (done)=>
    @testUser.logIn 'test.user', 'sParseTest',
      success:(m,r,o)=>
        @testUser.destroy 
          success:(m,r,o)=>
            done()