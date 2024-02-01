# Material Color Utilities for Delphi

This is a Delphi port from the CPP version of Google [Material Color Utilities](https://github.com/material-foundation/material-color-utilities)

Nothing fancy, just a line-to-line port with some Delphisms to deal with CPP std lib but it requires at least Delphi 11 (inline variables declarations)

All tests have been ported and require [DUnitX](https://github.com/VSoftTechnologies/DUnitX) and [TestInsight](https://bitbucket.org/sglienke/testinsight/wiki/Home) to be run.

The plan is to build a Custom Style class so delphi apps could automagically themed... (help needed)

# Material Color Utilities

Algorithms and utilities that power the Material Design 3 (M3) color system, including choosing theme colors from images and creating tones of colors; all in a new color space.

## Usage

See cheat sheet at [Material Color Utilities](https://github.com/material-foundation/material-color-utilities)

### Components

The library is composed of multiple components, each with its own folder and
tests, each as small as possible.

This enables easy merging and updating of subsets into other libraries, such as
Material Design Components, Android System UI, etc. Not all consumers will need
every component — ex. MDC doesn’t need quantization/scoring/image extraction.


| Components       | Purpose                                                   |
| ---------------- | --------------------------------------------------------- |
| **blend**        | Interpolate, harmonize, animate, and gradate colors in HCT |
| **contrast**     | Measure contrast, obtain contrastful colors               |
| **dislike**      | Check and fix universally disliked colors                 |
| **dynamiccolor** | Obtain colors that adjust based on UI state (dark theme, style, preferences, contrast requirements, etc.) |
| **hct**          | A new color space (hue, chrome, tone) based on CAM16 x L*, that accounts for viewing conditions |
| **palettes**     | Tonal palette — range of colors that varies only in tone <br>Core palette — set of tonal palettes needed to create Material color schemes |
| **quantize**     | Turn an image into N colors; composed of Celebi, which runs Wu, then WSMeans<br/><strong>NOT IMPLEMENTED</strong> |
| **scheme**       | Create static and dynamic color schemes from a single color or a core palette |
| **score**        | Rank colors for suitability for theming                   |
| **temperature**  | Obtain analogous and complementary colors                 |
| **utilities**    | Color — convert between color spaces needed to implement HCT/CAM16 <br>Math — functions for ex. ensuring hue is between 0 and 360, clamping, etc. <br>String - convert between strings and integers |

## Background

[The Science of Color & Design - Material Design](https://material.io/blog/science-of-color-design)

## Design tooling

The
[Material Theme Builder](https://www.figma.com/community/plugin/1034969338659738588/Material-Theme-Builder)
Figma plugin and
[web tool](https://material-foundation.github.io/material-theme-builder/) are
recommended for design workflows. The Material Theme Builder delivers dynamic
color to where design is done. Designers can take an existing design, and see
what it looks like under different themes, with just a couple clicks.

# Licence

The original code belongs to Google and this port is licenced under the [Apache Public Licence v2](https://www.apache.org/licenses/LICENSE-2.0)