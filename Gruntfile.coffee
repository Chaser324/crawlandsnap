
module.exports = (grunt) ->
    'use strict'

    grunt.initConfig

        clean: ['dist/']

        copy:
            main:
                files: [
                    {
                        src: ['helpers.js']
                        dest: 'dist/'
                    }
                ]

        coffee:
            main:
                expand: true
                src: ['crawler.coffee']
                ext: '.js'
                dest: 'dist/'

        casperjs:
            main:
                files: 
                    src: ['dist/crawler.js']

    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-casperjs'

    grunt.registerTask 'default', [
        'clean', 'copy', 'coffee', 'casperjs'
    ]
