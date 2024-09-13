True[X] RAF SSAI Example
==========================================

## Motivation

This project contains sample source code that demonstrates how to integrate true[X]'s Ad with RAF and SSAI

## Prerequisites
- Roku device with development mode enabled. Follow [this online guide][roku_device_development_setup] to setup your Roku device for developement. You will need to use Roku's IP and Dev server password.


## How to run this example
Note: Run the following code from the project's dir.
Note: Please replace <ROKU_DEV_TARGET> and <DEVPASSWORD> with your actual device ip and password.

```shell
ROKU_DEV_TARGET=<ROKU_DEV_TARGET> DEVPASSWORD=<ROKU_DEV_TARGET> make install
```

In this demo, we use Innovid Iroll Renderer ( distributed with RAF library ) to render TrueX Ad.
The Ad object will be used to [define AdPod with 4 Ads][adpods_object_creation].

The first ad will be TrueX Ad and 3 additional video ads.
Also this app uses [a prepared video][video_url] to simulate SSAI stream with ads.

## RAF CSAI with `.enableInPodStitching(true)` option


## RAF SSAI

### Disabling "TrueX Ad Flow" support methods in RAF
RAF has two special methods to support TrueX Ad Flow - `Roku_Ads().skipAllAdPods(skipcardAd_)` and `Roku_Ads().skipAdsInCurrentPod()`.
These methods work incorrectly with SSAI playback. Because of this, we need to [override both methods with an empty function][truex_helper_override_raf_methods].

### Event Loop Changes
After [RAF#stitchedAdHandledEvent][raf_stitched_ad_handled_event] handles the current message, we added a check relevant to TrueX Ad flow.
This check will:
- check if the current message is relevant to TrueX Ad.
- create `_TrueXAdHelper` instance if needed.
- invoke `_TrueXAdHelper` [message handling method][truex_helper_event_handling].
- release `_TrueXAdHelper` when TrueX Ad ended.

```brightscript
' check if we're rendering a stitched ad which handles the event
currentAdEvent_ = Roku_Ads().stitchedAdHandledEvent(msg_, player_)

if currentAdEvent_ <> invalid and currentAdEvent_.evtHandled = true then
  ' ad handled event

  if currentAdEvent_.adExited then
    trace("playStitchedContentWithAds() - User exited ad view, returning to content selection")
    playContent_ = false
  end if

  ' @type {{ ad: object, adPod: object, adPodIndex: number, adIndex: number }}
  currentAdInfo_ = findCurrentAdInfo(m.adPods, currentAdEvent_)

  if _isTrueXAdEvent(msg_, currentAdInfo_) then
    if m.truex = invalid then
      m.truex = _TrueXAdHelper(Roku_Ads(), currentAdInfo_)
    end if

    m.truex.handleTrueXAdEvent(msg_, currentAdInfo_)

    if m.truex.adEnded then
      m.truex = invalid
    end if
  end if
else
  ' the app playback logic
end if
```

### Handling Events from true[X] Ad
Please check reference-app's example of [handling these events][truex_helper_event_handling]

#### `exitSelectWatch`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitSelectWatch" }
end sub
```
This event will fire if the user opts for a normal video ad experience. The host app should resume playback and seek to the start position of the next ad.
Check [an example][truex_helper_skip_truex_and_start_next_ad] how to handle this event.

#### `exitAutoWatch`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitAutoWatch" }
end sub

```
This event will fire when the user simply allowed the choice card countdown to expire. The host app responds by resuming and seeking the underlying stream to the start position of the next ad.
Check [an example][truex_helper_skip_truex_and_start_next_ad] how to handle this event.

#### `exitWithSkipAdBreak`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitWithSkipAdBreak" }
end sub
```
This event will fire when the user exits the engagement unit by pressing the **Return to Content** button or pressing `Back` button on his remote **after earning credit**.
The "host app" responds by resuming and seeking the underlying stream over the current ad break. This accomplishes the "reward" portion of the engagement.

Check [an example][truex_helper_skip_ad_pod_and_start_next_content_portion] how to handle this event.


[gulp_guide]: https://gulpjs.com/docs/en/getting-started/quick-start
[truex_helper_event_handling]: ./components/example/truex-helper.brs#L46-L80
[truex_helper_skip_truex_and_start_next_ad]: ./components/example/truex-helper.brs#L113-L124
[truex_helper_skip_ad_pod_and_start_next_content_portion]: ./components/example/truex-helper.brs#L131-L146
[truex_helper_override_raf_methods]: ./components/example//truex-helper.brs#L3-L16
[event_loop_truex_events_checking]: ./components/example/raf-ssai-task.brs#L52-L81
[adpods_object_creation]: ./components/example/example-raf-common.brs#L1-L86
[video_url]: http://development.scratch.truex.com.s3.amazonaws.com/roku/simon/roku-reference-app-stream-med.mp4
[app_payload_example]:  ./source/payload.json

[roku_device_development_setup]: https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md
[yarn_install_guide]: https://yarnpkg.com/getting-started/install
[yarn_link_guide]: https://classic.yarnpkg.com/lang/en/docs/cli/link/
[raf_stitched_ad_handled_event]: https://developer.roku.com/en-ca/docs/developer-program/advertising/raf-api.md#stitchedadhandledeventmsg-as-object-player-as-object-as-roassociativearray
