@Char file=CB02_11M
@Font face=48
@Talk name=奈绪
第一个选项之前
@Hitret id=1
@AddSelect text=第一条路线 hint=穹
@StartSelect
@if exp="ChkSelect(1)"
@Char file=CC01_01M
@Talk name=悠
第二个选项跳转起点
@Hitret id=2
@Font face=36
@Talk name=悠
跳转途中使用临时小字
@Hitret id=3
@Talk name=瑛
第二个选项之前
@Hitret id=4
@AddSelect text=第二条路线 hint=穹
@StartSelect
@if exp="ChkSelect(1)"
@Talk name=悠
第二个选项之后
@Hitret id=5
@endif
@endif
