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
	watch(['index.pug', 'includes/*.pug'], function () {
		gulp.start('pug');
	});
	watch('sass/*.sass', function () {
		gulp.start('sass');
	});
	watch('js/*.coffee', function () {
		gulp.start('coffee');
	});
});

// Compiles Pug templates
gulp.task('pug', function() {
	return gulp.src('index.pug').pipe(pug({
		locals: {
			name: 'Weatha',
			version: '1.0.5',
			intro: 'simple weather app',
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

// Copies favicons to /dist
gulp.task('favicons', function() {
	gulp.src('includes/favicons/*').pipe(gulp.dest('dist/favicons/'));
});

// Uploads to server via FTP
gulp.task('deploy', function() {
	var conn = vftp.create({
		host: 'paulmakesthe.net',
		user: 'username',
		pass: 'password',
		parallel: 8,
		log: util.log,
		debug: util.log
	});
	return gulp.src('dist/**', { base: '.', buffer: false }).pipe(conn.dest('/public_html/weatha'));
});
