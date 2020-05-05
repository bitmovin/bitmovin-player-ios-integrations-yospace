# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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

