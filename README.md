[![Build Status](https://travis-ci.org/tandrewnichols/grunt-travis-matrix.png)](https://travis-ci.org/tandrewnichols/grunt-travis-matrix) [![downloads](http://img.shields.io/npm/dm/grunt-travis-matrix.svg)](https://npmjs.org/package/grunt-travis-matrix) [![npm](http://img.shields.io/npm/v/grunt-travis-matrix.svg)](https://npmjs.org/package/grunt-travis-matrix) [![Code Climate](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/grunt-travis-matrix) [![dependencies](https://david-dm.org/tandrewnichols/grunt-travis-matrix.png)](https://david-dm.org/tandrewnichols/grunt-travis-matrix)

[![NPM info](https://nodei.co/npm/grunt-travis-matrix.png?downloads=true)](https://nodei.co/npm/grunt-travis-matrix.png?downloads=true)


# grunt-travis-matrix

Run matrix-specific grunt tasks on travis

## Getting Started
This plugin requires Grunt `~0.4.5`

If you haven't used [Grunt](http://gruntjs.com/) before, be sure to check out the [Getting Started](http://gruntjs.com/getting-started) guide, as it explains how to create a [Gruntfile](http://gruntjs.com/sample-gruntfile) as well as install and use Grunt plugins. Once you're familiar with that process, you may install this plugin with this command:

```bash
npm install grunt-travis-matrix --save-dev
```

Once the plugin has been installed, it may be enabled inside your Gruntfile with this line of JavaScript:

```javascript
grunt.loadNpmTasks('grunt-travis-matrix');
```

Alternatively, install [task-master](http://github.com/tandrewnichols/task-master) and let it manage this for you.

## The "travis" task

Travis-ci is awesome, and you should use it if you're not already (seriously, it's very easy to set up and the benefits are instant). One problem I've run into using travis is that there is currently no way to tell it to run certain scripts only for certain matrix combinations (e.g. only on node v0.10). This task is designed to do that for you. It examines the matrix and compares it to your requirements, enqueueing additional tasks if it finds a match.

### Overview

In your project's Gruntfile, add a section named `travis` to the data object passed into `grunt.initConfig()`. Again, I recommend [task-master](https://github.com/tandrewnichols/task-master) as it makes grunt configuration much cleaner. Add a key called `targets` to the options for that task. This options can take many forms, but the most explicit is an array of objects:

```javascript
grunt.initConfig({
  travis: {
    options: {
      targets: [
        {
          test: '{{ FOO }}',
          when: 'bar',
          tasks: 'mocha:test'
        },
        {
          test: '{{ version }}',
          when: 'v0.10',
          tasks: 'mochacov:lcov'
        }
      ]
    }
  },
});
```

The `travis` task will use underscore interpolation with `process.env` combined with `process.version` as the context (note that `process.version` _does_ start with "v" - this took me some time to get right for some reason). The interpolation pattern is different than Grunt's built-in style because Grunt tries to be helpful by interpolating the strings before they even reach the task. :(

If you have only one "target", you can specify `targets` as an object literal:

```javascript
grunt.initConfig({
  travis: {
    options: {
      targets: {
        test: '{{ FOO }}',
        when: 'bar',
        tasks: 'mocha:test'
      }
    }
  },
});
```

`tasks` can also be an array:

```javascript
grunt.initConfig({
  travis: {
    options: {
      targets: {
        test: '{{ FOO }}',
        when: 'bar',
        tasks: ['jshint:all', 'mocha:test']
      }
    }
  },
});
```

There is also a short form you can use for very simple comparisons. This can be a string or an array of strings:

```javascript
grunt.initConfig({
  travis: {
    options: {
      targets: '{{ FOO == "bar" }}'
    }
  }
});
```

or

```javascript
grunt.initConfig({
  travis: {
    options: {
      targets: ['{{ FOO == "bar" }}', '{{ version == "v0.10" }}']
    }
  }
});
```

In this case the default task will be `matrix` (see below), and the target will be whatever the value of that property on the context is (so in the example above, the value of process.env.FOO and process.version).

## The "matrix" task

Tasks you specify in the `travis` task do not have to be targets on the `matrix` task, but they can be. The `matrix` task is a way to run arbitrary bash commands as part of your build process (but only for certain matrix combinations). Currently, there are two ways to use this task (but more to come). You specify a `cmd` option as either a string or an array. If you pass a string, the matrix task will run `child_process.exec`; if you pass an array, it will use `child_process.spawn`. So it depends mostly on what you want to do. Keep in mind that exec has an output buffer restriction of 128KB, but also works "better" (read easier) for complicated bash expressions. Here's an example based on the above supposed travis task configuration:

```javascript
grunt.initConfig({
  matrix: {
    bar: {
      options: {
        cmd: ['npm', 'config', 'set', 'author', 'Big Bird']
      }
    },
    'v0.10': {
      options: {
        cmd: 'codeclimate < coverage/coverage.lcov'
      }
    }
  }
});
```

The codeclimate example is the reason I wrote this in the first place. I want to send test coverage reports, but why do it for every build in the matrix, when you only need it once?

Besides these options, you can also pass `cwd` for either version and `stdio` for the spawn version (`exec` does not accept `stdio`). The defaults are '.' and 'inherit' respectively. If you want to simple turn `stdio` off (which you probably shouldn't want to do), you can pass `stdio: false`.

```javascript
grunt.initConfig({
  matrix: {
    bar: {
      options: {
        cmd: ['npm', 'config', 'set', 'author', 'Big Bird'],
        cwd: '../../sesame-street',
        stdio: [null, process.stdout, null]
      }
    }
  }
});
```
