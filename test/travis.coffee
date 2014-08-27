describe 'travis task', ->
  Given -> @grunt =
    registerTask: sinon.stub()
    task:
      run: sinon.stub()
  Given -> @context =
    options: sinon.stub()
    data: {}
  Given -> @context.options.returns {}
  Given -> @subject = sandbox '../tasks/travis', {}

  When -> @subject @grunt
  And -> expect(@grunt.registerTask).to.have.been.calledWith 'travis', 'Watches the travis matrix to enqueue matrix-specific tasks', sinon.match.func
  And -> @task = @grunt.registerTask.getCall(0).args[2]
  
  describe '"targets" is an object', ->
    afterEach -> delete process.env.FOO
    Given -> @context.options.returns
      targets:
        test: '<%= FOO %>'
        when: 'bar'
        task: 'matrix:foo'

    describe 'test passes', ->
      Given -> process.env.FOO = 'bar'
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run).to.have.been.calledWith ['matrix:foo']

    describe 'test does not pass', ->
      Given -> process.env.FOO = 'nope'
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run.called).to.be.false()

  describe '"targets" is an array', ->
    Given -> @version = process.version
    afterEach -> delete process.env.FOO
    afterEach -> process.version = @version

    describe 'both pass', ->
      Given -> process.env.FOO = 'bar'
      Given -> process.version = '0.10.30'
      Given -> @context.options.returns
        targets: [
          test: '<%= FOO %>'
          when: 'bar'
          task: 'matrix:foo'
        ,
          test: '<%= version %>'
          when: '0.10'
          task: 'matrix:v0.10'
        ]
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run).to.have.been.calledWith ['matrix:foo', 'matrix:v0.10']

    describe 'one passes', ->
      Given -> process.env.FOO = 'bar'
      Given -> process.version = '0.8.30'
      Given -> @context.options.returns
        targets: [
          test: '<%= FOO %>'
          when: 'bar'
          task: 'matrix:foo'
        ,
          test: '<%= version %>'
          when: '0.10'
          task: 'matrix:v0.10'
        ]
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run).to.have.been.calledWith ['matrix:foo']

    describe 'none passes', ->
      Given -> process.env.FOO = 'baz'
      Given -> process.version = '0.8.30'
      Given -> @context.options.returns
        targets: [
          test: '<%= FOO %>'
          when: 'bar'
          task: 'matrix:foo'
        ,
          test: '<%= version %>'
          when: '0.10'
          task: 'matrix:v0.10'
        ]
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run.called).to.be.false()

  describe '"targets" is a string', ->
    afterEach -> delete process.env.FOO
    
    describe 'test passes', ->
      Given -> process.env.FOO = 'bar'
      Given -> @context.options.returns
        targets: '<%= FOO == "bar" %>'
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run).to.have.been.calledWith ['matrix:bar']

    describe 'test does not pass', ->
      Given -> process.env.FOO = 'baz'
      Given -> @context.options.returns
        targets: '<%= FOO == "bar" %>'
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run.called).to.be.false()

  describe '"targets" is an array of strings', ->
    Given -> @version = process.version
    afterEach -> delete process.env.FOO
    afterEach -> process.version = @version
    
    describe 'both pass', ->
      Given -> process.env.FOO = 'bar'
      Given -> process.version = '0.10.30'
      Given -> @context.options.returns
        targets: ['<%= FOO == "bar" %>', '<%= version == "0.10" %>']
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run).to.have.been.calledWith ['matrix:bar', 'matrix:0.10']

    describe 'one passes', ->
      Given -> process.env.FOO = 'bar'
      Given -> process.version = '0.8.30'
      Given -> @context.options.returns
        targets: ['<%= FOO == "bar" %>', '<%= version == "0.10" %>']
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run).to.have.been.calledWith ['matrix:bar']

    describe 'none pass', ->
      Given -> process.env.FOO = 'baz'
      Given -> process.version = '0.8.30'
      Given -> @context.options.returns
        targets: ['<%= FOO == "bar" %>', '<%= version == "0.10" %>']
      When -> @task.apply @context, []
      Then -> expect(@grunt.task.run.called).to.be.false()

