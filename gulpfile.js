var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var stylus = require('gulp-stylus');
var jade = require('gulp-jade');

gulp.task('coffee', function() {
	gulp.src('./src/js/*.coffee')
		.pipe(coffee({bare: true}).on('error', gutil.log))
		.pipe(gulp.dest('./public/js/'));
});
gulp.task('one', function () {
	gulp.src('./src/css/main.styl')
		.pipe(stylus())
		.pipe(gulp.dest('./public/css/'));
});
gulp.task('templates', function() {
  gulp.src('./src/*.jade')
    .pipe(jade())
    .pipe(gulp.dest('./public/'))
});
gulp.task('default', function() {
	gulp.watch('./src/js/*.coffee', ['coffee']);
	gulp.watch('./src/css/main.styl', ['one']);
	gulp.watch('./src/*.jade', ['templates']);
});
