


@SetParam arg=112,2	

@PlaySe file=SE357
@Cg file=B01a   

@Talk name=悠
那我走了哦？
@Hitret id=10615

@Talk name=心の声
…………………………
@Hitret id=10616


@PlayBgm file=BGM03

@Talk name=心の声
穹自昨晚起就窝在自己房间里。我对穹打了声招呼，可没有回应。
@Hitret id=10617

@Talk name=心の声
既然没有声响，那是否说明她熬夜了，现在还在睡觉呢？
@Hitret id=10618

@Talk name=心の声
穹一直任性地拒绝上学，说是在解决制服问题前不想去。
@Hitret id=10619

@Talk name=心の声
只要制服送到了，我想她也会来上学的。不过看她一开始就这样子，我很是担心她不能融入新学校。
@Hitret id=10620

@Talk name=心の声
虽然我对班主任解释说她身体不舒服，但装病这套毕竟不是长久之计，就快行不通了。
@Hitret id=10621


@Cg file=B12a   

@Talk name=奈绪 voice=NO030001
早啊！　小悠？
@Hitret id=10622

@Talk name=心の声
在上学路上，奈绪对我招了招手喊道。
@Hitret id=10623


@Char file=CB01_01M 

@Talk name=悠
啊，早啊，奈绪，你是在等我吗？
@Hitret id=10624

@Talk name=奈绪 voice=NO030002
嗯，我想你差不多该出来了。
@Hitret id=10625


@Char file=CF01_01M x=-200   

@Talk name=亮平 voice=RH030001
哟！　让我好等啊，悠？
@Hitret id=10626


@Char file=CB01_13M 
@Update
@action id=奈緒 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=奈緒

@Talk name=奈绪 voice=NO030003
哇，为什么你也在啊？
@Hitret id=10627


@Char file=CB01_13M x=200   
@Char file=CF01_03M 

@Talk name=亮平 voice=RH030002
悠可是我的同班同学啊？　你可别给我来套近乎啊？
@Hitret id=10628

@Talk name=悠
啊、啊哈哈哈……
@Hitret id=10629


@Char file=CB01_06M 

@Talk name=奈绪 voice=NO030004
小悠，真的要当心了哦？　老和傻瓜呆一起，会被视为同类的。
@Hitret id=10630


@Char file=CF01_04M 

@Talk name=亮平 voice=RH030003
嘿，又笨又帅的男人才是最受欢迎的。
@Hitret id=10631

@Talk name=奈绪 voice=NO030005
你只有笨的一面吧？
@Hitret id=10632

@Talk name=奈绪 voice=NO030006
悠这样能受欢迎的因素，你一点都没有吧？
@Hitret id=10633


@Char file=CF01_09M 

@Talk name=亮平 voice=RH030004
你、你说什么！！　我比悠要多一年的人生经验呢，竟然看不懂其中的价值，你也就是只有胸部的女人了。
@Hitret id=10634


@Char file=CB01_13M 

@Talk name=奈绪 voice=NO030007
什么！？　胡子性骚扰！！　傻瓜！　你太差劲了！
@Hitret id=10635


@Char file=CF01_03M 

@Talk name=亮平 voice=RH030005
这是对我的褒扬，我收下了。
@Hitret id=10636


@Char file=CB01_01M 

@Talk name=奈绪 voice=NO030008
小悠，走吧？　这种家伙别管他。
@Hitret id=10637

@Talk name=悠
算了算了……一起走吧，都一条路。
@Hitret id=10638

@Talk name=亮平 voice=RH030006
悠就是懂男人之间的友情啊。
@Hitret id=10639


@Char file=CB01_06M 

@Talk name=奈绪 voice=NO030009
小悠他是太温柔了。
@Hitret id=10640


@Char file=CF01_04M 

@Talk name=亮平 voice=RH030007
总之，悠本来就不错了，接下来就焕发一下精神，培养幽默感和品味吧？
@Hitret id=10641

@Talk name=奈绪 voice=NO030010
明明所有方面的分都比他低，你还说什么呢？
@Hitret id=10642

@Talk name=悠
你们俩关系真好呢？
@Hitret id=10643


@Char file=CB01_08L 
@Char file=CF01_09L 
@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=奈绪＆亮平 voice=NO030011/RH030008
哪里好了？
@Hitret id=10644

@Talk name=悠
……像这样的地方……
@Hitret id=10645

@Talk name=心の声
真的一模一样。
@Hitret id=10646



@ClearChar
@Update

@Cg file=B19a   

@EyeCatch  

@Change target=00_b001b


