sub init()
  m.ready = true
  m.loggerCat = "Main"
  ' example view
  m.exampleView = invalid
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
  view_.callFunc("start", {
    data: config_,
    size: { w: sgScreen_.width, h: sgScreen_.height }
  })

  m.top.appendChild(view_)

  m.exampleView = view_
end sub

sub showExamplesScreen()
  trace("showExamples()")
end sub

function createExampleComponentView(type_ as string) as dynamic
  result_ = invalid

  if type_ = "raf-ssai-sponsored-ad-break" then
    result_ = CreateObject("roSGNode", "ExampleRAFSSAI")
  end if

  return result_
end function

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