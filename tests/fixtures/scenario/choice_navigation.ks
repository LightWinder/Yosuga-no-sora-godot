@Talk name=悠
选项跳转起点
@Hitret id=1
@Hide wait
@Wait time=500 HitCancel
@PlaySe file=SE001
@Cg file=missing_intermediate_navigation_asset
@Cg file=BLACK
@AddSelect text=继续前进 hint=穹
@StartSelect
@if exp="ChkSelect(1)"
@OnFlag id=8
@Show wait
@Talk name=悠
选项跳转完成
@Hitret id=2
@endif
