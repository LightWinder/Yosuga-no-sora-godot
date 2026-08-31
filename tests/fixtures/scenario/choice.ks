@AddSelect text=第一项 hint=穹
@AddSelect text=第二项 hint=奈绪
@StartSelect
@if exp="ChkSelect(2)"
@OnFlag id=7
@Talk name=奈绪
选择成功
@Hitret id=99
@endif
