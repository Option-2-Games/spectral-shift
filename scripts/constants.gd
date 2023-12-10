## Collection of global constants

## Spectrum enum
##
## BASE - Base reality, no spectrums merged
## RED - Red spectrum merged
## GREEN - Green spectrum merged
## BLUE - Blue spectrum merged
enum Spectrum { BASE = 0, RED = 1, GREEN = 2, BLUE = 3 }

## Physics Object type
##
## INTERACTABLE - any object that expects to have collisions with other things
## MOB - enemy types that can pass through each other without colliding
## GLASS - objects that ignore raycasts
enum PhysicsObjectType { INTERACTABLE = 1, MOB = 16, GLASS = 4096 }

## Standard spectrum color pallet
const STANDARD_COLOR: Array[Color] = [
	Color.WHITE, Color("c74e53"), Color("53c74e"), Color("4e53c7")
]

## Highlight spectrum color pallet
const HIGHLIGHT_COLOR: Array[Color] = [
	Color(1.5, 1.5, 1.5), Color(1.5, 0.31, 0.33), Color(0.33, 1.5, 0.31), Color(0.31, 0.33, 1.5)
]
