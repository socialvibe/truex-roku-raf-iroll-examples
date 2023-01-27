Roku Bluescript Engagement Ads Integration
==========================================

## Motivation

This project contains sample source code that demonstrates how to integrate true[X]'s Ad with RAF and SSAI.

## Prerequisites
- IDE with Roku support ( VSCode or IDEA )
- Node >= 18
- Roku device with development mode enabled. Follow [this online guide][roku_device_development_setup] to setup your Roku device for developement. You will need to use Roku's IP and Dev server password.


## Getting Started

- Clone Project
  ```bash
  git clone git@github.com:socialvibe/truex-bluescript-ads-integration.git
  ```
- Change to project directory
  ```bash
  cd reference-app-roku
  ```
- Install Dependencies ( we use [yarn][yarn_install_guide] )
  ```bash
  yarn install
  ```

## How to run this example
Note: Run the following code from the project's dir.
Note: Please replace <ROKU_DEV_TARGET> and <DEV_PASSWORD> with your actual device ip and password.

```bash
yarn just package-and-run \
  --device-ip=<ROKU_DEV_TARGET> \
  --device-pass=<DEV_PASSWORD> \
  --truex-ad-tag="https://qa-get.truex.com/50f0b0944f3a826e6d73c8895cb868fb2af0171c/vast/connected_device/inline?network_user_id=truex_engagement_test_user_001"
```

Running this script will load TrueX Ad Tag and create [payload.json][app_payload] file contains RAF compatible Ad object.
In this demo we use Innovid Iroll Renderer ( distributed with RAF library ) to render TrueX Ad.
This Ad object will be used to [define AdPod with 4 Ads][adpods_object_creation].

The first ad will be TrueX Ad and 3 additional video ads.
Also this app uses [a prepared video][video_url] to simulate SSAI stream with ads.


## Integration

### Disabling RAF default implementation supporting TrueX Ad Flow
RAF have 2 special methods in order to support TrueX Ad Flow - `Roku_Ads # skipAllAdPods` and `Roku_Ads # skipAdsInCurrentPod`.
These methods work incorrectly in SSAI environment.

So, in order to resolve there are 2 options:
- create and save a deep copy of AdPods object ( will be used in `_isTrueXAdEvent` method)
- override these 2 RAF methods with empty function


### Event Loop Changes
After handling the current message by [RAF#stitchedAdHandledEvent][raf_stitched_ad_handled_event] method we added additional check relevant to TrueX Ad flow.
It will:
- check if the current message is relevant to TrueX Ad
- create `_TrueXAdHelper` instance
- invoke `TrueXAdHelper` [message handling method][truex_helper_event_handling]
- dispose `_TrueXAdHelper` when TrueX Ad ended.

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
      m.truex = _TrueXAdHelper(m.video, currentAdInfo_)
    end if

    m.truex.handleTrueXAdEvent(msg_, currentAdInfo_)

    if m.truex.adEnded then
      m.truex = invalid
    end if
  end if
else
  ' other logic
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
This event will fire if the user opts for a normal video ad experience
Check [an example][truex_helper_skip_truex_and_start_next_ad] how to handle this event.

#### `exitAutoWatch`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitAutoWatch" }
end sub

```
This event will fire when the user simply allowed the choice card countdown to expire.
Check [an example][truex_helper_skip_truex_and_start_next_ad] how to handle this event.

#### `exitWithSkipAdBreak`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitWithSkipAdBreak" }
end sub
```
This event is relevant for `Sponsored Ad Break` product only and will fire when the user exits the engagement unit by pressing the **Return to Content** button or pressing `Back` button on his remote **after earning credit**.
Check [an example][truex_helper_skip_ad_pod_and_start_next_content_portion] how to handle this event.

#### `exitWithAdFree`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitWithAdFree" }
end sub
```
This event is relevant for `Sponsored Stream` product only and will fire when the user exits the engagement unit by pressing the **Return to Content** button or pressing `Back` button on his remote **after earning credit**.

[gulp_guide]: https://gulpjs.com/docs/en/getting-started/quick-start
[build_include_component_sources_snippet]: ./../just.config.ts#L136-L143
[truex_helper_event_handling]: ./components/example/truex-helper.brs#L37-L62
[truex_helper_skip_truex_and_start_next_ad]: ./components/example/truex-helper.brs#L61-L73
[truex_helper_skip_ad_pod_and_start_next_content_portion]: ./components/example/truex-helper.brs#L80-98
[event_loop_truex_events_checking]: ./components/example/raf-ssai-task.brs#L52-L81
[event_loop_ad_pods_deep_copy]: ./components/example/raf-ssai-task.brs#L18-L23
[adpods_object_creation]: ./components/example/example-raf-common.brs#L1-L80
[video_url]: http://development.scratch.truex.com.s3.amazonaws.com/roku/simon/roku-reference-app-stream-med.mp4

[roku_device_development_setup]: https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md
[yarn_install_guide]: https://yarnpkg.com/getting-started/install
[yarn_link_guide]: https://classic.yarnpkg.com/lang/en/docs/cli/link/
[raf_stitched_ad_handled_event]: https://developer.roku.com/en-ca/docs/developer-program/advertising/raf-api.md#stitchedadhandledeventmsg-as-object-player-as-object-as-roassociativearray