


@PlaySe file=SE357

@PlayBgm file=BGM05

@Cg file=B01a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Char file=CC01_02S 
@Update
@action id=瑛 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=瑛

@Talk name=瑛 voice=AK020324
早安！
@Hitret id=19281


@Char file=CB01_02S 
@Talk name=奈绪 voice=NO020018
早安，小悠。
@Hitret id=19282


@Char file=CF01_01S 
@Talk name=亮平 voice=RH020083
早！　早上好，小穹！
@Hitret id=19283


@Char file=CD01_10S 
@Talk name=一叶 voice=KA020108
早……早上好……
@Hitret id=19284

@Talk name=悠
大家久等啦，那走吧。
@Hitret id=19285


@Cg file=EZ01a

@Char file=CA10_01L x=370 y=130 order=910
@Char file=CB10_01L x=156 y=-80 order=950
@Char file=CC10_01L x=-240 y=85 order=940
@Char file=CD10_01L x=-414 y=62 order=930
@Char file=CF10_01L x=-64 y=-70 order=920
@Update transition=universal rule=WIP_BT time=500
	@action id=穹 action=ActionAdvWave width=0 height=2 cycle=1100 count=-1
	@action id=奈緒 action=ActionAdvWave width=0 height=6 cycle=1500 count=-1
	@action id=瑛 action=ActionAdvWave width=0 height=3 cycle=1000 count=-1
	@action id=一葉 action=ActionAdvWave width=0 height=3 cycle=1500 count=-1
	@action id=亮平 action=ActionAdvWave width=0 height=2 cycle=1300 count=-1

@BgScroll file=EZ01a mx=800 my=0 cycle=80000


@PlaySe file=SE302

@Talk name=瑛 voice=AK020325
啊，是蝉~！　今年第一次呢。
@Hitret id=19286

@Talk name=悠
虽然感觉还比较早，这附近来说已经是当然的了吧？
@Hitret id=19287

@Talk name=亮平 voice=RH020084
最近突然变热，真是性急的家伙。
@Hitret id=19288

@Talk name=奈绪 voice=NO020019
就像你。
@Hitret id=19289

@Talk name=穹 voice=SR020061
…………好热。
@Hitret id=19290

@Talk name=瑛 voice=AK020326
不久就可以听到大合唱了。甚至在家里都听不到电视声呢。
@Hitret id=19291

@Talk name=悠
从远处听，好像背景音效一样。天女目家后面是山，很厉害的哦。
@Hitret id=19292

@Talk name=瑛 voice=AK020327
嗯，所以可以随便捉蝉。悠君，来采集昆虫吧。
@Hitret id=19293

@Talk name=悠
久违地玩一次，应该很开心吧。不过如果捉到之后带回家，穹可能会嫌吵。
@Hitret id=19294

@Talk name=穹 voice=SR020062
………………哼。
@Hitret id=19295


@Talk name=亮平 voice=RH020085
不要玩那种小孩游戏了，我们成人一些，做些商业的事吧。
@Hitret id=19296

@Talk name=亮平 voice=RH020086
逮住独角仙和锹形虫，卖给旅客赚零花钱。
@Hitret id=19297

@Talk name=奈绪 voice=NO020020
什么成人啊。这想法本身就很小孩子嘛。而且，旅客根本不会来啊？
@Hitret id=19298

@Talk name=亮平 voice=RH020087
傻瓜，所以要销售啊，去邻镇之类。瑛，能赚到每天吃冰激凌的钱哦？　怎样，做吗？
@Hitret id=19299


@Char file=CC10_02L
@update
	@action id=瑛 action=ActionAdvWave width=0 height=3 cycle=1000 count=-1

@Talk name=瑛 voice=AK020328
做！
@Hitret id=19300


@Char file=CD10_02L
@update
	@action id=一葉 action=ActionAdvWave width=0 height=3 cycle=1500 count=-1

@Talk name=一叶 voice=KA020109
…………不干。
@Hitret id=19301


@Talk name=亮平 voice=RH020088
什么啊，让小叶也参加进来吧。
@Hitret id=19302

@Talk name=一叶 voice=KA020110
我，我才没有想参加呢！！
@Hitret id=19303

@Talk name=瑛 voice=AK020329
是呀，小叶最怕昆虫了，连蝗虫飞过来都会发出可爱的惊叫。
@Hitret id=19304

@Talk name=悠
啊，和穹一样。
@Hitret id=19305


@Char file=CA10_02L
@update
	@action id=穹 action=ActionAdvWave width=0 height=2 cycle=1100 count=-1

@PlaySe file=se006
@Flash color=RED enter=0 leave=500

@Talk name=悠
啊疼！？
@Hitret id=19306


@Talk name=亮平 voice=RH020089
这不是也有可爱的地方吗？　好，小穹和大小姐去揽客就好了。
@Hitret id=19307

@Talk name=一叶 voice=KA020111
我说了，不要随便把我拉进去！
@Hitret id=19308

@Talk name=瑛 voice=AK020330
哎—，小叶不来吗？
@Hitret id=19309

@Talk name=一叶 voice=KA020112
你根本没听人说话吧！
@Hitret id=19310

@Talk name=奈绪 voice=NO020021
不要去想那种梦里的事了，还有必须要想的事吧？
@Hitret id=19311

@Talk name=亮平 voice=RH020090
考试的事情总会有办法的。是吧，悠？
@Hitret id=19312

@Talk name=悠
如果问我，大概是会一起补习的。
@Hitret id=19313

@Talk name=亮平 voice=RH020091
什么啊，悠多给些毅力啊~。
@Hitret id=19314

@Talk name=悠
哎—，我才想要问的啊……
@Hitret id=19315

@Talk name=瑛 voice=AK020331
啊，我也是我也是！
@Hitret id=19316

@Talk name=一叶 voice=KA020113
中里前辈，如果瑛遭到补习，我绝对不原谅你哦？
@Hitret id=19317

@Talk name=亮平 voice=RH020092
既然说到这份上，大小姐也来帮忙吧？　为了深爱的瑛！
@Hitret id=19318

@Talk name=瑛 voice=AK020332
对对！
@Hitret id=19319

@Talk name=一叶 voice=KA020114
我说了，这轮不到你说！
@Hitret id=19320

@Talk name=悠
是吗……暑假前还有测验啊……
@Hitret id=19321

@Talk name=亮平 voice=RH020093
那种事情赶快结束，然后就是开心的暑假了。轻松点吧？还只是一年级而已。
@Hitret id=19322


@Char file=CB10_03L
@update
	@action id=奈緒 action=ActionAdvWave width=0 height=6 cycle=1500 count=-1

@Talk name=奈绪 voice=NO020022
这男人真是不长记性……
@Hitret id=19323

@Talk name=悠
来这边也一个月了……
@Hitret id=19324


@Char file=CF10_02L
@update
	@action id=亮平 action=ActionAdvWave width=0 height=2 cycle=1300 count=-1

@Talk name=亮平 voice=RH020094
喂喂，现在还轮不到去怀念过去哦？
@Hitret id=19325

@Talk name=悠
因为闹的这么厉害，和大家也融洽了，这个夏天不会闲了。
@Hitret id=19326

@Talk name=心の声
春假的时候，因为家里的事一直在忙，现在可以享受长时间的假期。
@Hitret id=19327

@Talk name=亮平 voice=RH020095
会带你一直玩到晚上的，做好觉悟哦？
@Hitret id=19328

@Talk name=悠
知道了，我很期待，亮平。
@Hitret id=19329


@Char file=CB10_02L
@update
	@action id=奈緒 action=ActionAdvWave width=0 height=6 cycle=1500 count=-1

@Talk name=奈绪 voice=NO020023
对了，小悠。暑假里可以随便用泳池哦，记得来玩。
@Hitret id=19330

@Talk name=悠
是吗？说起来，亮平也说过，只要拜托就可以用……
@Hitret id=19331

@Talk name=奈绪 voice=NO020024
因为没有部员认真练习啊。而且也没有人上课用，因为会浪费所以开放了。
@Hitret id=19332

@Talk name=奈绪 voice=NO020025
不用勉强游的，来乘凉也行。
@Hitret id=19333

@Talk name=悠
嗯，那我会去玩的。
@Hitret id=19334

@Talk name=瑛 voice=AK020333
我也想游！　小叶，一起去吧？
@Hitret id=19335

@Talk name=一叶 voice=KA020115
这倒没问题……
@Hitret id=19336

@Talk name=亮平 voice=RH020096
在那之前，大海啊大海！　大家，到了暑假立刻就去吧！
@Hitret id=19337

@Talk name=奈绪 voice=NO020026
我期待亮平当选补习。
@Hitret id=19338

@Talk name=亮平 voice=RH020097
真是的，我不会遭到补习了啦。是吧，瑛？
@Hitret id=19339

@Talk name=瑛 voice=AK020334
是呀—！　不要紧的。奇迹会发生的，大概。
@Hitret id=19340

@Talk name=一叶 voice=KA020116
真是的，这自信是哪来的啊。
@Hitret id=19341

@Talk name=心の声
大家，总会有办法的，但是还要加油哦—……
@Hitret id=19342

@Talk name=心の声
也有可能只有我补习。
@Hitret id=19343

@Talk name=悠
穹，考试不要紧吧？
@Hitret id=19344

@Talk name=穹 voice=SR020063
……不要把我当成悠。
@Hitret id=19345

@Talk name=悠
………………………………
@Hitret id=19346


@Cg file=B12a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=心の声
要是学习好这件事也像就好了……
@Hitret id=19347


@StopBgm

@ClearChar
@Update

@Cg file=B34a center=800,300

@EyeCatch

@Change target=00_c009b


