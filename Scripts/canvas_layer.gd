extends CanvasLayer

@onready var score_Label = $ScoreLabel

func _process(_delta: float) -> void:
	score_Label.text = "Score: " + str(Score.points)
