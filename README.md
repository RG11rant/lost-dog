# 🐕 Lost Dog

A child-friendly exploration and puzzle maze game built with **Godot 4.7**. Help a lost dog navigate procedurally generated mazes to find its way back home, gathering food and dodging comical neighborhood hazards along the way.

---

## 🎮 Gameplay Features

* **Dynamic Maze Generation**: A recursive backtracker algorithm generates a brand-new maze layout every single time you play or restart.
* **Survival Attributes**: 
  - **Water**: Depletes as you move. Refill by finding refreshing blue water puddles in the corridors.
  - **Food**: Depletes over time. Refill by collecting delicious bones.
* **Polished UI & Retro Look**: Centered game-over and victory overlays scale to any screen size, complete with scoring tracking.
* **Cartoon Vector Visuals**: Enemies are drawn using Godot's built-in vector `_draw()` methods for clean, sharp, and high-performance vector graphics.

---

## 🐕 Dog Abilities & Navigation Clues

Use the action buttons at the bottom of the screen to help you navigate:

1. **Bark**: Echolocates the exit and displays its distance (e.g. *"Home is 24 steps away"*). It also alerts catchers and cats!
2. **Sniff**: Sniffs the air and points you in the direction of the nearest bone (e.g. *"Bone is North-East"*).
3. **Listen**: Listens closely and reveals the cardinal direction of the home (e.g. *"Hear home to the South-West"*).
4. **Mark**: The dog pees to leave a yellow puddle on the ground. This acts as a visual breadcrumb so you don't go in circles (costs 10 water).

---

## ⚠️ Cartoon Obstacles & Enemies

* **Sleepy Dog Catcher**: Wanders cell-to-cell looking for the dog. If he spots you, he gives chase! If captured, you lose resources and are sent back to the starting point.
  - *Strategy*: **Bark** to distract him! He will walk to investigate the noise source, letting you sneak around him.
* **Grumpy Alley Cat**: Sits stationary and blocks critical intersections. Getting too close scratches you back.
  - *Strategy*: Stand nearby and **Bark** to scare her away permanently.
* **Terror Vacuum**: A rolling vacuum cleaner with googly eyes that rapidly patrols back and forth along straight corridors.
  - *Strategy*: Observe its movement and time your dash to slip past safely.

---

## 🕹️ Controls

* **Movement**: **Left Click** or **Touch** anywhere on the grass grid to command the dog to walk to that spot.
* **Actions**: Click the **Bark**, **Mark**, **Sniff**, or **Listen** buttons on the bottom control bar to trigger abilities.

---

## 🛠️ Setup and Running

### Prerequisites
* [Godot Engine 4.7+](https://godotengine.org/download)

### How to Run
1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/your-username/lost-dog.git
   ```
2. Open the Godot Project Manager, click **Import**, and select the `project.godot` file in the project folder.
3. Click **Run** (F5) in the Godot Editor, or run from the command line:
   ```bash
   path-to-godot-executable --path "lost dog"
   ```
