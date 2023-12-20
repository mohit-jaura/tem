# TEM iOS app

- [Environment configs](#environment-configs)
- [Versioning](#versioning)
- [Publishing](#publishing)

## Environment configs

Environment selection is dove via Schema selection (Dev, QA, Production).

Main environment config is [Configuration/env.json](./TemApp/Configuration/env.json). It holds default config properties, which could be overridden with a specific environment config:
- [Configuration/Production/env.json](./TemApp/Configuration/Production/env.json)
- [Configuration/QA/env.json](./TemApp/Configuration/QA/env.json)
- [Configuration/Dev/env.json](./TemApp/Configuration/Dev/env.json) - gitignored, so it possible to store different configs on each development machine.

Another concern, that uses environment selection, is Firebase config `GoogleService-Info.plist`, which is placed in the same folder for each environment, as `env.json`.

## Versioning

iOS applications are versioned with a following pair:
- Version number
- Build number

To simplify versioning, the same approach as for Android application was adopted:
- Version number is following SemVer: `{major}.{minor}.{patch}`
  - Minor version is a generally incremented version, when a new feature is to be released.
  - Patch version is to be incremented when there are some bugfixes to be released immediately.
- Build number is monotonously incremented for all builds that are to be submitted into App Store.

Check out release approach described for Android application [here](../android/readme.md#release-approach).

As versioning is entirely manual, there are following scripts to simplify versions management:
- `npm run version:major` - bumps major version **and** build number
- `npm run version:minor` - bumps minor version **and** build number
- `npm run version:patch` - bumps patch version **and** build number
- `npm run version:same` - bumps build number only

## Publishing

Application building & publishing could be performed on a properly configured Mac only. Build-machine should have the latest XCode installed, proper Apple ID should be registered:
- it should be added to `Capovela LLC` team
- it should have `App Manager` role
- it should have access to `Certificates, Identifiers & Profiles`

Publishing could be performed either manually or via shell (latter is used in an automated CI/CD process). In both approaches resulting artifact is pushed into TestFlight for review.

- Automatically: (replace `QA` scheme with `Production` for prod builds)

```bash
xcodebuild -workspace TemApp.xcworkspace -scheme QA -archivePath ../../../build/iphone/TemApp.xcarchive -quiet archive
xcodebuild -exportArchive -archivePath ../../../build/iphone/TemApp.xcarchive -exportOptionsPlist UploadBundle.plist -quiet -allowProvisioningUpdates
```

- Manually:
  1. Select needed environment-specific Scheme (QA, Production)
  2. Select target device `Any iOS Device`
  3. Select Product - Archive, wait until creating archive is  finished
  4. In the opened Organizer window, select newly created archive.
  5. Select `Distribute App`
  6. Select `App Store Connect`
  7. Select `Upload (send app to App Store Connect)`
  8. Leave selected all available options:
      - `Include bitcode for iOS content`
      - `Strip Swift Symbols`
      - `Upload your app symbols`
  9. Select `Automatically manage signing`
  10. Select `Upload`

When artifact review is finished (usually it takes 30-60 mins), there are compliance policies to be accepted manually in App Store. When accepted, the build is available for testers.

Please note, that only `Production` builds are to be used for creating generally-available releases.
