


@PlaySe file=SE357
@Cg file=B01a   
@Update time=2000
@WaitUpdate
@Update
@BlackOut
@Cg file=B02a   

@Talk name=悠
穹？　准备好了吗？
@Hitret id=11082

@Talk name=心の声
今天要起早点准备早餐，我也按照奈绪的建议做了简单的饭团便当。
@Hitret id=11083

@Talk name=心の声
我用大手帕包着难看得有点不像便当盒的食品容器。
@Hitret id=11084

@Talk name=心の声
最好还要水壶，而这我打算等下次大规模购物时再凑齐。
@Hitret id=11085


@PlayBgm file=BGM05

@Talk name=悠
穹？　饭要冷掉了？
@Hitret id=11086

@Talk name=穹 voice=SR030007
…………烦。
@Hitret id=11087


@Char file=CA01_01M 

@Talk name=悠
哦，尺寸还合身吧？
@Hitret id=11088

@Talk name=穹 voice=SR030008
………………………………
@Hitret id=11089

@Talk name=心の声
穹好像在意着什么，抓着袖子一会张开双手一会挥动双手。
@Hitret id=11090

@Talk name=悠
看来没什么问题啊。很般配啊，制服。
@Hitret id=11091


@Char file=CA01_10M 

@Talk name=穹 voice=SR030009
………没什么。
@Hitret id=11092

@Talk name=悠
来，吃饭吧。
@Hitret id=11093

@Talk name=穹 voice=SR030010
嗯……
@Hitret id=11094

@Talk name=心の声
总之今天，把平时分开来吃的色拉和鸡蛋夹在面包里，做成了三明智。
@Hitret id=11095



@Hide
@BlackOut time=1000
@Cg file=B01a   

@Talk name=悠
好了，没有忘带东西吧？
@Hitret id=11096


@Char file=CA01_01M 

@Talk name=穹 voice=SR030011
………不知道………
@Hitret id=11097

@Talk name=悠
什么叫不知道啊……喂………
@Hitret id=11098

@Talk name=穹 voice=SR030012
我又不知道课表………
@Hitret id=11099

@Talk name=悠
………啊………
@Hitret id=11100

@Talk name=心の声
说来忘记从穹那班级的老师要课表了……
@Hitret id=11101

@Talk name=心の声
但毕竟是第一天…应该能船到桥头自然直吧。
@Hitret id=11102


@Char file=CA01_06M 

@Talk name=穹 voice=SR030013
什么叫……“啊”？
@Hitret id=11103

@Talk name=悠
哈哈……这、这个……
@Hitret id=11104

@Talk name=奈绪 voice=NO030126
早啊！
@Hitret id=11105


@Char file=CA01_06M x=-200   
@Char file=CB01_01M x=200   

@Talk name=悠
啊，早，奈绪。
@Hitret id=11106

@Talk name=奈绪 voice=NO030127
哎呀，两人都很般配哦。
@Hitret id=11107

@Talk name=悠
多亏了奈绪来帮忙啊。
@Hitret id=11108

@Talk name=奈绪 voice=NO030128
不，我也没做什么。小穹，制服穿起来还好吧？
@Hitret id=11109


@Char file=CA01_05M 

@Talk name=穹 voice=SR030014
………一般。
@Hitret id=11110

@Talk name=奈绪 voice=NO030129
如果纽扣松了就和我说哦？　我好歹也有裁缝工具。
@Hitret id=11111

@Talk name=悠
喂……穹，昨天的事谢谢人家？
@Hitret id=11112


@Char file=CA01_12M 

@Talk name=穹 voice=SR030015
呃……
@Hitret id=11113

@Talk name=悠
奈绪帮你安了纽扣之类的呢？
@Hitret id=11114


@Char file=CA01_11M 

@Talk name=穹 voice=SR030016
……………………
@Hitret id=11115

@Talk name=心の声
穹扭扭捏捏地把视线和奈绪错开。
@Hitret id=11116

@Talk name=悠
………穹……
@Hitret id=11117

@Talk name=穹 voice=SR030017
………谢谢。
@Hitret id=11118


@Char file=CB01_02M 

@Talk name=奈绪 voice=NO030130
嗯……不客气。
@Hitret id=11119


@ClearChar id=穹

@Talk name=心の声
穹可能是难为情，一边嘟囔着什么一边走开了。
@Hitret id=11120

@Talk name=悠
穹，学校在反方向。
@Hitret id=11121


@ClearChar 
@Char file=CA01_06S x=-300   

@Talk name=心の声
正要向反方向行走的穹恶狠狠地盯了我一眼，然后修正了方向。
@Hitret id=11122


@ClearChar 
@Char file=CB01_02M 

@Talk name=奈绪 voice=NO030131
呵呵，我们也走吧。
@Hitret id=11123

@Talk name=悠
嗯。
@Hitret id=11124



@Hide
@BlackOut time=1000
@Cg file=B12a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=亮平 voice=RH030079
哎呀哎呀，真是巧啊？
@Hitret id=11125


@Char file=CF01_03M 

@Talk name=心の声
亮平把脚搁在路标上，摆好了姿势。
@Hitret id=11126


@Char file=CB01_06M 

@Talk name=奈绪 voice=NO030132
一大清早的，你真的很闲啊？
@Hitret id=11127


@ClearChar id=奈緒
@Char file=CA01_09M 
@Char file=CF01_02M 

@Talk name=亮平 voice=RH030080
早啊，小穹！！
@Hitret id=11128


@Char file=CF01_06M 
@Update
@Leave id=穹 mx=300 my=0 fade=1 time=1000 accel=1

@Talk name=亮平 voice=RH030081
哎呀？　哎呀呀呀，我说，等一等啊！？
@Hitret id=11129


@ClearChar 

@Talk name=心の声
穹无视亮平，自管自走了起来。
@Hitret id=11130


@Char file=CB01_08M 

@Talk name=奈绪 voice=NO030133
还真的是不吸取教训啊…………
@Hitret id=11131

@Talk name=心の声
亮平在穹的周围不停地转圈努力说话，但穹完全不理不睬。
@Hitret id=11132

@Talk name=心の声
被穹无视到那地步，也算是少见了……
@Hitret id=11133

@Talk name=心の声
都感觉亮平有些可怜了。
@Hitret id=11134

@Talk name=声 voice=KA030001
中里前辈，会让人家困扰的哦？
@Hitret id=11135


@ClearChar 
@Char file=CF01_06M 

@Talk name=亮平 voice=RH030082
什…！？　这声音是！！
@Hitret id=11136


@ClearChar 
@Char file=CC01_01M 
@Char file=CD01_07M 

@Talk name=瑛 voice=AK030001
早上好啊！
@Hitret id=11137

@Talk name=悠
啊，早，天女目、渚同学。
@Hitret id=11138


@Char file=CD01_10M 

@Talk name=一叶 voice=KA030002
早、早上好。
@Hitret id=11139

@Talk name=心の声
正好追上我们的两人。
@Hitret id=11140

@Talk name=心の声
她们好像关系很好，是邻居吗？
@Hitret id=11141

@Talk name=悠
啊，对了……穹！
@Hitret id=11142


@ClearChar 
@Char file=CA01_01M 

@Talk name=穹 voice=SR030018
………什么？
@Hitret id=11143

@Talk name=悠
正好，给大家介绍一下。
@Hitret id=11144

@Talk name=悠
大家……她是从今天起将和我们一起上学的穹。请多多关照。
@Hitret id=11145


@Char file=CF01_04M 

@Talk name=亮平 voice=RH030083
多多关照！！　好像还没自我介绍呢？　我叫中里亮平，是悠的亲友。
@Hitret id=11146


@Char file=CA01_04S 

@Talk name=心の声
穹后退了一大步。
@Hitret id=11147


@ClearChar
@Char file=CC01_01M 

@Talk name=瑛 voice=AK030002
那么，接下来是我们。
@Hitret id=11148


@Char file=CD01_02M 

@Talk name=一叶 voice=KA030003
我叫渚一叶，初次见面。
@Hitret id=11149

@Talk name=心の声
被天女目催促的渚同学很礼貌地低头行礼。
@Hitret id=11150

@Talk name=瑛 voice=AK030003
还记得我吗？
@Hitret id=11151


@Char file=CA01_13M 

@Talk name=穹 voice=SR030019
……呃……？
@Hitret id=11152


@Char file=CC01_02M 

@Talk name=瑛 voice=AK030004
啊，果然忘记了啊。我是瑛。天女目瑛。
@Hitret id=11153


@Char file=CA01_01M 

@Talk name=穹 voice=SR030020
………瑛……
@Hitret id=11154

@Talk name=瑛 voice=AK030005
好久不见，小穹。
@Hitret id=11155


@ClearChar id=一葉
@Char file=CF01_01M 

@Talk name=亮平 voice=RH030084
怎么？　瑛，你还认识小穹啊？
@Hitret id=11156

@Talk name=瑛 voice=AK030006
小时候迷路时我帮过她，可能已经忘记了吧。
@Hitret id=11157


@Char file=CC01_01M 

@Talk name=瑛 voice=AK030007
再一次多多关照，小穹。
@Hitret id=11158


@Char file=CA01_12M 

@Talk name=穹 voice=SR030021
……啊……嗯。
@Hitret id=11159


@Char file=CF01_02M 

@Talk name=亮平 voice=RH030085
好，现在起我们就是好朋友了！
@Hitret id=11160


@Char file=CC01_03M 

@Talk name=瑛 voice=AK030008
朋友~！！
@Hitret id=11161


@Char file=CA01_05M 
@StopBgm

@Talk name=亮平 voice=RH030086
好！　大家一起组团上学！！
@Hitret id=11162


@PlayBgm file=BGM03
@Char file=CA10_01L x=370 y=130 order=910
@Char file=CB10_01L x=156 y=-80 order=950
@Char file=CC10_01L x=-240 y=85 order=940
@Char file=CD10_01L x=-414 y=62 order=930
@Char file=CF10_01L x=-64 y=-70 order=920
@update
	@action id=穹 action=ActionAdvWave width=0 height=2 cycle=1100 count=-1
	@action id=奈緒 action=ActionAdvWave width=0 height=6 cycle=1500 count=-1
	@action id=瑛 action=ActionAdvWave width=0 height=3 cycle=1000 count=-1
	@action id=一葉 action=ActionAdvWave width=0 height=3 cycle=1500 count=-1
	@action id=亮平 action=ActionAdvWave width=0 height=2 cycle=1300 count=-1

@BgScroll file=EZ01a mx=800 my=0 cycle=80000

@Talk name=亮平 voice=RH030087
哎呀，没想到能和那么可爱的女孩成同班同学啊！
@Hitret id=11163

@Talk name=穹 voice=SR030022
……呃………
@Hitret id=11164

@Talk name=瑛 voice=AK030009
是吗？　是真的是真的？
@Hitret id=11165

@Talk name=奈绪 voice=NO030134
真是的，亮平适可而止啦，你没看到小穹在害怕吗？
@Hitret id=11166

@Talk name=亮平 voice=RH030088
刚转校时，谁都是孤独的。但是，有我在就不会让这种事发生！
@Hitret id=11167

@Talk name=悠
………………………
@Hitret id=11168

@Talk name=心の声
开、开不了口……穹其实是在其它班级的事……
@Hitret id=11169

@Talk name=心の声
穹慢慢离开热闹的集团，来到我身边。
@Hitret id=11170

@Talk name=悠
太、太好了呢，第一天上学就交到那么多朋友？
@Hitret id=11171

@Talk name=穹 voice=SR030023
……不要那么多……
@Hitret id=11172

@Talk name=悠
别这么说啦………
@Hitret id=11173

@Talk name=瑛 voice=AK030010
小叶，小悠和小穹真的很像呢。
@Hitret id=11174

@Talk name=一叶 voice=KA030004
是，妹妹我是第一次见，没想到……
@Hitret id=11175

@Talk name=亮平 voice=RH030089
是啊！　他们可是双胞胎啊，真厉害呢？
@Hitret id=11176

@Talk name=悠
没什么大不了的，而且性格也不是很像。
@Hitret id=11177

@Talk name=亮平 voice=RH030090
会不会有心灵感应这些？
@Hitret id=11178

@Talk name=奈绪 voice=NO030135
这种漫画里一样的事怎么可能啊？
@Hitret id=11179

@Talk name=悠
哈哈………抱歉，辜负你的期待了。
@Hitret id=11180

@Talk name=亮平 voice=RH030091
切，没有啊？　真没劲。
@Hitret id=11181

@Talk name=奈绪 voice=NO030136
你在期待些什么傻事呀。
@Hitret id=11182

@Talk name=心の声
大家都对我们投以温暖的眼光。
@Hitret id=11183

@Talk name=心の声
穹露出了不太适应的表情，躲在了我后面。
@Hitret id=11184

@Talk name=亮平 voice=RH030092
真的好可爱。我也真想像悠那样，有妹妹来仰慕啊。
@Hitret id=11185

@Talk name=奈绪 voice=NO030137
如果是这样，那妹妹就太可怜了。
@Hitret id=11186

@Talk name=瑛 voice=AK030011
是吗，亮哥哥我觉得挺有趣的。
@Hitret id=11187

@Talk name=亮平 voice=RH030093
哦哦，我的知己只有你啊。
@Hitret id=11188

@Talk name=一叶 voice=KA030005
中里前辈，请不要把瑛卷进去。
@Hitret id=11189

@Talk name=亮平 voice=RH030094
切，小叶也还是一如既往的顽固啊。
@Hitret id=11190

@Talk name=一叶 voice=KA030006
请、请不要用这称呼。
@Hitret id=11191

@Talk name=瑛 voice=AK030012
小穹也能一起上学了，感觉变得有趣了呢？
@Hitret id=11192

@Talk name=亮平 voice=RH030095
哦，是啊！　怎么说呢，感觉每天都有上学的动力了！
@Hitret id=11193

@Talk name=奈绪 voice=NO030138
你可别太缠人了。
@Hitret id=11194

@Talk name=心の声
哎，要是知道穹不在同一个班级，大家都会做出怎样的反应呢………
@Hitret id=11195


@BlackOut

@Talk name=心の声
把事实告诉给兴奋起来的大家，这我做不到。
@Hitret id=11196


@StopBgm

@ClearChar
@Update

@Cg file=B18a   

@EyeCatch

@Change target=00_b003b


