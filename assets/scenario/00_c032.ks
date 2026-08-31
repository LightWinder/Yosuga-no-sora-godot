


@Cg file=B09a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@PlayBgm file=BGM05

@Talk name=一叶 voice=KA020504
……怎么了？　真少见。
@Hitret id=25390


@Char file=CD03_01M 

@Talk name=悠
现在方便吗？
@Hitret id=25391

@Talk name=一叶 voice=KA020505
？　嗯，没问题。
@Hitret id=25392

@Talk name=悠
我有件事想拜托你……拒绝也没有关系。
@Hitret id=25393


@Char file=CD03_04M 

@Talk name=一叶 voice=KA020506
真突然啊……总之我先听听吧……看来是很认真的事？
@Hitret id=25394

@Talk name=悠
嗯，瑛的……而且也跟渚同学很有关系。
@Hitret id=25395


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020507
我和瑛？　好的，在这里的话，不知道什么时候就能碰到瑛，还是来我房间吧。
@Hitret id=25396



@Hide
@BlackOut time=1000
@Wait time=1000 
@Cg file=B10a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@PlaySe file=se101

@Talk name=初佳 voice=MT020054
失礼了。
@Hitret id=25397


@PlaySe file=se100
@Char file=CE01_01M 

@Talk name=初佳 voice=MT020055
哎呀，悠君好久不见—！　客人是说你吗—。
@Hitret id=25398

@Talk name=悠
是，我稍微打扰下。
@Hitret id=25399


@Char file=CD03_02M 

@Talk name=一叶 voice=KA020508
乃木坂，谢谢你。之后由我来吧。
@Hitret id=25400


@Char file=CE01_06M 
@Update
@action id=初佳 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=初佳

@Talk name=初佳 voice=MT020056
啊，对，对不起！！　那，那我先告辞了……
@Hitret id=25401


@Char file=CD03_02M x=-200  
@Char file=CE01_04M x=400 

@Talk name=初佳 voice=MT020057
那，悠君请慢用~。
@Hitret id=25402


@Leave id=初佳 mx=100 my=0 fade=1 time=1000 accel=1

@Talk name=心の声
她绝对是搞错了什么……
@Hitret id=25403


@Char file=CD03_02M x=0  

@Talk name=一叶 voice=KA020509
请。
@Hitret id=25404

@Talk name=悠
谢，谢谢。
@Hitret id=25405


@StopBgm

@Talk name=心の声
我的面前是冰茶。豪华的杯子好像很贵重，让我喝一口都不由得小心翼翼。
@Hitret id=25406


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020510
那么，跟我和瑛有关系的是什么事？
@Hitret id=25407

@Talk name=悠
这是和渚同学家也有关系的问题。希望你能帮忙的事，是这个。
@Hitret id=25408


@PlayBgm file=BGM16

@Talk name=心の声
我拿出速递过来的Ａ４尺寸的信封给渚同学看。
@Hitret id=25409


@Char file=CD03_04M 

@Talk name=一叶 voice=KA020511
……ＤＮＡ鉴定……难道说，我和瑛是真正的姐妹？……你是怀疑这个？
@Hitret id=25410

@Talk name=悠
答对一半……目的，是调查谁是谁的孩子。
@Hitret id=25411


@Char file=CD03_12M 

@Talk name=一叶 voice=KA020512
哎……
@Hitret id=25412

@Talk name=悠
所以说，你拒绝也可以。因为可能会挑出连渚同学都没有听说过的事。
@Hitret id=25413


@Char file=CD03_07M 

@Talk name=一叶 voice=KA020513
真是突然啊…………
@Hitret id=25414

@Talk name=悠
抱歉…………
@Hitret id=25415


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020514
可是，为什么会想要做这种事？
@Hitret id=25416

@Talk name=一叶 voice=KA020515
我听妈妈说，我和瑛是你奶奶接生的。
@Hitret id=25417

@Talk name=一叶 voice=KA020516
即使状况复杂，我也不认为作为助产师的奶奶会搞错。
@Hitret id=25418

@Talk name=悠
我本来也是这么认为的。
@Hitret id=25419


@Char file=CD03_07M 

@Talk name=一叶 voice=KA020517
发生什么事了？
@Hitret id=25420

@Talk name=悠
……如果听了，就无法后悔了。
@Hitret id=25421


@Char file=CD03_04M 

@Talk name=一叶 voice=KA020518
你说什么任性的话啊？　你来找我谈的时候已经把我卷进去了。
@Hitret id=25422

@Talk name=悠
是呀……可是也可以选择不再听下去。
@Hitret id=25423


@Char file=CD03_06M 

@Talk name=一叶 voice=KA020519
说吧。为了瑛，我如果能帮上忙，我什么都会做。
@Hitret id=25424

@Talk name=悠
谢谢……
@Hitret id=25425


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020520
可是，做了我和瑛的ＤＮＡ鉴定，就算知道了是父亲的孩子，又怎么样？
@Hitret id=25426

@Talk name=悠
虽然这也重要，但我想知道的是，谁是谁的母亲。
@Hitret id=25427



@Talk name=一叶 voice=KA020521
哎……可是，瑛的母亲在她出生后很快就失踪了，没办法调查……
@Hitret id=25428

@Talk name=悠
可是，能调查渚同学是谁生的。
@Hitret id=25429


@Char file=CD03_12M 

@Talk name=一叶 voice=KA020522
我……我！？　我，我是……母亲她……
@Hitret id=25430

@Talk name=悠
我的奶奶，去世之前把记有你们两人出生时经过的日志交给了瑛。
@Hitret id=25431

@Talk name=悠
说是可能能够成为瑛寻找母亲的线索……但是我自作主张地读了。
@Hitret id=25432

@Talk name=悠
奶奶在上面写道，有些事情她一直在意。
@Hitret id=25433


@Char file=CD03_07M 

@Talk name=一叶 voice=KA020523
……是说？
@Hitret id=25434

@Talk name=悠
渚同学的母亲当时似乎得了感冒，为了不传染渚同学，在分娩之后立刻将渚同学移到了别的房间。和瑛一起。
@Hitret id=25435

@Talk name=悠
之后，为了进行检查运到大医院之后，奶奶他们发现了，写着渚同学名字的标签扯断了，瑛身上的标签也不见了。
@Hitret id=25436

@Talk name=悠
瑛是由她母亲抱上救护车的，所以大家认为不会搞错的，但是同时两个人的标签都掉了，这让奶奶到最后都不放心。
@Hitret id=25437


@Char file=CD03_08M 

@Talk name=一叶 voice=KA020524
那，那是……那可能是多心了啊……
@Hitret id=25438

@Talk name=悠
嗯……可能是奶奶多心了。可是，我还有一件事很在意。
@Hitret id=25439

@Talk name=悠
渚同学记不记得，瑛小时候有个项链？
@Hitret id=25440


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020525
嗯，是说她母亲曾经戴的……可是，不知从什么时候没有了……
@Hitret id=25441

@Talk name=悠
日志上写着，渚同学母亲生的孩子太活泼了，把母亲的项链扯断了。
@Hitret id=25442

@Talk name=悠
是说渚同学母亲的孩子……虽说应该是不记得了，不过你听说过这种故事吗？
@Hitret id=25443


@Char file=CD03_08M 

@Talk name=一叶 voice=KA020526
我不记得……也许听说过……我不知道……
@Hitret id=25444

@Talk name=悠
那，瑛的项链呢？
@Hitret id=25445


@Char file=CD03_12M 

@Talk name=一叶 voice=KA020527
！？
@Hitret id=25446

@Talk name=悠
那项链，在我第一次见到瑛的时候弄丢了。
@Hitret id=25447

@Talk name=悠
可是……之前偶然在后山发现了。而且那时，我偶然看到了日志。
@Hitret id=25448

@Talk name=一叶 voice=KA020528
……啊……瑛说了什么？
@Hitret id=25449

@Talk name=悠
……她说，母亲不可能弄错自己的孩子。
@Hitret id=25450

@Talk name=悠
奶奶在日志上写道，两个孩子长的一模一样，很容易弄错……这件事也让我十分在意……
@Hitret id=25451


@Char file=CD03_08M 

@Talk name=一叶 voice=KA020529
所以，你想要调查吗？
@Hitret id=25452

@Talk name=悠
如果是多心了，那就什么事也没有。可是，万一不是多心……？
@Hitret id=25453

@Talk name=一叶 voice=KA020530
……那，那就……
@Hitret id=25454

@Talk name=悠
瑛说，她不想去对答案。为了保护渚同学……为了保护渚同学的家庭。
@Hitret id=25455


@Char file=CD03_12M 

@Talk name=一叶 voice=KA020531
…………！……………………
@Hitret id=25456


@Char file=CD03_08M 

@Talk name=悠
所以，如果渚同学也认为这样下去就好，那么这件事就到此为止。
@Hitret id=25457

@Talk name=悠
结局就是，我是凭着臆测伤害了两位的最差劲的男人。
@Hitret id=25458

@Talk name=悠
可是，如果你帮忙，结局又和我的臆测一样……那就会演变成为难以收拾的重大事件。
@Hitret id=25459


@Char file=CD03_07M 

@Talk name=一叶 voice=KA020532
如果我不是这家里的孩子，而瑛是这家里的孩子……事到如今母亲也不会接受瑛……
@Hitret id=25460

@Talk name=一叶 voice=KA020533
而且我的母亲……也不知道在哪里。
@Hitret id=25461

@Talk name=悠
……瑛不想让渚同学变成这样。所以，一直保守这个秘密。
@Hitret id=25462

@Talk name=悠
瑛想要独自一人，把这秘密带入坟墓。
@Hitret id=25463


@Char file=CD03_08M 

@Talk name=一叶 voice=KA020534
……啊……瑛……
@Hitret id=25464


@Char file=CD03_07M 

@Talk name=一叶 voice=KA020535
……你……你调查这件事想要如何？
@Hitret id=25465

@Talk name=悠
我想让瑛不用再继续说谎……仅此而已。
@Hitret id=25466


@Char file=CD03_08M 

@Talk name=一叶 voice=KA020536
……………………………………
@Hitret id=25467

@Talk name=心の声
明明可能破坏她至今为止的生活，我却还让她帮忙，这简直太乱来了。
@Hitret id=25468

@Talk name=心の声
对于她来说没有任何好处。
@Hitret id=25469

@Talk name=心の声
而我不用担负任何责任……我只是把她卷入我对瑛的感情中而已，我太差劲了。
@Hitret id=25470

@Talk name=心の声
如果是我在幻惑大家，那还是我从这里消失比较好。
@Hitret id=25471


@Char file=CD03_07M 

@Talk name=一叶 voice=KA020537
……没办法……既然你使出了瑛这张牌，我怎么可能拒绝呢？
@Hitret id=25472

@Talk name=悠
渚同学……
@Hitret id=25473


@Char file=CD03_08M 

@Talk name=一叶 voice=KA020538
可能你这样称呼我的日子也不多了。
@Hitret id=25474

@Talk name=悠
对不起……
@Hitret id=25475


@Char file=CD03_01M 

@Talk name=一叶 voice=KA020539
不用道歉。这和我家一直放置瑛不管的做法也有关。
@Hitret id=25476

@Talk name=一叶 voice=KA020540
那么，责任当然是要负的。
@Hitret id=25477

@Talk name=悠
谢谢……
@Hitret id=25478

@Talk name=一叶 voice=KA020541
那，上面写了具体该怎么做吗？
@Hitret id=25479

@Talk name=悠
嗯……我来写文件。只要写上爷爷医院的名字，应该比较好说话。
@Hitret id=25480

@Talk name=悠
在结果出来之前，希望不要和渚同学的双亲说起。如果会变得严重，那还是由我来说吧。
@Hitret id=25481

@Talk name=一叶 voice=KA020542
……春日野君……我知道了。那，瑛呢？　她的直觉很敏锐，很快会发现的。
@Hitret id=25482

@Talk name=悠
我这边会尽力的。
@Hitret id=25483


@Char file=CD03_06M 

@Talk name=一叶 voice=KA020543
我还以为你有计划……看来准备不足啊……
@Hitret id=25484

@Talk name=悠
头发没什么问题，但粘膜比较麻烦……我从唾液之类的地方采集试试吧。
@Hitret id=25485


@Char file=CD03_04M 

@Talk name=一叶 voice=KA020544
……真色。
@Hitret id=25486

@Talk name=悠
哎？
@Hitret id=25487


@Char file=CD03_10M 

@Talk name=一叶 voice=KA020545
没，没什么……
@Hitret id=25488

@Talk name=悠
渚同学……如果……
@Hitret id=25489


@Char file=CD03_07M 

@Talk name=一叶 voice=KA020546
我会做的。我对瑛的喜欢，绝对不会输给你的。
@Hitret id=25490

@Talk name=悠
…………嗯。
@Hitret id=25491


@Char file=CD03_08M 

@Talk name=一叶 voice=KA020547
我可能会被她叫姐姐呢……
@Hitret id=25492

@Talk name=心の声
我这样会践踏很多人。
@Hitret id=25493

@Talk name=心の声
只有我自己……呆在安全的地方……
@Hitret id=25494


@StopBgm

@ClearChar
@Update

@Cg file=B15a   

@EyeCatch  

@Change target=00_c032b


