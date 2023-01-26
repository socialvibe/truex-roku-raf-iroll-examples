function isTrueXAdEvent(msg_ as Object, adEventInfo_ as Object, adPods_ as Object) as Boolean
  if type(msg_) <> "roSGNodeEvent" then
    return false
  end if

  ' in this case - Innovid is responsible to render and play TrueX Ad
  ' so we check the sender node id - it should start with "iroll-" prefix
  if not(msg_.GetNode().StartsWith("iroll-") and msg_.GetField() = "event") then
    return false
  end if

  ' .adpodindex starts with 1
  ' .adindex starts with 1

  currentAdPod_ = adPods_[_Math_Max(0, adEventInfo_.adpodindex - 1)]

  ' truex ad should be the first ad in Ad break.
  if currentAdPod_ = invalid or adEventInfo_.adindex > 1 then
    return false
  end if

  currentAd_ = currentAdPod_.ads[_Math_Max(0, adEventInfo_.adindex - 1)]

  if currentAd_ = invalid then
    return false
  end if

  ' in this particular case we assume `adId` should start with `truex-`
  ' but in real world screnario it depends on the publisher adserver's response
  return _isString(currentAd_.adId) and currentAd_.adId.StartsWith("truex-")
end function

function handleTrueXAdExitEvent(msg_ as Object) as Void
  evt_ = msg_.GetData()

  if evt_.type = "exitBeforeOptIn" then
    exitPlayback()
  else if evt_.type = "exitSelectWatch" or evt_.type = "exitAutoWatch" then
    skipTrueXAdAndContinue()
  else if evt_.type = "exitWithSkipAdBreak" then
    skipCurrentAdPodAndContinue()
  end if
end function

sub skipTrueXAdAndContinue()
  ? ""
  ? ""
  ? "skipTrueXAdAndContinue()"
  ? ""
  ? ""
end sub

sub exitPlayback()
  ' handled in event loop - if currentAd_.adExited = true then ....
end sub

sub skipCurrentAdPodAndContinue()
  ? ""
  ? ""
  ? "skipCurrentAdPodAndContinue()"
  ? ""
  ? ""
end sub