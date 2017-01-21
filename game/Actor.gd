extends Node2D

# No lighthouse for old sailor
# Those damn waves

const Y_TOLERANCE = 10
const STAFF_LENGTH = 100
const ROTATIONS_PER_SECOND = 0.5

var timeSinceLastAction = -10000
var platformNum = 0

const WAITING = 0
const STAFF_FALLING = 1
const JUMPING = 2

var state = WAITING
var staffTarget
var jumpTarget


