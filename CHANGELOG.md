# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased]

### Added
- `BitmovinAnalyticsCollector` to `BitmovinYospacePlayer`

### Changed
- `IntegrationConfiguration` class name to `BitmovinYospaceIntegration`
- Added `PlayerConfiguration` and `YospaceConfiguration` to `BitmovinYospaceIntegration`

## [1.22.0]

### Changed
- Bitmovin player to `2.60.0` 

## [1.21.0]

### Added
- Added support for normalizing the playhead, to guard against the known Apple bug where unexpected time jumps can intermittently occur
- Added an `IntegrationConfiguration` to toggle whether to use normalization

### Changed
- updated the `DateEmitter` to utilize the playhead normalizer, when so configured
- changed the `BitmovinYospacePlayer` init to optionally take a `IntegrationConfiguration` instance

## [1.20.0]

### Added
- `creativeId`, `sequence`, `title`, `avertiser`, `system`, `lineage` and `isFiller` properties to `YospaceAd`

### Changed
- Bitmovin player to `2.59.0` 
- `id` property from `YospaceAd` now returns shortened identifier
- `mediaFileUrl` property from `YospaceAd` now returns the interactive unit source
- `AdBreakPosition` to `YospaceAdBreakPosition`

## [1.19.0]

### Changed
- Bitmovin player to `2.57.1` 

## [1.18.0]

### Added
- Emit Yospace generated ID3 events in `onMetadata` and `onMetadataParsed`

## [1.17.2]

### Changed
- `fireCompanionEvent()` in `BitmovinYospacePlayer`  to `companionRendered()`

## [1.17.1]

### Added
- `fireCompanionEvent()` to `BitmovinYospacePlayer`, which sends companion tracking events to the Yospace SDK

## [1.17.0]

### Added
- List of creative companion ads to `AdStartedEvent`

### Removed
- `truexAd` property from `AdStartedEvent`

## [1.16.0]

### Changed
- Bitmovin player to `2.55.0` 

## [1.15.0]

### Changed
- Yospace SDK to `1.12.3`

## [1.14.0]

### Added
- `suppressAnalytics()` to `BitmovinYospacePlayer`, which suppresses creative tracking beacons 

### Changed
- Yospace SDK to `1.12.0`

## [1.13.1]

### Added
- Emit `DrmDataParsedEvent` from `BitmovinYospacePlayer`

## [1.13.0]

### Changed
- Bitmovin Player to `2.53.0` 

## [1.12.0]

### Changed
- Yospace SDK to `1.11.0`
- Bitmovin player to `2.52.0`

## [1.11.0]

### Changed
- Bitmovin player to `2.51.0` 

## [1.10.1]

### Fixed
- `MetadataParsedEvent` failing to emit

## [1.10.0]

### Changed
- Bitmovin player to `2.50.0` 

## [1.9.0]

### Changed
- Bitmovin player to `2.49.0` 

## [1.8.0]

### Added
- `YSResource.h` to Yospace SDK umbrella header

### Changed
- Yospace SDK to `1.10.4`

## [1.7.0]

### Changed
- Bitmovin player to `2.48.0` 

## [1.6.1]

### Changed
- Bitmovin player to  `2.46.1`

## [1.6.0]

### Added
- Exposed VAST extensions

## [1.5.0]

### Added
- Emit `AdQuartileEvent`

## [1.4.0]

### Added
- `position` (pre/mid/post roll or unknown) to `AdBreak`

### Changed
- Bitmovin player to `2.45.0` 
- Yospace errors to be emitted in the `PlayerListener`

### Removed
- `onYospaceError()` from `YospaceListener`

## [1.3.1]

### Fixed
- `BitLog` visibility flag always being true

## [1.3.0]

### Changed
- Bitmovin player to `2.44.0`
- Fire `AdSkippedEvent` when previously paused in a live ad and then resuming in main content

## [1.2.11]

### Fixed
- tvOS TruexRenderer build issues 
- `truexAd` in `YospaceAdStartedEvent` not being respected

## [1.2.10]

### Fixed
- Incorrect `activeAdBreak` abosluteStart & relativeStart
- Incorrect `activeAd` abosluteStart & relativeStart
- Variation in `absoluteStart` of `activeAd` and matching ad in `activeAdBreak`
- Variation in `relativeStart` of `activeAd` and matching ad in `activeAdBreak`

## [1.2.9]

### Changed
- TrueX prerolls that meet ad free conditions now yield an ad free experience for entire session
- TrueX midrolls that meet ad free conditions now yield an ad free experience for current ad break only

### Fixed
- Incorrect relative time in for VoD & live ads

## [1.2.8]

### Changed
- Bitmovin player to `2.41.0` 
- Yospace SDK to `1.10.0`

### Added
- Modular stability on public value types (structs, enums)

### Fixed
- Empty ad list for live ad breaks

