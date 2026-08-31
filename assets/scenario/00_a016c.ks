


@Cg file=B23a   

@Talk name=亮平 voice=RH010276
喂！！悠！！
@Hitret id=5621


@ClearChar 

@Talk name=心の声
突然间传来的大声吼叫打破了海岸边的宁静。
@Hitret id=5622

@Talk name=悠
怎，怎么……？
@Hitret id=5623


@PlayBgm file=BGM14

@Talk name=心の声
沿着声音传来的方向看去……橡皮艇正乘着波浪向这边突击。
@Hitret id=5624

@Talk name=悠
…………
@Hitret id=5625


@Char file=CF06_04S 

@Talk name=心の声
橡皮艇上的亮平就像海之男一样，两手交叉胸前笔直站立着。
@Hitret id=5626


@Char file=CF06_02S 
@Update time=0
@Update
@MoveCamera x=0 y=-128 z=114 time=800

@Talk name=亮平 voice=RH010277
小穹——！！
@Hitret id=5627


@Cg file=B23a   
@Char file=CA07_04M 

@Talk name=穹 voice=SR010631
唔…………诶——！！！！
@Hitret id=5628


@PlaySe file=se003

@Talk name=亮平 voice=RH010278
噗唔！？
@Hitret id=5629


@PlaySe file=SE204

@Talk name=心の声
海之男受到了穹凉鞋的直击，被击坠到海里。
@Hitret id=5630


@ClearChar 
@Char file=CH06_06M 

@Talk name=班长 voice=KO010106
终……终于回来了……
@Hitret id=5631

@Talk name=悠
班长，奈绪，不要紧吧？
@Hitret id=5632


@Char file=CB07_06M 

@Talk name=奈绪 voice=NO010169
从来没这么狼狈过，真是的……那个笨蛋把船桨弄丢了，要回来还真困难啊。
@Hitret id=5633


@PlaySe file=SE201
@ClearChar 
@Char file=CF06_04L 

@Talk name=亮平 voice=RH010279
小穹！！
@Hitret id=5634


@ClearChar id=亮平
@Update time=0
@Char file=CA07_13M 
@Char file=CH06_05M 
@Update time=0
@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=穹＆班长 voice=SR010632/KO010107
讨厌！！
@Hitret id=5635


@PlaySe file=se003

@Talk name=亮平 voice=RH010280
唔咳！！好痛！？
@Hitret id=5636


@PlaySe file=SE204

@Talk name=心の声
有如不死身一般的亮平刚从海中复活，中了穹和班长的合体技后又一次坠落到海里。
@Hitret id=5637


@Char file=CA07_05M 
@Char file=CH06_04M 
@PlaySe file=SE007

@Talk name=穹 voice=SR010633
你这个！嘿！嘿！！
@Hitret id=5638



@Char file=CH06_07M 

@Talk name=亮平 voice=RH010281
啊哇！？咦！？啊——！？
@Hitret id=5639

@Talk name=心の声
穹对坠入海中的亮平仍不放过，继续进行着不留一丝情面的追击。
@Hitret id=5640


@Char file=CA07_06M 
@Update
@action id=穹 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=穹

@Talk name=穹 voice=SR010634
…………变，变态！！
@Hitret id=5641



@Talk name=班长 voice=KO010108
……那个，穹……已经这样了就收收手吧……
@Hitret id=5642

@Talk name=心の声
给了亮平一击的班长也开始担心了……
@Hitret id=5643


@Char file=CA07_09M 

@Talk name=穹 voice=SR010635
……哼。
@Hitret id=5644


@ClearChar 
@Char file=CB07_06M 

@Talk name=奈绪 voice=NO010170
你不会是毫无畏惧吧？
@Hitret id=5645

@Talk name=悠
……不要紧吧，亮平？
@Hitret id=5646


@Char file=CF06_03M 

@Talk name=亮平 voice=RH010282
……哼，什么啊，没什么大不了的。
@Hitret id=5647

@Talk name=心の声
被踢了那么多下还能承受住……应该说真不愧是亮平吗？
@Hitret id=5648

@Talk name=亮平 voice=RH010283
不过，不仅是小穹的攻击，班长的一击也很有效……真是强力的一击啊。
@Hitret id=5649


@Char file=CH06_10M 

@Talk name=班长 voice=KO010109
做，做了那样变态的事情，这是自作自受！
@Hitret id=5650


@Char file=CB07_08M 

@Talk name=奈绪 voice=NO010171
完全就是呢。
@Hitret id=5651


@Char file=CH06_01M 
@Char file=CF06_01M 

@Talk name=亮平 voice=RH010284
真是的，爱情表现也不轻松呢……话说，感觉穹的心情很差，现在这么精神不是很好吗？
@Hitret id=5652

@Talk name=悠
嗯？那和有精神应该是两码事……
@Hitret id=5653

@Talk name=班长 voice=KO010110
话说小穹到哪里去了？
@Hitret id=5654


@Char file=CF06_06M 

@Talk name=亮平 voice=RH010285
唔，这可不好！不快去找可不行！走了，悠……咕啊！？
@Hitret id=5655


@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=心の声
正要跑出去的亮平，被奈绪一把抓住手臂。
@Hitret id=5656


@Char file=CB07_06M 

@Talk name=奈绪 voice=NO010172
你要去还橡皮艇！小悠，在穹迷路前要找到她。
@Hitret id=5657


@StopBgm

@Talk name=悠
哦，嗯……那，亮平，之后见！
@Hitret id=5658


@ClearChar 

@Talk name=心の声
我向着穹跑去的方向走去。
@Hitret id=5659

@Talk name=亮平 voice=RH010286
唔喔——喂！告诉小穹，之后要两个人一起乘橡皮艇！
@Hitret id=5660

@Talk name=心の声
我无视了从后面传来的亮平的要求。
@Hitret id=5661



@Hide
@BlackOut time=1000
@Wait time=2000 
@Cg file=B23a   
@Char file=CC07_02M 
@PlayBgm file=BGM03

@Talk name=瑛 voice=AK010209
给，小悠，这是果汁。
@Hitret id=5662

@Talk name=悠
啊，谢谢。
@Hitret id=5663


@Char file=CD06_02M 

@Talk name=一叶 voice=KA010093
穹没事吧？
@Hitret id=5664

@Talk name=悠
哦，嗯。只是闹得太厉害了累了而已。
@Hitret id=5665


@Cg file=EA05   

@Talk name=心の声
穹在海边小屋那儿的空闲的躺椅上躺了下来，呼呼地睡着。
@Hitret id=5666

@Talk name=悠
暂且这样吧，肚子饿了的话会一下子起来的。
@Hitret id=5667

@Talk name=初佳 voice=MT010018
话说如此~。不过小穹真的很可爱呢~。连睡姿都像一幅漂亮的画呢。
@Hitret id=5668

@Talk name=班长 voice=KO010111
真的呢……这样的睡姿就像模特的写真集一样……
@Hitret id=5669

@Talk name=悠
……睡觉的时候，是最平和的时候哦。
@Hitret id=5670

@Talk name=奈绪 voice=NO010173
总觉得，悠把小穹说得像婴儿似的。
@Hitret id=5671

@Talk name=悠
啊，千万不要对本人这样说，她听到后立刻会生气的。
@Hitret id=5672


@Cg file=B23a   
@Char file=CB07_02M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=奈绪 voice=NO010174
是是。
@Hitret id=5673


@Char file=CF06_05M 

@Talk name=亮平 voice=RH010287
什么嘛，小穹在睡觉啊。切，难得人家想要带穹去一个秘密的地方的说。
@Hitret id=5674


@Char file=CC07_02M 

@Talk name=瑛 voice=AK010210
哎，哪里哪里？是有趣的地方吗？
@Hitret id=5675

@Talk name=亮平 voice=RH010288
对瑛来说去那里的话还稍微早了点。
@Hitret id=5676

@Talk name=瑛 voice=AK010211
是么，真遗憾呢。
@Hitret id=5677


@ClearChar id=奈緒
@Char file=CD06_07M 

@Talk name=一叶 voice=KA010094
不去也罢，那种地方。
@Hitret id=5678

@Talk name=亮平 voice=RH010289
我也会带大小姐去的啦，不要再这样闹脾气了。
@Hitret id=5679


@Char file=CD06_06M 

@Talk name=一叶 voice=KA010095
人，人家才没闹脾气呢！！
@Hitret id=5680


@ClearChar 
@Char file=CE04_01M 

@Talk name=初佳 voice=MT010019
好了，要对睡着的公主大人说声抱歉了哦，吃午饭了哟~。
@Hitret id=5681

@Talk name=心の声
便当都是大家各自做的，然后各自带来混在一起。
@Hitret id=5682

@Talk name=心の声
我和穹在早上大致也做了一些东西……
@Hitret id=5683


@ClearChar id=初佳
@Char file=CF06_04M 

@Talk name=亮平 voice=RH010290
话说，哪个是穹捏的饭团？
@Hitret id=5684

@Talk name=悠
哎，是哪个呢……感觉好像是比较小的那个。
@Hitret id=5685


@Char file=CF06_02M 

@Talk name=亮平 voice=RH010291
嗯，是这个么，我开动了！！
@Hitret id=5686


@Char file=CB07_06M 

@Talk name=奈绪 voice=NO010175
你不要这么狼吞虎咽。
@Hitret id=5687


@Char file=CB07_01M 

@Talk name=奈绪 voice=NO010176
小悠，觉得三明治好吃的话这里还有哦。
@Hitret id=5688

@Talk name=悠
嗯，谢谢。
@Hitret id=5689


@Char file=CC07_02M 

@Talk name=瑛 voice=AK010212
要煮的菜的话这里有哦~。啊，小叶做的东西在这里，干炸货很好吃哟。
@Hitret id=5690

@Talk name=亮平 voice=RH010292
嘿，大小姐也做料理吗？我还以为是初佳做的呢？
@Hitret id=5691


@StopBgm fade=0
@ClearChar 
@Char file=CE04_09M 

@Talk name=初佳 voice=MT010020
……唔…………
@Hitret id=5692


@PlayBgm file=BGM13

@Talk name=悠
怎，怎么了？
@Hitret id=5693


@Char file=CE04_10M 

@Talk name=初佳 voice=MT010021
对，对不起……尽管我是这里最年长的，却什么也没准备……
@Hitret id=5694


@Char file=CD06_02M 

@Talk name=一叶 voice=KA010096
没关系啦，因为我突然间就把你从休息的地方叫出来陪我。
@Hitret id=5695


@Char file=CE04_09M 

@Talk name=初佳 voice=MT010022
……小，小姐……
@Hitret id=5696


@Char file=CC07_02M 

@Talk name=瑛 voice=AK010213
来！初佳姐姐，吃吧吃吧。
@Hitret id=5697

@Talk name=心の声
天女目把盛满菜的纸盘子递给了初佳。
@Hitret id=5698


@ClearChar id=一葉
@Char file=CC07_02M x=-100  
@Char file=CE04_04M x=100  

@Talk name=初佳 voice=MT010023
嗯嗯，小瑛真是个好孩子呢，好乖好乖……
@Hitret id=5699


@StopBgm

@Talk name=瑛 voice=AK010214
哎嘿嘿。
@Hitret id=5700



@ClearChar 
@Char file=CH06_07M 

@Talk name=班长 voice=KO010112
啊，我也做了一些东西……大家请吃吧。
@Hitret id=5701


@PlayBgm file=BGM05

@Talk name=心の声
班长递过来的篮子里，装满了日式和洋式的色彩缤纷的菜肴。
@Hitret id=5702


@Char file=CD06_03M 

@Talk name=一叶 voice=KA010097
哇，仓永做的便当真精致……
@Hitret id=5703

@Talk name=班长 voice=KO010113
没，没有这回事……也没那么精致的说。
@Hitret id=5704

@Talk name=悠
不，看上去相当好吃……我能吃一点吗？
@Hitret id=5705


@Char file=CH06_03M 

@Talk name=班长 voice=KO010114
诶？唔，嗯，当然可以！
@Hitret id=5706


@Char file=CC07_02M 

@Talk name=瑛 voice=AK010215
哇，我也要吃！
@Hitret id=5707


@Char file=CD06_04M 

@Talk name=一叶 voice=KA010098
等等，瑛，把手好好擦一下哟。
@Hitret id=5708


@ClearChar 
@Char file=CF06_02M 

@Talk name=亮平 voice=RH010293
唔哇，果然还是穹做的饭团好吃！这是精华！美少女的精华！
@Hitret id=5709


@Char file=CH06_11M 

@Talk name=班长 voice=KO010115
那个，中里……这个有点……
@Hitret id=5710


@Char file=CB07_08M 

@Talk name=奈绪 voice=NO010177
我说你，不要用这样恶心的方式来说话。
@Hitret id=5711


@Char file=CF06_10M 

@Talk name=亮平 voice=RH010294
其实更想要像“啊”那样让我张嘴喂我吃。
@Hitret id=5712


@ClearChar id=奈緒
@ClearChar id=梢
@Char file=CC07_04M 

@Talk name=瑛 voice=AK010216
亮平哥哥，我来喂你怎么样？啊－？
@Hitret id=5713


@Char file=CD06_07M 

@Talk name=一叶 voice=KA010099
快停下。
@Hitret id=5714

@Talk name=心の声
大家在和谐的气氛中吃着各种各样的便当。
@Hitret id=5715


@ClearChar 
@Char file=CA07_01M 

@Talk name=穹 voice=SR010636
……悠……肚子饿了……
@Hitret id=5716

@Talk name=悠
嗯，起来了吗……来，坐这里。
@Hitret id=5717

@Talk name=心の声
她从躺椅上下来，在我旁边轻轻地坐下。
@Hitret id=5718

@Talk name=悠
稍等一下……嗯……给。
@Hitret id=5719

@Talk name=穹 voice=SR010637
……唔……嗯嗯…………
@Hitret id=5720

@Talk name=心の声
接过了盛了一些菜的纸盘，穹一声不吭地拿起筷子开动了。
@Hitret id=5721


@Char file=CF06_05M 

@Talk name=亮平 voice=RH010295
小穹，要不要吃我家做的酱菜，会迷上的哦。
@Hitret id=5722


@Char file=CA07_04M 

@Talk name=穹 voice=SR010638
……不需要。
@Hitret id=5723


@Char file=CH06_02M 

@Talk name=班长 voice=KO010116
给，穹，茶放在这里了哦。
@Hitret id=5724


@Char file=CA07_01M 

@Talk name=穹 voice=SR010639
……嗯。
@Hitret id=5725


@ClearChar id=梢
@Char file=CF06_02M 

@Talk name=亮平 voice=RH010296
小穹做的饭团好好吃！真的很会做料理呢。上面撒的这些东西很不错的哟。
@Hitret id=5726


@Char file=CA07_09M 

@Talk name=穹 voice=SR010640
……？做饭团的是悠……
@Hitret id=5727


@Char file=CF06_06M 
@Update
@action id=亮平 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=亮平

@Talk name=亮平 voice=RH010297
噗！！悠，你！！
@Hitret id=5728

@Talk name=悠
啥，随便拿了就吃的人不是你自己吗！？
@Hitret id=5729

@Talk name=穹 voice=SR010641
……咀嚼中…………
@Hitret id=5730


@Char file=CB07_06M 

@Talk name=奈绪 voice=NO010178
哎，亮平，好好静下来吃东西吧。
@Hitret id=5731


@Char file=CF06_01M 

@Talk name=亮平 voice=RH010298
切……反正这是和小穹遗传因子相似的悠做的东西，也不错啦。
@Hitret id=5732


@StopBgm

@Talk name=悠
所以说了，不要用那么恶心的说法……
@Hitret id=5733


@BlackOut
@Cg file=B23a   
@Char file=CD06_02M 
@PlayBgm file=BGM07

@Talk name=一叶 voice=KA010100
那，我们稍微离开一下。
@Hitret id=5734

@Talk name=悠
嗯，看行李就交给我好了。
@Hitret id=5735


@Char file=CB07_01M 

@Talk name=奈绪 voice=NO010179
小悠一个人没关系吗？要不要我也留下来？
@Hitret id=5736

@Talk name=悠
不用了，穹又睡下了，这次我来照看她。
@Hitret id=5737


@Char file=CE04_03M 

@Talk name=初佳 voice=MT010024
对不起呢，各方面都让你操心了。
@Hitret id=5738

@Talk name=悠
不会的，难得来一次，初佳就好好玩吧。
@Hitret id=5739


@ClearChar 
@Char file=CF06_02M 

@Talk name=亮平 voice=RH010299
所以说，让我来看着就好了哟。
@Hitret id=5740

@Talk name=悠
不……这个首先排除。
@Hitret id=5741


@Char file=CH06_01M 

@Talk name=班长 voice=KO010117
就是说，如果中里留下来的话，我们不知道穹的身上会发生什么事。
@Hitret id=5742


@Char file=CF06_06M 

@Talk name=亮平 voice=RH010300
唔！连班长也用这样的眼光看我吗……
@Hitret id=5743


@Char file=CH06_10M 

@Talk name=班长 voice=KO010118
这是从平时你的行动中得出的结果！
@Hitret id=5744

@Talk name=心の声
哈哈哈……如果醒来的瞬间，看到亮平在自己身边注视着自己的话，穹不知道会做出什么暴力行为……
@Hitret id=5745


@Char file=CC07_02M 
@Char file=CH06_01M 

@Talk name=瑛 voice=AK010217
那，我们回来后带点礼物。
@Hitret id=5746

@Talk name=悠
嗯，好好玩。
@Hitret id=5747


@Char file=CF06_03M 

@Talk name=亮平 voice=RH010301
出了什么事的话要大声叫哦。
@Hitret id=5748

@Talk name=悠
我想不会发生那种事情的……知道了。
@Hitret id=5749


@ClearChar 

@Talk name=心の声
午饭结束后，大家刚放松下来穹又开始睡觉了。
@Hitret id=5750

@Talk name=心の声
把穹丢下不管可不行，正好是个好机会替换一下一直看着行李的初佳。
@Hitret id=5751


@Cg file=EA05   
@Update time=2000
@WaitUpdate

@Talk name=穹 voice=SR010642
…………
@Hitret id=5752

@Talk name=心の声
从睡着的穹那里传来轻轻的呼呼声。
@Hitret id=5753

@Talk name=悠
相当累了呢……
@Hitret id=5754

@Talk name=心の声
她本来就没什么体力……就算穿着泳装，一直曝在这么炎热的地方也受不了……
@Hitret id=5755

@Talk name=心の声
或许也有每次全力应对亮平的关系。
@Hitret id=5756

@Talk name=心の声
尽管如此，能这样在外面……而且还是在海边让我看到她游玩的身姿，这两层意义上，我都感到很高兴……
@Hitret id=5757

@Talk name=穹 voice=SR010643
……悠………………
@Hitret id=5758

@Talk name=悠
……嗯……我在这里哦……
@Hitret id=5759

@Talk name=心の声
我抚摸着穹的头。
@Hitret id=5760

@Talk name=心の声
于是，穹像是觉得很酥痒一般扭了扭身子。
@Hitret id=5761

@Talk name=穹 voice=SR010644
……嗯…………
@Hitret id=5762

@Talk name=心の声
只有这个时候，反应才这么温顺呢……
@Hitret id=5763

@Talk name=心の声
从海边吹来的风不断梳理着穹的头发。
@Hitret id=5764

@Talk name=心の声
被海风吹过头了会出问题的……
@Hitret id=5765

@Talk name=心の声
不过，若是盖上浴巾的话恐怕会中暑。
@Hitret id=5766

@Talk name=悠
……这样就好吗？
@Hitret id=5767

@Talk name=穹 voice=SR010645
…………
@Hitret id=5768

@Talk name=心の声
……这般看来，她的睡脸还是很可爱的啊。
@Hitret id=5769

@Talk name=悠
……可爱……么。
@Hitret id=5770

@Talk name=心の声
这话从我嘴里说出，稍微有些不协调。
@Hitret id=5771

@Talk name=心の声
说起来，我有多久没有说过穹很可爱这样的话了呢……
@Hitret id=5772

@Talk name=心の声
别说是说穹可爱。就算平时，我有好好夸奖过穹吗？
@Hitret id=5773

@Talk name=心の声
客观上讲，穹的可爱，那当然是肯定的。
@Hitret id=5774

@Talk name=心の声
可是，我们是双胞胎……一直以来，大家都说我们很相像。
@Hitret id=5775

@Talk name=心の声
因此，如果说穹可爱，总感觉像在说自己一样……为此我也经常害臊纠结着。
@Hitret id=5776

@Talk name=心の声
在我印象中的穹，是那纯白色病房的床上，如同洋娃娃般，温顺地等着我的景象。
@Hitret id=5777

@Talk name=心の声
不过这样一个娃娃，却有着与乖巧的外表截然不同的任性，而且还有些容易害羞……
@Hitret id=5778

@Talk name=心の声
这是只有我才知道的穹。
@Hitret id=5779

@Talk name=心の声
所以，就算相互远离……冥冥之中也依然会有被无法言表的羁绊牵连着，这样不可思议的感觉。
@Hitret id=5780

@Talk name=心の声
是因为双胞胎吧……所以才有必须要守护住另外那重要的一半的心情。
@Hitret id=5781

@Talk name=心の声
从很久以前开始……就一直有这样的感觉。
@Hitret id=5782

@Talk name=心の声
在那之后……父母出事之后……这样的心情就更强烈了。
@Hitret id=5783

@Talk name=心の声
作为留下来的最后的家人……作为哥哥。
@Hitret id=5784

@Talk name=心の声
会有怜爱的感觉也很正常。毕竟这在家族之中也是很自然的感情。
@Hitret id=5785

@Talk name=心の声
……穹虽然没有说出口，但是内心一定很不安。
@Hitret id=5786

@Talk name=心の声
没有了父母，离开了充满了回忆的家……
@Hitret id=5787

@Talk name=心の声
并且，搬来的乡下，还有着奈绪。可能把作为她最后依靠的我夺走的人。
@Hitret id=5788

@Talk name=心の声
虽然这件事情已经和解了……但是根本的不安和孤寂却没有消失。
@Hitret id=5789

@Talk name=心の声
正因为如此，穹把我，这世界上唯一的亲人——哥哥，作为了心灵的支柱……
@Hitret id=5790



@Talk name=心の声
这份感情，只是对我纯真的思慕吧……
@Hitret id=5791

@Talk name=心の声
对，仅仅是纯真的……感情……
@Hitret id=5792


@Cg file=SP01

@Talk name=穹 voice=SR010646
我也做同样的事情的话，你会喜欢上我么？
@Hitret id=5793



@Hide
@BlackOut time=1000
@Cg file=EA05   
@Update time=2000
@WaitUpdate

@Talk name=心の声
那时穹的一句话。
@Hitret id=5794

@Talk name=心の声
一直在我耳边回响，怎么也消除不了……
@Hitret id=5795

@Talk name=心の声
我觉得穹问的不是我，而是在问她自己。
@Hitret id=5796

@Talk name=心の声
穹已经注意到自己的心意了，但是好像还在考虑用什么方式来表白……
@Hitret id=5797

@Talk name=心の声
……所以，偶尔触碰到穹的话，我会觉得心跳加快。
@Hitret id=5798

@Talk name=心の声
那句话里，总是带着一抹现实中的香艳色彩。
@Hitret id=5799

@Talk name=悠
……真差劲啊。
@Hitret id=5800

@Talk name=心の声
再怎么可爱……我居然这样看待自己的妹妹。
@Hitret id=5801

@Talk name=心の声
而且，还对妹妹产生了邪恶的念头……
@Hitret id=5802

@Talk name=心の声
我不能否认，在我内心的某处，有着作为男人才有的欲望……
@Hitret id=5803

@Talk name=心の声
穹的心中，一定也有着类似的感觉……
@Hitret id=5804

@Talk name=心の声
那是和血缘关系毫不相干的，生物的本能。
@Hitret id=5805

@Talk name=心の声
现在，因为理性和常识而抑制住了。
@Hitret id=5806

@Talk name=心の声
但是，穹现在是在主动越过这条界限……？
@Hitret id=5807

@Talk name=穹 voice=SR010647
…………嗯唔…………
@Hitret id=5808

@Talk name=悠
！？
@Hitret id=5809

@Talk name=心の声
穹轻轻地翻了一下身，臀部转向了这边。
@Hitret id=5810

@Talk name=心の声
……也只有对我，穹才会展现出这样毫无防备的身姿。
@Hitret id=5811

@Talk name=心の声
一点一点向我表露感情的穹，她的真实意图是什么？
@Hitret id=5812

@Talk name=心の声
喜欢上，又是指哪方面的事？
@Hitret id=5813

@Talk name=悠
…………
@Hitret id=5814

@Talk name=心の声
我的心脏开始猛烈跳动。
@Hitret id=5815



@Cg file=SP01
@Update transition=universal rule=CLOUD_A time=500
@WaitUpdate

@Talk name=穹 voice=SR010648
我也做同样的事情的话………………
@Hitret id=5816

@Talk name=心の声
在这里面，有被省略的言词。
@Hitret id=5817

@Talk name=心の声
那毫无疑问……是“和奈绪做一样的事情”的意思。
@Hitret id=5818

@Talk name=悠
…………
@Hitret id=5819

@Talk name=心の声
不行的……
@Hitret id=5820

@Talk name=心の声
兄妹的话……那种事情……
@Hitret id=5821

@Talk name=心の声
要成为那样的关系，是不可以的……
@Hitret id=5822

@Talk name=心の声
………………
@Hitret id=5823


@StopBgm

@Hide
@BlackOut time=1000
@Wait time=1500 
@Update
@Cg file=B23a   
@PlayEnvSe file=SE400 fade=0

@Talk name=穹 voice=SR010649
…………嗯……
@Hitret id=5824

@Talk name=心の声
我轻轻地在穹的身上披上了浴巾。
@Hitret id=5825

@Talk name=心の声
因为太阳开始倾斜，日光已经晒到了穹的身体……
@Hitret id=5826

@Talk name=心の声
没错，仅仅如此而已……
@Hitret id=5827

@Talk name=穹 voice=SR010650
…………
@Hitret id=5828

@Talk name=心の声
穹还是一如既往地，可爱地呼呼着。
@Hitret id=5829


@StopEnvSe id=SE400
@EyeCatch type=DATE 

@Change target=00_a017


