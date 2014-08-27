EventEmitter = require('events').EventEmitter

describe 'matrix task', ->
  Given -> @grunt =
    registerMultiTask: sinon.stub()
  Given -> @context =
    async: sinon.stub()
    options: sinon.stub()
  Given -> @context.options.returns {}
  Given -> @cp =
    spawn: sinon.stub()
    exec: sinon.stub()
  Given -> @emitter = new EventEmitter()
  Given -> @cb = sinon.stub()
  Given -> @context.async.returns @cb
  Given -> @subject = sandbox '../tasks/matrix',
    child_process: @cp

  When -> @subject @grunt
  And -> expect(@grunt.registerMultiTask).to.have.been.calledWith 'matrix', 'Tasks that only run under the right travis matrix', sinon.match.func
  And -> @task = @grunt.registerMultiTask.getCall(0).args[2]

  describe '"cmd" is string', ->
    Given -> @cp.exec.withArgs('foo bar baz', { cwd: '.' }, sinon.match.func).callsArgWith 2, null, 'stdout', 'stderr'
    Given -> @context.options.returns
      cmd: 'foo bar baz'
    When -> @task.apply @context, []
    Then -> expect(@cb).to.have.been.called

  describe '"cmd" is array', ->
    Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { stdio: 'inherit', cwd: '.' }).returns @emitter
    Given -> @context.options.returns
      cmd: ['foo', 'bar', 'baz']
    When ->
      @task.apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called

  describe 'additional options', ->
    Given -> @cp.exec.withArgs('foo bar baz', { cwd: '..' }, sinon.match.func).callsArgWith 2, null, 'stdout', 'stderr'
    Given -> @context.options.returns
      cmd: 'foo bar baz'
      cwd: '..'
    When -> @task.apply @context, []
    Then -> expect(@cb).to.have.been.called

  describe '"cmd" is array', ->
    Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { cwd: '.' }).returns @emitter
    Given -> @context.options.returns
      cmd: ['foo', 'bar', 'baz']
      stdio: false
    When ->
      @task.apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.called
