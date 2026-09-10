class_name AppreciationMusicButton
extends Button

# Display text transcribed from the original track_XX title artwork.
const TITLES := {
	"track_01": ["道路同天空的交界处", "道の町、空の向こう"],
	"track_02": ["那个温柔的风吹拂的地方", "優しい風が吹くあの場所で"],
	"track_03": ["骗小孩的摇篮曲", "子守歌じゃないのに"],
	"track_04": ["对安宁的向往", "スローライフに憧れて"],
	"track_05": ["辽阔的天空与纸飞机", "大空と紙飛行機"],
	"track_06": ["膝枕相伴的放学后", "膝枕で過ごす放課後"],
	"track_07": ["耿直、笨拙却好强", "素直と不器用と意地っ張り"],
	"track_08": ["黄昏时的归家路", "黄昏の帰り道"],
	"track_09": ["划过脸颊的冰冷泪水", "頬を伝う冷たい涙"],
	"track_10": ["灰暗的念头", "漆黒の思惑"],
	"track_11": ["背反的思绪", "気持ちの狭間"],
	"track_12": ["哎哟哟～", "むふ～"],
	"track_13": ["来，冲呀！", "よーし、やっちまえ！"],
	"track_14": ["享受当下便是胜利", "楽しんだ今が勝ち！"],
	"track_15": ["寂寞的夜晚", "寂しい夜"],
	"track_16": ["永不凋零的珍贵之心", "無くならない大事な心"],
	"track_17": ["一直追寻的宝物", "追い求めてきたもの"],
	"track_18": ["繁星的雨点", "星の滴"],
	"track_19": ["迈向未来的那一步", "未来へ踏み出す一歩"],
	"track_20": ["开荒辟土", "開闢新地"],
	"track_21": ["透过曙光的三棱镜", "夜明けのプリズム"],
}

var item_id: StringName = &""
var _selected := false

func _ready() -> void:
	focus_entered.connect(_update_focus)
	focus_exited.connect(_update_focus)
	_update_focus()


func _update_focus() -> void:
	(%FocusInner as Control).visible = has_focus()


func configure(index: int, track: AppreciationMusicTrack) -> void:
	item_id = track.track_id
	(%Number as Label).text = "%02d" % (index + 1)
	var titles: Array = TITLES.get(track.title_id, [track.title_id, ""])
	(%Title as Label).text = titles[0]
	(%Subtitle as Label).text = titles[1]
	var stream := load(track.stream_path) as AudioStream
	var seconds := int(stream.get_length()) if stream != null else 0
	(%Duration as Label).text = "%d:%02d" % [seconds / 60, seconds % 60]
	tooltip_text = str(track.track_id)

func set_selected(value: bool) -> void:
	_selected = value
	button_pressed = value
	(%MusicIcon as Label).text = "" if value else "♪"
	(%Equalizer as Control).visible = value

func is_selected() -> bool:
	return _selected
