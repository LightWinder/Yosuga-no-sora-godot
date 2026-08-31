



@PlayEnvSe file=SE302 fade=0
@Cg file=B07a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@Update
@Wait time=2000 
@Cg file=B08a   
@Char file=CD02_02M 
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=一叶 voice=KA020466
好吃吗？
@Hitret id=24384


@Char file=CD02_02M x=200   
@Char file=CC02_11M x=0   

@Talk name=瑛 voice=AK021630
嗯……湫……嗯，好吃……
@Hitret id=24385

@Talk name=瑛 voice=AK021631
小叶……我还要……
@Hitret id=24386

@Talk name=一叶 voice=KA020467
好的哦……
@Hitret id=24387

@Talk name=瑛 voice=AK021632
嗯……湫……啊……
@Hitret id=24388

@Talk name=一叶 voice=KA020468
嘻嘻，不用那么着急，真是拿你没办法。
@Hitret id=24389


@Char file=CD02_11M 

@Talk name=一叶 voice=KA020469
等等，我来帮你弄掉……嗯……湫……
@Hitret id=24390


@StopEnvSe id=SE302 fade=0
@ClearChar 
@Char file=CF03_06L 

@Talk name=亮平 voice=RH020459
你……你们……
@Hitret id=24391


@ClearChar 
@Char file=CC02_03M x=0   

@Talk name=瑛 voice=AK021633
啊，亮哥哥！
@Hitret id=24392


@Char file=CC02_03M x=0   
@Char file=CD02_12M x=200   
@Update
@action id=一葉 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=一葉

@Talk name=一叶 voice=KA020470
呀！！！
@Hitret id=24393


@PlayBgm file=BGM14
@Char file=CF03_05M x=-300   

@Talk name=亮平 voice=RH020460
也让我加—入—啊—！！
@Hitret id=24394


@Char file=CC02_02M x=0   

@Talk name=瑛 voice=AK021634
给，亮哥哥，啊—嗯？
@Hitret id=24395


@Char file=CF03_02M x=-300   

@Talk name=亮平 voice=RH020461
嗯——！　好美味！
@Hitret id=24396

@Talk name=瑛 voice=AK021635
也给悠君哦，来，啊—嗯？
@Hitret id=24397

@Talk name=悠
我，我普通地吃就好……
@Hitret id=24398


@Char file=CC02_06M x=0   

@Talk name=瑛 voice=AK021636
唔，那太没意思了。不要介意！
@Hitret id=24399


@Char file=CC02_02M x=0   

@Talk name=悠
是，是吗？　啊—嗯……哦！　真好吃！
@Hitret id=24400


@Char file=CC02_14M x=0   

@Talk name=瑛 voice=AK021637
嘻嘻~，太好啦！　这样大家都是同伴了！
@Hitret id=24401


@Char file=CF03_08M x=-300   

@Talk name=亮平 voice=RH020462
接下来，我想问一件事情……
@Hitret id=24402


@Char file=CD02_07M x=200   
@Char file=CC02_14M x=0   

@Talk name=一叶 voice=KA020471
我拒绝。
@Hitret id=24403


@Char file=CF03_04M x=-300   

@Talk name=亮平 voice=RH020463
啥啊？　想保持沉默吗？　大白天让瑛躺在腿上还剥葡萄给她吃。
@Hitret id=24404


@Char file=CD02_04M x=200   
@Update
@action id=一葉 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=一葉

@Talk name=一叶 voice=KA020472
呜！？　一直不出声地看着呢吗？　真色！！
@Hitret id=24405


@Char file=CF03_03M x=-300   

@Talk name=亮平 voice=RH020464
哎呀，氛围好像不错，就觉得不该打搅……
@Hitret id=24406

@Talk name=亮平 voice=RH020465
不过，因为氛围变得太奇怪了，结果悠就……
@Hitret id=24407

@Talk name=悠
是我吗？　是亮平吧，兴奋得无法控制自己了。
@Hitret id=24408


@Char file=CF03_02M x=-300   

@Talk name=亮平 voice=RH020466
瑛，我说过吧？　好像会变得有意思的时候，就叫上我。
@Hitret id=24409


@Char file=CC02_02M x=0   

@Talk name=瑛 voice=AK021638
啊，对不起，亮哥哥，我没替你着想。
@Hitret id=24410


@Char file=CD02_06M x=200   

@Talk name=一叶 voice=KA020473
不用替他着想！！！
@Hitret id=24411


@Char file=CF03_05M x=-300   

@Talk name=亮平 voice=RH020467
而且这真是露骨啊。被悠抢走，就那么不愿意吗？　还在暗地里偷偷地—！
@Hitret id=24412


@Char file=CD02_07M x=200   

@Talk name=一叶 voice=KA020474
这，这是女孩子之间的交流！　和男人用拳头沟通是一个意思。
@Hitret id=24413

@Talk name=悠
哎？
@Hitret id=24414


@Char file=CF03_04M x=-300   

@Talk name=亮平 voice=RH020468
哎呀，是说太~可~爱~了吗？　这种话应该更大胆地说出来！！！
@Hitret id=24415

@Talk name=悠
大，大胆是说……
@Hitret id=24416


@Char file=CF03_05M x=-300   

@Talk name=亮平 voice=RH020469
悠也是，百合这种程度的事情，就放得宽松一些吧！好吗？
@Hitret id=24417

@Talk name=悠
呜……我也会像别人那样嫉妒啊……
@Hitret id=24418


@Char file=CD02_12M x=200   

@Talk name=一叶 voice=KA020475
对，对不起……春日野君……！！
@Hitret id=24419


@Char file=CD02_10M x=300   
@Char file=CC02_12M x=-100   
@Update
@wait time=500
@Move id=瑛 my=640 cycle=500
@Update
@WaitAction id=瑛
@PlaySe file=se018

@Talk name=瑛 voice=AK021639
呀！？
@Hitret id=24420

@Talk name=心の声
渚同学慌忙扔下了腿上的瑛。
@Hitret id=24421


@ClearChar 
@Char file=CF03_02M 

@Talk name=亮平 voice=RH020470
太好了瑛！　悠没有输给百合鉴赏的诱惑，而是选择了你！
@Hitret id=24422


@Char file=CC02_03M 

@Talk name=瑛 voice=AK021640
啊哈—。
@Hitret id=24423

@Talk name=悠
你没真的明白吧，瑛！！
@Hitret id=24424


@StopBgm
@Char file=CC02_02M 

@Talk name=瑛 voice=AK021641
算了算了，你们俩慢慢享受，我去端茶来。
@Hitret id=24425


@ClearChar id=瑛
@Char file=CD02_05M 

@Talk name=一叶 voice=KA020476
……说起来，你们怎么来了？　我还以为新学期开始之前不用见面了呢。
@Hitret id=24426


@PlayBgm file=BGM13
@Char file=CF03_03M 

@Talk name=亮平 voice=RH020471
悠，她说让你回去。
@Hitret id=24427


@Char file=CD02_06M 

@Talk name=一叶 voice=KA020477
我是在对中里前辈说！！
@Hitret id=24428


@Char file=CF03_04M 

@Talk name=亮平 voice=RH020472
我吗？　我比你们要年长一岁，所以是来检查你们有没有认真完成作业。
@Hitret id=24429


@Char file=CD02_03M 

@Talk name=一叶 voice=KA020478
也就是说，你是来抄袭作业的吧。不过很可惜，瑛也什么都没写！
@Hitret id=24430

@Talk name=悠
……………………………………
@Hitret id=24431


@Char file=CF03_06M 

@Talk name=亮平 voice=RH020473
……稍微帮忙说句话啊……
@Hitret id=24432


@Char file=CF03_04M 

@Talk name=亮平 voice=RH020474
于是就想一起写作业，为了让没有集中力的家伙有干劲，就使用了葡萄来萌是吗。
@Hitret id=24433


@Char file=CD02_12M 
@Update
@action id=一葉 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=一葉

@Talk name=一叶 voice=KA020479
呜…………
@Hitret id=24434

@Talk name=悠
嗯，挺好……正好我们也可以一起做。
@Hitret id=24435


@Char file=CF03_01M 

@Talk name=亮平 voice=RH020475
切，这次失策了。本来以为可以更轻松些的。
@Hitret id=24436


@Char file=CD02_01M 

@Talk name=一叶 voice=KA020480
顺便问一句，穹同学今天怎么了？
@Hitret id=24437

@Talk name=悠
还是一样。她窝在房间里不出来。如果有空调，她就会高兴地出来了。
@Hitret id=24438


@Char file=CF03_04M 

@Talk name=亮平 voice=RH020476
那么，下次就在大小姐的家里集合吧。
@Hitret id=24439


@Char file=CD02_04M 

@Talk name=一叶 voice=KA020481
什么！？　为什么是我家？
@Hitret id=24440

@Talk name=亮平 voice=RH020477
因为很宽敞啊，很干净啊，很香啊，有空调啊，还有初佳小姐会端来甜点。
@Hitret id=24441


@Char file=CD02_07M 

@Talk name=一叶 voice=KA020482
如果叫男人来，父母会误解的，所以不叫。
@Hitret id=24442

@Talk name=亮平 voice=RH020478
如果是悠呢？
@Hitret id=24443


@Char file=CD02_04M 

@Talk name=一叶 voice=KA020483
呜……勉强可以。
@Hitret id=24444


@Char file=CF03_09M 
@Update
@action id=亮平 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=亮平
@Font face=36

@Talk name=亮平 voice=RH020479
为啥啊！！！
@Hitret id=24445


@StopBgm
@Char file=CC02_02M 

@Talk name=瑛 voice=AK021642
好高兴的样子呢—。来，久等了，悠君，亮哥哥。
@Hitret id=24446

@Talk name=悠
谢谢。
@Hitret id=24447


@PlayBgm file=BGM05
@Char file=CF03_01M 

@Talk name=亮平 voice=RH020480
谢谢啊！　喂瑛—，下次的学习会，去大小姐家开吧？
@Hitret id=24448

@Talk name=瑛 voice=AK021643
哎，小叶，可以吗？
@Hitret id=24449


@Char file=CD02_05M 

@Talk name=一叶 voice=KA020484
呜……那是中里前辈随口说的，不能认真！
@Hitret id=24450


@Char file=CF03_03M 
@Char file=CD02_04M 

@Talk name=亮平 voice=RH020481
切……自己一个人吹空调，太狡猾了。
@Hitret id=24451


@Char file=CC02_14M 

@Talk name=瑛 voice=AK021644
啊，亮哥哥，如果把冰块放在脸盆里，搁在电风扇前面的话，就会吹过来凉风哦。像空调一样。
@Hitret id=24452


@Char file=CF03_01M 

@Talk name=亮平 voice=RH020482
冰很快就化完了吧？　性价比很差啊。
@Hitret id=24453

@Talk name=瑛 voice=AK021645
可是，只要在凉快的时候睡着，就赢了哦。
@Hitret id=24454

@Talk name=亮平 voice=RH020483
赢什么啊……虽说你想说的东西我也不是不明白。
@Hitret id=24455


@Char file=CD02_07M 

@Talk name=一叶 voice=KA020485
好了好了，别再聊了，该开始做作业了吧？
@Hitret id=24456


@Char file=CF03_03M 

@Talk name=亮平 voice=RH020484
最先岔开话题的是大小姐啊。
@Hitret id=24457


@Char file=CD02_06M 

@Talk name=一叶 voice=KA020486
吵死了，中里前辈。
@Hitret id=24458


@ClearChar 
@Char file=CC02_01M 

@Talk name=瑛 voice=AK021646
悠君，我们边对答案边做吧？
@Hitret id=24459

@Talk name=悠
嗯，好的。
@Hitret id=24460


@Char file=CF03_05M 

@Talk name=亮平 voice=RH020485
让我也~加~入~啊。
@Hitret id=24461

@Talk name=悠
那，从哪里开始？
@Hitret id=24462


@Char file=CC02_04M 

@Talk name=瑛 voice=AK021647
数学吧。抄起来最麻烦的。
@Hitret id=24463

@Talk name=悠
已，已经完全打算抄了！？
@Hitret id=24464


@Char file=CC02_01M 
@Char file=CD02_04M 

@Talk name=一叶 voice=KA020487
喂，抄之前也稍微思考一下啊！
@Hitret id=24465


@ClearChar id=一葉
@Char file=CC02_01M 

@Talk name=瑛 voice=AK021648
好—！　那写完一页就对答案吧。
@Hitret id=24466

@Talk name=悠
好的。那加油做吧！
@Hitret id=24467


@Char file=CC02_14M 

@Talk name=瑛 voice=AK021649
啊，悠君。这里怎么做呢？
@Hitret id=24468

@Talk name=悠
哎！？　一上来就不会？
@Hitret id=24469


@Char file=CF03_03M 

@Talk name=亮平 voice=RH020486
哦，这个我也得听一下。
@Hitret id=24470


@ClearChar 
@StopBgm
@Char file=CD02_04M 

@Talk name=一叶 voice=KA020488
真是的…期末考试你们能过，真是奇迹啊…
@Hitret id=24471



@Hide
@BlackOut time=1000
@Wait time=2000 
@Cg file=B34b center=800,300
@Char file=CF03_01M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@PlayBgm file=BGM07

@Talk name=亮平 voice=RH020487
真是麻烦你啦瑛。
@Hitret id=24472


@Char file=CC02_02M 

@Talk name=瑛 voice=AK021650
才不是哦，我才是得救了呢。下次再开学习会吧小叶！
@Hitret id=24473


@Char file=CD02_04M 

@Talk name=一叶 voice=KA020489
如果能认真来做，就开。
@Hitret id=24474

@Talk name=亮平 voice=RH020488
好，我陪你走一段吧瑛。现在你要去八寻小姐家做饭是吧？
@Hitret id=24475

@Talk name=瑛 voice=AK021651
嗯！　那再见，悠君。小叶！
@Hitret id=24476


@Char file=CD02_07M 

@Talk name=一叶 voice=KA020490
要是发生什么事，就把他推到田里去哦！
@Hitret id=24477


@Char file=CC02_04S 

@Talk name=瑛 voice=AK021652
嗯，我知道了！
@Hitret id=24478


@Char file=CF03_06S 

@Talk name=亮平 voice=RH020489
喂，瑛！　你！！
@Hitret id=24479


@ClearChar id=瑛
@ClearChar id=亮平
@Char file=CD02_01M 

@Talk name=一叶 voice=KA020491
…………发生什么事了？
@Hitret id=24480

@Talk name=悠
哎？　怎么？
@Hitret id=24481

@Talk name=一叶 voice=KA020492
想问的是我啊。春日野君，今天很老实啊。是热晕了？
@Hitret id=24482

@Talk name=悠
不是，这倒是没有。
@Hitret id=24483

@Talk name=一叶 voice=KA020493
而且，很奇怪地没有亲近瑛。
@Hitret id=24484

@Talk name=悠
呃，不，那是因为，在大家面前亲热，会让大家不舒服吧？
@Hitret id=24485


@Char file=CD02_04M 

@Talk name=一叶 voice=KA020494
……确，确实，可能会不自在。
@Hitret id=24486


@Char file=CD02_08M 

@Talk name=一叶 voice=KA020495
瑛，好像有些寂寞。因为你没有去理她。
@Hitret id=24487

@Talk name=悠
哎，是吗？　我觉得没什么不正常……
@Hitret id=24488


@Char file=CD02_01M 

@Talk name=一叶 voice=KA020496
…………有什么烦恼吗？
@Hitret id=24489

@Talk name=悠
也，也不算是那种…………
@Hitret id=24490


@Char file=CD02_10M 

@Talk name=一叶 voice=KA020497
我没有和男人交往过，所以……也不太熟悉那种关系的事，不过有事可以来找我商量哦。
@Hitret id=24491

@Talk name=悠
谢谢你，渚同学。
@Hitret id=24492


@Char file=CD02_04M 

@Talk name=一叶 voice=KA020498
呼……真是没有干劲啊……
@Hitret id=24493

@Talk name=悠
哎？
@Hitret id=24494


@Char file=CD02_02M 

@Talk name=一叶 voice=KA020499
好不容易交往了，要更多地享受一下啊。
@Hitret id=24495

@Talk name=悠
我们有一直在玩啊。
@Hitret id=24496

@Talk name=一叶 voice=KA020500
不止是这样，你们应该两个人去个什么地方。
@Hitret id=24497

@Talk name=悠
去个什么地方……？
@Hitret id=24498


@Char file=CD02_03M 

@Talk name=一叶 voice=KA020501
对。不止是后山和点心店，比如邻镇。最近那里好像新增了很多东西，仅仅是逛一下也会很有意思。
@Hitret id=24499

@Talk name=悠
嗯，那，我们就对渚同学保密，去一趟吧。
@Hitret id=24500


@Char file=CD02_07M 

@Talk name=一叶 voice=KA020502
是，是呀……
@Hitret id=24501

@Talk name=悠
呜，对，对不起……
@Hitret id=24502


@Char file=CD02_02M 

@Talk name=一叶 voice=KA020503
嘻嘻，开玩笑啦。打起精神来，春日野君。那再见。
@Hitret id=24503

@Talk name=悠
嗯，谢谢你……渚同学。
@Hitret id=24504


@ClearChar 

@Talk name=心の声
渚同学低头行礼，然后向着和我相反的方向走去。
@Hitret id=24505


@StopBgm

@Talk name=悠
应该是说不愧是渚同学……还是说她太敏锐了……
@Hitret id=24506

@Talk name=心の声
渚同学都能发觉，瑛应该也明白的……
@Hitret id=24507


@PlayBgm file=BGM16

@Talk name=心の声
之前我看过日志之后，瑛和渚同学的事就没有离开过我的脑海。
@Hitret id=24508

@Talk name=心の声
今天我看到她们两人那么要好，也产生了复杂的感觉。
@Hitret id=24509

@Talk name=心の声
并不是因为嫉妒。如果我凭着奶奶的日志去追求真实，那么会怎样呢……
@Hitret id=24510

@Talk name=心の声
她们两人还能如此要好地笑吗？　做了那种事，有谁会得益呢……这种思考一直在我脑中打转。
@Hitret id=24511

@Talk name=心の声
这不是能随便和人商量的事。仅有一部分人知道的，瑛出生的秘密，可能会因此产生严重的颠覆。
@Hitret id=24512


@Cg file=Sp12
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=瑛 voice=AK021653
如果只是和我有关的事那还好……可是……小叶她……
@Hitret id=24513



@Hide
@BlackOut time=1000
@Wait time=1500 
@Cg file=B34b center=800,300
@Update transition=universal rule=WIP_MOZV time=500
@WaitUpdate

@Talk name=心の声
还会搅乱渚同学的人生……
@Hitret id=24514

@Talk name=心の声
所以，瑛一直保守着这个秘密。
@Hitret id=24515

@Talk name=心の声
以后也会一直……
@Hitret id=24516

@Talk name=心の声
瑛说了，现在这样就好。因为不会有任何拘束。
@Hitret id=24517

@Talk name=心の声
所以我也一直装作不知情，只要和瑛一起开心生活就好……。
@Hitret id=24518

@Talk name=心の声
但是，这样真的好吗？
@Hitret id=24519

@Talk name=心の声
瑛独自担负着痛苦而生活下去，这是真的幸福吗？
@Hitret id=24520

@Talk name=心の声
并没有人拜托她这样……为什么……
@Hitret id=24521

@Talk name=心の声
瑛能够相通那些事，在我看来却有些悲伤。
@Hitret id=24522


@StopBgm
@EyeCatch type=DATE 

@Change target=00_c028


