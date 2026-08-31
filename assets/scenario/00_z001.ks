


@Wait time=5000 
@PlayBgm file=BGM05
@Cg file=B34a center=400,300
@Update
@MoveCamera x=966 y=0 time=20000 accel=0

@Talk name=心の声
穹走这么长时间的路是多久以前的事情了？
@Hitret id=113

@Talk name=穹 voice=SR000026
………真是的……还没到吗？
@Hitret id=114

@Talk name=心の声
从车站出来，差不多已经走了四十分钟了。
@Hitret id=115


@Cg file=B34a center=800,300
@Update time=0
@Char file=CA02_01M 

@Talk name=穹 voice=SR000027
…………我累了。
@Hitret id=116

@Talk name=心の声
这句话穹已经说了好多遍了。
@Hitret id=117

@Talk name=悠
好久没有走这么远的路了，确实是有点累人…还差一点就到了，再加把劲吧。
@Hitret id=118

@Talk name=穹 voice=SR000028
你刚才也这么说的。
@Hitret id=119

@Talk name=心の声
我也只能重复刚才说过的话。
@Hitret id=120

@Talk name=悠
和刚才比的话现在确实是近了一点了啊。
@Hitret id=121


@Char file=CA02_06M 

@Talk name=穹 voice=SR000029
呜—………你的话一点都不让人觉得放心……
@Hitret id=122

@Talk name=心の声
她说话时有气无力的，看来是真累了。
@Hitret id=123

@Talk name=心の声
虽然路上已经休息过几次了，但穹的体力也快到极限了吧，她本来身体就不怎么好的……
@Hitret id=124


@ClearChar id=穹

@Talk name=悠
话说，今天的天气真不错呢ー……
@Hitret id=125

@Talk name=心の声
天空比刚才在电车里看到的还要宽广，无论到哪里都是蔚蓝一片，让人心情舒畅。
@Hitret id=126

@Talk name=心の声
劳累的旅途中唯一感到欣慰的是，这像青空一般纯净清澈的空气……或者说是……空气中没有半点湿气，让人觉得全身清爽。多亏了这一点，身上才没怎么出汗。
@Hitret id=127

@Talk name=心の声
直到今天早上，我还以为这里的空气会像城市里那样潮湿闷热呢，可没想到会如此清爽让我的声音也高扬了起来。
@Hitret id=128

@Talk name=悠
来，我在后面推着你，加油前进。
@Hitret id=129


@Char file=CA02_04M x=100  

@Talk name=心の声
我刚把手伸过去，她就迅速地躲开了。
@Hitret id=130


@Char file=CA02_11M x=0  

@Talk name=穹 voice=SR000030
别这样……多难为情啊……
@Hitret id=131

@Talk name=悠
又没有人看……不愿意的话就再坚持一会吧。
@Hitret id=132

@Talk name=心の声
正当我们再次向前走的时候。
@Hitret id=133


@Char file=CA02_12L 
@Update
@action id=穹 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=穹

@Talk name=穹 voice=SR000031
哎！？　呀啊！！
@Hitret id=134

@Talk name=悠
嗯、怎么了？
@Hitret id=135


@ClearChar id=穹

@Talk name=心の声
穹躲到我的背后，用手拽着我的袖子。
@Hitret id=136

@Talk name=穹 voice=SR000032
刚才，有什么东西从草丛里跳出来了！
@Hitret id=137


@Cg file=B34a center=400,300
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=悠
哎？
@Hitret id=138

@Talk name=心の声
我向草丛望去，只见一只绿色的昆虫跳了出来。
@Hitret id=139


@Char file=CA02_13M 
@Update
@action id=穹 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=穹

@Talk name=穹 voice=SR000033
呀！？
@Hitret id=140

@Talk name=悠
啊哈哈！是一只蝗虫啊。
@Hitret id=141

@Talk name=心の声
而且还有两三只蝗虫紧随其后地也跳了出来。
@Hitret id=142


@Char file=CA02_05M 

@Talk name=穹 voice=SR000034
呜……我不要！！
@Hitret id=143


@ClearChar id=穹
@Cg file=B34a center=800,300
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=悠
啊，喂，等等我。
@Hitret id=144

@Talk name=心の声
穹急匆匆地向前走了出去。
@Hitret id=145

@Talk name=悠
哈哈哈，话说你以前就被蝗虫吓到过呢。
@Hitret id=146


@Char file=CA02_11M 

@Talk name=穹 voice=SR000035
没，没那回事……不许笑！
@Hitret id=147

@Talk name=悠
别生气，别生气。总之我们先走吧。
@Hitret id=148

@Talk name=心の声
就像被蝗虫追赶着似的，穹加快了脚步，结果我们比预计更早地到达了目的地。
@Hitret id=149

@Talk name=心の声
都是蝗虫的功劳……吗？
@Hitret id=150


@StopBgm
@Cg file=B01a   

@Talk name=悠
……终于到了啊。
@Hitret id=151


@Char file=CA02_08M 
@Update
@Move id=穹 my=25 cycle=2000
@WaitAction id=穹

@Talk name=穹 voice=SR000036
………累了……
@Hitret id=152

@Talk name=心の声
穹瘫软地坐在了地上。
@Hitret id=153


@ClearChar id=穹
@Update
@Update
@Move id=穹 y=0 cycle=1000
@WaitAction id=穹
@PlayBgm file=BGM03

@Talk name=心の声
坐落在我们眼前的是一所无人居住并且略显破旧的房子。
@Hitret id=154

@Talk name=心の声
…………挂在门前的老牌匾上写着。春日野医院。
@Hitret id=155

@Talk name=心の声
我的爷爷是小镇上的医生，奶奶是一位接生婆。
@Hitret id=156

@Talk name=心の声
这所医院曾经由这两位老人经营。
@Hitret id=157

@Talk name=心の声
两人直到去世之前都一直继续着自己的工作，爷爷瘦高的背影和奶奶胖乎乎的面容我仍记忆犹新。
@Hitret id=158

@Talk name=心の声
两位老人和蔼慈祥，非常疼爱我和穹。
@Hitret id=159

@Talk name=心の声
二老过世后这所医院无人继承，所以将遗物大致地整理后一直关闭到现在。
@Hitret id=160

@Talk name=心の声
由于许久没有使用，我们在来之前委托当地的房屋管理局事先打扫过，并办理好水电和燃气的使用手续。
@Hitret id=161

@Talk name=悠
………从今以后，这里就是我们的家了。
@Hitret id=162

@Talk name=心の声
我向老房子轻轻地点头致意后，再次抬起头凝视着它的残容。
@Hitret id=163

@Talk name=心の声
和穹在一起的话，总会有办法生活下去的。
@Hitret id=164

@Talk name=心の声
在这个留有我们儿时回忆的地方。
@Hitret id=165

@Talk name=心の声
我已经没有回头地打算了。
@Hitret id=166

@Talk name=悠
那么，在搬家公司来之前还要做很多准备工作。
@Hitret id=167

@Talk name=悠
对不起啊穹，要是你觉得口渴的话就到附近的自动贩卖机去买点饮料喝吧……
@Hitret id=168

@Talk name=心の声
还没等我说完，穹就朝屋中走去。
@Hitret id=169

@Talk name=悠
哎呀~、你不喝果汁了啊？
@Hitret id=170


@Char file=CA02_01M x=-400  

@Talk name=穹 voice=SR000037
………喝。
@Hitret id=171


@Leave id=穹 mx=-50 my=0 fade=1 time=1000 accel=1

@Talk name=心の声
她探出头回答我后，又回到了屋里。
@Hitret id=172

@Talk name=悠
………………
@Hitret id=173


@StopBgm

@Talk name=心の声
结果还是想让我帮她买啊……这让我的心情有些郁闷。
@Hitret id=174


@BlackOut   time=1000

@Talk name=心の声
没过多久，搬家公司的卡车就来了。
@Hitret id=175

@Talk name=心の声
纸箱子一个一个地被搬进屋里，堆得像座小山。
@Hitret id=176

@Talk name=心の声
一些大件的家具需要组装调试，所以我需要事先交代好摆放的位置。
@Hitret id=177


@Cg file=B02a   
@PlaySe file=SE015

@Talk name=悠
穹……你在哪儿？
@Hitret id=178

@Talk name=心の声
顺着被搬进屋的行李……我找到了穹……
@Hitret id=179


@StopSe
@PlayBgm file=BGM05
@Cg file=B04a   
@Char file=CA02_01M 

@Talk name=心の声
原来她挑了一间最里面的房间。
@Hitret id=180

@Talk name=悠
这里的采光不太好，可以吗？
@Hitret id=181

@Talk name=穹 voice=SR000038
……讨厌热，所以没事。
@Hitret id=182

@Talk name=悠
相对的，到了冬天这里会很冷哦。
@Hitret id=183


@Char file=CA02_04M 

@Talk name=穹 voice=SR000039
唔………
@Hitret id=184

@Talk name=悠
还有，开窗户时别忘了关纱窗，会进蚊子的。
@Hitret id=185

@Talk name=穹 voice=SR000040
杀虫剂呢？
@Hitret id=186

@Talk name=悠
还没有买。我打算像以前那样用蚊帐避蚊呢。
@Hitret id=187

@Talk name=穹 voice=SR000041
……麻烦。
@Hitret id=188

@Talk name=悠
……你又来了。啊，对了，你那边收拾好了之后能不能过来帮帮忙？
@Hitret id=189


@ClearChar id=穹

@Talk name=心の声
我正说着，穹就打开了笔记本电脑没有半点想要帮我的意思……
@Hitret id=190

@Talk name=悠
啊，还没开通网络呢。
@Hitret id=191


@Char file=CA02_13M 

@Talk name=穹 voice=SR000042
哎……为什么！？
@Hitret id=192

@Talk name=心の声
穹很不高兴地合上了笔记本。
@Hitret id=193

@Talk name=悠
那是因为才刚搬过来啊。
@Hitret id=194


@Char file=CA02_06M 

@Talk name=穹 voice=SR000043
……真是的，怎么这样啊……
@Hitret id=195

@Talk name=悠
所以说啊，要是穹能来帮我下忙的话就好了。
@Hitret id=196


@Char file=CA02_04M 

@Talk name=穹 voice=SR000044
哎………
@Hitret id=197

@Talk name=悠
收拾完之后我会买你最喜欢的零食和冰糕的啦。
@Hitret id=198

@Talk name=穹 voice=SR000045
我现在不想吃。
@Hitret id=199

@Talk name=悠
不是只买一份哦，两个三个也没问题的哦？
@Hitret id=200

@Talk name=穹 voice=SR000046
………太麻烦了。
@Hitret id=201

@Talk name=悠
别这么说嘛……来吧来吧……
@Hitret id=202


@BlackOut   time=1000

@Talk name=心の声
然后，过了两个小时。
@Hitret id=203

@Talk name=悠
呼………总算是………收拾得差不多了吧………？
@Hitret id=204


@Cg file=B02a   

@Talk name=心の声
我一屁股坐在了厨房里的椅子上。
@Hitret id=205

@Talk name=心の声
从那边出发的时候是做了尽可能减少行李的打算，不过即使是最必需的，也还是有相当的数量……
@Hitret id=206

@Talk name=心の声
把那些东西从包裹里面拿出来，整理后放好……单单是这几个过程就够累人的了。
@Hitret id=207

@Talk name=心の声
虽然穹也来帮忙了，不过遗憾的是东西还是没有全部收拾完。
@Hitret id=208

@Talk name=穹 voice=SR000047
…………悠。
@Hitret id=209


@Char file=CA02_01M 

@Talk name=悠
辛苦了，帮了我大忙了。
@Hitret id=210

@Talk name=穹 voice=SR000048
…………嗯。
@Hitret id=211

@Talk name=悠
这要是我一个人来弄的话，估计现在连一半都还没有弄完吧。
@Hitret id=212

@Talk name=穹 voice=SR000049
悠……
@Hitret id=213

@Talk name=悠
所以啊，剩下东西要是你也能来帮我的话就……嗯？
@Hitret id=214

@Talk name=穹 voice=SR000050
………我饿了。
@Hitret id=215

@Talk name=悠
哎？啊，啊，说的也是呢………
@Hitret id=216

@Talk name=心の声
毕竟是一直都在埋头干活，被穹这么一说，我也稍稍觉得肚子有点饿了。
@Hitret id=217

@Talk name=心の声
不过，怎么办呢……搬家的时候带的行李里面是没有吃的东西的啊。
@Hitret id=218

@Talk name=心の声
今天早上坐电车的时候买的零食也早就已经吃完了。
@Hitret id=219

@Talk name=心の声
……这样的话……果然只能出去买点什么东西回来了。
@Hitret id=220

@Talk name=悠
我现在就去买点东西回来。你有什么想要的吗？
@Hitret id=221

@Talk name=穹 voice=SR000051
……零食。
@Hitret id=222

@Talk name=悠
别的呢？
@Hitret id=223

@Talk name=穹 voice=SR000052
………没有。
@Hitret id=224

@Talk name=悠
好的。来，还有剩下一点茶……喝了这个之后好好地休息一下吧。
@Hitret id=225


@Char file=CA02_04M 

@Talk name=穹 voice=SR000053
………温了……
@Hitret id=226

@Talk name=悠
稍微忍耐一下啦。那么我走了。
@Hitret id=227


@ClearChar id=穹
@StopBgm

@ClearChar
@Update

@Cg file=B34b center=800,300
@EyeCatch

@Talk name=心の声
………好远。
@Hitret id=228

@Talk name=心の声
太阳西斜，乌鸦鸣叫。
@Hitret id=229


@PlayBgm file=BGM07

@Talk name=悠
说真的，真没想到乡下会是这个样子……以前也是这样的吗？
@Hitret id=230

@Talk name=心の声
为了找便利店我连车站那边都转过了，不过还是连个影子都没看到。
@Hitret id=231

@Talk name=心の声
虽然在问了路人之后被告之在县道那边有家超市……
@Hitret id=232

@Talk name=心の声
不过在听到那个县道距离这里还有３０分钟的路程后还真是觉得无比绝望。
@Hitret id=233

@Talk name=心の声
接着对方又告诉我在相比之下要近一点的地方有家超市，总之就先去那里好了。
@Hitret id=234

@Talk name=心の声
那个超市与其说是超市，到更像是蔬菜店的威力加强版，看样子短时间内要靠那里来过日子了。
@Hitret id=235


@StopBgm

@Talk name=心の声
这样的话需要自行车呢……摩托也行…
@Hitret id=236


@PlayEnvSe file=SE256 fade=0

@Talk name=心の声
………………
@Hitret id=237

@Talk name=悠
？
@Hitret id=238

@Talk name=心の声
………………
@Hitret id=239


@StopEnvSe id=SE256 fade=0
@Cg file=B34b center=1366,300
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=心の声
呼的一声，觉得听到了什么声音的我转身看去。
@Hitret id=240

@Talk name=心の声
听起来像是推着自行车走路的时候发出的嘎啦嘎啦的声音……
@Hitret id=241

@Talk name=悠
………………？
@Hitret id=242

@Talk name=心の声
不过在我身后只有我一路走来的道路而已。
@Hitret id=243


@PlayEnvSe file=SE256 fade=0
@Cg file=B34b center=800,300
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=心の声
估计是因为我满脑子都是自行车的缘故才听错了吧？不过，自行车啊……有和没有效果一定完全不同吧。
@Hitret id=244

@Talk name=心の声
虽然住在城里的时候我没有骑，不过在这里的话要是想去个什么地方，自行车还是必须的。
@Hitret id=245


@StopEnvSe id=SE256 fade=0

@Talk name=悠
嗯？
@Hitret id=246

@Talk name=心の声
怎么搞的……感觉好像又听到自行车的声音了。
@Hitret id=247


@Cg file=B34b center=1366,300
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=心の声
我又回头看了一眼，没有半个人影。老旧的农房倒是有一个。
@Hitret id=248

@Talk name=悠
………算了，无所谓了。
@Hitret id=249

@Talk name=心の声
因为想要自行车从听错上升成幻听了吗？是不是因为太累了脑筋有点不太正常了？
@Hitret id=250



@Hide
@BlackOut time=1000
@MessageFrame type=1
@PlayEnvSe file=SE256 fade=0

@Talk name=心の声
………………
@Hitret id=251

@Talk name=心の声
…………………………
@Hitret id=252


@StopEnvSe id=SE256 fade=0
@Cg file=B34b   
@Char file=CC06_01M 

@Talk name=声 voice=AK000001
………嗯－……那个男孩是……
@Hitret id=253

@Talk name=声 voice=AK000002
……啊！　……呵呵呵………
@Hitret id=254

@Talk name=声 voice=AK000003
……………
@Hitret id=255


@Char file=CC06_02M 

@Talk name=声 voice=AK000004
……回到这里来了呢………
@Hitret id=256



@Hide
@BlackOut time=1000
@MessageFrame
@Wait time=3000 
@Cg file=B02c   

@Talk name=悠
………我回……
@Hitret id=257


@Char file=CA02_05M 

@Talk name=悠
………来了………怎么了？
@Hitret id=258


@PlayBgm file=BGM09

@Talk name=穹 voice=SR000054
………慢死了。
@Hitret id=259

@Talk name=悠
啊，对不起。我找不到商店的位置……结果跑了很多地方。
@Hitret id=260

@Talk name=穹 voice=SR000055
………我以为你跑掉了。
@Hitret id=261

@Talk name=悠
………啊？　那怎么可能………
@Hitret id=262

@Talk name=穹 voice=SR000056
……那个。
@Hitret id=263

@Talk name=心の声
顺着穹手指的方向……我看到了桌子上放着的手机。
@Hitret id=264

@Talk name=悠
啊……我忘记带了啊……对不起对不起。
@Hitret id=265

@Talk name=穹 voice=SR000057
…………
@Hitret id=266

@Talk name=悠
总之我买了不少东西回来呢，先吃点什么吧。
@Hitret id=267

@Talk name=穹 voice=SR000058
………不吃了。
@Hitret id=268

@Talk name=心の声
她丢过来一句牢骚。
@Hitret id=269

@Talk name=悠
都，都说是我不好了啦……
@Hitret id=270


@Char file=CA02_06L 

@Talk name=心の声
穹凑到我的身边，从下往上盯着我。
@Hitret id=271

@Talk name=悠
所以说啊，真的对不起啦………
@Hitret id=272

@Talk name=穹 voice=SR000059
………嗯——………………
@Hitret id=273

@Talk name=心の声
距离近到连彼此的呼吸都能感觉到的穹。
@Hitret id=274

@Talk name=心の声
用她那双小小的，炯炯有神的眼睛直直的看着我。
@Hitret id=275

@Talk name=心の声
我也一样看着穹的眼睛……看着从她的眼眸中映出的自己……毕竟我们是双胞胎有种就像是在照镜子一样的幻想状态。
@Hitret id=276

@Talk name=心の声
即使是已经一起生活了很长一段时间的我这个哥哥也不知道我眼前的这双仿佛要将对手望穿的双瞳在想着些什么。
@Hitret id=277

@Talk name=心の声
但是……有一种会永远被这双眼睛吸引住的感觉。
@Hitret id=278

@Talk name=心の声
就在那个瞬间。
@Hitret id=279


@ClearChar id=穹
@Update time=0
@StopBgm fade=0
@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=悠
………穹，穹………啊！？
@Hitret id=280


@PlayBgm file=BGM13

@Talk name=心の声
穹趁我一不注意，从我手中的袋子里面把薯片拿走了。
@Hitret id=281

@Talk name=悠
那，那个是我喜欢的清汤味的！
@Hitret id=282


@Char file=CA02_09M 

@Talk name=穹 voice=SR000060
………哼…………
@Hitret id=283


@ClearChar 

@Talk name=悠
……真是的，别全都吃光了啊。
@Hitret id=284

@Talk name=心の声
穹一言不发的向里屋走去。
@Hitret id=285


@StopBgm

@Talk name=心の声
………算了，没办法的事。再说我也确实是回来晚了。
@Hitret id=286

@Talk name=心の声
打开手机一看，上面全是未接来电和短信。
@Hitret id=287

@Talk name=心の声
联系人和发信人全部都是穹。
@Hitret id=288

@Talk name=心の声
“慢死了”“还没好吗？”“干什么呢？”“悠？”“不要太过分了”“回话啊”……
@Hitret id=289

@Talk name=心の声
……“我以为你跑掉了”吗……
@Hitret id=290


@PlaySe file=SE153

@Talk name=心の声
“对不起，真的”
@Hitret id=291

@Talk name=心の声
我只打了这么几个字之后，用短信发给了穹。
@Hitret id=292

@Talk name=心の声
从里屋里面隐约听到了收到短信的声音……
@Hitret id=293

@Talk name=心の声
回信很快就过来了。
@Hitret id=294

@Talk name=心の声
“………笨蛋”
@Hitret id=295


@StopBgm
@EyeCatch type=DATE

@Change target=00_z002


