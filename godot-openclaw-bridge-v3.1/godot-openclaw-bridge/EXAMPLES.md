# Example Godot Commands for OpenClaw

## Basic Scene Creation

**Create a simple player character:**
```
Create a new scene called "Player" with:
- A CharacterBody2D as root
- A Sprite2D child with a placeholder texture
- A CollisionShape2D with a circle shape
Then add a script with WASD movement
```

## Scene Management

**Get current project info:**
```
What project is currently open in Godot?
```

**List all scenes:**
```
List all .tscn files in my Godot project
```

## Node Operations

**Add a node:**
```
Add a Camera2D node as a child of the Player node
```

**Modify properties:**
```
Set the Player's position to (100, 200) and scale to (2, 2)
```

**Change colors:**
```
Change the background color of the main scene to dark blue
```

## Scripting

**Add movement script:**
```
Add a GDScript to the Player node with this code:
extends CharacterBody2D

@export var speed = 300.0

func _physics_process(delta):
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * speed
    move_and_slide()
```

**Edit existing script:**
```
Edit the Player.gd script and add a jump function with spacebar input
```

## Running the Game

**Test the game:**
```
Run the game and tell me if there are any errors
```

**Stop game:**
```
Stop the running game
```

## File Operations

**Read a script:**
```
Show me the content of res://Player/Player.gd
```

**Create a new script:**
```
Create a file at res://utils.gd with utility functions for health and damage
```