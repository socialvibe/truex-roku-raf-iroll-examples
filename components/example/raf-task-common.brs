function handleRafTrackingEvent(iface_, event_ = invalid, ctx_ = invalid) as Void
  if event_ = invalid and ctx_.time <> invalid then
    wrapperEvent_ = { type: "__PrerollProgress", time: ctx_.time }
  else
    wrapperEvent_ = { type: event_ }
  end if

  dt_ = CreateObject("roDateTime")
  wrapperEvent_.ts = 1000& * dt_.asSeconds() + dt_.GetMilliseconds()

  iface_.wrapperEvent = wrapperEvent_
end function
function overrideRafSkipAPI() as Void
  ' m.raf.skipAdsInCurrentPod = function() as Void
  '   dt_ = CreateObject("roDateTime")

  '   GetGlobalAA().top.wrapperEvent = {
  '     ts   : 1000& * dt_.asSeconds() + dt_.GetMilliseconds(),
  '     type : "skipAdsInCurrentPod"
  '   }
  ' end function

  ' m.raf.skipAllAdPods = function(replacementSkipAd_ as Object) as Void
  '   dt_ = CreateObject("roDateTime")

  '   GetGlobalAA().top.wrapperEvent = {
  '     ts   : 1000& * dt_.asSeconds() + dt_.GetMilliseconds(),
  '     type : "skipAllAdPods",
  '     skipCardUrl : replacementSkipAd_.adServer,
  '   }
  ' end function
end function
