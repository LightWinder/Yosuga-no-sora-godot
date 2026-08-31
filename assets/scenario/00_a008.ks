


@PlaySe file=SE352
@Cg file=B19a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=亮平 voice=RH010082
唔唔……结束了结束了。
@Hitret id=3321


@PlayBgm file=BGM03
@Char file=CF01_01M 
@Char file=CC01_01M 

@Talk name=瑛 voice=AK010057
哈……很累了呢。
@Hitret id=3322


@Char file=CD01_04M 

@Talk name=一叶 voice=KA010022
……不过是一直都在瞎聊而已。
@Hitret id=3323


@ClearChar id=一葉

@Talk name=悠
接下来，又要例行去买点吃的了哟。
@Hitret id=3324

@Talk name=亮平 voice=RH010083
每次都用买的……钱够不够？虽然对我们来说可能并不是需要担心的东西。
@Hitret id=3325

@Talk name=悠
嗯，确实会不够呢。如果不稍微计划一下的话……
@Hitret id=3326


@Char file=CC01_02M 

@Talk name=瑛 voice=AK010058
我做了很多东西哦，分给你一些吧。
@Hitret id=3327

@Talk name=悠
谢谢你，天女目。果然还是每天早上准备些米饭比较好呢。
@Hitret id=3328

@Talk name=瑛 voice=AK010059
是呢，如果有米饭的话或许就会想做便当了呢。
@Hitret id=3329


@Char file=CF01_02M 

@Talk name=亮平 voice=RH010084
没错没错，配菜的话，用梅干开始和人交换，最后可能会换到牛排哦。
@Hitret id=3330

@Talk name=悠
我又不是稻梗长者（典出《宇治拾遗物语》）……而且也没有人会在便当里放牛排的。
@Hitret id=3331


@Char file=CF01_05M 

@Talk name=亮平 voice=RH010085
大小姐不是偶尔会放吗？
@Hitret id=3332


@Char file=CD01_12M 
@Update
@action id=一葉 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=一葉

@Talk name=一叶 voice=KA010023
才，才没有呢，人家才不会放呢！
@Hitret id=3333


@Char file=CC01_14M 

@Talk name=瑛 voice=AK010060
不过，有时候会放鱼子酱或者鹅肝之类的东西哦。
@Hitret id=3334


@Char file=CD01_10M 

@Talk name=一叶 voice=KA010024
啊，瑛！你在说什么啊！！
@Hitret id=3335


@Char file=CF01_06M 

@Talk name=亮平 voice=RH010086
呜噢，本来只是开个玩笑没想到是真的……大小姐，我用盐烤三文鱼和你交换怎么样？
@Hitret id=3336


@Char file=CD01_07M 

@Talk name=一叶 voice=KA010025
我拒绝，会吃坏肚子的。
@Hitret id=3337

@Talk name=一叶 voice=KA010026
瑛，今天去别的地方吃饭吧？
@Hitret id=3338


@Char file=CC01_06M 

@Talk name=瑛 voice=AK010061
诶，不和大家一起吃么？
@Hitret id=3339

@Talk name=一叶 voice=KA010027
在这呆着会消化不良的。
@Hitret id=3340


@Char file=CF01_04M 

@Talk name=亮平 voice=RH010087
胃药的话我有哦？
@Hitret id=3341


@Char file=CD01_06M 

@Talk name=一叶 voice=KA010028
不必了！我们走吧。
@Hitret id=3342


@Char file=CF01_04M x=300  
@Char file=CD01_06M x=0  
@Char file=CC01_09M x=-200  

@Talk name=瑛 voice=AK010062
哇啊，别拉啊~。
@Hitret id=3343


@ClearChar
@Char file=CF01_01M 

@Talk name=亮平 voice=RH010088
哈，真是无情的大小姐啊。我说你，再不去的话得卖光了哦？
@Hitret id=3344

@Talk name=悠
啊，不好了。
@Hitret id=3345

@Talk name=女孩子 voice=NO010060
没这个必要哦。
@Hitret id=3346


@Char file=CB01_01M 


@Talk name=悠
啊，奈绪。
@Hitret id=3347

@Talk name=奈绪 voice=NO010061
小悠，还没吃中午饭吧？今天我做了很多三明治，足够分给你了哦。
@Hitret id=3348

@Talk name=悠
诶，这样好么？
@Hitret id=3349

@Talk name=奈绪 voice=NO010062
我做了太多了嘛。
@Hitret id=3350

@Talk name=亮平 voice=RH010089
抱歉啊，承蒙款待。
@Hitret id=3351


@Char file=CB01_06M 

@Talk name=奈绪 voice=NO010063
你这荷兰芹堆得跟山似的。
@Hitret id=3352


@Char file=CF01_09M 

@Talk name=亮平 voice=RH010090
可恶，为啥待遇差别这么大。
@Hitret id=3353


@Char file=CB01_01M 

@Talk name=奈绪 voice=NO010064
真是的……啊，小穹呢？
@Hitret id=3354


@Char file=CF01_01M 

@Talk name=悠
差不多也该来了……啊，穹。
@Hitret id=3355

@Talk name=心の声
刚刚好，穹惴惴不安地张望着进了这边的教室。
@Hitret id=3356


@Char file=CA01_01M 

@Talk name=奈绪 voice=NO010065
小穹，一起吃吧？我做了很多哦。
@Hitret id=3357


@StopBgm fade=0
@ClearChar 
@Char file=CA01_04M 

@Talk name=穹 voice=SR010174
………不需要。
@Hitret id=3358


@ClearChar id=穹
@PlayBgm file=BGM16

@Talk name=悠
穹………………
@Hitret id=3359

@Talk name=心の声
走向这边的途中，穹突然转身……回去了。
@Hitret id=3360

@Talk name=心の声
果然……不行么？
@Hitret id=3361


@Char file=CB01_10M 

@Talk name=奈绪 voice=NO010066
小穹……
@Hitret id=3362

@Talk name=悠
奈绪，很抱歉……
@Hitret id=3363

@Talk name=奈绪 voice=NO010067
唔，我没有在意的……
@Hitret id=3364

@Talk name=心の声
……虽然口里这么说，但是奈绪的脸上的疲惫，诉说着像是发生过什么事情。
@Hitret id=3365

@Talk name=心の声
果然，穹和奈绪之间，有我不知情的内幕……？
@Hitret id=3366


@Char file=CF01_03M 

@Talk name=亮平 voice=RH010091
喂喂，不吃的话就浪费了哦？小穹的那分，我就不客气地吃掉了哦。
@Hitret id=3367


@Char file=CB01_06M 

@Talk name=奈绪 voice=NO010068
……你自己不是有便当么？
@Hitret id=3368


@Char file=CF01_01M 

@Talk name=亮平 voice=RH010092
切……
@Hitret id=3369

@Talk name=悠
……？
@Hitret id=3370

@Talk name=心の声
亮平像是只让我明白般地闭上眼睛。
@Hitret id=3371

@Talk name=悠
那，那奈绪，因为很难得所以我就收下了好么？今天本来也正好要去买面包。
@Hitret id=3372


@Char file=CB01_02M 

@Talk name=奈绪 voice=NO010069
啊，嗯……做的不是很好，想吃多少都可以哦。
@Hitret id=3373

@Talk name=悠
嗯……那我就不客气了。
@Hitret id=3374



@ClearChar 

@Talk name=心の声
与奈绪的谦逊之辞相反，三明治非常好吃。
@Hitret id=3382

@Talk name=心の声
但是这美味仅仅从我的舌头上溜过……现在，连到底在吃什么也浑然不知……
@Hitret id=3383


@StopBgm

@Talk name=心の声
只有穹走出教室后的背影，烙印在我的视网膜中……
@Hitret id=3384



@Hide
@BlackOut time=1000
@MessageFrame type=1
@Cg file=B20a   
@Update transition=universal rule=WIP_MOZH time=500
@WaitUpdate

@Talk name=穹 voice=SR010175
…………傻瓜……傻瓜傻瓜……
@Hitret id=3385


@Char file=CA01_04M 
@PlayBgm file=BGM08

@Talk name=穹 voice=SR010176
……悠这傻瓜……！
@Hitret id=3386



@Talk name=心の声 voice=SR010177
悠总是这样……什么都不知道，却总是一副担心我的表情，很讨厌。
@Hitret id=3387

@Talk name=心の声 voice=SR010179
总是好像自己的地盘一样，大剌剌地闯进来的那个人……
@Hitret id=3389

@Talk name=心の声 voice=SR010180
还有，像什么事都没发生过那样，亲热地叫着我的名字……
@Hitret id=3390

@Talk name=心の声 voice=SR010181
悠也是。
@Hitret id=3391

@Talk name=心の声 voice=SR010182
动不动就把那个人的名字挂在嘴边……！
@Hitret id=3392


@Cg file=B27a center=400,900
@Update
@MoveCamera x=0 y=-600 time=40000 accel=0

@Talk name=心の声 voice=SR010183
走到运动场角落靠着朝会台睡下。
@Hitret id=3393

@Talk name=心の声 voice=SR010184
毒辣的太阳，燃烧的铁板将后背烤得抽搐。
@Hitret id=3394

@Talk name=心の声 voice=SR010185
和内心的混乱相比，这些根本不值一提。
@Hitret id=3395

@Talk name=心の声 voice=SR010186
只是随悠的喜好才选择了这样……
@Hitret id=3396

@Talk name=心の声 voice=SR010187
除此以外不管怎样都好。
@Hitret id=3397

@Talk name=心の声 voice=SR010188
只要能够在一起……只要这样就足够了。
@Hitret id=3398

@Talk name=心の声 voice=SR010189
这种不便的乡下也好，摸索着生活的每一天也罢……就那样让自己喜欢上，只要和悠在一起，其实去哪里都可以。
@Hitret id=3399

@Talk name=心の声 voice=SR010190
但是……只有一点。
@Hitret id=3400

@Talk name=心の声 voice=SR010191
那个毫不客气地踏入我们这样的生活的人……只有她的存在……
@Hitret id=3401

@Talk name=心の声 voice=SR010192
还有和那个女人关系好上的悠……我不要。
@Hitret id=3402

@Talk name=穹 voice=SR010193
…………
@Hitret id=3403

@Talk name=心の声 voice=SR010194
……对悠来说，自己是不可不守护的存在，这点我也清楚。
@Hitret id=3404

@Talk name=心の声 voice=SR010195
保护者和被保护者……是的，我什么忙都帮不上。
@Hitret id=3405

@Talk name=心の声 voice=SR010196
这样的我……难道是妨碍他的存在么……？
@Hitret id=3406

@Talk name=心の声 voice=SR010197
不，甚至算不上妨碍……说不定有没有都无关紧要吧……？
@Hitret id=3407

@Talk name=穹 voice=SR010198
…………
@Hitret id=3408

@Talk name=心の声 voice=SR010199
那个时候，悠他……
@Hitret id=3409

@Talk name=心の声 voice=SR010200
不想回想，记忆却苏醒过来。
@Hitret id=3410

@Talk name=心の声 voice=SR010201
………所以，才选择了这里么？
@Hitret id=3411

@Talk name=心の声 voice=SR010202
心在不断动摇着……好难受……
@Hitret id=3412

@Talk name=心の声 voice=SR010203
只是看着两人要好的样子，就觉得我……已经是个可有可无的存在。
@Hitret id=3413

@Talk name=心の声 voice=SR010204
悠想要逃避吗……？
@Hitret id=3414

@Talk name=心の声 voice=SR010205
把所有都丢下……
@Hitret id=3415

@Talk name=心の声 voice=SR010206
把我也丢下……
@Hitret id=3416


@StopBgm

@Talk name=穹 voice=SR010207
……一定是这样……
@Hitret id=3417

@Talk name=声 voice=AK010063
诶……怎么了，睡在这个地方？
@Hitret id=3418

@Talk name=穹 voice=SR010208
！？
@Hitret id=3419


@Cg file=B20a center=400,300
@Char file=CC01_02M 
@PlayBgm file=BGM03

@Talk name=瑛 voice=AK010064
不热么，睡在这儿？
@Hitret id=3420

@Talk name=穹 voice=SR010209
……没什么，我不要紧。
@Hitret id=3421

@Talk name=瑛 voice=AK010065
是这样么？要喝果汁么？虽然是我喝到一半的。
@Hitret id=3422

@Talk name=穹 voice=SR010210
……不需要。
@Hitret id=3423

@Talk name=瑛 voice=AK010066
那，我去买新的给你好了。喜欢哪种？
@Hitret id=3424

@Talk name=穹 voice=SR010211
我说了不要……
@Hitret id=3425

@Talk name=瑛 voice=AK010067
稍微等等哦。
@Hitret id=3426


@ClearChar id=瑛

@Talk name=穹 voice=SR010212
…………真是的…………
@Hitret id=3427

@Talk name=心の声 voice=SR010213
匆忙奔跑过去的，是悠的同班同学。
@Hitret id=3428

@Talk name=心の声 voice=SR010214
在以前好像见过一次，虽然看上去无忧无虑，但总觉得是个不可思议的人。
@Hitret id=3429

@Talk name=心の声 voice=SR010215
……有那样开朗的性格，悠也会觉得高兴吧。
@Hitret id=3430

@Talk name=心の声 voice=SR010216
谈话也很起劲，每天看起来都很快乐。
@Hitret id=3431

@Talk name=心の声 voice=SR010217
悠，是没办法才和我一起的吗……
@Hitret id=3432

@Talk name=心の声 voice=SR010218
放在朝会台上的是她留下来的盒装果汁。
@Hitret id=3433

@Talk name=心の声 voice=SR010219
突然淌下的汗水，滴到了铁板上马上就蒸发掉了。
@Hitret id=3434

@Talk name=心の声 voice=SR010220
这样的感觉，就好像我会在不知不觉中渐渐消失一样。
@Hitret id=3435

@Talk name=穹 voice=SR010221
…………
@Hitret id=3436

@Talk name=心の声 voice=SR010222
拿起纸包装饮料，从吸管吸了一口。
@Hitret id=3437

@Talk name=心の声 voice=SR010223
干渴而粘附着的咽喉，被湿润了。
@Hitret id=3438

@Talk name=心の声 voice=SR010224
流过喉咙的果汁瞬间治愈了嗓子的干渴上。马上，只是这样已经感到有些不够了。
@Hitret id=3439

@Talk name=心の声 voice=SR010225
仅仅是一点点进入咽喉的果汁，却让需要补充更多水分的身体觉醒了。
@Hitret id=3440

@Talk name=穹 voice=SR010226
…………
@Hitret id=3441

@Talk name=心の声 voice=SR010227
我，也一样。
@Hitret id=3442

@Talk name=心の声 voice=SR010228
无法满足的心情，如果……没有某个能填满它的东西出现，它就永远无法被填满。
@Hitret id=3443

@Talk name=心の声 voice=SR010229
而且……无论怎么喝都感觉不够……我要索求的心情，似乎是永远都无法填满一般。
@Hitret id=3444


@PauseBgm

@Talk name=瑛 voice=AK010068
啊，果然喝了呢~。
@Hitret id=3445


@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=穹 voice=SR010230
~~~~唔！！！！
@Hitret id=3446


@Char file=CC01_01M 

@Talk name=瑛 voice=AK010069
买好了，蜜柑果汁怎么样？
@Hitret id=3447

@Talk name=穹 voice=SR010231
谢……谢谢……
@Hitret id=3448


@Char file=CC01_02M 
@RestartBgm

@Talk name=瑛 voice=AK010070
呐呐，是不是到阴凉的地方去比较好呢？这里太热了，会中暑的哦。
@Hitret id=3449

@Talk name=穹 voice=SR010232
……嗯，嗯。
@Hitret id=3450

@Talk name=穹 voice=SR010233
……你，你的果汁……
@Hitret id=3451

@Talk name=瑛 voice=AK010071
没关系啦，只要让我也喝一口小穹的就行了。
@Hitret id=3452


@ClearChar 
@Update time=0
@Update
@MoveCamera x=907 y=0 time=1000 accel=0
@WaitCamera

@Talk name=心の声 voice=SR010234
她啪嗒啪嗒地走到阴凉的草坪，弯腰坐下来。
@Hitret id=3453


@Cg file=B20a center=1307,300
@Char file=CC01_01M 

@Talk name=瑛 voice=AK010072
啊，已经吃过午饭了吗？
@Hitret id=3454

@Talk name=穹 voice=SR010235
……还没。
@Hitret id=3455


@Char file=CC01_05M 

@Talk name=瑛 voice=AK010073
不好意思呢，要是有什么小点心的话就好了呢。
@Hitret id=3456

@Talk name=穹 voice=SR010236
不用了，可以了……
@Hitret id=3457


@ClearChar 

@Talk name=心の声 voice=SR010237
她就这样躺在了草坪上。
@Hitret id=3458

@Talk name=心の声 voice=SR010238
果然是个让人感觉不可思议的……人呢。
@Hitret id=3459


@Char file=CC01_01M 

@Talk name=瑛 voice=AK010074
喂喂，小穹？
@Hitret id=3460

@Talk name=穹 voice=SR010239
诶……怎么了？
@Hitret id=3461

@Talk name=瑛 voice=AK010075
虽然这样的事情，感觉不问比较好……难道说小穹想家了吗？
@Hitret id=3462

@Talk name=穹 voice=SR010240
诶……
@Hitret id=3463


@Char file=CC01_02M 

@Talk name=瑛 voice=AK010076
嗯嗯，总觉得小穹看上去很寂寞。
@Hitret id=3464

@Talk name=穹 voice=SR010241
……已经没有可以回的家了……
@Hitret id=3465


@Char file=CC01_05M 

@Talk name=瑛 voice=AK010077
啊……是这样啊……对不起……
@Hitret id=3466

@Talk name=穹 voice=SR010242
嗯~嗯，做决定的人是悠……我只是追随他而已。
@Hitret id=3467


@Char file=CC01_01M 

@Talk name=瑛 voice=AK010078
……两个人生活是不是很辛苦？
@Hitret id=3468

@Talk name=穹 voice=SR010243
或许是吧……悠要买东西，做饭……
@Hitret id=3469


@Char file=CC01_02M 

@Talk name=瑛 voice=AK010079
嗯~，不愧是悠君，作为哥哥很活跃呀。
@Hitret id=3470

@Talk name=穹 voice=SR010244
……嗯，一直都很努力的……
@Hitret id=3471

@Talk name=瑛 voice=AK010080
不过，小穹看上去倒是也有姐姐的感觉呢。
@Hitret id=3472

@Talk name=穹 voice=SR010245
……诶？
@Hitret id=3473


@Char file=CC01_11M 

@Talk name=瑛 voice=AK010081
总觉得，一直注视着悠君的小穹。也许这一点像姐姐吧。
@Hitret id=3474

@Talk name=瑛 voice=AK010082
要说双胞胎就是这种感觉么？不过，这样的关系也好。
@Hitret id=3475

@Talk name=穹 voice=SR010246
……不要说了。
@Hitret id=3476


@Char file=CC01_01M 

@Talk name=瑛 voice=AK010083
果然，兄妹吵架也会变得很复杂吗。
@Hitret id=3477

@Talk name=穹 voice=SR010247
……这样的事情，我不太明白……
@Hitret id=3478


@Char file=CC01_02M 

@Talk name=瑛 voice=AK010084
啊哈哈，这样啊……不过，如果我也是双胞胎，有像悠君一样的哥哥在的话就好了。
@Hitret id=3479

@Talk name=穹 voice=SR010248
…………？
@Hitret id=3480

@Talk name=瑛 voice=AK010085
因为，就会像叫小穹那样，很快以“瑛”来称呼我。
@Hitret id=3481

@Talk name=瑛 voice=AK010086
无论怎样的形式，自己被看作是第一重要的感觉也会很高兴啊。
@Hitret id=3482

@Talk name=穹 voice=SR010249
…………！
@Hitret id=3483


@Char file=CC01_12M 
@Update
@action id=瑛 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=瑛

@Talk name=瑛 voice=AK010087
啊，不好！把小叶忘记了！
@Hitret id=3484

@Talk name=穹 voice=SR010250
诶……啊。
@Hitret id=3485


@Char file=CC01_02M 

@Talk name=瑛 voice=AK010088
差不多要走了。果汁给你了哦。
@Hitret id=3486

@Talk name=心の声 voice=SR010251
她站了起来，拍了一下裙子。
@Hitret id=3487


@Char file=CC01_01M 

@Talk name=瑛 voice=AK010089
那一会儿见哦。下次吃午饭也会一起的吧？
@Hitret id=3488

@Talk name=穹 voice=SR010252
啊…………
@Hitret id=3489


@ClearChar id=瑛

@Talk name=心の声 voice=SR010253
她就这样嗒嗒嗒地跑了出去……在路上回了一下头。
@Hitret id=3490

@Talk name=穹 voice=SR010254
…………？
@Hitret id=3491


@Char file=CC01_02S 

@Talk name=心の声 voice=SR010255
之后，笑嘻嘻地指向了右边……
@Hitret id=3492


@StopBgm

@Talk name=心の声 voice=SR010256
那里是……
@Hitret id=3493



@Hide
@BlackOut time=1000
@Wait time=1000 
@MessageFrame type=0
@Cg file=B20a   
@Char file=CC01_02M 

@Talk name=瑛 voice=AK010090
好了，悠君，来接力。
@Hitret id=3494

@Talk name=悠
诶？
@Hitret id=3495


@ClearChar id=瑛


@Talk name=心の声
突然出现的天女目，挥着手向校舍的方向跑了过去。
@Hitret id=3496

@Talk name=心の声
并且，天女目跑过来的方向是……
@Hitret id=3497


@Cg file=B20a center=1307,300
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=悠
……在这样的地方做什么？
@Hitret id=3498


@PlayBgm file=BGM05
@Char file=CA01_01M 

@Talk name=穹 voice=SR010257
…………悠…………
@Hitret id=3499

@Talk name=悠
……不过，太好了。肚子饿了吧。给，我买了面包。
@Hitret id=3500

@Talk name=心の声
买来的是天女目喜欢的奶油面包，记得穹之前吃的时候也是很中意的。
@Hitret id=3501

@Talk name=穹 voice=SR010258
……给我。
@Hitret id=3502

@Talk name=悠
……嗯。
@Hitret id=3503

@Talk name=心の声
穹用纤细的手指，抢一样地从我的手里把点心面包抓走了。
@Hitret id=3504


@Char file=CA01_05M 

@Talk name=穹 voice=SR010259
……怎么了？
@Hitret id=3505

@Talk name=悠
啊，不，没什么……我不会跟你抢的，快吃吧。
@Hitret id=3506

@Talk name=穹 voice=SR010260
……别得意。
@Hitret id=3507

@Talk name=悠
……怎么样，好吃吗？
@Hitret id=3508


@Char file=CA01_01M 

@Talk name=穹 voice=SR010261
……好甜，不过我终于能明白为什么她那么喜欢吃这个。
@Hitret id=3509


@Char file=CA01_02M 

@Talk name=穹 voice=SR010262
……好奇怪哦，吃的时候感觉有种能让人想笑出来的甜蜜感。
@Hitret id=3510

@Talk name=悠
是么。要快点吃哦。马上午休时间就要结束了。
@Hitret id=3511

@Talk name=穹 voice=SR010263
……嗯。
@Hitret id=3512


@Hide
@ClearChar 
@MessageFrame type=1

@Talk name=心の声 voice=SR010264
真的是，连牙齿也能溶化般的甜美溢满了嘴巴……
@Hitret id=3513

@Talk name=心の声 voice=SR010265
就这样，因为面包太甜的关系，眼睛一点一点地湿润了。
@Hitret id=3514

@Talk name=心の声 voice=SR010266
……因为担心么？碍手碍脚么？不能丢开不管么？
@Hitret id=3515

@Talk name=心の声 voice=SR010267
无论我被怎样看待，那都是我自身存在的证明。
@Hitret id=3516

@Talk name=心の声 voice=SR010268
我还有可以回的家……
@Hitret id=3517

@Talk name=心の声 voice=SR010269
所以，我……
@Hitret id=3518

@Talk name=心の声 voice=SR010270
不能光看着……
@Hitret id=3519

@Talk name=心の声 voice=SR010271
不能让悠在前面开路我却只是跟在后面。
@Hitret id=3520

@Talk name=心の声 voice=SR010272
我要向前进……前进到可以回头看他的程度。
@Hitret id=3521


@StopBgm
@EyeCatch type=DATE 
@MessageFrame

@Change target=00_a009


