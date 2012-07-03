class Template

  constructor: (@appName, @opts) ->
    @files = this.setFiles()

  setFiles: ->
    files = {}

    # ./myapp
    files["#{@appName}/.gitignore"] = """
      node_modules/
    """

    files["#{@appName}/package.json"] = """
      {
          "name": "#{@appName}"
        , "version": "0.0.1"
        , "dependencies": {
              "express": "3.0.x"
            , "connect-assets": "2.1.x"
            #{this.printTemplateEngine()}
            #{this.printCssEngine()}
            #{this.printJsEngine()}
          }
        , "scripts": {
            "start": "server.js"
          }
        , "engines": {
            "node": "0.8.0"
          }
      }
    """

    files["#{@appName}/README.md"] = """
      # #{@appName}
      ***
      App structure generated by [Skeleton](https://github.com/EtienneLem/skeleton)
    """

    files["#{@appName}/server.js"] = """
      require("coffee-script")
      require("./app/app.coffee")
    """

    # ./myapp/app
    files["#{@appName}/app/app.coffee"] = """
      # Modules
      express = require 'express'
      http = require 'http'
      #{ if @opts.renderer != 'jade' then "partials = require 'express-partials'\n" else ''}app = express()

      # Boot setup
      require("\#{__dirname}/../config/boot")(app)

      # Configuration
      app.configure ->
        port = process.env.PORT || 3000
        if process.argv.indexOf('-p') >= 0
          port = process.argv[process.argv.indexOf('-p') + 1]

        app.set 'port', port
        app.set 'views', "\#{__dirname}/views"
        app.set 'view engine', '#{@opts.renderer}'
        app.use express.static("\#{__dirname}/../public")
        app.use express.favicon()
        app.use express.logger('dev')
        app.use express.bodyParser()
        app.use express.methodOverride()
        #{ if @opts.renderer != 'jade' then 'app.use partials()\n  ' else ''}app.use require('connect-assets')(src: "\#{__dirname}/assets")
        app.use app.router

      app.configure 'development', ->
        app.use express.errorHandler()

      # Routes
      require("\#{__dirname}/routes")(app)

      # Server
      http.createServer(app).listen app.get('port'), ->
        console.log "Express server listening on port \#{app.get 'port'} in \#{app.settings.env} mode"
    """

    # ./myapp/app/assets/css
    if @opts.css == 'stylus'
      files["#{@appName}/app/assets/css/styles.styl"] = """
        // Based on <https://github.com/heliom/stylus-utils/blob/master/styles.styl-sample>
        // @import "nib"

        // Reset ---------------------------------------------------------------------
        *
          margin: 0; padding: 0
          -webkit-box-sizing: border-box
          -moz-box-sizing: border-box
          box-sizing: border-box

        // Base ----------------------------------------------------------------------
        $background-color = #f4f4f4

        html
          font-size: 62.5%
          height: 100%

        body
          font-size: 16px
          font-size: 1.6rem
          background-color: $background-color

        body, legend, input, textarea, button
          font-family: 'Helvetica Neue'
          line-height: 1.4
          color: #333

        a:link, a:visited { color: deeppink }
        a:focus, a:hover, a:visited:hover { color: hotpink }
      """

    if @opts.css == 'less'
      files["#{@appName}/app/assets/css/styles.less"] = """
        // Based on <https://github.com/heliom/stylus-utils/blob/master/styles.styl-sample>

        // Reset ---------------------------------------------------------------------
        * {
          margin: 0; padding: 0;
          -webkit-box-sizing: border-box;
          -moz-box-sizing: border-box;
          box-sizing: border-box;
        }

        // Base ----------------------------------------------------------------------
        @background-color: #f4f4f4;

        html {
          font-size: 62.5%;
          height: 100%;
        }

        body {
          font-size: 16px;
          font-size: 1.6rem;
          background-color: @background-color;
        }

        body, legend, input, textarea, button {
          font-family: 'Helvetica Neue';
          line-height: 1.4;
          color: #333;
        }

        a:link, a:visited { color: deeppink }
        a:focus, a:hover, a:visited:hover { color: hotpink }
      """

    if @opts.css == 'css'
      files["#{@appName}/app/assets/css/styles.css"] = """
        /* Based on <https://github.com/heliom/stylus-utils/blob/master/styles.styl-sample> */

        /* Reset --------------------------------------------------------------------- */
        * {
          margin: 0; padding: 0;
          -webkit-box-sizing: border-box;
          -moz-box-sizing: border-box;
          box-sizing: border-box;
        }

        /* Base ---------------------------------------------------------------------- */
        html {
          font-size: 62.5%;
          height: 100%;
        }

        body {
          font-size: 16px;
          font-size: 1.6rem;
          background-color: #f4f4f4;
        }

        body, legend, input, textarea, button {
          font-family: 'Helvetica Neue';
          line-height: 1.4;
          color: #333;
        }

        a:link, a:visited { color: deeppink }
        a:focus, a:hover, a:visited:hover { color: hotpink }
      """

    # ./myapp/app/assets/js
    if @opts.js == 'coffee'
      files["#{@appName}/app/assets/js/scripts.coffee"] = """
        # console.log '#{@appName}'
      """

    if @opts.js == 'js'
      files["#{@appName}/app/assets/js/scripts.js"] = """
        // console.log('#{@appName}')
      """

    # ./myapp/app/controllers
    files["#{@appName}/app/controllers/application_controller.coffee"] = """
      class ApplicationController

        # GET /
        @index = (req, res) ->
          res.render 'index',
            view: 'index'


      # Exports
      module.exports = (app) ->
        app.ApplicationController = ApplicationController
    """

    # ./myapp/app/helpers
    files["#{@appName}/app/helpers/index.coffee"] = """
      fs = require 'fs'

      # Recursively require a folder’s files
      exports.autoload = autoload = (dir, app) ->
        fs.readdirSync(dir).forEach (file) ->
          path = "\#{dir}/\#{file}"
          stats = fs.lstatSync(path)

          # Go through the loop again if it is a directory
          if stats.isDirectory()
            autoload path, app
          else
            require(path)?(app)

      # Capitalize a string
      # string => String
      String::capitalize = () ->
          this.replace /(?:^|s)S/g, (a) -> a.toUpperCase()

      # Classify a string
      # application_controller => ApplicationController
      String::classify = (str) ->
        classified = []
        words = str.split('_')
        for word in words
          classified.push word.capitalize()

        classified.join('')
    """

    # ./myapp/app/routes
    files["#{@appName}/app/routes/index.coffee"] = """
      module.exports = (app) ->
        # Index
        app.get '/', app.ApplicationController.index

        # Error handling (No previous route found. Assuming it’s a 404)
        app.get '/*', (req, res) ->
          NotFound res

        NotFound = (res) ->
          res.render '404', status: 404, view: 'four-o-four'
    """

    # ./myapp/app/views
    if @opts.renderer == 'ejs'
      files["#{@appName}/app/views/404.ejs"] = "<h1>Nothing here…</h1>"

      files["#{@appName}/app/views/index.ejs"] = """
        <h1>This page has been generated by <a href="https://github.com/EtienneLem/skeleton">Skeleton</a></h1>
        <p>Edit in <span>#{@appName}/views/index.ejs</span></p>
      """

      files["#{@appName}/app/views/layout.ejs"] = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>#{@appName}</title>
            <%- css('styles.css') %>
          </head>
          <body data-view="<%= view %>">
            <%- body %>
            <script>
            document.write('<script src=' +
            ('__proto__' in {} ? 'http://zeptojs.com/zepto.min.js' : 'http://code.jquery.com/jquery-1.7.2.min.js') +
            '><\\/script>')
            </script>
            <%- js('scripts.js') %>
          </body>
        </html>
      """

    if @opts.renderer == 'jade'
      files["#{@appName}/app/views/404.jade"] = """
        extends layout

        block content
          h1 Nothing here…
      """

      files["#{@appName}/app/views/index.jade"] = """
        extends layout

        block content
          h1 This page has been generated by <a href="https://github.com/EtienneLem/skeleton">Skeleton</a>
          p Edit in <span>#{@appName}/views/index.ejs</span>
      """

      files["#{@appName}/app/views/layout.jade"] = """
        doctype 5
        html(lang="en")
          head
            meta(charset="utf-8")
            title #{@appName}
            != css('styles.css')

          body(data-view="\#{view}")
            block content

            | <script>
            | document.write('<script src=' +
            | ('__proto__' in {} ? 'http://zeptojs.com/zepto.min.js' : 'http://code.jquery.com/jquery-1.7.2.min.js') +
            | '><\\/script>')
            | </script>

            != js('scripts.js')
      """

    # ./myapp/config
    files["#{@appName}/config/boot.coffee"] = """
      module.exports = (app) ->
        # Helpers
        app.helpers = require "\#{__dirname}/../app/helpers"

        # Lib
        app.helpers.autoload "\#{__dirname}/../lib", app

        # Controllers
        app.helpers.autoload "\#{__dirname}/../app/controllers", app
    """

    # ./myapp/lib/myapp
    files["#{@appName}/lib/#{@appName}/my_custom_class.coffee"] = """
      # module.exports = (app) ->
      #   # Your code
      #
      #
      # Or if you want this to be a class
      #
      # class MyCustomClass
      #
      #   constructor: (args) ->
      #     # Your code
      #
      # # Exports
      # module.exports = (app) ->
      #   app.MyCustomClass = MyCustomClass
      #
      # Usage: new app.MyCustomClass(args)
    """

    # ./myapp/public
    files["#{@appName}/public/empty"] = ""

    # Return the files object
    files

  printTemplateEngine: ->
    module = ''
    spaces = '      '

    # Jade doesn’t need express-partials
    if @opts.renderer != 'jade'
      module = """
        , "express-partials": ">= 0.0.5"\n#{spaces}
      """

    module += """
      , "#{@opts.renderer}": "*"
    """

    # Returns the module(s) string
    module

  printCssEngine: ->
    if @opts.css != 'css'
      """
        , "#{@opts.css}": "*"
      """
    else ''

  printJsEngine: ->
    if @opts.js == 'coffee'
      """
        , "coffee-script": "*"
      """
    else ''


module.exports = Template
