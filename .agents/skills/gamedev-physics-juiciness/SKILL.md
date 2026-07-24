---
name: gamedev-physics-juiciness
description: >-
  Guidelines and math patterns for game UX juiciness, spring physics, camera shakes,
  3D hatching cutscenes, and visual feedback in game development. Adaptable for Roblox,
  Three.js, Unity, and Godot.
---

# Game Dev Physics & Juiciness Skill

## Overview
This skill provides best practices for tactile feedback, micro-animations, physics-based movement, and dynamic visual flair ("Juiciness") in 3D and 2D games.

## Core Pillars of Juiciness
1. **Spring & Lerp Physics**:
   - Use critically damped springs for UI buttons and floating companions/pets.
   - Combine sine wave bobbing with smooth target interpolation (`RenderStepped` / `requestAnimationFrame`).
2. **Camera Shake & Impact**:
   - Multi-axis rotational & translational camera shakes during hatching, explosions, or achievements.
   - Dynamic 3-stage hatching cutscenes: Zoom-In $\to$ Tension Shake $\to$ Particle Burst $\to$ Rarity Aura Reveal.
3. **Object Pooling for VFX**:
   - Pre-allocate particle emitters, light blooms, and coin popups.
   - Recycle instances immediately after particle lifespan expires.
4. **Distance & LOD Optimization**:
   - Disable secondary physics (sine bobbing, high-frequency springs) for objects beyond distance thresholds (e.g. $> 120$ studs/units).

## Common Mistakes
1. Using linear Tweens for physics objects instead of spring dynamics.
2. Unbounded particle spawning that triggers memory leaks or frame drops on low-end devices.
3. Sudden camera movement without smooth easing or dampening.
