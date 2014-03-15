{View, EditorView, $} = require 'atom'
moment = require 'moment'
path = require 'path'

module.exports =
class AtomMemolistNewView extends View
  AtomMemolistNew: null

  @activate: (state) ->
    @atomMemolistNew = new AtomMemolistNewView(state.atomMemolistNew)

  initialize: ->
    atom.workspaceView.command 'atom-memolist-new:toggle', => @toggle()
    @miniEditor.setPlaceholderText('Enter a Name for new Memo');
    @on 'core:confirm', => @confirm()
    @on 'core:cancel', => @detach()

  @detaching: false

  toggle: ->
    if @hasParent()
      @detach()
    else
      @attach()

  @content: (params)->
    @div class: 'atom-memolist-new overlay from-top', =>
      @subview 'miniEditor', new EditorView({mini:true})

  confirm: ->
    title = @miniEditor.getEditor().getText()

    memodir = atom.config.get('atom-memolist.memo_dir_path')
    today = moment().format('YYYY-MM-DD-')
    newFile = path.join(memodir, today + title + '.md')

    try
      atom.workspaceView.open newFile
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
    else
      atom.workspaceView.focus()

    super

    @detaching = false

  attach: ->
    console.log 'atom-memolist-new: attach'
    @detaching = true
    @previouslyFocusedElement = $(':focus')
    atom.workspaceView.append(this)
    @miniEditor.focus()
