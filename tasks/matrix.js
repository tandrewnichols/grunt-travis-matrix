var cp = require('child_process');

module.exports = function(grunt) {
  grunt.registerMultiTask('matrix', 'Tasks that only run under the right travis matrix', function() {
    var done = this.async();
    var options = this.options();
    if (typeof options.cmd === 'string') {
      cp.exec(options.cmd, { cwd: options.cwd || '.' }, function(err, stdout, stderr) {
        console.log(arguments);
        done();
      });
    } else {
      var opts = { cwd: options.cwd || '.', stdio: 'inherit' };
      if (options.stdio === false) delete opts.stdio;
      var proc = cp.spawn(options.cmd.shift(), options.cmd, opts);
      proc.on('close', function(code) {
        done();
      });
    }
  });
};
