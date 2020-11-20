# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.17.1]

### Added
- `fireCompanionEvent` API to send companion tracking events
- `id` to `CompanionAd`

## [1.17.0]

### Added
- Companion ads to `AdStartedEvent`

### Removed
- Duplicate `truexAd` property from `AdStartedEvent`

## [1.16.0]

### Changed
- Bitmovin Player to version 2.55.0 

## [1.15.0]

### Changed
- Yospace SDK to 1.12.3

## [1.14.0]

### Added
- `suppressAnalytics` API

### Changed
- Yospace SDK to 1.12.0

## [1.13.1]

### Changed
- Pass through `onDrmDataParsed`

## [1.13.0]

### Changed
- Bitmovin Player to version 2.53.0 

## [1.12.0]

### Changed
- Yospace SDK to 1.11.0
- Bitmovin Player to version 2.52.0 

## [1.11.0]

### Changed
- Bitmovin Player to version 2.51.0 

## [1.10.1]

### Fixed
- MetadataParsedEvent not being passed through 

## [1.10.0]

### Changed
- Bitmovin Player to version 2.50.0 

## [1.9.0]

### Changed
- Bitmovin Player to version 2.49.0 

## [1.8.0]

### Added
- YSResource.h to Yospace SDK umbrella header

### Changed
- Yospace SDK to 1.10.4

## [1.7.0]

### Changed
- Bitmovin Player to version 2.48.0 

## [1.6.1]

### Changed
- Bitmovin Player to version 2.46.1 

## [1.6.0]

### Added
- Exposed VAST extensions

## [1.5.0]

### Added
- Exposed AdQuartile event

## [1.4.0]

### Added
- AdBreak position property (pre/mid/post roll or unknown)

### Changed
- Bitmovin Player to version 2.45.0 
- Yospace errors now go through the PlayerListener

### Removed
- YospaceListener.onYospaceError()

## [1.3.1]

### Fixed
- BitLog visibility flag always being true

## [1.3.0]

### Changed
- Bitmovin Player to version 2.44.0 
- Fire AdSkippedEvent when previously paused in a live ad and then resuming in main content

## [1.2.11]

### Fixed
- tvOS TruexRenderer build issues 
- YospaceAdStartedEvent.truexAd not being respected

## [1.2.10]

### Fixed
- Incorrect activeAdBreak abosluteStart & relativeStart
- Incorrect activeAd abosluteStart & relativeStart
- Variation in absoluteStart of activeAd and matching ad in activeAdBreak
- Variation in relativeStart of activeAd and matching ad in activeAdBreak

## [1.2.9]

### Changed
- TrueX prerolls that meet ad free conditions now yield an ad free experience for entire session
- TrueX midrolls that meet ad free conditions now yield an ad free experience for current ad break only

### Fixed
- Incorrect relative time in for VoD & live ads

## [1.2.8]

### Changed
- Bitmovin Player to version 2.41.0 
- Yospace SDK to 1.10.0

### Added
- Modular stability on public value types (structs, enums)

### Fixed
- Empty ad list for live ad breaks

