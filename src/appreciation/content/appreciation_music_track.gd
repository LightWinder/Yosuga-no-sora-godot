class_name AppreciationMusicTrack
extends Resource


@export var track_id: StringName = &""
@export var title_id: String = ""
@export var stream_path: String = ""
@export var loop_enabled: bool = false
@export var loop_sample: int = 0
@export var sample_rate: int = 44100


func loop_offset_seconds() -> float:
	if not loop_enabled or sample_rate <= 0:
		return 0.0
	return float(loop_sample) / float(sample_rate)
