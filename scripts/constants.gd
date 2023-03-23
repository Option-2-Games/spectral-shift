extends Node
## Collection of global constants

## Spectrum enum
##
## BASE - Base reality, no spectrums merged
## RED - Red spectrum merged
## GREEN - Green spectrum merged
## BLUE - Blue spectrum merged
enum Spectrum { BASE, RED, GREEN, BLUE }

## Standard spectrum color pallet
const STANDARD_COLOR = {
	Spectrum.RED: Color("c74e53"),
	Spectrum.GREEN: Color("53c74e"),
	Spectrum.BLUE: Color("4e53c7")
}

## Highlight spectrum color pallet
const HIGHLIGHT_COLOR = {
	Spectrum.BASE: Color("646464"),
	Spectrum.RED: Color(1.5, 0.31, 0.33),
	Spectrum.GREEN: Color(0.33, 1.5, 0.31),
	Spectrum.BLUE: Color(0.31, 0.33, 1.5)
}
