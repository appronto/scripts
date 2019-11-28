/*
  Gulpfile.js for theming Mendix themes. Source: https://github.com/mendix/ux-theming.git, version 1.6.0
*/

/* jshint node:true */
'use strict';

// What is the name of the style folder in this theme folder?
var sourceStyleFolder = 'theme/styles';

// What is the name of the style folder in the deployment folder?
var deploymentStyleFolder = 'styles';

// Browsersync feature, please specify the host & port of the running project (without http://)
var proxyAddress = 'localhost:8080';

var baseRepo = 'https://github.com/appronto/'
var lsgrepo = 'Living-Style-Guide/'
var clientrepo = 'bkd/'

/*
  *************************************************************************
  * Don't try to edit below this line, unless you know what you are doing *
  *************************************************************************/
var gulp = require('gulp'),
    sass = require('gulp-sass'),
    browserSync = require('browser-sync').create(),
    path = require('path'),
    sourcemaps = require('gulp-sourcemaps'),
	git = require('gulp-git'),
	mkdirp = require('mkdirp'); 
	

var sourceFolder = './' + sourceStyleFolder + '/',
    sourceSassFolder = sourceFolder + 'sass/',
    sourceCssFolder = sourceFolder + 'css/',
	githubFolder = './github/';

var deploymentFolder = './deployment/web/' + deploymentStyleFolder,
    deploymentCssFolder = deploymentFolder + '/css/';

gulp.task('build-sass', function () {
  return gulp.src(sourceSassFolder + '**/*.scss')
    .pipe(sass({
      outputStyle: 'expanded'
    }).on('error', sass.logError))
    .pipe(gulp.dest(sourceCssFolder))
    .pipe(gulp.dest(deploymentCssFolder));
});

gulp.task('build', function () {
  return gulp.src(sourceSassFolder + '**/*.scss')
    .pipe(sass({
      outputStyle: 'compressed'
    }).on('error', sass.logError))
    .pipe(gulp.dest(sourceCssFolder))
    .pipe(gulp.dest(deploymentCssFolder));
});

gulp.task('copy-css', function () {
  return gulp.src(sourceCssFolder + '**/*.css')
    .pipe(gulp.dest(deploymentCssFolder));
});

gulp.task('watch:sass', function () {
  gulp.watch('**/*.scss', { cwd: sourceSassFolder }, gulp.series('build-sass'));
});

gulp.task('watch:css', function () {
  gulp.watch('**/*.css', { cwd: sourceCssFolder }, gulp.series('copy-css'));
});

gulp.task('default', gulp.series(['watch:sass']));
gulp.task('css', gulp.series(['watch:css']));

// Browsersync
gulp.task('browsersync-sass', function () {
  return gulp.src(sourceSassFolder + '**/*.scss')
    .pipe(sourcemaps.init())
    .pipe(sass({
      outputStyle: 'expanded'
    }).on('error', sass.logError))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(sourceCssFolder))
    .pipe(gulp.dest(deploymentCssFolder))
    .pipe(browserSync.stream());
});

gulp.task('watch:browsersync-sass', function () {
  gulp.watch('**/*.scss', { cwd: sourceSassFolder }, gulp.series('browsersync-sass'));
});

gulp.task('browsersync', function () {
  browserSync.init({
    proxy: {
      target: proxyAddress,
      ws: true
    },
    online: true,
    open: true,
    reloadOnRestart: true,
    notify: true,
    ghostMode: false
  });
});


gulp.task('github', done => {    
	mkdirp('./github', function (err) {
		if (err) console.error(err)
		else console.log('github dir created')
	});

	console.log('github '+ baseRepo + clientrepo);
	git.clone(baseRepo + clientrepo,{cwd: githubFolder});
	git.pull('origin', 'master', {args: '--rebase', cwd: githubFolder + clientrepo});
		
	console.log('github '+ baseRepo + lsgrepo);
	git.clone(baseRepo + lsgrepo,{cwd: githubFolder});
	git.pull('origin', 'master', {args: '--rebase', cwd: githubFolder + lsgrepo});
	
	console.log(githubFolder + clientrepo+'**/*.* -> ' + sourceSassFolder);
	gulp.src(githubFolder + clientrepo+'**/*.*')
		.pipe(gulp.dest(sourceSassFolder));
	
	
	console.log(githubFolder + lsgrepo+'**/*.* -> ' + sourceSassFolder);
	gulp.src(githubFolder + lsgrepo+'**/*.*')
		.pipe(gulp.dest(sourceSassFolder));
		
    done();
});

gulp.task('dev', gulp.series(['github'], gulp.parallel(['browsersync-sass', 'watch:browsersync-sass', 'browsersync', ])));
