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

Run the following code from the project's dir.
Note: Please replace <ROKU_DEV_TARGET> and <DEV_PASSWORD> with your actual device ip and password.

```bash
yarn just package-and-run \
  --device-ip=<ROKU_DEV_TARGET> \
  --device-pass=<DEV_PASSWORD> \
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
sub handleTrueXAdEvent(msg_ as Object)
    evt_ = msg_.GetData()

    ' evt_ = { type: "exitWithAdFree" }
end sub
```

This event is relevant for `Sponsored Stream` product only and will fire when the user exits the engagement unit by pressing the **Return to Content** button or pressing `Back` button on his remote **after earning credit**.


[gulp_guide]: https://gulpjs.com/docs/en/getting-started/quick-start
[build_include_component_sources_snippet]: ./../just.config.ts#L136-L143
[event_loop_truex_events_checking]: ./components/example//raf-ssai-task.brs#L59-L61

[roku_device_development_setup]: https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md
[yarn_install_guide]: https://yarnpkg.com/getting-started/install
[yarn_link_guide]: https://classic.yarnpkg.com/lang/en/docs/cli/link/
