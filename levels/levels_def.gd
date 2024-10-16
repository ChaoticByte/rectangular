extends Node

const SCENES = {
	"menu": "uid://bqmpoix37kutp",
	"intro": "uid://c6w7lrydi43ts",
	"test": "uid://dqf665b540tfg",
}

var ENTRYPOINTS = {
	"intro_start": LevelsCore.Entrypoint.new(
		"intro",
		Vector2(-1440, 56),
		false, Vector2.ZERO,
		true),
	"test": LevelsCore.Entrypoint.new(
		"test",
		Vector2(1680, 200),
		false, Vector2(0, -500)),
}
