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

Example tags:

- ATTX Target - https://ee.truex.com/ads/af2eac91d/config_json
- ATTX Today's Military Influencer (Fire Team) - https://ee.truex.com/ads/aad3e82fa/config_json
- ATTX Target, Multiple Videos - https://ee.truex.com/ads/afca28654/config_json

Run the following code from the project's dir.
Note: Please replace <ROKU_DEV_TARGET> and <DEV_PASSWORD> with your actual device ip and password.

```bash
yarn just package-and-run \
  --device-ip=<ROKU_DEV_TARGET> \
  --device-pass=<DEV_PASSWORD> \
  --preview-uri="<ENGAGEMENT_AD_TAG_URL>"
```

## Integration

### Handling Events from true[X] Ad
Once `init` has been called on the component, it will start to emit events.
Please check reference-app's example of [handling these events][engagement_handling_events]

#### `exitSelectWatch`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitSelectWatch" }
end sub
```

This event will fire if the user opts for a normal video ad experience

#### `exitAutoWatch`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitAutoWatch" }
end sub

```

This event will fire when the user simply allowed the choice card countdown to expire.

This is an `exit event`. This event will fire when the user exits the engagement unit by pressing the **Return to Content** button **after earning credit**.

#### `exitWithSkipAdBreak`
```brightscript
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitWithSkipAdBreak" }
end sub
```


This event is relevant for `Sponsored Ad Break` product only and will fire when the user exits the engagement unit by pressing the **Return to Content** button or pressing `Back` button on his remote **after earning credit**.

#### `exitWithAdFree`
```brightscript
sub handleEngagementEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = {
    '     type: "backOutBeforeTrueAttention"
    '     timespent: 113631, // spent time since the start in MS
    '     timespentwithpauses: 113631, // spent time since the start in MS, not includes yes-or-no dialog time
    ' }
end sub
```

This event is relevant for `Sponsored Stream` product only and will fire when the user exits the engagement unit by pressing the **Return to Content** button or pressing `Back` button on his remote **after earning credit**.


[gulp_guide]: https://gulpjs.com/docs/en/getting-started/quick-start
[build_include_component_sources_snippet]: ./../just.config.ts#L136-L143
[engagement_handling_events]: ./../components/infillion/examples/engagement/engagement-event-handler.brs

[roku_device_development_setup]: https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md
[yarn_install_guide]: https://yarnpkg.com/getting-started/install
[yarn_link_guide]: https://classic.yarnpkg.com/lang/en/docs/cli/link/
[bluescript_reference]: https://github.com/socialvibe/truex-ads-docs/blob/master/bluescript-reference.md
[truex_roku_renderer_repo]: https://github.com/socialvibe/TruexAdRenderer-Roku
[integration_engagement_component]: docs/engagement-component-integration.md
[integration_bluescript_engine]: docs/bluescript-engine-integration.md
