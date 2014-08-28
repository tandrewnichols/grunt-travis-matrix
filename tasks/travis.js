var _ = require('lodash');
_.templateSettings.interpolate = /{{([\s\S]+?)}}/g;
var extend = require('config-extend');
var list = require('listify');

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
          tasks: 'matrix:' + context[ target.match(/\{\{ ([^\s]+)/)[1] ]
        };
      }
      if (_.template(target.test, context) === target.when.toString()) memo = memo.concat(target.tasks);
      return memo;
    }, []);

    if (tasks.length) {
      grunt.log.writeln('Queueing tasks ' + list(tasks));
      grunt.task.run(tasks);
    }
  });
};
