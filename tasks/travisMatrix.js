var list = require('listify');

module.exports = function(grunt) {
  grunt.registerMultiTask('travisMatrix', 'Watches the travis matrix to enqueue matrix-specific tasks', function() {
    var tasks = this.data.tasks;
    if (this.data.test()) {
      grunt.log.writeln('Queueing tasks ' + list(tasks));
      grunt.task.run(tasks);
    }
  });
};
