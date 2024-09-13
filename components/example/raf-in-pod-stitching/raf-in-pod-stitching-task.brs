' TASK THREAD

Library "Roku_Ads.brs"

sub runInBackground()
  m.raf = Roku_Ads()
  m.raf.setDebugOutput(true)

  playStitchedAdPod(m.top.view, m.top.adPod)

  if m.exitEvent <> invalid then
    m.top.event = m.exitEvent
  end if
end sub

function playStitchedAdPod(adContainer_ as Object, adPod_ as Object) as Boolean
  trace("playStitchedAdPod() -- started")

  adPodInfo_ = prepareAdPodInfo(adPod_)
  shouldSkipAdPod_ = false
  userExited_ = false

  if adPodInfo_.truexAd <> invalid then
    shouldSkipAdPod_ = playTrueXAd(m.top.view, adPodInfo_.truexAd)
  end if

  if not(shouldSkipAdPod_) then
    m.raf.importAds(adPodInfo_.adPods)
    m.raf.enableInPodStitching(true)

    userExited_ = m.raf.showAds(adPodInfo_.adPods, invalid, adContainer_)
  end if

  trace("playStitchedAdPod() -- ended")

  return userExited_
end function

function prepareAdPodInfo(adPod_ as Object) as Object
  truexAd_ = invalid
  adPods_ = [ adPod_ ]

  if adPod_.ads[0] <> invalid and LCase(_asString(adPod_.ads[0].adSystem)) = "truex" then
    ' update adpod ads array
    ' - remove truex ad
    ' - update adPod.duration

    truexAd_ = adPod_.ads.shift()
    adPod_.duration = adPod_.duration - truexAd_.duration
  end if

  trace("prepareAdPodInfo() -- has truex ad: %s".format(_asString(truexAd_ <> invalid)))
  return { truexAd: truexAd_, adPods: adPods_ }
end function

function playTrueXAd(adContainer_ as Object, truexAd_ as Object) as Boolean
  if not(loadTrueXRenderer()) then
    return false
  end if

  port_ = CreateObject("roMessagePort")

  renderer_ = adContainer_.createChild("TruexLibrary:TruexAdRenderer")
  renderer_.observeFieldScoped("event", port_)

  rect_ = m.top.getScene().currentDesignResolution

  renderer_.action = {
    type: "init",
    adParameters: ParseJson(truexAd_.adparameters)
    slotType: "preroll",
    channelWidth: rect_.width,
    channelHeight: rect_.height,
  }

  renderer_.action = { type: "start" }
  tokenAchieved_ = false

  while true
    msg_ = wait(0, port_)

    if type(msg_) <> "roSGNodeEvent" and msg_.GetField() <> "event" then
      continue while
    end if

    evt_ = msg_.GetData()

    trace("handleTruexEvent() - %s".format(FormatJson(evt_)))

    if evt_.type = "adError" then
      exit while
    else if evt_.type = "noAdsAvailable" then
      exit while
    else if evt_.type = "adFreePod" then
      tokenAchieved_ = true
    else if evt_.type = "adCompleted" then
      exit while
    end if
  end while

  renderer_.unobserveFieldScoped("event")

  if renderer_.getParent() <> invalid then
    renderer_.getParent().removeChild(renderer_)
  end if

  renderer_ = invalid

  return tokenAchieved_
end function

function loadTrueXRenderer() as Boolean
  global_ = GetGlobalAA().global

  if global_.hasField("___truexLibrary") then
    trace("loadTrueXRenderer() -- already loaded")

    return true
  end if

  port_ = CreateObject("roMessagePort")

  library_ = CreateObject("roSGNode", "ComponentLibrary")
  library_.id = "truex-ad-renderer-library"
  library_.uri = "https://ctv.truex.com/roku/v1/release/TruexAdRenderer-Roku-v1.pkg"
  library_.observeFieldScoped("loadStatus", port_)

  while true
    msg_ = wait(3000, port_)

    if msg_ = invalid or type(msg_) <> "roSGNodeEvent" then
      exit while
    end if

    if library_.loadStatus = "ready" or library_.loadStatus = "failed" then
      exit while
    end if
  end while

  trace("loadTrueXRenderer() -- loadStatus: %s".format(library_.loadStatus))

  if library_.loadStatus = "ready" then
    global_.addFields({ "___truexLibrary": library_ })
    return true
  end if

  return false
end function

function playStitchedAdPod(adContainer_ as Object, adPod_ as Object, raf_ as Object) as boolean
  ? "playStitchedAdPod() -- started"

  adPodInfo_ = prepareAdPodInfo(adPod_)
  shouldSkipAdPod_ = false
  userExited_ = false

  if adPodInfo_.truexAd <> invalid then
    shouldSkipAdPod_ = playTrueXAd(adContainer_, adPodInfo_.truexAd)
  end if

  if not(shouldSkipAdPod_) then
    raf_.importAds(adPodInfo_.adPods)
    raf_.enableInPodStitching(true)

    userExited_ = raf_.showAds(adPodInfo_.adPods, invalid, adContainer_)
  end if

  ? "playStitchedAdPod() -- ended"

  return userExited_
end function
