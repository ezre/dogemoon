gulp    = require 'gulp'
gutil   = require 'gulp-util'
coffee  = require 'gulp-coffee'
stylus  = require 'gulp-stylus'
jade    = require 'gulp-jade'


gulp.task 'coffee', ->
  gulp.src './src/js/*.coffee'
    .pipe coffee(bare: true).on 'error', gutil.log
    .pipe gulp.dest '.public/js/'

gulp.task 'one', ->
  gulp.src './src/css/main.styl'
    .pipe stylus()
    .pipe gulp.dest './public/css/'

gulp.task 'templates', ->
  gulp.src './src/*.jade'
    .pipe jade()
    .pipe gulp.dest './public/'

gulp.task 'default', ->
  gulp.watch './src/js/*.coffee', ['coffee']
  gulp.watch './src/css/main.styl', ['one']
  gulp.watch './src/*.jade', ['templates']
