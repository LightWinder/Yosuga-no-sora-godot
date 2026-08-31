


@Cg file=B07a   
@Char file=CB03_01M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@PlayBgm file=BGM06

@Talk name=奈绪 voice=NO020027
啊，小悠欢迎回来~。
@Hitret id=20324

@Talk name=悠
我回来了。穹，怎么样？
@Hitret id=20325


@Char file=CA03_01M 

@Talk name=穹 voice=SR020106
……想回家。
@Hitret id=20326

@Talk name=悠
哎……好不容易可以体验祭典的幕后，再加油一下啊。
@Hitret id=20327


@Char file=CA03_04M 

@Talk name=穹 voice=SR020107
……做不到。
@Hitret id=20328


@Char file=CB03_02M 

@Talk name=奈绪 voice=NO020028
现在不太忙，小穹先休息也可以哦？
@Hitret id=20329


@Char file=CF03_04M 

@Talk name=亮平 voice=RH020157
好！　小穹，和我一起去逛露天店吧！
@Hitret id=20330


@Char file=CB03_08M 

@Talk name=奈绪 voice=NO020029
你还有工作要做吧？
@Hitret id=20331


@Char file=CF03_08M 

@Talk name=亮平 voice=RH020158
……哥哥。
@Hitret id=20332

@Talk name=悠
什，什么……这么正式……
@Hitret id=20333


@ClearChar 
@Char file=CF03_03L 

@Talk name=亮平 voice=RH020159
交给我吧。
@Hitret id=20334

@Talk name=心の声
他拍着我的肩膀，不知为何露出了爽朗的表情。
@Hitret id=20335

@Talk name=悠
啊？　什么啊……
@Hitret id=20336


@Char file=CF03_02M 

@Talk name=亮平 voice=RH020160
因为小穹很无聊，那么就由我来取悦她吧~！
@Hitret id=20337


@Char file=CB03_06M 
@Char file=CA03_04M 

@Talk name=奈绪 voice=NO020030
我说了，你的工作还没干完吧？　小悠还不熟，不能让他一个人！
@Hitret id=20338


@Char file=CF03_04M 

@Talk name=亮平 voice=RH020161
好，那么悠也来！　我一起照顾你们！
@Hitret id=20339

@Talk name=悠
可以吗？　休息一下。
@Hitret id=20340


@ClearChar 
@Char file=CC06_02M 

@Talk name=瑛 voice=AK020530
啊~，真好。我也想去露天店买东西吃。
@Hitret id=20341


@Char file=CD03_04M 

@Talk name=一叶 voice=KA020165
说什么呢，你接下来还有重要的事吧？
@Hitret id=20342


@Char file=CC06_08M 
@Update
@Move id=瑛 my=25 cycle=1000
@WaitAction id=瑛

@Talk name=瑛 voice=AK020531
呜……我以前没跟小叶说过，其实在跳神乐舞之前如果不吃苹果糖，就会紧张得跳不了……
@Hitret id=20343


@Char file=CD03_12M 

@Talk name=一叶 voice=KA020166
哎……
@Hitret id=20344


@Char file=CC06_11M 

@Talk name=瑛 voice=AK020532
所以，即使一口也好……我想吃苹果糖……
@Hitret id=20345

@Talk name=亮平 voice=RH020162
……居然用这种少见的对策……
@Hitret id=20346


@Char file=CD03_06M 
@Update
@action id=一葉 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=一葉

@Talk name=一叶 voice=KA020167
尽是骗人！！　去年不是吃了便当和布丁后满足的吗！
@Hitret id=20347

@Char file=CC06_11M x=-300 y=25 
@Char file=CD03_06M x=0 
@Char file=CF03_05M x=300 

@Talk name=亮平 voice=RH020163
记得真清楚……不愧是公认跟踪者。
@Hitret id=20348


@Char file=CD03_04M 

@Talk name=一叶 voice=KA020168
那边，很吵喂。
@Hitret id=20349

@autoPosition
@Char file=CF03_02M 

@Talk name=亮平 voice=RH020164
对不起！
@Hitret id=20350


@ClearChar id=亮平
@Char file=CC06_02M 

@Talk name=瑛 voice=AK020533
切，不行吗。
@Hitret id=20351


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020169
至少等到神乐舞结束之后吧。来，现在不去沐浴，就来不及了哦？
@Hitret id=20352


@Char file=CC06_01M 

@Talk name=瑛 voice=AK020534
是—，那我走啦。
@Hitret id=20353

@Talk name=悠
嗯，加油哦。
@Hitret id=20354


@ClearChar id=瑛

@Talk name=心の声
天女目很有精神地跑上了神社后面的坡道。
@Hitret id=20355



@Talk name=悠
咦……沐浴在哪里？
@Hitret id=20356


@Char file=CD03_02M 

@Talk name=一叶 voice=KA020170
后山的湖。
@Hitret id=20357

@Talk name=悠
哎……到那么远的地方？
@Hitret id=20358

@Talk name=一叶 voice=KA020171
嗯，以前那里就是神圣的地方，所以在那里沐浴哦。
@Hitret id=20359


@Char file=CF03_05M 

@Talk name=亮平 voice=RH020165
想要偷看也很费力。
@Hitret id=20360


@Char file=CD03_06M 

@Talk name=一叶 voice=KA020172
比起那种事，你要干活不能偷懒！
@Hitret id=20361


@Char file=CF03_01M 

@Talk name=亮平 voice=RH020166
切……没办法，悠，来拿那边的东西。
@Hitret id=20362

@Talk name=悠
啊，嗯，知道了。
@Hitret id=20363


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020173
里面有神乐舞中用的道具，拜托了。
@Hitret id=20364


@ClearChar 
@Char file=CB03_02M 

@Talk name=奈绪 voice=NO020031
小穹我来照顾，你们先加油吧。
@Hitret id=20365

@Talk name=悠
嗯，拜托了。穹，有钱吧？　随便买些东西吃吧。
@Hitret id=20366


@Char file=CA03_01M 

@Talk name=穹 voice=SR020108
……棉花糖……
@Hitret id=20367


@Char file=CB03_01M 

@Talk name=奈绪 voice=NO020032
咦，想吃棉花糖吗？　那就去买吧。
@Hitret id=20368


@Char file=CF03_02M 

@Talk name=亮平 voice=RH020167
我们也会追上去的，等着哦小穹~！
@Hitret id=20369

@Talk name=奈绪 voice=NO020033
那么我们就先休息吧。
@Hitret id=20370


@ClearChar 

@Talk name=悠
好，亮平拿那边。
@Hitret id=20371


@Char file=CF03_01M 

@Talk name=亮平 voice=RH020168
好。
@Hitret id=20372

@Talk name=心の声
我们两个人搬起古旧的木箱。说是神乐舞中用，到底放了什么呢？
@Hitret id=20373

@Talk name=悠
我第一次看神乐舞，很期待。
@Hitret id=20374

@Talk name=亮平 voice=RH020169
每年都会有类似的东西，我已经看够了。第一次的话就仔细看吧，关键是瑛哦。
@Hitret id=20375

@Talk name=悠
哎，天女目是主角吗？
@Hitret id=20376


@Char file=CF03_04M 

@Talk name=亮平 voice=RH020170
这个要留到看的时候再说。
@Hitret id=20377

@Talk name=悠
？　知道了。
@Hitret id=20378


@PlaySe file=SE155 fade=0

@Talk name=悠
嗯？　电话？　穹吗……
@Hitret id=20379


@StopSe

@Talk name=悠
喂喂……
@Hitret id=20380

@Talk name=声 voice=AK020535
嘻嘻，悠君？
@Hitret id=20381

@Talk name=悠
哎……天女目？　怎么了？
@Hitret id=20382


@Char file=CF03_06M 

@Talk name=亮平 voice=RH020171
嗯？瑛打的？她干什么呢……
@Hitret id=20383

@Talk name=瑛 voice=AK020536
那个，我忘记带换的衣服了。所以，想托你带来。
@Hitret id=20384

@Talk name=悠
啊，嗯……好的，放在哪了？
@Hitret id=20385

@Talk name=瑛 voice=AK020537
应该是放在了社务所的入口。白纸袋。能帮我拿来吗？
@Hitret id=20386

@Talk name=悠
嗯，知道了。
@Hitret id=20387

@Talk name=瑛 voice=AK020538
谢谢。那我等着哦。
@Hitret id=20388


@Char file=CF03_01M 

@Talk name=亮平 voice=RH020172
怎么了？　那家伙没去沐浴被露天店劫持了吗？
@Hitret id=20389

@Talk name=悠
她说忘了东西，让我带去。
@Hitret id=20390

@Talk name=亮平 voice=RH020173
真是的，没办法的家伙啊。
@Hitret id=20391

@Talk name=悠
那我去了。亮平，你一个人行吗？
@Hitret id=20392


@Char file=CF03_05M 

@Talk name=亮平 voice=RH020174
嗯，你回来之前，我去找小穹玩。
@Hitret id=20393


@StopBgm

@Talk name=悠
别，别把她吓回家哦……
@Hitret id=20394



@Hide
@BlackOut time=1000
@Wait time=1500 
@Cg file=B07a   
@Update transition=universal rule=WIP_TB time=500
@WaitUpdate

@Talk name=心の声
我去了社务所那边，在天女目说的入口出找。
@Hitret id=20395

@Talk name=悠
啊，有了……这个吧……
@Hitret id=20396

@Talk name=心の声
我确认了里面，有毛巾和换用的巫女服……
@Hitret id=20397


@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=悠
哇！？
@Hitret id=20398


@PlayBgm file=BGM13

@Talk name=心の声
和服内衣，裙袴……另外还有条纹内裤。
@Hitret id=20399

@Talk name=心の声
白蓝条的内裤，稍微有些小孩子的感觉。
@Hitret id=20400

@Talk name=悠
……！！！
@Hitret id=20401

@Talk name=心の声
我慌忙按回里面。
@Hitret id=20402

@Talk name=悠
…………条纹……呃不！　我在说什么……
@Hitret id=20403

@Talk name=心の声
平时我也有洗穹的份，所以内裤和胸罩应该也看习惯了，但我被出乎意料的情景吓到了。
@Hitret id=20404

@Talk name=心の声
天女目……因为她不是故意的，所以才可怕……难道她是在享受反向的性骚扰？
@Hitret id=20405

@Talk name=心の声
……那就更可怕了。
@Hitret id=20406

@Talk name=心の声
总之，这样的话，天女目可能赤裸地等着我送衣服，那么还是我别去，让女孩子……让渚同学她们去比较好吧……
@Hitret id=20407

@Talk name=心の声
渚同学应该是和奈绪她们一起，招待来祭典的来宾，送茶之类。她应该在这里，但我找不到。
@Hitret id=20408

@Talk name=心の声
离神乐舞没有时间了，必须尽快送去……
@Hitret id=20409

@Talk name=悠
啊……呜……怎么办……
@Hitret id=20410


@StopBgm

@ClearChar
@Update

@Cg file=B26a   

@EyeCatch  

@Change target=00_c013c


