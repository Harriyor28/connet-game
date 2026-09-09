# Connect 3D Asset Bible

## Overview
This document defines the visual language for the Phase 2 and Phase 4 premium prototype. The goal is a clean, mobile-first 3D puzzle aesthetic that feels polished without using a large asset library or heavy runtime dependencies.

## 1. Node geometry
- Primary geometry: stylized sphere with a rounded silhouette.
- Visual treatment: white core with a subtle cyan tint, glossy highlight, and soft edges.
- Scale: comfortable mobile touch size with slightly enlarged active/selected nodes.
- Depth: nodes sit above the board plane with a subtle offset and cast shadow.
- Rim lighting: thin edge highlight to separate the node from the dark board.

## 2. Node material
- Base color: near-white with a cool cyan sheen.
- Highlight: a faint white specular area on the upper-left edge.
- Shadow: dark radial shadow under each node to anchor it to the board.
- State colors:
  - idle: white/cool cyan
  - active: bright cyan
  - connected: magenta/cyan accent
  - completed: success green
  - invalid: warning red

## 3. Cable material
- Geometry: rounded tube with a soft glow and a narrow core highlight.
- Thickness: consistent across all connections, slightly heavier for active/locked paths.
- Glow: soft blurred outer halo with a brighter core to create readable depth.
- Color progression: cyan default, brighter cyan while active, magenta when locked, warm alert red when invalid.
- Energy pulse: short traveling highlight passes from start to end on successful confirmation.

## 4. Board material
- Surface: dark rounded platform with a subtle bevel and layered gradients.
- Depth cue: soft perspective grid and low-opacity lines to suggest a 3D plane.
- Edge treatment: thin cyan border and corner accent details.
- Surface formula: low-contrast dark tones to keep white nodes visually dominant.

## 5. Lighting
- Primary light: soft overhead illumination to create a premium, readable presentation.
- Ambient fill: low-intensity dark blue to preserve contrast.
- Rim light: cool cyan edge lighting for the nodes and cables.
- Contact shadow: soft shadow below nodes and the board edges when supported by the canvas style.

## 6. Camera
- Perspective: slight elevated angle, stable and mobile-friendly.
- Depth: nodes are positioned with subtle z-offset so ordering remains readable.
- Motion: no continuous camera rotation; only tiny response to successful interactions.
- Framing: keep the board centered with safe-area padding on small phones and large screens.

## 7. Particle style
- Lightweight, procedural particles only.
- Lifetime: short, under 0.6s for most interactions.
- Spawn rules: small bursts triggered by successful connection and level completion.
- Limit: keep counts intentionally low to preserve frame rate and avoid memory bloat.

## 8. UI style
- Minimal glass panels with soft transparency and a modern premium HUD.
- Type: clean, modern sans/tech-inspired styling for mobile.
- Use: labels, HUD stats, and completion states stay readable and non-distracting.
- Panels: rounded corners, subtle cyan borders, low-opacity fills.

## 9. Typography
- UI targets: modern, compact, and readable on small screens.
- Letter-spaced headings for the game title and level attribution.
- Numeric HUD values should be high-contrast and easy to scan.

## 10. Spacing and layout
- Use consistent spacing units rather than arbitrary pixel values.
- Keep the board centered and unobstructed by HUD panels.
- Respect safe areas and notched devices.
- Do not rely on fixed-size coordinates for the entire interface.

## 11. Animation principles
- Subtle, clean motion beats that reinforce state changes.
- Idle node pulse: very gentle and low amplitude.
- Selected node: small scale-up and glow.
- Connection feedback: short burst and energy pulse without oversaturating the board.
- Level completion: quick celebration with strong readability and smooth fade-out.

## 12. Color system
- Background: deep midnight blue / graphite foundation.
- Primary accent: cyan.
- Secondary accent: magenta.
- Success: green.
- Warning: red/orange.
- Text: white, muted cool gray, and cyan highlights.
- Keep colors centralized in the app theme and constants rather than scattering colors across widgets.

## 13. Future guidance
- Keep the visual language consistent across nodes, board, cables, UI, and particles.
- Add more environments only after the base prototype is fully validated.
- Prefers procedural geometry and lightweight effects over large static assets.

## 14. World architecture
- World 1, Neon Lab, is the fully styled demonstration environment.
- Space, Crystal, Cyber City, Ancient Temple, Ocean, and Volcano are registered as lightweight placeholder worlds.
- A world selects its background, board palette, accent colors, particle color, environment identifier, and asset keys through configuration.
- World-specific logic must not be embedded in puzzle validation or node rendering.

## 15. Environment layers
- Background: two-color gradient with a low-opacity grid.
- Distant layer: reserved for future world scenery and low-detail silhouettes.
- Midground layer: reserved for ambient lights and decorative geometry.
- Puzzle layer: the board, nodes, cables, and blockers remain the visual focus.
- Effect layer: short-lived energy events and restrained particles sit above gameplay.

## 16. Asset management
- Asset names use stable identifiers such as `world_neon_lab`, `node_energy`, `obstacle_static`, and `effect_connection`.
- The asset manager loads only the active world's registered keys.
- Procedural visuals do not require file-backed assets and remain offline-safe.
- World assets should be unloaded when the active world changes to keep memory bounded.

## 17. Special nodes
- Normal: standard connection point and baseline pulse.
- Energy: brighter cable pulse and stronger activation response.
- Bonus: short reward burst and score bonus.
- Locked: unavailable until its declarative activation requirement is satisfied.
- Rotating: reserved for orientation-aware mechanics.
- Timed: reserved for time-window mechanics.
- Special behavior is described by `SpecialNodeDefinition`; renderers consume the definition rather than owning puzzle rules.

## 18. Obstacles
- Static blocker: fixed rounded volume that prevents cable segments from crossing.
- Moving blocker: predictable horizontal oscillation with a fixed period.
- Rotating blocker: reserved for future angle-aware collision.
- Energy barrier: translucent accent-colored barrier with a glow treatment.
- Obstacle bounds are normalized to the board and are checked mathematically by the puzzle state before a connection is accepted.

## 19. Effect rules
- Connection effects are emitted through one `EffectController` stream.
- Combo intensity scales gradually with combo count; no random effect spawning is allowed.
- Perfect and completion effects are separate event types but share the same visual channel.
- Effects should be short, readable, and bounded in object count on mobile hardware.
