RedrushSassCompiler = require '../lib/redrush-sass-compiler'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RedrushSassCompiler", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('redrush-sass-compiler')

  describe "when the redrush-sass-compiler:compile-project event is triggered", ->
    it "compiles the project", ->
      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'redrush-sass-compiler:compile-project'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(isSass).toBe false
    #
    # it "hides and shows the view", ->
    #   # This test shows you an integration test testing at the view level.
    #
    #   # Attaching the workspaceElement to the DOM is required to allow the
    #   # `toBeVisible()` matchers to work. Anything testing visibility or focus
    #   # requires that the workspaceElement is on the DOM. Tests that attach the
    #   # workspaceElement to the DOM are generally slower than those off DOM.
    #   jasmine.attachToDOM(workspaceElement)
    #
    #   expect(workspaceElement.querySelector('.redrush-sass-compiler')).not.toExist()
    #
    #   # This is an activation event, triggering it causes the package to be
    #   # activated.
    #   atom.commands.dispatch workspaceElement, 'redrush-sass-compiler:toggle'
    #
    #   waitsForPromise ->
    #     activationPromise
    #
    #   runs ->
    #     # Now we can test for view visibility
    #     redrushSassCompilerElement = workspaceElement.querySelector('.redrush-sass-compiler')
    #     expect(redrushSassCompilerElement).toBeVisible()
    #     atom.commands.dispatch workspaceElement, 'redrush-sass-compiler:toggle'
    #     expect(redrushSassCompilerElement).not.toBeVisible()
