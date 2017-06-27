var gulp = require('gulp'),
	util = require('gulp-util'),
	vftp = require('vinyl-ftp'),
	pug  = require('gulp-pug')
	sass = require('gulp-sass'),
	coff = require('gulp-coffee');

// Compile everything
gulp.task('default', ['pug', 'sass', 'coffee']);

// Compiles Pug templates
gulp.task('pug', function() {
	return gulp.src('*.pug').pipe(pug({
		locals: {
			name: 'Weatha',
			intro: 'simple weather app, v1.0.0'
		}
	})).pipe(gulp.dest('dist/'));
});

// Compiles Sass
gulp.task('sass', function() {
	return gulp.src('sass/main.sass').pipe(sass({
		outputStyle: 'compressed'
	}).on('error', sass.logError)).pipe(gulp.dest('dist/css'));
});

// Compiles CoffeeScript
gulp.task('coffee', function() {
	return gulp.src('js/*.coffee').pipe(coff({
		bare: true
	})).pipe(gulp.dest('dist/js'));
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
	globs = 'dist/*';

	return gulp.src(globs, { buffer: false })
		  .pipe(conn.newer('/public_html/weatha'))
		  .pipe(conn.dest('/public_html/weatha'));
});
