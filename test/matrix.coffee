EventEmitter = require('events').EventEmitter

describe 'matrix task', ->
  Given -> @grunt =
    registerMultiTask: sinon.stub()
    log:
      writeln: sinon.stub()
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
  Given -> @cwd = process.cwd()
  Given -> @subject = sandbox '../tasks/matrix',
    child_process: @cp

  When -> @subject @grunt
  And -> expect(@grunt.registerMultiTask).to.have.been.calledWith 'matrix', 'Tasks that run under the right travis matrix', sinon.match.func
  And -> @task = @grunt.registerMultiTask.getCall(0).args[2]

  describe 'cmd is string', ->
    Given -> @cp.exec.withArgs('foo bar baz', { cwd: @cwd }, sinon.match.func).callsArgWith 2, null, 'stdout', 'stderr'
    Given -> @context.options.returns
      cmd: 'foo bar baz'
    When -> @task.apply @context, []
    Then -> expect(@cb).to.have.been.called

  describe 'cmd is array', ->
    Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { stdio: 'inherit', cwd: @cwd }).returns @emitter
    Given -> @context.options.returns
      cmd: ['foo', 'bar', 'baz']
    When ->
      @task.apply @context, []
      @emitter.emit 'close', 0
    Then -> expect(@cb).to.have.been.calledWith 0

  describe 'cmd is function', ->
    Given -> @func = sinon.stub()
    Given -> @context.options.returns
      cmd: @func
    When -> @task.apply @context, []
    Then -> expect(@func).to.have.been.calledWith @grunt, @context.options(), @cb

  describe 'cmd in task definition', ->
    describe 'cmd is string', ->
      Given -> @cp.exec.withArgs('foo bar baz', { cwd: @cwd }, sinon.match.func).callsArgWith 2, null, 'stdout', 'stderr'
      Given -> @context.data = 'foo bar baz'
      When -> @task.apply @context, []
      Then -> expect(@cb).to.have.been.called

    describe 'cmd is array', ->
      Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { stdio: 'inherit', cwd: @cwd }).returns @emitter
      Given -> @context.data = ['foo', 'bar', 'baz']
      When ->
        @task.apply @context, []
        @emitter.emit 'close', 0
      Then -> expect(@cb).to.have.been.calledWith 0

    describe 'cmd is function', ->
      Given -> @func = sinon.stub()
      Given -> @context.data = @func
      When -> @task.apply @context, []
      Then -> expect(@func).to.have.been.calledWith @grunt, @context.options(), @cb

  describe 'additional options', ->
    describe 'cwd', ->
      Given -> @cp.exec.withArgs('foo bar baz', { cwd: '..' }, sinon.match.func).callsArgWith 2, null, 'stdout', 'stderr'
      Given -> @context.options.returns
        cmd: 'foo bar baz'
        cwd: '..'
      When -> @task.apply @context, []
      Then -> expect(@cb).to.have.been.called

    describe 'stdio is false', ->
      Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { cwd: @cwd }).returns @emitter
      Given -> @context.options.returns
        cmd: ['foo', 'bar', 'baz']
        stdio: false
      When ->
        @task.apply @context, []
        @emitter.emit 'close', 0
      Then -> expect(@cb).to.have.been.calledWith 0

    describe 'stdio is something else', ->
      Given -> @emitter.stdout = new EventEmitter()
      Given -> @emitter.stderr = new EventEmitter()
      Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { stdio: 'pipe', cwd: @cwd }).returns @emitter
      Given -> @context.options.returns
        cmd: ['foo', 'bar', 'baz']
        stdio: 'pipe'
      When ->
        @task.apply @context, []
        @emitter.stdout.emit 'data', 'stdout'
        @emitter.stderr.emit 'data', 'stderr'
        @emitter.emit 'close', 0
      Then -> expect(@cb).to.have.been.calledWith 0
      And -> expect(@grunt.log.writeln).to.have.been.calledWith 'stdout'
      And -> expect(@grunt.log.writeln).to.have.been.calledWith 'stderr'

    describe 'cmd is array', ->
      Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { cwd: @cwd }).returns @emitter
      Given -> @context.options.returns
        cmd: ['foo', 'bar', 'baz']
        stdio: false
      When ->
        @task.apply @context, []
        @emitter.emit 'close', 0
      Then -> expect(@cb).to.have.been.calledWith 0

  describe 'with error', ->
    describe 'force is true', ->
      Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { stdio: 'inherit', cwd: @cwd }).returns @emitter
      Given -> @context.target = 'foo'
      Given -> @context.options.returns
        cmd: ['foo', 'bar', 'baz']
        force: true
      When ->
        @task.apply @context, []
        @emitter.emit 'close', 2
      And -> console.log(@grunt.log.writeln.getCall(0).args)
      Then -> expect(@cb).to.have.been.calledWith 0
      And -> expect(@grunt.log.writeln).to.have.been.calledWith 'matrix:foo returned code 2. Ignoring...'

    describe 'force is false', ->
      Given -> @cp.spawn.withArgs('foo', ['bar', 'baz'], { stdio: 'inherit', cwd: @cwd }).returns @emitter
      Given -> @context.options.returns
        cmd: ['foo', 'bar', 'baz']
      When ->
        @task.apply @context, []
        @emitter.emit 'close', 2
      Then -> expect(@cb).to.have.been.calledWith 2
