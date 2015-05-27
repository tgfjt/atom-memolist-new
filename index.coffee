{View, TextEditorView, $} = require 'atom-space-pen-views'
moment = require 'moment'
path = require 'path'

module.exports =
class AtomMemolistNewView extends View
  AtomMemolistNew: null

  @activate: (state) ->
    @atomMemolistNew = new AtomMemolistNewView(state.atomMemolistNew)

  initialize: ->
    atom.commands.add "atom-workspace",
      'atom-memolist-new:toggle', => @toggle()
    atom.commands.add(this[0], 'core:confirm', () => this.confirm())
    atom.commands.add(this[0], 'core:cancel', () => this.detach())

  @detaching: false

  toggle: ->
    if @hasParent()
      @detach()
    else
      @attach()

  @content: (params)->
    @div class: 'atom-memolist-new overlay from-top', =>
      @subview 'miniEditor', new TextEditorView({
        mini: true
        placeholderText: 'Enter a Name for new Memo'
      })


  confirm: ->
    title = @miniEditor.getText()

    memodir = atom.config.get('atom-memolist.memo_dir_path')
    today = moment().format('YYYY-MM-DD-')
    newFile = path.join(memodir, today + title + '.md')

    try
      atom.workspace.open newFile
      @detach()
    catch error
      console.log error.message

    @detach()

  detach: ->
    return unless @hasParent()

    console.log 'atom-memolist-new: detach'
    @detaching = true
    @miniEditor.setText ''

    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()

    super

    @detaching = false

  attach: ->
    console.log 'atom-memolist-new: attach'
    @detaching = true
    @previouslyFocusedElement = $(':focus')
    atom.workspace.addTopPanel(item: this)
    @miniEditor.focus()
