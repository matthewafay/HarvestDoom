# Product Overview

## Arcade FPS Farming Game

A prototype game blending fast-paced arcade FPS combat with cozy farming mechanics. Players alternate between peaceful farming sessions and intense combat runs in short 10-15 minute gameplay loops.

## Core Concept

- **Dual Gameplay Loop**: Farm crops in a peaceful hub, then enter combat zones to test your skills
- **Progression System**: Crops provide temporary buffs for combat runs, while combat rewards unlock permanent upgrades
- **Procedural Visuals**: All art generated at runtime using deterministic algorithms - no asset files
- **Short Sessions**: Complete gameplay loops designed for quick, satisfying play sessions

## Key Features

- First-person FPS combat with multiple weapon types
- Grid-based farming system with time-based and run-based crop growth
- Procedurally generated combat arenas and enemy waves
- Buff system linking farming success to combat power
- Permanent progression through unlockable upgrades
- Comprehensive property-based testing for correctness validation

## Target Platform

- Windows standalone executable
- Target size: Under 50MB
- Built with Godot 4.x using GDScript

## Development Philosophy

- Correctness first: All systems validated through property-based testing
- Modular architecture: Scene-based design with autoload singletons
- Signal-driven communication: Loose coupling between systems
- Resource-based data: Type-safe serialization for game data
