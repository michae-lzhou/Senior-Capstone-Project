extends Control

var score = 0

func update_score():
	$ScoreLabel.text = "Score: " + str(score)
