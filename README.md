# Worth the Climb — Script Setup Guide

A quick reference for wiring up all the new scripts. Share this with your sister!

---

## 1. GameState Autoload (do this first)

1. Open **Project > Project Settings > Autoload**
2. Click the folder icon and select `scripts/game_state.gd`
3. Set the **Node Name** to exactly: `GameState`
4. Click **Add**

This makes `GameState` accessible from every other script in the project.

---

## 2. Scene Structure for tower.tscn

Your Tower scene needs these children added:

```
Tower (Node2D) — tower.gd
├── Parallax2D / background (already exists)
├── Knight (already exists)
├── Princess (Area2D) — princess.gd
│   ├── CollisionShape2D
│   └── AnimatedSprite2D
├── ItemMenu (CanvasLayer) — item_menu.gd
│   └── Panel
│       ├── TitleLabel   (Label)
│       ├── Button0      (Button)
│       ├── Button1      (Button)
│       └── Button2      (Button)
└── Cutscene (CanvasLayer) — cutscene.gd
    └── Panel
        ├── DialogueLabel  (RichTextLabel)
        └── ContinueLabel  (Label, text = "Press Space to continue")
```

Both `Panel` nodes should have **Visible = false** in the editor by default.

---

## 3. item.tscn — create this new scene

1. Create a new scene, root node type: **Area2D**
2. Rename root to `Item`
3. Add children:
   - **CollisionShape2D** (small circle or rect shape)
   - **Sprite2D** (placeholder icon — use any texture for now)
   - *(optional)* **Label** to show the category name above it
4. Attach `scripts/item.gd` to the root
5. Save as `scenes/item.tscn`

---

## 4. Player group

The updated `player.gd` adds the player to the `"player"` group automatically in `_ready()`. No manual editor step needed.

---

## 5. Princess node paths

In `princess.gd`, two `@export` variables point to the Cutscene and ItemMenu nodes:

```gdscript
@export var cutscene_path:  NodePath = "/root/Tower/Cutscene"
@export var item_menu_path: NodePath = "/root/Tower/ItemMenu"
```

If your scene tree uses different names, update these in the Inspector.

---

## 6. Placeholder scenes needed

The following scenes are referenced but not yet created — stub them out as simple nodes so the game doesn't crash:

- `res://scenes/win_screen.tscn`
- `res://scenes/game_over.tscn`

Each can just be a Node2D with a Label saying "Win!" or "Game Over" for now.

---

## 7. Script → Node summary

| Script          | Node type   | Where              |
|-----------------|-------------|--------------------|
| game_state.gd   | (Autoload)  | Project Settings   |
| tower.gd        | Node2D      | Tower (root)       |
| player.gd       | CharacterBody2D | Knight         |
| item.gd         | Area2D      | item.tscn (root)   |
| item_menu.gd    | CanvasLayer | Tower/ItemMenu     |
| cutscene.gd     | CanvasLayer | Tower/Cutscene     |
| princess.gd     | Area2D      | Tower/Princess     |