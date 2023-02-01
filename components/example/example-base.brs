function init() as Void
  ' @enum
  ' - "not_started"
  ' - "running"
  ' - "ended"
  m.top.state = "not_started"
  m.top.error = invalid

  ' disable Innovid log output
  ' temp_ = CreateObject("roSGNode", "ContentNode")
  ' temp_.addFields({ "__LoggerLevel": { value: 0 }})

  ' m.global.addFields({ "_Innovid": temp_ })

  m.data = invalid
  m.size = invalid

  m.wrapperEvents = []
end function

' @interface
function start(_ as Object) as Void
  if m.top.state <> "not_started" then
    return
  end if

  ' save example info
  m.data = _.data
  m.size = _.size

  ' start iroll
  if startExample() then
    _processExampleStarted()
  end if
end function

' @interface
function unload(_ as Object) as Void
  if m.top.state <> "running" then
    return
  end if

  if stopExample(_) then
    _processExampleEnded()
  end if
end function

' @template
function startExample() as Boolean
  return false
end function

' @template
function stopExample(_) as Boolean
  return false
end function

function _processExampleStarted() as Void
  trace("_processExampleStarted()")

  m.top.state = "running"
  m.top.error = invalid
end function

function _processExampleEnded() as Void
  trace("_processExampleEnded()")

  m.top.state = "ended"
  m.top.error = invalid
end function

function _processExampleFailed(error_ = { type: "generic error" }) as Void
  trace("_processExampleFailed()", error_)

  m.top.state = "ended"
  m.top.error = error_
end function