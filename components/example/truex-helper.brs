function isTrueXAdEvent(msg_ as Object, currentAd_ as Dynamic) as Boolean
  if type(msg_) <> "roSGNodeEvent" then
    return false
  end if

  ' in this case - Innovid is responsible to render and play TrueX Ad
  ' so we check the sender node id - it should start with "iroll-" prefix
  if not(msg_.GetNode().StartsWith("iroll-") and msg_.GetField() = "event") then
    return false
  end if

  if currentAd_ = invalid then
    return false
  end if

  ' in this particular case we assume `adId` should start with `truex-`
  ' but in real world screnario it depends on the publisher adserver's response
  return _isString(currentAd_.adId) and currentAd_.adId.StartsWith("truex-")
end function

' @returns {{ adPod: object, ad: object, adPodIndex: number, adIndex: number } | invalid}
function findCurrentAdInfo(adPods_ as Object, adEventInfo_ as Object) as Dynamic
  ' .adpodindex starts with 1
  ' .adindex starts with 1

  currentAdPod_ = adPods_[_Math_Max(0, adEventInfo_.adpodindex - 1)]

  ' truex ad should be the first ad in Ad break.
  if currentAdPod_ = invalid or adEventInfo_.adindex > 1 then
    return invalid
  end if

  currentAd_ = currentAdPod_.ads[_Math_Max(0, adEventInfo_.adindex - 1)]

  return {
    adPod: currentAdPod_,
    adPodIndex: adEventInfo_.adPodIndex,
    ad: currentAd_,
    adIndex: adEventInfo_.adIndex,
  }
end function

' @param {roSGNodeEvent} msg_
' @param {{ adPod: object, ad: object, adPodIndex: number, adIndex: number }} currentAdInfo_
function handleTrueXAdEvent(msg_ as Object, currentAdInfo_ as Object) as Void
  evt_ = msg_.GetData()

  if evt_.type = "exitBeforeOptIn" then
    exitPlayback()
  else if evt_.type = "exitSelectWatch" or evt_.type = "exitAutoWatch" then
    skipTrueXAdAndContinue(currentAdInfo_)
  else if evt_.type = "exitWithSkipAdBreak" then
    skipCurrentAdPodAndContinue(currentAdInfo_)
  end if
end function

sub skipTrueXAdAndContinue(currentAdInfo_ as Object)
  currentAdInfo_.ad.viewed = true

  ' calculate the next ad position in stream
  ' in case the app has better timing info from SSAI provider better to use it here
  nextAdStartPosition_ = currentAdInfo_.adPod.rendertime + currentAdInfo_.ad.duration

  trace(Substitute("skipTrueXAdAndContinue() -- seek: ", nextAdStartPosition_.ToStr()))

  ' seek to the next Ad start position
  m.video.control = "play"
  m.video.seek = nextAdStartPosition_
end sub

sub exitPlayback()
  ' handled in event loop - if currentAd_.adExited = true then ....
  ' this event fired when the user
end sub

sub skipCurrentAdPodAndContinue(currentAdInfo_ as Object)
  currentAdPod_ = currentAdInfo_.adPod
  nextContentPortionStartPosition_ = currentAdPod_.rendertime

  ' mark this as `viewed`
  currentAdPod_.viewed = true

  ' mark every ad in this adPod as `viewed`
  for each ad_ in currentAdPod_.ads
    ad_.viewed = true
    nextContentPortionStartPosition_ += ad_.duration
  end for

  trace(Substitute("skipCurrentAdPodAndContinue() -- seek: ", nextContentPortionStartPosition_.ToStr()))

  ' seek to the next Ad start position
  m.video.control = "play"
  m.video.seek = nextContentPortionStartPosition_
end sub