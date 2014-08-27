var _ = require('lodash');
var extend = require('config-extend');

module.exports = function(grunt) {
  grunt.registerTask('travis', 'Watches the travis matrix to enqueue matrix-specific tasks', function() {
    var options = this.options();
    var targets = options.targets;
    var context = extend({}, _.clone(process.env), { version: process.version.split('.').slice(0, 2).join('.') });

    if (!_.isArray(targets)) targets = [targets];
    var tasks = _.reduce(targets, function(memo, target) {
      if (!_.isPlainObject(target)) {
        target = {
          test: target,
          when: true,
          task: 'matrix:' + target.match(/<%= .* == '?"?([^'"\s]+)/)[1].toLowerCase()
        };
      }
      if (_.template(target.test, context) === target.when.toString()) memo.push(target.task);
      return memo;
    }, []);

    if (tasks.length) {
      grunt.task.run(tasks);
    }
  });
};
