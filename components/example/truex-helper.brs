function _TrueXAdHelper(raf_ as Object, currentAdInfo_ as Object) as Object

  ' RAF has two special methods to support TrueX Ad Flow for CSAI.
  ' But they do not work for SSAI, so, we need to disable them
  ' - Roku_Ads # skipAllAdPods
  ' - Roku_Ads # skipAdsInCurrentPod
  if raf_.__originalSkipAllAdPods = invalid then
    raf_.__originalSkipAllAdPods = raf_.skipAllAdPods
    raf_.__skipAdsInCurrentPod = raf_.skipAdsInCurrentPod

    raf_.skipAllAdPods = sub(_ignore = invalid)
    end sub

    raf_.skipAdsInCurrentPod = sub()
    end sub
  end if

  return {
    scope: m,

    adStarted: false,
    adEnded: false,

    ' ref to RAF instance
    raf: raf_,

    ' {m.rafPlayerWrapper} is video player wrapper provided by RAF to innovid-iroll-renderer instance
    ' it implements {ifVideoPlayer} interface.
    ' We have to use it to ensure RAF internal ad-state is being to be updated properly.
    ' @see https://developer.roku.com/en-ca/docs/references/brightscript/interfaces/ifvideoplayer.md
    ' @type {ifVideoPlayer} interface
    rafPlayerWrapper: invalid,
    rafIrollInstance: invalid,

    isSameAd: _TrueXAdHelper_IsSameAd,

    adPod: currentAdInfo_.adPod,
    adPodIndex: currentAdInfo_.adPodIndex,
    ad: currentAdInfo_.ad,
    adIndex: currentAdInfo_.adIndex,

    handleTrueXAdEvent: _TrueXAdHelper_HandleTrueXAdEvent,
    reset: _TrueXAdHelper_Reset,

    _exitPlayback: __TrueXAdHelper_ExitPlayback,
    _skipCurrentAdPodAndContinue: __TrueXAdHelper_SkipCurrentAdPodAndContinue,
    _skipTrueXAdAndContinue: __TrueXAdHelper_SkipTrueXAdAndContinue,

    _isVideoEvent: __TrueXAdHelper_IsVideoEvent,
    _isInnovidRendererEvent: __TrueXAdHelper_IsInnovidRendererEvent,

    _handleAdStarted: __TrueXAdHelper_HandleAdStarted,
    _handleAdEnded: __TrueXAdHelper_HandleAdEnded,
    _handleVideoEvent: __TrueXAdHelper_HandleVideoEvent,

    _stopVideoPlayback: __TrueXAdHelper_StopVideoPlayback,
    _restartVideoPlayback: __TrueXAdHelper_RestartVideoPlayback,

    _isObject: __TrueXAdHelper_IsObject,
    _isString: __TrueXAdHelper_IsString,
  }
end function

' @param {roSGNodeEvent} msg_
' @param {{ adPod: object, ad: object, adPodIndex: number, adIndex: number }} currentAdInfo_
sub _TrueXAdHelper_HandleTrueXAdEvent(msg_ as Object, currentAdInfo_ as Object)
  if currentAdInfo_.adPodIndex <> m.adPodIndex or currentAdInfo_.adindex <> m.adIndex then
    return
  end if

  if type(msg_) <> "roSGNodeEvent" then
    return
  end if

  if m._isVideoEvent(msg_) then
    m._handleVideoEvent(msg_)
    return
  end if

  evt_ = msg_.GetData()

  if not(m._isObject(evt_)) or not(m._isString(evt_.type)) then
    return
  end if

  if m._isInnovidRendererEvent(msg_) and evt_.type = "Ended" then
    m._handleAdEnded()
  else if evt_.type = "exitBeforeOptIn" then
    m._exitPlayback()
  else if evt_.type = "exitSelectWatch" or evt_.type = "exitAutoWatch" then
    m._skipTrueXAdAndContinue()
  else if evt_.type = "exitWithSkipAdBreak" then
    m._skipCurrentAdPodAndContinue()
  end if
end sub

sub _TrueXAdHelper_Reset()
  trace("truex # reset()")

  m.rafIrollInstance = invalid
  m.rafPlayerWrapper = invalid

  m.raf = invalid
  m.adPod = invalid
  m.ad = invalid
end sub

' @param {{ adPodIndex: number, adIndex: number }} adInfo_
sub _TrueXAdHelper_IsSameAd(adInfo_ as Object) as boolean
  return adInfo_.adIndex = m.adIndex and adInfo_.adPodIndex = m.adPodIndex
end sub

sub __TrueXAdHelper_SkipTrueXAdAndContinue()
  ' mark the current ad as 'viewed'
  m.ad.viewed = true

  ' calculate the next ad position in stream
  ' in case the app has better timing info from SSAI provider better to use it here
  nextAdStartPosition_ = m.adPod.rendertime + m.ad.duration - .5

  trace(Substitute("truex # skipTrueXAdAndContinue() -- seek: {0} sec", nextAdStartPosition_.ToStr()))

  m._restartVideoPlayback(nextAdStartPosition_)
end sub

sub __TrueXAdHelper_ExitPlayback()
  ' handled in the event loop - `if currentAd_.adExited = true then ... end if`
  ' this event fired when the user exited choice_card by pressing `Back` button
end sub

sub __TrueXAdHelper_SkipCurrentAdPodAndContinue()
  nextContentPortionStartPosition_ = m.adPod.rendertime

  ' mark this AdPod as `viewed`
  m.adPod.viewed = true

  ' mark every ad in the current adPod as `viewed`
  for each ad_ in m.adPod.ads
    ad_.viewed = true
    nextContentPortionStartPosition_ += ad_.duration
  end for

  trace(Substitute("truex # skipCurrentAdPodAndContinue() -- seek: {0} sec", nextContentPortionStartPosition_.ToStr()))

  m._restartVideoPlayback(nextContentPortionStartPosition_)
end sub

sub __TrueXAdHelper_StopVideoPlayback() as Void
  trace("truex # _stopPlayback()")

  ' stop player
  m.rafPlayerWrapper.Pause()
  m.rafPlayerWrapper.Stop()
end sub

sub __TrueXAdHelper_HandleAdStarted()
  trace("truex # handleAdStarted()")

  m.rafIrollInstance = m.raf.util.infocache.curadrenderer.instance
  m.rafPlayerWrapper = m.raf.util.infocache.curadrenderer.player

  ' at this time Innovid renderer is still not completely initialized
  m.adStarted = true
  m._stopVideoPlayback()
end sub

sub __TrueXAdHelper_HandleAdEnded()
  trace("truex # handleAdEnded()")
  m.adEnded = true
end sub

sub __TrueXAdHelper_HandleVideoEvent(msg_ as Object)
  field_ = msg_.GetField()

  if field_ = "position" and not(m.adStarted) then
    m._handleAdStarted()
  end if
end sub

sub __TrueXAdHelper_RestartVideoPlayback(positionInSeconds_ as Float)
  trace(Substitute("truex # _restartVideoPlayback()", positionInSeconds_.ToStr()))

  m.rafIrollInstance.ssai.restartPosition = positionInSeconds_
  m.rafIrollInstance.ssai.restarting = true
  m.rafIrollInstance.ssai.restartRequested = false

  m.rafPlayerWrapper.Play()
  m.rafPlayerWrapper.Seek(positionInSeconds_ * 1000)
end sub

function __TrueXAdHelper_IsInnovidRendererEvent(msg_ as Object) as Boolean
  return type(msg_) = "roSGNodeEvent" and msg_.GetNode().StartsWith("iroll-") and msg_.GetField() = "event"
end function

function __TrueXAdHelper_IsObject(value_ as Dynamic) as Boolean
  return type(value_) <> "<uninitialized>" and GetInterface(value_, "ifAssociativeArray") <> invalid
end function

function __TrueXAdHelper_IsString(value_ as Dynamic) as Boolean
  return type(value_) <> "<uninitialized>" and GetInterface(value_, "ifString") <> invalid
end function

function __TrueXAdHelper_IsVideoEvent(msg_ as Object) as Boolean
  if type(msg_) <> "roSGNodeEvent" then
    return false
  end if

  node_ = msg_.GetRoSGNode()
  field_ = msg_.GetField()

  if node_ <> invalid and not(node_.isSubtype("Video")) then
    return false
  end if

  return field_ = "state" or field_ = "position"
end function