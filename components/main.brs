sub init()
  m.ready = true
  m.loggerCat = "Main"
  ' current page view
  m.currentView = invalid
  ' example config
  ' @see getPayload() example
  m.example = invalid
  ' list of examples
  m.examples = invalid

  m.top.observeFieldScoped("focusedChild", "traceFocusedElement")
end sub


sub setup(payload_ as object)
  trace("setup()", payload_)

  m.payload = payload_

  m.example = payload_.example
  m.examples = payload_.examples

  showStartScreenIfReady()
end sub

sub showStartScreenIfReady()
  trace(Substitute("showStartScreenIfReady() -- ready: {0}", m.ready.ToStr()))

  if not(m.ready) then
    return
  end if

  if m.example <> invalid then
    showExample(m.example)
  else
    showExamplesScreen()
  end if
end sub

sub showExample(config_)
  trace("showExample()")

  sgScreen_ = m.top.currentDesignResolution

  view_ = createExampleComponentView(config_.type)
  view_.observeFieldScoped("event", "handleExampleEvent")
  view_.callFunc("start", {
    data: config_,
    size: { w: sgScreen_.width, h: sgScreen_.height }
  })

  setCurrentView(view_)
end sub

sub showExamplesScreen()
  trace("showExamplesScreen()")

  sgScreen_ = m.top.currentDesignResolution

  view_ = CreateObject("roSGNode", "Examples")
  view_.observeFieldScoped("event", "handleExamplesScreenEvent")
  view_.callFunc("start", {
    examples: m.examples,
    size: { w: sgScreen_.width, h: sgScreen_.height }
  })

  setCurrentView(view_)
end sub

function createExampleComponentView(type_ as string) as dynamic
  result_ = invalid

  if type_ = "raf-ssai-sponsored-ad-break" then
    result_ = CreateObject("roSGNode", "ExampleRAFSSAI")
  end if

  return result_
end function

sub setCurrentView(view_ as Dynamic)
  if m.currentView <> invalid then
    ' release
    m.currentView.callFunc("unload", {})
    ' remove from the stage
    m.top.removeChild(m.currentView)
  end if

  m.currentView = view_

  if view_ <> invalid then
    m.top.appendChild(view_)
  end if
end sub

sub handleExamplesScreenEvent(msg_ as Object)
  evt_ = msg_.GetData()

  trace("handleExamplesScreenEvent()", evt_)

  if evt_.type = "select" then
    showExample(evt_.data)
  end if
end sub

sub handleExampleEvent(msg_ as Object)
  evt_ = msg_.GetData()

  if evt_.type = "exit" then
    trace(Substitute("handleExampleEvent() -- type: exit, reason: {0}", _asString(evt_.reason)))
    showExamplesScreen()
  end if
end sub

sub traceFocusedElement()
  focused_ = m.top.focusedChild

  if focused_ <> invalid then
    result_ = [m.top.subtype()]

    while true
      if focused_.id = "" then
        result_.Push(focused_.subtype())
      else
        result_.Push(Substitute("{0}(id='{1}')", focused_.subtype(), focused_.id))
      end if

      if focused_.focusedChild = invalid or focused_.isSameNode(focused_.focusedChild) then
        exit while
      end if

      focused_ = focused_.focusedChild
    end while
  else
    result_ = ["invalid"]
  end if

  trace("focus()", result_.Join(" / "))
end sub