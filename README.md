# Taxi Rush: Ultimate Edition

Taxi Rush: Ultimate Edition is a console-based real-time arcade simulation game developed entirely in **x86 Assembly Language** using **MASM** and the **Irvine32** library. The game recreates a taxi-driving experience inside a structured **20×20 grid map**, where the player navigates through traffic, picks up passengers, collects bonuses, avoids collisions, and tries to maximize score in real time.

This project was built to demonstrate strong understanding of **low-level programming**, including register manipulation, memory management, modular procedure design, file handling, integer parsing, array-based grid systems, and direct control over program flow without relying on high-level abstractions.

---

## Project Overview

The game simulates a taxi operating in a dynamic grid-based environment. It includes:
- Real-time player movement using non-blocking keyboard input
- Multiple independently moving NPC cars
- Passenger pickup and destination drop-off mechanics
- Bonus events and score rewards
- Collision and crash penalty system
- Multiple gameplay modes
- Taxi selection with different strengths and weaknesses
- Persistent leaderboard stored across executions

The game loop continuously updates movement, rendering, interactions, and scoring, making gameplay smooth and responsive even in a text-mode console environment.

---

## Key Features

- Fully interactive **20×20 grid-based game world**
- Real-time taxi movement with smooth keyboard handling
- **Three independently moving NPC cars**
- NPC path reversal based on collisions with map boundaries
- Passenger spawning with pickup and destination system
- Bonus collection system for additional score
- Collision detection using **2D to 1D array index translation**
- Three gameplay modes:
  - **Career Mode**
  - **Endless Mode**
  - **Time Mode (30 seconds)**
- Taxi selection system:
  - **Yellow Taxi** — faster but more fragile
  - **Red Taxi** — slower but stronger
- Leaderboard system using `highscores.txt`
- Sorting and rewriting logic for persistent scores
- Real-time HUD showing:
  - Score
  - Drops completed
  - Timer
  - Alerts
  - Board state
- Event-based sound feedback using the **Windows Beep API**
- Modular Assembly code organized into **20+ procedures**

---

## Technologies Used

- **x86 Assembly Language**
- **MASM**
- **Irvine32 Library**
- **Windows Console**
- **Windows Beep API**

---

## Learning Objectives

This project was created to practice and demonstrate:
- Low-level problem solving
- Register and memory operations
- Procedure-based program structure
- Dynamic arrays and coordinate mapping
- Real-time input handling
- Collision logic in assembly
- File reading and writing
- Score sorting and persistence
- Console rendering with colors and text-mode UI

---

## Gameplay Mechanics

### Taxi Movement
The player controls a taxi inside a 20×20 map. Movement happens in real time using non-blocking keyboard checks, so the game does not pause while waiting for input.

### NPC Cars
Three NPC cars move automatically across the grid. Their directions reverse when they encounter boundaries or collision conditions, creating dynamic obstacles for the player.

### Passengers and Destinations
Passengers spawn randomly on the map. The player must move close enough to pick them up, then drive them to generated destination points to earn score.

### Bonuses
Bonus items appear randomly and give extra rewards when collected, encouraging exploration and faster reactions.

### Collision System
Collisions are checked at the grid-cell level. Coordinates are converted from 2D positions into 1D array indices for efficient map interaction and crash handling.

### Leaderboard
Player scores are saved in `highscores.txt`. The game reads, sorts, updates, and rewrites leaderboard data so scores persist across multiple runs.

---

## Game Modes

### Career Mode
A structured progression mode focused on completing drop-offs and earning score while managing risks.

### Endless Mode
An open-ended survival mode where the player continues as long as possible while maximizing score.

### Time Mode
A timed challenge mode lasting **30 seconds**, requiring quick decisions and fast movement for the highest possible score.

---

## Project Structure

The codebase is organized into multiple independent procedures for better readability and modularity. Major modules include:
- Grid rendering
- Player movement
- NPC movement
- Passenger generation
- Destination generation
- Bonus spawning
- Collision checking
- Score updates
- HUD rendering
- Leaderboard file handling
- Sound events

---

## How to Run

### Requirements
- Windows OS
- MASM assembler
- Irvine32 library properly configured
- Visual Studio / compatible MASM environment

### Steps
1. Clone this repository:
   ```bash
   git clone <your-repo-link>
