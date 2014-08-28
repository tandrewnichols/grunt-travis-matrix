var cp = require('child_process');

module.exports = function(grunt) {
  grunt.registerMultiTask('matrix', 'Tasks that only run under the right travis matrix', function() {
    var done = this.async();
    var options = this.options();

    if (typeof options.cmd === 'string') {
      cp.exec(options.cmd, { cwd: options.cwd || '.' }, function(err, stdout, stderr) {
        if (err) grunt.log.writeln(err);
        if (stdout) grunt.log.writeln(stdout);
        if (stderr) grunt.log.writeln(stderr);
        done();
      });
    } else {
      var opts = { cwd: options.cwd || '.', stdio: options.stdio || 'inherit' };
      if (options.stdio === false) delete opts.stdio;
      var proc = cp.spawn(options.cmd.shift(), options.cmd, opts);

      if (proc.stdout && options.stdio !== false) {
        proc.stdout.on('data', function(data) {
          grunt.log.writeln(data.toString());
        });
      }

      if (proc.stderr && options.stdio !== false) {
        proc.stderr.on('data', function(data) {
          grunt.log.writeln(data.toString());
        });
      }

      proc.on('close', function(code) {
        if (code) done(code);
        else done();
      });
    }
  });
};
