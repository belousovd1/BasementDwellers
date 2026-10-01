class_name Projectile
extends Area2D
## Anything that hurts the player on contact.
##
## Projectiles sit on the "Projectiles" physics layer, which the player's
## ProjectileDetector watches; the player then reads [member damage].

@export var damage := 20
