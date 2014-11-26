gulp        = require 'gulp'
gutil       = require 'gulp-util'
coffee      = require 'gulp-coffee'
stylus      = require 'gulp-stylus'
jade        = require 'gulp-jade'
sourcemaps  = require 'gulp-sourcemaps'

gulp.task 'coffee', ->
  gulp.src './src/js/*.coffee'
    .pipe sourcemaps.init()
    .pipe coffee(bare: true).on 'error', gutil.log
    .pipe sourcemaps.write '.'
    .pipe gulp.dest './public/js/'

gulp.task 'one', ->
  gulp.src './src/css/*.styl'
    .pipe stylus({
      sourcemap:
        inline: true
        sourceRoot: '../..'
        basePath: 'src/css'
      url:
        name: 'url'
        paths: ["#{__dirname}/src/images"]
        limit: false
    })
    .pipe sourcemaps.init
      loadMaps: true
    .pipe sourcemaps.write '.',
      includeContent: false
      sourceRoot: '../../src/css'
    .pipe gulp.dest './public/css/'

gulp.task 'templates', ->
  gulp.src './src/*.jade'
    .pipe jade()
    .pipe gulp.dest './public/'

gulp.task 'default', ->
  gulp.watch './src/js/*.coffee', ['coffee']
  gulp.watch './src/css/main.styl', ['one']
  gulp.watch './src/*.jade', ['templates']
