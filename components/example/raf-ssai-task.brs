' TASK THREAD

Library "Roku_Ads.brs"

function runInBackground()
  m.raf = Roku_Ads()
  m.raf.setDebugOutput(true)
  m.raf.setTrackingCallback(handleRAFTrackingEvent, m.top)

  overrideRafSkipAPI()
  playStitchedContentWithAds(m.top.adPods, m.top.video)

  reset()
end function

function playStitchedContentWithAds(adPods_ As Object, video_ as Object) as Void
  trace("playStitchedContentWithAds() -- raf version: " + m.raf.getLibVersion())
  trace("playStitchedContentWithAds() -- ad pods", adPods_[0])

  m.adPods = adPods_
  m.raf.stitchedAdsInit(adPods_)

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

  stopPlaybackAt_ = adPods_[0].rendertime + adPods_[0].duration + 10

  player_ = { sgNode: video_, port: port_ }

  trace("playStitchedContentWithAds() - loop started")

  while playContent_
    msg_ = wait(0, port_)
    msgType_ = type(msg_)

    ' check if we're rendering a stitched ad which handles the event
    currentAdEvent_ = m.raf.stitchedAdHandledEvent(msg_, player_)

    if currentAdEvent_ <> invalid and currentAdEvent_.evtHandled <> invalid then
      ' ad handled event

      if currentAdEvent_.adExited then
        trace("playStitchedContentWithAds() - User exited ad view, returning to content selection")
        playContent_ = false
      end if

      currentAdInfo_ = findCurrentAdInfo(m.adPods, currentAdEvent_)

      if isTrueXAdEvent(msg_, currentAdInfo_) then
        handleTrueXAdEvent(msg_, currentAdInfo_)
      end if
    else
      ' no current ad, the ad did not handle event, fall through to default event handling
      if msgType_ = "roSGNodeEvent"

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

          if value_ > stopPlaybackAt_ then
            video_.control = "STOP"
          end if
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
