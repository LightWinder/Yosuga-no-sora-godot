@AddSelect text=不可选择 invalid
@AddSelect text=可以选择
@StartSelect
@SelectTerminate
@if exp="ChkSelect(2)"
@SetParam arg=112,4
@OnGlobalFlag id=9
@Talk name=悠
有效选项继续执行
@Hitret id=2
@endif
