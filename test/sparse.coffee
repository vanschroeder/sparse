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

describe 'sParse Test Suite', ->
  describe 'sparse Inflection', =>
    it 'should have PLURALIZATION', =>
      sparse.Inflection.pluralize('Man').should.equal 'Men'
      sparse.Inflection.pluralize('Person').should.not.equal 'Persons'
      sparse.Inflection.pluralize('Person').should.equal 'People'
      sparse.Inflection.pluralize('Ox').should.equal 'Oxen'
      sparse.Inflection.pluralize('Mouse').should.equal 'Mice'
      sparse.Inflection.pluralize('Deer').should.equal 'Deer'
      sparse.Inflection.pluralize('Child').should.equal 'Children'
      sparse.Inflection.pluralize('Life').should.equal 'Lives'
      sparse.Inflection.pluralize('Lens').should.equal 'Lenses'
      sparse.Inflection.pluralize('Mine').should.equal 'Mines'
      sparse.Inflection.pluralize('Business').should.equal 'Businesses'
      sparse.Inflection.pluralize('Octopus').should.equal 'Octopi'
  describe 'sparse.Util._parseDate', =>
    it 'should parse iso8601 UTC datetime', =>
      sparse._parseDate('2013-10-20T00:39:00.00Z').should.not.equal null
  describe 'sparse.getConstructorName', =>
    it 'should return a constructor Name', =>
      (new (class TestCase
        constructor: -> @name = sparse.getConstructorName @
      )).name.should.equal 'TestCase'