



@PlaySe file=SE357

@Cg file=B01a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=悠
穹，准备好了吗？
@Hitret id=18248


@Char file=CA01_07M 
@Update
@Move id=穹 my=30 cycle=1000
@WaitAction id=穹

@Talk name=穹 voice=SR020023
…………困。
@Hitret id=18249

@Talk name=悠
说过不要熬夜的吧。
@Hitret id=18250


@Char file=CA01_09M 
@Update
@Move id=穹 y=0 cycle=1000
@WaitAction id=穹

@Talk name=穹 voice=SR020024
……………………
@Hitret id=18251

@Talk name=心の声
唉……不占优势的时候，总会无视我……
@Hitret id=18252



@Talk name=瑛 voice=AK020094
早安~！　悠君—！！
@Hitret id=18253

@Talk name=悠
啊，早安……天女目，渚同学。
@Hitret id=18254


@PlayBgm file=BGM03
@ClearChar 
@Char file=CA01_01M x=-300   
@Char file=CC01_02M x=0   
@Char file=CD01_01M x=300   

@Talk name=一叶 voice=KA020001
早安……啊……
@Hitret id=18255

@Talk name=瑛 voice=AK020095
刚才提到的，悠君的妹妹小穹。
@Hitret id=18256

@Talk name=一叶 voice=KA020002
初次见面，我是渚一叶。
@Hitret id=18257

@Talk name=悠
来，穹也打招呼。
@Hitret id=18259

@Talk name=穹 voice=SR020025
…………请多关照。
@Hitret id=18260

@Talk name=悠
对，对不起哦……她不太爱说话……她叫穹，请多关照。
@Hitret id=18261


@Char file=CD01_02M 

@Talk name=一叶 voice=KA020003
嗯，也请你多关照呢，穹。
@Hitret id=18262

@Talk name=穹 voice=SR020026
…………嗯。
@Hitret id=18263

@Talk name=悠
你呀……
@Hitret id=18264


@Char file=CC01_01M 

@Talk name=瑛 voice=AK020096
这样也不错啊，小穹很害羞呢。
@Hitret id=18265


@Char file=CA01_12M x=-400   
@Char file=CC01_02M x=-200   

@Talk name=穹 voice=SR020027
……啊…………
@Hitret id=18266

@Talk name=心の声
天女目拉起了穹和渚同学的手，向前走去。
@Hitret id=18267


@ClearChar 

@Char file=CD01_04M 

@Talk name=一叶 voice=KA020004
瑛？　不要突然吓我啊！
@Hitret id=18268


@Char file=CC01_02M x=-400   

@Talk name=瑛 voice=AK020097
啊哈—，悠君也来吧？
@Hitret id=18269

@Talk name=悠
嗯！
@Hitret id=18270


@StopBgm

@Talk name=心の声
我也走到她们旁边。
@Hitret id=18271




@Hide
@BlackOut time=1000
@Wait time=2000 

@PlayBgm file=BGM06

@Cg file=B12a   
@Char file=CF01_05M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=亮平 voice=RH020008
哦！　有两个悠……呃不，那边的美少女难道是！！　呀哈！！
@Hitret id=18272


@ClearChar 
@Char file=CA01_13L 
@Update
@action id=穹 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=穹

@Talk name=穹 voice=SR020028
呀！？
@Hitret id=18273


@ClearChar 
@PlaySe file=se008
@Flash color=RED enter=0 leave=1000

@Char file=CF01_06M 
@Update
@Move id=亮平 my=800 cycle=1000
@WaitAction id=亮平

@Talk name=亮平 voice=RH020009
呜！？
@Hitret id=18274


@PlaySe file=se018

@ClearChar 

@Char file=CB01_01M 

@Talk name=奈绪 voice=NO020001
好了好了，不要吓到我们哦？
@Hitret id=18275

@Talk name=心の声
亮平朝穹扑去，奈绪用书包挡住，击坠了亮平。
@Hitret id=18276

@Talk name=奈绪 voice=NO020002
早安，大家。小穹的制服也到啦。发型也可爱，很配哦。
@Hitret id=18277


@Char file=CF01_03M x=-300   

@Talk name=亮平 voice=RH020010
我好想见你，小穹……让你久等对不起哦？不过我不会再离开你的……希望你能一直在我身边。
@Hitret id=18278


@Char file=CB01_08M x=300   
@update time=0
@action id=奈緒 action=ActionAdvHop width=35 height=2 cycle=150 count=2
@WaitAction id=奈緒

@Talk name=奈绪 voice=NO020003
呀！？　你，你从哪里冒出来的！！
@Hitret id=18279

@Talk name=心の声
刚才击坠的亮平，从奈绪脚边迅速站起。
@Hitret id=18280


@Char file=CF01_04M 
@Char file=CB01_06M 

@Talk name=亮平 voice=RH020011
走吧！　朝着我们的未来！
@Hitret id=18281


@Char file=CA01_04M x=0   

@Talk name=穹 voice=SR020029
走远些……
@Hitret id=18282


@Char file=CF01_02M 

@Talk name=亮平 voice=RH020012
真是的！　开玩笑的啦！　小穹也多关照哦？　跟哥哥真是很像啊。
@Hitret id=18283


@Char file=CF01_04M 

@Talk name=亮平 voice=RH020013
困扰的事情，想倾诉的事情，都可以跟我说哦？　为了小穹，我什么都会做哦？
@Hitret id=18284

@Talk name=穹 voice=SR020030
走远些……
@Hitret id=18285


@Char file=CF01_03M 

@Talk name=亮平 voice=RH020014
不！　只有这件事，太残酷了我做不到！
@Hitret id=18286


@Char file=CB01_08M 

@Talk name=奈绪 voice=NO020004
你赶快注意到你们没说到一起啊。
@Hitret id=18287


@Char file=CB01_02M 

@Talk name=奈绪 voice=NO020005
总之，小穹，来这边吧。虽然旁边有很吵的家伙，以后也请多多关照。
@Hitret id=18288

@Talk name=悠
……来，穹……
@Hitret id=18289


@Char file=CA01_06M 

@Talk name=穹 voice=SR020031
……请多关照……
@Hitret id=18290


@Char file=CF01_02M 

@Talk name=亮平 voice=RH020015
好耶！！！　这样我们是同伴了！
@Hitret id=18291


@ClearChar 

@Char file=CC01_02M 

@Talk name=瑛 voice=AK020098
同伴同伴！
@Hitret id=18292


@Char file=CC01_02M x=-200   
@Char file=CD01_04M x=200   

@Talk name=一叶 voice=KA020005
真是一直都在吵……
@Hitret id=18293


@Talk name=悠
真好啊，穹。这么受欢迎。
@Hitret id=18294


@Char file=CA01_01M x=-300   
@Char file=CC01_02M x=0   
@Char file=CD01_01M x=300   

@Talk name=穹 voice=SR020032
…………
@Hitret id=18295


@Talk name=心の声
还没对大家介绍穹呢。
@Hitret id=18296

@Talk name=心の声
大家都很有个性，穹可能也会有些不适应，但是这样强行的方式可能更好。
@Hitret id=18297

@Talk name=心の声
虽然穹有些困惑，不过旁边有天女目在帮她。
@Hitret id=18298

@Talk name=心の声
天女目容易和人混熟这一点，现在让我很感激。
@Hitret id=18299

@StopBgm


@Hide
@BlackOut time=1000
@Wait time=2000 

@Change target=00_c003


