



@PlayEnvSe file=SE302
@Cg file=B17a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@Update
@Wait time=1000 
@Cg file=B21a   
@Update
@Wait time=1000 

@Hide
@BlackOut time=1000
@Cg file=EB02a  

@Talk name=奈绪 voice=NO031353
…………………………
@Hitret id=15499


@Cg file=EB02b  

@Talk name=奈绪 voice=NO031354
？　………啊，小……悠………
@Hitret id=15500


@Cg file=EB02a  

@Talk name=奈绪 voice=NO031355
切……是你啊………
@Hitret id=15501


@Cg file=B21a   
@Char file=CF01_09M 

@Talk name=亮平 voice=RH030337
干嘛，人家难得来玩。
@Hitret id=15502

@Talk name=亮平 voice=RH030338
话说，咂什么舌头啊。
@Hitret id=15503


@Char file=CB04_05M 

@Talk name=奈绪 voice=NO031356
是是，欢迎光临。费用是１小时１５００日圆。
@Hitret id=15504


@Char file=CF01_06M 

@Talk name=亮平 voice=RH030339
好贵！！　话说这地方又不是你的，收啥钱啊！
@Hitret id=15505


@Char file=CB04_06M 

@Talk name=奈绪 voice=NO031357
真是的，好烦。
@Hitret id=15506


@Char file=CF01_01M 

@Talk name=亮平 voice=RH030340
……悠那家伙……也不在这啊？
@Hitret id=15507


@Char file=CB04_05M 

@Talk name=奈绪 voice=NO031358
小悠？　……他现在不在。
@Hitret id=15508

@Talk name=亮平 voice=RH030341
啊？　为啥？
@Hitret id=15509


@Char file=CB04_09M 

@Talk name=奈绪 voice=NO031359
因为今天是盂兰会………
@Hitret id=15510


@Char file=CF01_08M 

@Talk name=亮平 voice=RH030342
啊……这样啊。
@Hitret id=15511

@Talk name=奈绪 voice=NO031360
在很多事情解决之前，要先住在亲戚家里。
@Hitret id=15512


@Char file=CF01_01M 

@Talk name=亮平 voice=RH030343
那么……什么时候回来？
@Hitret id=15513

@Talk name=奈绪 voice=NO031361
听说是今天这样子………
@Hitret id=15514


@Char file=CF01_05M 

@Talk name=亮平 voice=RH030344
真可惜啊，来的是我。
@Hitret id=15515


@Char file=CB04_06M 

@Talk name=奈绪 voice=NO031362
就是说……哎……
@Hitret id=15516

@Talk name=亮平 voice=RH030345
嘿……
@Hitret id=15517

@Talk name=奈绪 voice=NO031363
……干嘛？
@Hitret id=15518


@Char file=CF01_01M 

@Talk name=亮平 voice=RH030346
没什么，本来想去悠家抄…一起做作业的，但不在的话就算了。
@Hitret id=15519

@Talk name=亮平 voice=RH030347
让我游一会好了。
@Hitret id=15520

@Talk name=奈绪 voice=NO031364
别弄脏水了。
@Hitret id=15521


@Char file=CF01_09M 

@Talk name=亮平 voice=RH030348
别，别说傻话！！
@Hitret id=15522


@Char file=CF01_01M 
@Update
@Wait time=1000
@Char file=CF04_04M 
@Char file=CB04_13M 
@Update
@action id=奈緒 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=奈緒

@Talk name=奈绪 voice=NO031365
哇！？
@Hitret id=15523


@Char file=CF04_01M 

@Talk name=亮平 voice=RH030349
啊？　干嘛，好吵。
@Hitret id=15524

@Talk name=奈绪 voice=NO031366
别、别突然脱呀……吓了我一跳………
@Hitret id=15525


@Char file=CF04_05M 

@Talk name=亮平 voice=RH030350
啊？　男人总是在下面穿着泳裤的。
@Hitret id=15526


@Char file=CB04_06M 

@Talk name=奈绪 voice=NO031367
别做这种容易让人误会的事。
@Hitret id=15527


@Char file=CF04_02M 

@Talk name=亮平 voice=RH030351
难不成你期待了？
@Hitret id=15528

@Talk name=奈绪 voice=NO031368
想被我踢进泳池？
@Hitret id=15529


@Char file=CF04_05M 

@Talk name=亮平 voice=RH030352
好怕好怕……
@Hitret id=15530


@ClearChar 
@Char file=CF04_01S 

@Talk name=亮平 voice=RH030353
……悠……他能回来真是太好了。
@Hitret id=15531



@Talk name=奈绪 voice=NO031369
………呃………
@Hitret id=15532


@ClearChar id=亮平

@Talk name=亮平 voice=RH030354
嘿！！
@Hitret id=15533


@PlaySe file=SE204
@Char file=CB04_06M 

@Talk name=奈绪 voice=NO031370
！…………真是的ー！！
@Hitret id=15534

@Talk name=亮平 voice=RH030355
嘿嘿，果然很舒服啊ー！！
@Hitret id=15535


@Char file=CB04_09M 

@Talk name=奈绪 voice=NO031371
………………………
@Hitret id=15536

@Talk name=奈绪 voice=NO031372
………怎么大家都……一个说法………
@Hitret id=15537


@ClearChar
@Update

@StopEnvSe id=SE302 fade=0
@Cg file=B12b   
@EyeCatch  
@PlayBgm file=BGM16
@MessageFrame type=1

@Talk name=心の声 voice=NO031373
太阳下山，镇里的灯被一盏一盏点亮。
@Hitret id=15538

@Talk name=心の声 voice=NO031374
其中，有一间屋子一直是黑黑的。
@Hitret id=15539


@Cg file=B01b   

@Talk name=心の声 voice=NO031375
小悠的家。
@Hitret id=15540

@Talk name=心の声 voice=NO031376
这里的主人似乎还没回来。
@Hitret id=15541

@Talk name=心の声 voice=NO031377
现在已不再使用的医院的部分，总是关着窗帘，再没有灯光就仿佛被废弃的屋子。
@Hitret id=15542

@Talk name=心の声 voice=NO031378
自医生夫妇去世过了几年……
@Hitret id=15543

@Talk name=心の声 voice=NO031379
在小悠他们回来之前，这里没人居住。
@Hitret id=15544

@Talk name=心の声 voice=NO031380
因为这里有许多愉快的回忆，所以当看着这栋建筑渐渐老朽，会很伤感。
@Hitret id=15545

@Talk name=心の声 voice=NO031381
所以……我希望他总有一天能回来。
@Hitret id=15546

@Talk name=心の声 voice=NO031382
还想和他无忧无虑地玩。
@Hitret id=15547


@Cg file=B05b   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=心の声 voice=NO031383
到家后，忧郁感会急增。
@Hitret id=15548

@Talk name=心の声 voice=NO031384
车库停着车，爸爸看来也回来了。
@Hitret id=15549


@PlaySe file=se100

@Talk name=奈绪 voice=NO031385
我回来了ー。
@Hitret id=15550


@BlackOut

@Talk name=心の声 voice=NO031386
我马上走向浴室，把泳衣浸在洗衣框里。不这样的话，泳衣容易被盐素弄伤。
@Hitret id=15551

@Talk name=心の声 voice=NO031387
我把今天用过的毛巾丢进洗衣机里，然后准备回到自己的房间。
@Hitret id=15552

@Talk name=奈绪之母 voice=NP500013
回家了？　总是去社团活动……作业之类的不要紧吗？
@Hitret id=15553

@Talk name=心の声 voice=NO031389
妈妈从厨房探出头来。虽然她的语气不强，但明显不开心。
@Hitret id=15554

@Talk name=奈绪 voice=NO031390
每天都有做，没问题的。
@Hitret id=15555

@Talk name=奈绪之母 voice=NP500014
………今天和小悠在一起？
@Hitret id=15556

@Talk name=奈绪 voice=NO031392
小悠因为盂兰会，回那边去了。
@Hitret id=15557

@Talk name=奈绪之母 voice=NP500015
是吗……什么时候回来？
@Hitret id=15558

@Talk name=奈绪 voice=NO031394
应该是今天，但好像还没回来。
@Hitret id=15559

@Talk name=奈绪之母 voice=NP500016
就两个孩子一起生活，很辛苦的……让那边的亲戚收养了多好……
@Hitret id=15560

@Talk name=奈绪 voice=NO031396
唔………
@Hitret id=15561

@Talk name=奈绪 voice=NO031397
那妈妈也去帮帮他们啊？
@Hitret id=15562

@Talk name=奈绪之母 voice=NP500017
话虽然这么说…………
@Hitret id=15563

@Talk name=奈绪 voice=NO031399
………………………………
@Hitret id=15564

@Talk name=心の声 voice=NO031400
妈妈开始吱吱唔唔。
@Hitret id=15565

@Talk name=心の声 voice=NO031401
这就好像是在说自己不想多个麻烦。
@Hitret id=15566

@Talk name=奈绪之母 voice=NP500018
总之，要注意别给他们添麻烦了啊？
@Hitret id=15567

@Talk name=奈绪 voice=NO031403
………我知道…………
@Hitret id=15568

@Talk name=心の声 voice=NO031404
我有些生气地回到自己房间。
@Hitret id=15569


@Cg file=B06c   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=心の声 voice=NO031405
我把包放在墙角，为了关窗帘而靠近窗口。
@Hitret id=15570

@Talk name=心の声 voice=NO031406
小悠家依旧没有亮起灯光。
@Hitret id=15571

@Talk name=心の声 voice=NO031407
公交车早已经没有了，电车也只剩下了最后一次末班车，如果他们是乘那来，那回到这已经要很晚了。
@Hitret id=15572

@Talk name=心の声 voice=NO031408
小悠之前住的地方离这里很远，来这还要换几次车，很麻烦。
@Hitret id=15573

@Talk name=心の声 voice=NO031409
所以既然这时间还没来，那今天可能就不回来了。
@Hitret id=15574

@Talk name=心の声 voice=NO031410
就算明天回来也没关系……总之希望能平安回来。
@Hitret id=15575

@Talk name=心の声 voice=NO031411
我一边这样想，一边拉上的窗帘。
@Hitret id=15576


@PlaySe file=se063

@Talk name=奈绪 voice=NO031412
…………呼………………
@Hitret id=15577

@Talk name=心の声 voice=NO031413
我背靠床躺了下来。
@Hitret id=15578

@Talk name=心の声 voice=NO031414
用手遮挡耀眼的灯光。
@Hitret id=15579

@Talk name=奈绪 voice=NO031415
…………哎……………
@Hitret id=15580

@Talk name=心の声 voice=NO031416
…………透不过气来。
@Hitret id=15581

@Talk name=心の声 voice=NO031417
父母总是每当我要出门，脸色就不好看。
@Hitret id=15582

@Talk name=心の声 voice=NO031418
明明不会有什么问题的，他们却总是以怀疑的目光看我。
@Hitret id=15583

@Talk name=心の声 voice=NO031419
……但是……可能这也是没办法的……
@Hitret id=15584

@Talk name=心の声 voice=NO031420
………我……做了足以令他们那样的事。
@Hitret id=15585

@Talk name=奈绪 voice=NO031421
………小悠……不知道什么时候才回来呢………
@Hitret id=15586

@Talk name=心の声 voice=NO031422
仅仅几天没见……我就感到很不安，怕再也不能见面，只能紧紧抱住自己。
@Hitret id=15587


@StopBgm

@EyeCatch type=DATE 
@MessageFrame type=0

@Change target=00_b024


