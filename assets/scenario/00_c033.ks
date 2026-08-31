


@PlaySe file=SE357
@Cg file=B01a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@Update
@Wait time=1500 

@Hide
@BlackOut time=1000
@Cg file=B02a   
@Char file=CA01_01M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@PlayEnvSe file=SE155 fade=0

@Talk name=穹 voice=SR020243
……悠，电话。
@Hitret id=25573

@Talk name=悠
……谁打的？
@Hitret id=25574

@Talk name=穹 voice=SR020244
……００４－１５６－７５……
@Hitret id=25575

@Talk name=悠
啊？　这我不懂啊！　穹，给我接。
@Hitret id=25576

@Talk name=心の声
我把炉子拧成弱火，把锅铲给了穹。
@Hitret id=25577


@PlayBgm file=BGM03
@ClearChar 
@StopEnvSe id=SE155 fade=0

@Talk name=悠
您好！　我是春日野……
@Hitret id=25578

@Talk name=电话的声 voice=NP460001
喂喂，这里是穗见邮政局，有一封挂号信寄到春日野医院处，请问您今天在家吗？
@Hitret id=25579

@Talk name=悠
啊，呃……上午家里没有人，下午会回来……
@Hitret id=25580

@Talk name=邮政职员 voice=NP460002
这样啊，那么请问可以在一点到三点之间拜访吗？
@Hitret id=25581

@Talk name=悠
好的，那么我们在那之前回来。
@Hitret id=25582

@Talk name=邮政职员 voice=NP460003
那么之后会送到您处。再见。
@Hitret id=25583

@Talk name=悠
是，拜托了。
@Hitret id=25584


@PlaySe file=SE154
@Char file=CA01_01M 

@Talk name=穹 voice=SR020245
…………谁？
@Hitret id=25585

@Talk name=悠
邮政局。今天……有文件送来。
@Hitret id=25586

@Talk name=穹 voice=SR020246
是吗……
@Hitret id=25587

@Talk name=悠
啊，穹！　已经煎好了，放到盘子里。
@Hitret id=25588


@Char file=CA01_04M 

@Talk name=穹 voice=SR020247
……悠来做。
@Hitret id=25589

@Talk name=悠
啊啊，真是的……那你去倒咖啡吧。
@Hitret id=25590


@Char file=CA01_06M 

@Talk name=穹 voice=SR020248
……没有开水。
@Hitret id=25591

@Talk name=悠
……啊—，这种倦怠感是怎么回事。
@Hitret id=25592


@ClearChar 

@Talk name=心の声
明明今天开始就是新学期了，但却觉得前途令人担忧。
@Hitret id=25593

@Talk name=心の声
我把煎鸡蛋放到盘子里，加上了切碎的洋白菜。我从冰箱里取出了牛奶、黄油、果酱放在了穹面前。她不说我开始吃了就伸手去拿面包。
@Hitret id=25594

@Talk name=悠
我开始吃了呢？
@Hitret id=25595


@Char file=CA01_06M 

@Talk name=穹 voice=SR020249
嗯……我开始吃了…………不要牛奶。
@Hitret id=25596

@Talk name=悠
喝啊，看你脸就像缺钙。
@Hitret id=25597

@Talk name=穹 voice=SR020250
……悠才是。
@Hitret id=25598

@Talk name=悠
我会喝哦。我开始吃了……
@Hitret id=25599


@ClearChar 

@Talk name=心の声
是休息太多了吗，早饭变得有些匆忙了。接下来必须要逐渐恢复过来……
@Hitret id=25600

@Talk name=心の声
而且，今天会很忙。
@Hitret id=25601

@Talk name=心の声
文件来了……就是说，瑛的结果出来了。
@Hitret id=25602

@Talk name=心の声
根据结果……
@Hitret id=25603


@Char file=CA01_01M 

@Talk name=穹 voice=SR020251
……悠洒了……
@Hitret id=25604

@Talk name=悠
啊……哦哦，糟……
@Hitret id=25605

@Talk name=心の声
我想要把洋白菜送入口中，结果掉到了桌上。
@Hitret id=25606

@Talk name=心の声
因为嫌麻烦，我用手拿起来放入嘴里。
@Hitret id=25607


@Char file=CA01_04M 

@Talk name=穹 voice=SR020252
吃相真差……
@Hitret id=25608


@StopBgm

@Talk name=悠
……对不起了啊。
@Hitret id=25609

@Talk name=心の声
一切都在……今天。
@Hitret id=25610

@Talk name=心の声
我心不在焉地吃着早饭，完全尝不到味道。
@Hitret id=25611



@Hide
@BlackOut time=1000
@Wait time=1000 
@Cg file=B12a   
@Char file=CB01_01M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@PlayBgm file=BGM05

@Talk name=奈绪 voice=NO020159
早安，小悠，小穹！
@Hitret id=25612

@Talk name=悠
早安，奈绪。
@Hitret id=25613

@Talk name=奈绪 voice=NO020160
明明住得很近，说好久不见会很奇怪吧。过的好吗？
@Hitret id=25614

@Talk name=悠
嗯，经常出门。
@Hitret id=25615


@Char file=CF01_02M 

@Talk name=亮平 voice=RH020497
小穹——！！　我想死你了——！！
@Hitret id=25616


@Char file=CA01_04M 

@Talk name=穹 voice=SR020253
呜……
@Hitret id=25617

@Talk name=亮平 voice=RH020498
没我在的日子，很寂寞吧？　病了吗？　去哪玩了吗？　我去找你玩也都不在家啊~。
@Hitret id=25618

@Talk name=悠
………………………………
@Hitret id=25619

@Talk name=心の声
亮平是趁我不在家的时候来的吗？
@Hitret id=25620

@Talk name=心の声
穹那家伙，白天不是死睡就是上网，所以完全无视的吧……
@Hitret id=25621


@Char file=CB01_06M 

@Talk name=奈绪 voice=NO020161
好了好了，躲开躲开！　你也该适可而止了，不然新学期该被逮捕了。
@Hitret id=25622


@Char file=CF01_09M 

@Talk name=亮平 voice=RH020499
你才是，居然妨碍别人恋爱！　悠会踢你的哦！
@Hitret id=25623

@Talk name=悠
哎，为什么是我！？
@Hitret id=25624


@ClearChar 
@Char file=CC01_02M 
@Update
@action id=瑛 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=瑛

@Talk name=瑛 voice=AK021894
早上好—！　大家—！！
@Hitret id=25625


@Char file=CD01_02M 

@Talk name=一叶 voice=KA020564
早上好。
@Hitret id=25626

@Talk name=悠
早上好，瑛，渚同学。
@Hitret id=25627

@Talk name=瑛 voice=AK021895
啊哈—，小穹！　过的好吗？　抱——！！
@Hitret id=25628


@ClearChar id=一葉
@Char file=CA01_13M x=200   
@Char file=CC01_03M x=0   

@Talk name=穹 voice=SR020254
呀！？　呜……好，好痛苦……
@Hitret id=25629


@Char file=CC01_14M 

@Talk name=瑛 voice=AK021896
啊，小穹，瘦了啊—？　我可能胖了些呢—！　吃冰激凌吃的—！
@Hitret id=25630


@Char file=CA01_12M 
@Update
@action id=穹 action=ActionAdvHop width=35 height=2 cycle=150 count=2
@WaitAction id=穹

@Talk name=穹 voice=SR020255
所……所以……不……不要…………
@Hitret id=25631

@Talk name=心の声
瑛抱着穹，一边用脸蹭一边左右甩，开始了奇妙的肌肤之亲攻击。
@Hitret id=25632


@StopBgm fade=0
@Char file=CF01_04M x=-300  

@Talk name=亮平 voice=RH020500
喂喂，瑛，把她抱紧哦——？
@Hitret id=25633


@PlayBgm file=BGM13

@Talk name=瑛 voice=AK021897
哎？　可以啊——！
@Hitret id=25634


@Char file=CA01_13M 
@Update
@action id=穹 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=穹

@Talk name=穹 voice=SR020256
呀！！
@Hitret id=25635


@Char file=CF01_05M 

@Talk name=亮平 voice=RH020501
好，干的漂亮！　之后请你吃冰激凌！小穹啊啊啊啊啊——！！
@Hitret id=25636


@PlaySe file=se003
@Flash color=RED enter=0 leave=1000
@ClearChar id=亮平

@Talk name=亮平 voice=RH020502
呃啊！？
@Hitret id=25637


@PlaySe file=se018
@ClearChar 
@Char file=CB01_08M 
@Char file=CD01_05M 

@Talk name=奈绪 voice=NO020162
我说你啊——！
@Hitret id=25638

@Talk name=一叶 voice=KA020565
请不要碰到瑛！！
@Hitret id=25639


@Char file=CF01_10M 

@Talk name=亮平 voice=RH020503
呜呜……到了新学期，居然结成了更强的联盟来挡我……
@Hitret id=25640

@Talk name=奈绪 voice=NO020163
真是不长记性的家伙。
@Hitret id=25641


@Char file=CD01_06M 

@Talk name=一叶 voice=KA020566
瑛也是！　不要和他学坏！
@Hitret id=25642


@ClearChar 
@Char file=CC01_02M 

@Talk name=瑛 voice=AK021898
嘻嘻？
@Hitret id=25643


@Char file=CD01_10M 

@Talk name=一叶 voice=KA020567
不要用那种可爱的表情来装傻！
@Hitret id=25644

@Talk name=悠
不要紧吧……穹？
@Hitret id=25645


@Char file=CA01_11M 

@Talk name=穹 voice=SR020257
瑛……好可怕……
@Hitret id=25646


@Char file=CC01_05M 

@Talk name=瑛 voice=AK021899
对不起哦，小穹。
@Hitret id=25647


@Char file=CD01_04M 

@Talk name=一叶 voice=KA020568
真是的，一大早都做了些什么啊。
@Hitret id=25648


@ClearChar 
@Char file=CB01_01M 

@Talk name=奈绪 voice=NO020164
好的好的，我们该走了吧？　如果没赶上开学典礼，就会被看做亮平的同伴的。
@Hitret id=25649


@ClearChar 
@Char file=CF01_03M 

@Talk name=亮平 voice=RH020504
嘿嘿，不要仰慕我哦？
@Hitret id=25650


@StopBgm
@Char file=CF01_06M 

@Talk name=亮平 voice=RH020505
呃！？　喂！　别放下我不管啊！！！
@Hitret id=25651


@ClearChar 

@Talk name=悠
渚同学…………
@Hitret id=25652


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020569
什么？
@Hitret id=25653

@Talk name=悠
今天……就到了，结果。
@Hitret id=25654


@Char file=CD01_08M 

@Talk name=一叶 voice=KA020570
……是吗……我知道了。
@Hitret id=25655

@Talk name=悠
那，我们也走吧。
@Hitret id=25656

@Talk name=一叶 voice=KA020571
……嗯。
@Hitret id=25657

@Talk name=心の声
今天是开始的日子，也许也是结束的日子。
@Hitret id=25658

@Talk name=心の声
大家一起上学……也许也是最后一次了。
@Hitret id=25659


@ClearChar 
@Char file=CA01_01M 

@Talk name=穹 voice=SR020258
……………………………………
@Hitret id=25660


@ClearChar
@Update

@Cg file=B17a   
@EyeCatch  
@Update
@Wait time=1500 

@Hide
@BlackOut time=1000
@Cg file=B19a   
@Char file=CF01_01M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@PlayBgm file=BGM06
@PlaySe file=SE403

@Talk name=亮平 voice=RH020506
唉——……今天到寒假，半天就结束了多好？
@Hitret id=25661

@Talk name=悠
那也可以啊，不过就不能和穹吃便当了哦？
@Hitret id=25662


@Char file=CF01_04M 

@Talk name=亮平 voice=RH020507
啥！？　那可不行！　那，今天去你家吃流水素面吧。
@Hitret id=25663

@Talk name=悠
啊——，今天大概不行…………
@Hitret id=25664


@StopSe
@Char file=CH01_01M 

@Talk name=班长 voice=KO020024
中里同学，老师让你去办公室。
@Hitret id=25665


@Char file=CF01_09M 

@Talk name=亮平 voice=RH020508
啊？　为什么只有我？　悠呢？
@Hitret id=25666

@Talk name=悠
……我可不可以问一下，为什么我要一起啊……
@Hitret id=25667


@Char file=CH01_04M 

@Talk name=班长 voice=KO020025
春日野君有认真地交作业啊。
@Hitret id=25668


@Char file=CF01_06M 
@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=亮平 voice=RH020509
哎——！？
@Hitret id=25669

@Talk name=悠
抱歉……亮平。
@Hitret id=25670


@Char file=CF01_10M 

@Talk name=亮平 voice=RH020510
我一直信任你的……我以为，我们两个人可以一起被责罚，在回家的路上加深友情，结果——！！
@Hitret id=25671


@Char file=CH01_02M 

@Talk name=班长 voice=KO020026
记得去办公室哦？　啊，春日野君可以回家了。
@Hitret id=25672


@Char file=CF01_02M 
@Char file=CH01_01M 

@Talk name=亮平 voice=RH020511
悠~，能等我一下吗？
@Hitret id=25673

@Talk name=悠
抱歉亮平……今天有东西要领，我先回去了。
@Hitret id=25674


@Char file=CF01_04M 

@Talk name=亮平 voice=RH020512
我知道了，这里就交给我吧。之后我一定会追上你的，不用担心我。
@Hitret id=25675

@Talk name=悠
这种台词好像就绝对不会追上来了……
@Hitret id=25676


@Char file=CH01_10M 

@Talk name=班长 voice=KO020027
走吧？　老师说了让我带你去。
@Hitret id=25677


@StopBgm
@Char file=CF01_10M 
@Char file=CH01_01M 

@Talk name=亮平 voice=RH020513
不信任人啊……
@Hitret id=25678


@ClearChar 

@Talk name=悠
啊……亮平…………
@Hitret id=25679


@Char file=CF01_01M 

@Talk name=亮平 voice=RH020514
嗯？　怎么了？
@Hitret id=25680

@Talk name=悠
啊……不……之后跟你说……
@Hitret id=25681


@Char file=CF01_05M 

@Talk name=亮平 voice=RH020515
恋爱烦恼吗？　好的好的，我来仔细听你说吧！
@Hitret id=25682


@Char file=CH01_07M 

@Talk name=班长 voice=KO020028
恋，恋爱……！？　啊，不，中，中里同学！　该走了！
@Hitret id=25683


@Char file=CF01_04M 

@Talk name=亮平 voice=RH020516
好的好的！　啊，班长，你变漂亮些了啊？难道你恋爱了？
@Hitret id=25684


@Char file=CH01_05M 
@Update
@action id=梢 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=梢

@Talk name=班长 voice=KO020029
什，什什什，什么啊你说的！？春，春日野君，再，再见！！
@Hitret id=25685


@ClearChar 

@Talk name=悠
嗯，再见，班长。
@Hitret id=25686

@Talk name=心の声
……………………
@Hitret id=25687


@PlayBgm file=BGM08

@Talk name=悠
…………亮平…………
@Hitret id=25688

@Talk name=心の声
如果我说出了即将对瑛做出的事，亮平会怎么看我呢？
@Hitret id=25689

@Talk name=心の声
亮平一直很珍惜地守望着瑛，就像是她的哥哥。如果我把瑛弄哭，他应该会揍我。
@Hitret id=25690

@Talk name=心の声
不过……那样也好…………
@Hitret id=25691

@Talk name=心の声
如果那时，他能代替我来照顾瑛……
@Hitret id=25692

@Talk name=心の声
他是亮平啊。如果我对他说这种话，会惹他更生气……
@Hitret id=25693


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020572
春日野君，该回去了吧？
@Hitret id=25694

@Talk name=悠
嗯，邮政局的人该来了。
@Hitret id=25695

@Talk name=一叶 voice=KA020573
我一会儿去打扰可以吗？
@Hitret id=25696

@Talk name=悠
其实我没有足够的勇气一个人看呢。
@Hitret id=25697


@Char file=CD01_08M 

@Talk name=一叶 voice=KA020574
我也是。
@Hitret id=25698

@Talk name=悠
领取之后，还是先拿到八寻小姐那里去比较好吧。
@Hitret id=25699


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020575
那样也好。……另外瑛呢？　哪里都没看到她。
@Hitret id=25700

@Talk name=悠
是呀……刚才好像还在呢……
@Hitret id=25701

@Talk name=一叶 voice=KA020576
……咦……书包也不在……是不是回去了？
@Hitret id=25702

@Talk name=悠
她可能不找渚同学就回去吗？
@Hitret id=25703


@Char file=CD01_08M 

@Talk name=一叶 voice=KA020577
…………不会……
@Hitret id=25704

@Talk name=悠
…………总之，我们也回去吧。
@Hitret id=25705


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020578
嗯。
@Hitret id=25706


@Cg file=B18a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=悠
穹的班应该也放学了……咦……？
@Hitret id=25707


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020579
怎么了？
@Hitret id=25708

@Talk name=悠
……等不及了自己回去了吗？
@Hitret id=25709

@Talk name=心の声
穹的位子上，椅子已经推进去了，书包也没有。
@Hitret id=25710

@Talk name=心の声
我取出了手机，没看到穹发来短信。
@Hitret id=25711

@Talk name=悠
穹平时总是这样。那我们赶快回去吧。
@Hitret id=25712


@Cg file=B20a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate


@Talk name=奈绪 voice=NO020165
小悠——！
@Hitret id=25713


@Char file=CB01_01M 

@Talk name=悠
咦，奈绪的社团活动呢？
@Hitret id=25714

@Talk name=奈绪 voice=NO020166
嗯，要给泳池换水。暑假比较闲，那时候做就好了。
@Hitret id=25715


@Char file=CB01_02M 

@Talk name=奈绪 voice=NO020167
咦……渚同学和小悠，真是少见的组合。
@Hitret id=25716

@Talk name=悠
啊—，因为穹先回去了。
@Hitret id=25717

@Talk name=奈绪 voice=NO020168
是吗？　她和小瑛也一起回去了。
@Hitret id=25718


@Char file=CD01_12M 

@Talk name=一叶 voice=KA020580
和瑛一起？
@Hitret id=25719

@Talk name=奈绪 voice=NO020169
因为是并不少见的组合……她们把你们丢下了？
@Hitret id=25720

@Talk name=悠
……看，看来是如此。
@Hitret id=25721


@Char file=CD01_01M 
@Char file=CB01_03M 

@Talk name=奈绪 voice=NO020170
是不是因为小悠被小瑛夺走了，她嫉妒呢？
@Hitret id=25722

@Talk name=悠
是，是吗……
@Hitret id=25723


@Char file=CB01_01M 

@Talk name=奈绪 voice=NO020171
现在跑的话大概能追上哦。
@Hitret id=25724

@Talk name=悠
如果远远看见，会去追的。
@Hitret id=25725

@Talk name=奈绪 voice=NO020172
嗯。那你们俩也辛苦了。
@Hitret id=25726

@Talk name=悠
奈绪，社团活动加油哦。
@Hitret id=25727


@Char file=CB01_03M 

@Talk name=奈绪 voice=NO020173
啊哈哈，即使说加油，也只是盯着看水被抽走啊。
@Hitret id=25728


@Char file=CD01_02M 

@Talk name=一叶 voice=KA020581
那么，我们先失陪了。
@Hitret id=25729


@ClearChar 

@Talk name=心の声
奈绪挥着手朝泳池走去。
@Hitret id=25730

@Talk name=心の声
…………奈绪…………
@Hitret id=25731

@Talk name=心の声
如果，我们和奈绪商量，能够找到更妥善的方法吗……
@Hitret id=25732

@Talk name=心の声
还是说，她会成为和我们一起保守秘密的同伴？
@Hitret id=25733

@Talk name=心の声
可是，就算把大家都卷进来，也没有益处……
@Hitret id=25734

@Talk name=心の声
我不能一直去麻烦奈绪……
@Hitret id=25735

@Talk name=心の声
我已经这样决定了，不能现在再去找她哭诉。
@Hitret id=25736

@Talk name=悠
走吧。
@Hitret id=25737



@Hide
@BlackOut time=1000
@Wait time=1000 
@Cg file=B12a   
@Char file=CD01_08M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=一叶 voice=KA020582
……春日野君，不要紧吧？
@Hitret id=25738

@Talk name=悠
哎…………
@Hitret id=25739


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020583
刚才开始，你好像一直紧张呢。
@Hitret id=25740

@Talk name=悠
确实有一点……。
@Hitret id=25741


@Char file=CD01_08M 

@Talk name=一叶 voice=KA020584
我以为自己不要紧的……但现在也有些害怕。
@Hitret id=25742

@Talk name=悠
嗯…………
@Hitret id=25743


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020585
检查结果，是不是会像考试的结果通知那样写上明确的东西？
@Hitret id=25744

@Talk name=悠
例子上面，有写着结果，后面还有对比结果。
@Hitret id=25745

@Talk name=心の声
最上面会写着，『从生物学上来说，亲生关系：否定』这样。
@Hitret id=25746


@Char file=CD01_08M 

@Talk name=一叶 voice=KA020586
看到了就很容易懂吧……当然了……不会像电视上那样，广告之后……那么拖延……
@Hitret id=25747

@Talk name=悠
……一瞬间的事。
@Hitret id=25748


@StopBgm
@ClearChar 

@Talk name=心の声
不会有心理准备之类的东西。
@Hitret id=25749

@Talk name=悠
咦……
@Hitret id=25750

@Talk name=心の声
我家那边，驶来了摩托车。仔细看看，车筐上印有邮政的标致，应该是邮政局来的。
@Hitret id=25751

@Talk name=悠
啊，打扰一下！！！
@Hitret id=25752


@PlaySe file=SE258

@Talk name=心の声
我挥手示意，店员先生在我眼前停下来。
@Hitret id=25753

@Talk name=悠
我是春日野……抱歉我来晚了……那个……寄来的东西呢……？
@Hitret id=25754

@Talk name=邮政职员 voice=NP460004
啊啊，春日野先生？　挂号信刚才您的家人已经收下了啊？
@Hitret id=25755

@Talk name=悠
……啊，这样啊。打扰了，谢谢您。
@Hitret id=25756

@Talk name=邮政职员 voice=NP460005
没关系，请您下次光顾。告辞了。
@Hitret id=25757


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020587
穹同学收的吗？
@Hitret id=25758

@Talk name=悠
好像是。总之快走吧。
@Hitret id=25759

@Talk name=一叶 voice=KA020588
嗯。
@Hitret id=25760



@Hide
@BlackOut time=1000
@Wait time=1500 
@Cg file=B01a   
@Update transition=universal rule=WIP_MOZV time=500
@WaitUpdate
@PlaySe file=SE105

@Talk name=悠
我回来啦——…………
@Hitret id=25761

@Talk name=心の声
我打开门，闷热的空气扑面而来。
@Hitret id=25762

@Talk name=悠
穹—？　领的挂号信在哪里？
@Hitret id=25763

@Talk name=心の声
……………………………………………………
@Hitret id=25764

@Talk name=悠
咦？　……渚同学，稍等一下。
@Hitret id=25765


@Char file=CD01_08M 

@Talk name=一叶 voice=KA020589
嗯……
@Hitret id=25766


@ClearChar 

@Talk name=悠
穹！！　书包扔在门口了哦！
@Hitret id=25767

@Talk name=心の声
我脱了鞋进了家门。
@Hitret id=25768


@Cg file=B02a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=悠
穹……？　你放到哪了？
@Hitret id=25769

@Talk name=心の声
厨房桌子上什么都没有。
@Hitret id=25770

@Talk name=心の声
和我早上收拾完的时候一样。
@Hitret id=25771

@Talk name=悠
咦…………
@Hitret id=25772


@Cg file=B03a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=悠
………………………………
@Hitret id=25773

@Talk name=心の声
我房间的桌子上也没有。
@Hitret id=25774


@Cg file=B32a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=悠
………………嗯？
@Hitret id=25775

@Talk name=心の声
这里也没有………………
@Hitret id=25776


@BlackOut

@Talk name=心の声
不会是放在了厕所和浴室…………
@Hitret id=25777

@Talk name=心の声
………………………………
@Hitret id=25778

@Talk name=心の声
果然没有。两处都确认了，哪里都没有像是信封的东西。
@Hitret id=25779

@Talk name=心の声
那就是…………
@Hitret id=25780

@Talk name=悠
穹—！！　你放到哪里去了？
@Hitret id=25781


@PlaySe file=se101

@Talk name=悠
我开门了哦—？
@Hitret id=25782


@Cg file=B04a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@PlaySe file=se100

@Talk name=悠
…………………………………………
@Hitret id=25783

@Talk name=心の声
房间里谁也没有，窗户关着，空气很闷。
@Hitret id=25784

@Talk name=悠
……不在……是吗？
@Hitret id=25785

@Talk name=一叶 voice=KA020590
春日野君—？
@Hitret id=25786


@Cg file=B01a   
@Char file=CD01_07M 
@Update transition=universal rule=WIP_MOZV time=500
@WaitUpdate
@PlayBgm file=BGM11

@Talk name=一叶 voice=KA020591
有穹同学的鞋吗？
@Hitret id=25787

@Talk name=悠
说起来……没有…………
@Hitret id=25788

@Talk name=一叶 voice=KA020592
……会是去附近吗？
@Hitret id=25789

@Talk name=悠
不换衣服，还拿着信封？
@Hitret id=25790


@Char file=CD01_12M 

@Talk name=一叶 voice=KA020593
！！　难道说……
@Hitret id=25791



@Talk name=悠
说起来，奈绪说……穹和瑛一起回来……
@Hitret id=25792


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020594
瑛也……看到了吗……领挂号信的时候……
@Hitret id=25793

@Talk name=悠
总之，去瑛那里看看吧。
@Hitret id=25794


@Char file=CD01_07M 

@Talk name=一叶 voice=KA020595
嗯。
@Hitret id=25795

@Talk name=悠
为甚…………穹她………………
@Hitret id=25796



@Hide
@BlackOut time=1000
@Wait time=2000 

@Change target=00_c033b


