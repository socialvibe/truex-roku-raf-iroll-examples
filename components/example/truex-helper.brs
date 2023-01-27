function _TrueXAdHelper(video_ as Object, currentAdInfo_ as Object) as Object
  deepCopy_ = ParseJson(FormatJson(currentAdInfo_))

  return {
    scope: m,

    adStarted: false,
    adEnded: false,

    ' ref to the main player
    video: video_,

    adPod: deepCopy_.adPod,
    adPodIndex: deepCopy_.adPodIndex,
    ad: deepCopy_.ad,
    adIndex: deepCopy_.adIndex,

    handleTrueXAdEvent: _TrueXAdHelper_HandleTrueXAdEvent,

    _exitPlayback: __TrueXAdHelper_ExitPlayback,
    _skipCurrentAdPodAndContinue: __TrueXAdHelper_SkipCurrentAdPodAndContinue,
    _skipTrueXAdAndContinue: __TrueXAdHelper_SkipTrueXAdAndContinue,

    _isVideoPositionChangeEvent: __TrueXAdHelper_IsVideoPositionChangeEvent,
    _isInnovidRendererEvent: __TrueXAdHelper_IsInnovidRendererEvent,
    _stopVideoPlayback: __TrueXAdHelper_StopVideoPlayback,
    _handleAdStarted: __TrueXAdHelper_HandleAdStarted,
    _handleAdEnded: __TrueXAdHelper_HandleAdEnded,

    _isObject: __TrueXAdHelper_IsObject,
    _isString: __TrueXAdHelper_IsString,
  }
end function

' @param {roSGNodeEvent} msg_
' @param {{ adPod: object, ad: object, adPodIndex: number, adIndex: number }} currentAdInfo_
sub _TrueXAdHelper_HandleTrueXAdEvent(msg_ as Object, currentAdInfo_ as Object)
  if type(msg_) <> "roSGNodeEvent" then
    return
  end if

  evt_ = msg_.GetData()

  if not(m._isObject(evt_)) or not(m._isString(evt_.type)) then
    return
  end if

  if m._isVideoPositionChangeEvent(msg_) and not(m.adStarted) then
    m._handleAdStarted()
  else if m._isInnovidRendererEvent(msg_) and evt_.type = "Ended" then
    m._handleAdEnded()
  else if evt_.type = "exitBeforeOptIn" then
    m._exitPlayback()
  else if evt_.type = "exitSelectWatch" or evt_.type = "exitAutoWatch" then
    m._skipTrueXAdAndContinue(currentAdInfo_)
  else if evt_.type = "exitWithSkipAdBreak" then
    m._skipCurrentAdPodAndContinue(currentAdInfo_)
  end if
end sub

sub __TrueXAdHelper_SkipTrueXAdAndContinue(currentAdInfo_ as Object)
  currentAdInfo_.ad.viewed = true

  ' calculate the next ad position in stream
  ' in case the app has better timing info from SSAI provider better to use it here
  nextAdStartPosition_ = currentAdInfo_.adPod.rendertime + currentAdInfo_.ad.duration

  trace(Substitute("truex # skipTrueXAdAndContinue() -- seek: ", nextAdStartPosition_.ToStr()))

  ' seek to the next Ad start position
  m.video.control = "play"
  m.video.seek = nextAdStartPosition_
end sub

sub __TrueXAdHelper_ExitPlayback()
  ' handled in event loop - if currentAd_.adExited = true then ....
  ' this event fired when the user
end sub

sub __TrueXAdHelper_SkipCurrentAdPodAndContinue(currentAdInfo_ as Object)
  currentAdPod_ = currentAdInfo_.adPod
  nextContentPortionStartPosition_ = currentAdPod_.rendertime

  ' mark this as `viewed`
  currentAdPod_.viewed = true

  ' mark every ad in the current adPod as `viewed`
  for each ad_ in currentAdPod_.ads
    ad_.viewed = true
    nextContentPortionStartPosition_ += ad_.duration
  end for

  trace(Substitute("truex # skipCurrentAdPodAndContinue() -- seek: {0} sec", nextContentPortionStartPosition_.ToStr()))

  ' seek to the next Ad start position
  m.video.control = "play"
  m.video.seek = nextContentPortionStartPosition_
end sub

sub __TrueXAdHelper_StopVideoPlayback() as Void
  trace("truex # _stopPlayback()")

  ' save position info
  m._stoppedPositionInfo = m.video.positionInfo
  ' stop player
  m.video.control = "stop"
end sub

sub __TrueXAdHelper_HandleAdStarted()
  trace("truex # handleAdStarted()")

  ' at this time Innovid renderer is still not completely initialized
  m.adStarted = true
  m._stopVideoPlayback()
end sub

sub __TrueXAdHelper_HandleAdEnded()
  trace("truex # handleAdEnded()")
  m.adEnded = true
end sub

function __TrueXAdHelper_IsInnovidRendererEvent(msg_ as Object) as Boolean
  return type(msg_) = "roSGNodeEvent" and msg_.GetNode().StartsWith("iroll-") and msg_.GetField() = "event"
end function

function __TrueXAdHelper_IsVideoPositionChangeEvent(msg_ as Object) as Boolean
  return type(msg_) = "roSGNodeEvent" and msg_.GetField() = "position"
end function

function __TrueXAdHelper_IsObject(value_ as Dynamic) as Boolean
  return type(value_) <> "<uninitialized>" and GetInterface(value_, "ifAssociativeArray") <> invalid
end function

function __TrueXAdHelper_IsString(value_ as Dynamic) as Boolean
  return type(value_) <> "<uninitialized>" and GetInterface(value_, "ifString") <> invalid
end function