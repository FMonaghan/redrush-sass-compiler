RedrushSassCompilerView = require './redrush-sass-compiler-view'
{CompositeDisposable, File, NotificationManager} = require 'atom'
Sass = require './vendor/sassjs/sass.js'

module.exports = RedrushSassCompiler =
  redrushSassCompilerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @redrushSassCompilerView = new RedrushSassCompilerView(state.redrushSassCompilerViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @redrushSassCompilerView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'redrush-sass-compiler:compile-project': => @compileProject()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @redrushSassCompilerView.destroy()

  serialize: ->
    redrushSassCompilerViewState: @redrushSassCompilerView.serialize()

  compileProject: ->
    @sass = new Sass()
    Sass.setWorkerUrl(require.resolve('./vendor/sassjs/sass.worker.js'))

    page = atom.workspace.getActiveTextEditor()
    isSass = @checkFileType page

    if (isSass)
      path = @getDirectoryPath page
      name = @getFilename page
      text = page.getText()
      @compileSass path, name, text

  checkFileType: (page) ->
    # Checks that the file is a sass file
    filename = page.getTitle()
    [first, ..., last] = filename.split '.'
    return (last == 'scss')

  getDirectoryPath: (page) ->
    # Gets the full path withot the filename
    path = page.getPath()
    [content..., last] = path.split '/'
    return content.join '/'

  getFilename: (page) ->
    # Gets the first part of the filename (without the extension)
    filename = page.getTitle()
    [first, ..., last] = filename.split '.'
    return first

  compileSass: (path, name, text) ->
    # Returns css output after parsing/compiling sass

    _this = @
    @sass.compile text, (result) ->
      if (result.status == 0)
        if (result.text != null)
          file = new File "#{path}/#{name}.css", false
          filePath = file.getPath()
          file.write result.text
          _this.triggerNotification "SCSS_SUCCESSFULLY_PARSED", filePath
        else
          _this.triggerNotification "SCSS_NO_COMMANDS", filePath
      else
        _this.triggerNotification "SCSS_PARSE_ERROR", result.formatted

  triggerNotification: (error, message) ->
    n = atom.notifications
    switch error
      when "SCSS_SUCCESSFULLY_PARSED"
        n.addSuccess "Looking Sassy! The css parsed successfully :-)", {
          detail: "Check it out at #{ message }",
          dismissable: true
        }
      when "SCSS_PARSE_ERROR"
        n.addError "Hmm, not so Sassy... There was a bit of a problem", {
          detail: "#{ message }",
          dismissable: true
        }
      when "SCSS_NO_COMMANDS"
        n.addWarning "The file doesn't have Sass, it's just empty!", {
          detail: "The file was empty or there were no css commands to parse",
          dismissable: true
        }
