var gulp = require('gulp'),
	util = require('gulp-util'),
	vftp = require('vinyl-ftp'),
	pug  = require('gulp-pug')
	sass = require('gulp-sass'),
	coff = require('gulp-coffeescript'),
	watch= require('gulp-watch');

// Compile everything
gulp.task('default', ['pug', 'sass', 'coffee']);

// Recompile everything on changing Pug, Sass, or CoffeeScript files
gulp.task('watch', function() {
	gulp.start('default');
	watch(['*.pug', 'sass/*.sass', 'js/*.coffee'], function () {
		gulp.start('default');
	});
});

// Compiles Pug templates
gulp.task('pug', function() {
	return gulp.src('*.pug').pipe(pug({
		locals: {
			name: 'Weatha',
			intro: 'simple weather app v1.0.3',
			githubURL: 'https://github.com/pschfr/weatha'
		}
	})).pipe(gulp.dest('dist/'));
});

// Compiles Sass
gulp.task('sass', function() {
	return gulp.src('sass/*.sass').pipe(sass({
		outputStyle: 'compressed'
	}).on('error', sass.logError)).pipe(gulp.dest('dist/css'));
});

// Compiles CoffeeScript
gulp.task('coffee', function() {
	return gulp.src('js/*.coffee').pipe(coff({
		bare: true
	})).on('error', util.log).pipe(gulp.dest('dist/js'));
});

// Uploads to server via FTP
gulp.task('deploy', function() {
	var conn = vftp.create({
		host: 'paulmakesthe.net',
		user: 'username',
		pass: 'password',
		parallel: 8,
		log: util.log
	}),
	globs = 'dist/**';

	return gulp.src(globs, { buffer: false })
		  .pipe(conn.newer('/public_html/weatha'))
		  .pipe(conn.dest('/public_html/weatha'));
});
