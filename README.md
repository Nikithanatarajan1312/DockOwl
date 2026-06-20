# DockOwl

A tiny pixel owl that lives above your Dock and guards your focus sessions.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- Pixel owl on a **cloud** (home, screen center) — click to fly to the **tree** (left) and start focus
- Tree with a **digital clock block** showing time remaining
- Click the owl to **fly home and pause**
- Smooth flight animation and chiptune sound effects (toggle in menu)
- Menu bar controls
- Native Swift + AppKit — no Electron, no runtime

## Download (easiest)

1. Go to [Releases](https://github.com/Nikithanatarajan1312/DockOwl/releases)
2. Download `DockOwl-x.x.x.zip`
3. Unzip and drag **DockOwl.app** to Applications
4. First launch: if macOS blocks it, **right-click → Open** (unsigned app)

## Build from source

**Requirements:** macOS 13+, Xcode Command Line Tools or Xcode 15+

```bash
git clone https://github.com/Nikithanatarajan1312/DockOwl.git
cd DockOwl
chmod +x build-app.sh
./build-app.sh
open DockOwl.app
```

Development:

```bash
swift run
```

## Usage

| Action | How |
|--------|-----|
| Start focus | Click the cloud — owl flies to the tree, clock starts |
| Pause | Click the owl — flies home to the cloud, timer pauses |
| Resume | Click the cloud again — owl flies to the tree, timer resumes |
| End session | Menu bar → End Session |
| Toggle sounds | Menu bar → Sounds |
| Quit | Menu bar → Quit DockOwl |

Default timer: **25 min** focus, **5 min** break.

## Project layout

```
Sources/DockOwl/
  App/          Entry point, menu bar, app delegate
  Window/       Scene view + window controller
  Scene/        Cloud, tree, clock, flight animation
  Render/       Pixel owl sprites and drawing
  Brain/        Behavior state machine
  Focus/        Pomodoro-style focus timer
  Support/      Constants, sounds, dock positioning
```

## Publishing a release (maintainers)

```bash
chmod +x package-release.sh
./package-release.sh 0.1.0
```

Upload the generated zip to a new GitHub Release tagged `v0.1.0`.

## License

MIT — see [LICENSE](LICENSE).
