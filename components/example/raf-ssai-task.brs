' TASK THREAD

Library "Roku_Ads.brs"

function runInBackground()
  m.raf = Roku_Ads()
  m.raf.setDebugOutput(true)
  m.raf.setTrackingCallback(handleRAFTrackingEvent, m.top)

  playStitchedContentWithAds(m.top.video, m.top.truexTagUrl)

  if m.exitEvent <> invalid then
    m.top.event = m.exitEvent
  end if

  reset()
end function

function playStitchedContentWithAds(video_ as Object, truexTagUrl_ as String) as Void
  trace("playStitchedContentWithAds() -- raf version: " + m.raf.getLibVersion())

  m.adPods = resolveAdPods(truexTagUrl_)
  m.video = video_
  m.raf.stitchedAdsInit(m.adPods)

  port_ = CreateObject("roMessagePort")

  video_.observeFieldScoped("position", port_)
  video_.observeFieldScoped("state", port_)
  video_.observeFieldScoped("control", port_)

  video_.visible = true
  video_.setFocus(true)
  video_.control = "play"

  playContent_ = true

  m.currentPosition = -1
  m.currentState = "loading"

  player_ = { sgNode: video_, port: port_ }
  videoId_ = m.video.id

  trace("playStitchedContentWithAds() - loop started")

  while playContent_
    msg_ = wait(0, port_)
    msgType_ = type(msg_)

    ' check if we're rendering a stitched ad which handles the event
    currentAdEvent_ = m.raf.stitchedAdHandledEvent(msg_, player_)

    ' if msgType_ = "roSGNodeEvent" then
    '   _ = m.raf.util.infocache

    '   ? ""
    '   ? ""
    '   ? "node: ";msg_.GetNode();", field: ";msg_.GetField();", value: ";msg_.GetData()
    '   ? "position: ";_.curplaypos"adindex: ";_.curadindex;", adpodindex: ";_.curadpodindex;", state: ";_.curadstate
    '   ? ""
    '   ? ""
    ' end if

    if currentAdEvent_ <> invalid then
      if currentAdEvent_.evtHandled and currentAdEvent_.adExited then
        trace("playStitchedContentWithAds() - User exited ad view, returning to content selection")
        playContent_ = false
        m.exitEvent = { type: "exit", reason: "back" }
      end if

      currentAdInfo_ = findCurrentAdInfo(m.adPods, currentAdEvent_)

      if _isTrueXAdEvent(msg_, currentAdInfo_) then
        if m.truex = invalid then
          m.truex = _TrueXAdHelper(m.raf, findCurrentAdInfo(m.adPods, currentAdEvent_))
        end if

        m.truex.handleTrueXAdEvent(msg_, currentAdInfo_)
      end if

      if currentAdEvent_.adCompleted and m.truex <> invalid and not(m.truex.isSameAd(currentAdInfo_)) then
        m.truex.reset()
        m.truex = invalid
      end if
    else
      ' no current ad, the ad did not handle event, fall through to default event handling
      if msgType_ = "roSGNodeEvent" and msg_.GetNode() = videoId_ then

        field_ = msg_.GetField()
        value_ = msg_.GetData()

        trace(Substitute("handleVideoPropertyChanged(field: {0}) -- value", field_), value_)

        if field_ = "control" then
          if value_ = "stop" then
            ? ""
            ? "RAF - VIDEO STOPPED"
            ? ""
            exit while
          end if
        else if field_ = "position" then
          m.currentPosition = value_
          m.currentState = "playing"

        else if field_ = "state" then
          m.currentState = value_

          if m.currentState = "stopped" then
            playContent_ = false
          else if m.currentState = "finished" then
            playContent_ = false
          end if
        endif
      end if
    end if
  end while

  trace("playStitchedContentWithAds() - loop ended")
end function

function reset() as Void
  trace("reset()")

  m.top.video = invalid
  m.top.view = invalid
end function

function handleRafTrackingEvent(_iface, event_ = invalid, ctx_ = invalid) as Void
  trace(Substitute("handleRafTrackingEvent() -- evt: {0}, data: {1}", _asString(event_), FormatJson(ctx_)))

  if not(_isString(event_)) then
    return
  end if

  if event_ = "PodStart" then
    trace("handlePodStart()")
  else if event_ = "PodComplete" then
    trace("handlePodComplete()")
  else if event_ = "Skip"
    trace("handleAdSkipped()")
  end if
end function

' @returns {{ adPod: object, ad: object, adPodIndex: number, adIndex: number } | invalid}
function findCurrentAdInfo(adPods_ as Object, adEventInfo_ as Object) as Dynamic
  ' .adpodindex starts with 1
  ' .adindex starts with 1

  currentAdPod_ = adPods_[_Math_Max(0, adEventInfo_.adpodindex - 1)]

  if currentAdPod_ = invalid then
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

function _isTrueXAdEvent(msg_ as Object, currentAdInfo_ as Dynamic) as Boolean
  if type(msg_) <> "roSGNodeEvent" or currentAdInfo_ = invalid then
    return false
  end if

  ' in this particular case we assume `adId` should start with `truex-`
  ' but in real world screnario it depends on the publisher adserver's response
  return _asString(currentAdInfo_.ad.adId).StartsWith("truex-")
end function