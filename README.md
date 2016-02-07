[![Build Status](https://travis-ci.org/tandrewnichols/grunt-travis-matrix.png)](https://travis-ci.org/tandrewnichols/grunt-travis-matrix) [![downloads](http://img.shields.io/npm/dm/grunt-travis-matrix.svg)](https://npmjs.org/package/grunt-travis-matrix) [![npm](http://img.shields.io/npm/v/grunt-travis-matrix.svg)](https://npmjs.org/package/grunt-travis-matrix) [![Code Climate](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix) [![dependencies](https://david-dm.org/tandrewnichols/grunt-travis-matrix.png)](https://david-dm.org/tandrewnichols/grunt-travis-matrix)

# grunt-travis-matrix

Run matrix-specific grunt tasks on travis

## Getting Started

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```bash
npm install grunt-travis-matrix --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```javascript
grunt.loadNpmTasks('grunt-travis-matrix');
```

Alternatively, install [task-master](http://github.com/tandrewnichols/task-master) and let it manage this for you.

## The "travisMatrix" task

One problem I've run into using travis is that there is currently no way to tell it to run certain scripts only for certain matrix combinations (e.g. only on node v0.10). This task is designed to do that for you.

### Overview

In your project's Gruntfile, add a section named `travisMatrix` to the data object passed into `grunt.initConfig()`. Each target should have a `test` property and a `tasks` property. The test property is a simple function that returns true or false. If it returns true, the tasks inside the `tasks` property will be queued to run.

```javascript
grunt.initConfig({
  travisMatrix: {
    v4: {
      test: function() {
        return /^v4/.test(process.version);
      },
      tasks: ['foo', 'bar']
    }
  }
});
```

This task can pair well with an arbitrary shell task wrapper like [grunt-exec](https://github.com/jharding/grunt-exec).

## Contributing

Please see [the contribution guidelines](CONTRIBUTING.md).
