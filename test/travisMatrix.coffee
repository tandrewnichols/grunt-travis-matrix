sinon = require 'sinon'

describe 'travis task', ->
  Given -> @grunt =
    registerMultiTask: sinon.stub()
    task:
      run: sinon.stub()
    log:
      writeln: sinon.stub()
  Given -> @context = {}
  Given -> @subject = require '../tasks/travisMatrix'

  context 'test is truthy', ->
    Given -> @context.data =
      test: -> true
      tasks: ['foo', 'bar']
    When -> @subject @grunt
    And -> @grunt.registerMultiTask.getCall(0).args[2].apply @context
    Then ->
      @grunt.log.writeln.calledWith('Queueing tasks foo and bar').should.be.true()
      @grunt.task.run.calledWith(['foo', 'bar']).should.be.true()

  context 'test is truthy', ->
    Given -> @context.data =
      test: -> false
      tasks: ['foo', 'bar']
    When -> @subject @grunt
    And -> @grunt.registerMultiTask.getCall(0).args[2].apply @context
    Then ->
      @grunt.log.writeln.calledWith('Queueing tasks foo and bar').should.be.true
      @grunt.task.run.calledWith(['foo', 'bar']).should.be.true
