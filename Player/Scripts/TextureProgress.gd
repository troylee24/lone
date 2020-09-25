tool
extends TextureProgress

export(Color) var COLOR

func update_value(new_value):	
	$TweenColor.interpolate_property(self,'modulate',modulate,Color(255,255,255),0.4,Tween.TRANS_LINEAR,Tween.EASE_OUT_IN)
	$TweenColor.start()
	
	$TweenProgress.interpolate_property(self,'value',value,new_value,0.3,Tween.TRANS_ELASTIC,Tween.EASE_OUT)
	$TweenProgress.start()

func _on_TweenColor_tween_completed(_object, _key):
	set_color_normal(COLOR)
	
func set_color_normal(value):
	COLOR = value
	modulate = value
