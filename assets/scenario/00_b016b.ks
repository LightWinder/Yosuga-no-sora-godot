


@PlayEnvSe file=SE301 fade=0
@Cg file=B17a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=心の声
毕竟很少有学生暑假也来学校。
@Hitret id=13996

@Talk name=心の声
只看看见少数穿着运动短裤和运动衫的同学，而校舍的窗基本上都被窗帘挡着。
@Hitret id=13997

@Talk name=心の声
虽然这学校的学生并不算多，但这一放假也未免变得太过安静了。
@Hitret id=13998


@Cg file=B21a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=心の声
天气如此炎热，来泳池的人却几乎没有。
@Hitret id=13999

@Talk name=心の声
而今天这泳池的管理员（？）依旧是在泳池边上看着书。
@Hitret id=14000


@Cg file=EB02a  

@Talk name=悠
奈绪。
@Hitret id=14001


@Cg file=EB02b  

@Talk name=奈绪 voice=NO030765
啊，欢迎，小悠。
@Hitret id=14002

@Talk name=悠
我来玩了，今天真热呢~？
@Hitret id=14003

@Talk name=奈绪 voice=NO030766
是啊~，刚才棒球部和篮球部的人还来这乘凉呢。
@Hitret id=14004

@Talk name=悠
哦，今天还有客人啊。
@Hitret id=14005

@Talk name=心の声
仔细一看，泳池旁到处都有被水冲过的痕迹。
@Hitret id=14006

@Talk name=心の声
可能游的人玩得很尽兴，旁边基本上都湿透了。
@Hitret id=14007

@Talk name=奈绪 voice=NO030767
不过，下午就几乎没人了。今天社团活动基本上都集中在上午。
@Hitret id=14008

@Talk name=悠
奈绪，今天你一天都要呆这吗？
@Hitret id=14009

@Talk name=奈绪 voice=NO030768
我也没决定过，随便了。难得小悠来了，差不多就游一会吧。
@Hitret id=14010

@Talk name=心の声
奈绪合上书，站了起来。
@Hitret id=14011


@Cg file=B21a   
@Char file=CB04_02M 
@Update
@Move id=奈緒 my=-25 cycle=1000
@WaitAction id=奈緒

@Talk name=奈绪 voice=NO030769
嗯………小悠你怎么办？　要浸一下水吗？
@Hitret id=14012


@Update
@Move id=奈緒 y=0 cycle=1000
@WaitAction id=奈緒

@Talk name=悠
嗯，难得来了，光是浸水应该不要紧。
@Hitret id=14013

@Talk name=奈绪 voice=NO030770
嗯，那去换好衣服吧？　更衣室开着，随便用就可以。
@Hitret id=14014

@Talk name=悠
嗯，那一会见。
@Hitret id=14015


@Talk name=奈绪 voice=NO030771
快点啊。
@Hitret id=14016


@StopEnvSe id=SE301

@Hide
@BlackOut time=1000
@Wait time=1000 
@Cg file=B21a   
@Update transition=universal rule=WIP_BT time=500
@WaitUpdate
@PlaySe file=SE202

@Talk name=心の声
我冲好淋浴，来到泳池边上，看到奈绪正好要游完２５米的泳道。
@Hitret id=14017

@Talk name=心の声
她在快到底时做了一个漂亮的空翻，接着又向反方向冲刺过去。
@Hitret id=14018

@Talk name=心の声
我在海边也看到过，奈绪的动作很优美，速度看似也很快。
@Hitret id=14019

@Talk name=心の声
我不在的期间，努力于社团活动的奈绪。
@Hitret id=14020

@Talk name=心の声
她漂亮地击碎了我认为她属于文化系的印象，这让我很是感动。
@Hitret id=14021



@Talk name=心の声
我想着这些的时候，奈绪很快又游完了５０米。
@Hitret id=14022

@Talk name=心の声
然后，她这次又仰着身体踢了下池壁，浮在水面上飘了起来。
@Hitret id=14023


@PlayBgm file=BGM08

@Talk name=心の声
一直看着天空……
@Hitret id=14024

@Talk name=心の声
她在想些什么呢？
@Hitret id=14025

@Talk name=心の声
感觉现在的她有些难以接近。
@Hitret id=14026

@Talk name=心の声
但是，她的这副表情我似曾相识。
@Hitret id=14027

@Talk name=心の声
在学校………没有和我们在一起时的奈绪。
@Hitret id=14028

@Talk name=心の声
以及……我刚搬到这里时，时隔许久第一次看到的表情……
@Hitret id=14029

@Talk name=心の声
显得很无聊……又寂寞……
@Hitret id=14030

@Talk name=心の声
是否有我所不知晓的隐情……
@Hitret id=14031

@Talk name=心の声
总是和颜悦色且又待人温柔的奈绪的另一张脸…
@Hitret id=14032


@StopBgm

@Talk name=心の声
被她伤感的表情弄得踌躇不前的我，故意发出声音来接近她。
@Hitret id=14033

@Talk name=奈绪 voice=NO030772
啊，小悠，很快啊。
@Hitret id=14034

@Talk name=心の声
奈绪游到我这里，从水里出来用毛巾擦了下脸。
@Hitret id=14035


@PlayBgm file=BGM06
@Char file=CB06_02M 

@Talk name=奈绪 voice=NO030773
伸展运动做过了吗？
@Hitret id=14036

@Talk name=悠
现在开始做。
@Hitret id=14037

@Talk name=奈绪 voice=NO030774
当心别扭到脚啊。还有泳池的中央水比较深，要注意了。
@Hitret id=14038

@Talk name=悠
我不会靠近那么危险的地方的。
@Hitret id=14039


@Char file=CB06_03M 

@Talk name=奈绪 voice=NO030775
哈哈，没事的。我会把你训练到碰到水也完全不怕的。
@Hitret id=14040

@Talk name=悠
我能游得像奈绪一样吗？
@Hitret id=14041


@Char file=CB06_01M 

@Talk name=奈绪 voice=NO030776
总之，五年左右？　努力练一定可以的。
@Hitret id=14042

@Talk name=悠
你练得那么多？
@Hitret id=14043


@Char file=CB06_03M 

@Talk name=奈绪 voice=NO030777
哈哈哈，开个玩笑啦。我也只练过一年左右。
@Hitret id=14044


@Char file=CB06_01M 

@Talk name=奈绪 voice=NO030778
游泳是进入这所学校后才开始的。
@Hitret id=14045

@Talk name=悠
这样啊……但是，已经游得既漂亮又快了呢？
@Hitret id=14046


@Char file=CB06_02M 

@Talk name=奈绪 voice=NO030779
谢谢。但那只是表象，成绩还差得很呢？
@Hitret id=14047

@Talk name=悠
但对不会游的我来说，已经很厉害了。
@Hitret id=14048


@Char file=CB06_05M 

@Talk name=奈绪 voice=NO030780
啊，对不起………
@Hitret id=14049

@Talk name=悠
不………不用在意。还有，我也是来让你教我的，尽管训练我吧。
@Hitret id=14050


@Char file=CB06_02M 

@Talk name=奈绪 voice=NO030781
嗯……知道了。那慢慢熟悉吧。
@Hitret id=14051


@ClearChar 

@Talk name=心の声
我做伸展运动活动开手脚。
@Hitret id=14052

@Talk name=心の声
体育课时我一直都是靠蒙混过关的，但也不能一直骗下去。
@Hitret id=14053

@Talk name=心の声
难得奈绪愿意来教我，最好就趁此机会把水给克服了。
@Hitret id=14054


@Char file=CB04_01M 

@Talk name=奈绪 voice=NO030782
那先从浸脸开始吧？
@Hitret id=14055

@Talk name=悠
呃……？
@Hitret id=14056


@Char file=CB04_02M 

@Talk name=奈绪 voice=NO030783
这是基础哦？　有的人就算洗脸和冲淋浴没事，但脸一浸到水里就有抵触了。
@Hitret id=14057

@Talk name=奈绪 voice=NO030784
然后为了让脸不碰到水面，用很勉强的姿势去游，就会更加耗体力了。
@Hitret id=14058

@Talk name=奈绪 voice=NO030785
所以，只要脸浸到水里也不慌，并学会换气的话，就算不会游也能长时间浮在上面。
@Hitret id=14059

@Talk name=悠
原来如此……
@Hitret id=14060


@Char file=CB04_01M 

@Talk name=奈绪 voice=NO030786
呼吸一困难任谁都会慌的，所以先要习惯。
@Hitret id=14061

@Talk name=奈绪 voice=NO030787
只要习惯了，就能冷静应对了。
@Hitret id=14062


@Char file=CB04_03M 

@Talk name=奈绪 voice=NO030788
之后再学游泳，也为时不晚哦。
@Hitret id=14063

@Talk name=悠
嗯，知道了。听奈绪这么一说，我就感觉自己能办到了呢。
@Hitret id=14064


@Char file=CB04_02M 

@Talk name=奈绪 voice=NO030789
呵呵，为了悠，我可要狠下心了哦？那就先浸１分钟脸。啊，眼睛可以闭上。
@Hitret id=14065

@Talk name=悠
呃？　１分钟？
@Hitret id=14066


@Char file=CB04_03M 

@Talk name=奈绪 voice=NO030790
还是希望像洗澡时那样数１００秒？
@Hitret id=14067

@Talk name=悠
………那就１分钟好了。
@Hitret id=14068


@Char file=CB04_04M 

@Talk name=奈绪 voice=NO030791
好的！　加油！　１分钟做到了，接下来就要睁着眼睛浸１分钟哦？
@Hitret id=14069

@Talk name=悠
唔………知、知道了………
@Hitret id=14070


@ClearChar 

@Talk name=心の声
我们进入泳池，首先从浸脸开始训练。
@Hitret id=14071

@Talk name=心の声
水位在我胸部这里。
@Hitret id=14072

@Talk name=心の声
说实话，仅仅是这样我的心脏就已经和全力冲刺时跳得一样快了。
@Hitret id=14073

@Talk name=奈绪 voice=NO030792
害怕的话，可以立刻抬头的。
@Hitret id=14074


@StopBgm

@Talk name=悠
嗯……知道了。
@Hitret id=14075


@BlackOut
@PlaySe file=SE205

@Talk name=心の声
我做好觉悟，把脸放进水里。
@Hitret id=14076

@Talk name=心の声
正常来想，只要不犯太低级的错误，是不可能在这里溺水的。
@Hitret id=14077

@Talk name=心の声
就算难以屏气了，只要一抬头就能正常呼吸。
@Hitret id=14078

@Talk name=心の声
而且紧紧握着泳池边上的把手，也不用怕身体失去平衡。
@Hitret id=14079

@Talk name=心の声
这样一想，心情就稍微轻松了点，但不能呼吸这点还是没有办法。
@Hitret id=14080

@Talk name=心の声
小时候也没事屏气玩过，１分钟还是很轻松的。
@Hitret id=14081

@Talk name=心の声
但是在水里就不一样了，一旦呼吸就会吸进水。
@Hitret id=14082

@Talk name=心の声
可能是这的缘故……屏气时间越长就越感到害怕。
@Hitret id=14083


@PlayBgm file=BGM05
@PlaySe file=SE208
@Cg file=B21a   
@Update transition=universal rule=WIP_TB time=250
@WaitUpdate

@Talk name=悠
啊ーー！
@Hitret id=14084


@Char file=CB04_09M 

@Talk name=奈绪 voice=NO030793
没事吧？
@Hitret id=14085

@Talk name=悠
嗯……还没过１分钟吧？
@Hitret id=14086


@Char file=CB04_01M 

@Talk name=奈绪 voice=NO030794
嗯，但毕竟第一次也没办法。
@Hitret id=14087

@Talk name=奈绪 voice=NO030795
还是害怕？
@Hitret id=14088

@Talk name=悠
闭着眼睛的话。
@Hitret id=14089

@Talk name=奈绪 voice=NO030796
带游泳镜来就好了呢……
@Hitret id=14090

@Talk name=悠
不，我再试一次。
@Hitret id=14091


@BlackOut
@PlaySe file=SE205

@Talk name=心の声
我再一次把脸浸到水里。
@Hitret id=14092

@Talk name=心の声
耳朵因为没浸在水里，所以能听见周围的声音。
@Hitret id=14093

@Talk name=心の声
奈绪在慢慢从１数起。
@Hitret id=14094

@Talk name=心の声
刚才连３０秒都没到。
@Hitret id=14095

@Talk name=心の声
这次一定要…………
@Hitret id=14096

@Talk name=心の声
即使这么想，心脏却还是跳得厉害，屏着呼吸越来越难受，让我身体一抖。
@Hitret id=14097

@Talk name=心の声
没事的……不会有问题的……虽然我想努力，但空气从肺部涌了上来，撑开嘴巴，实在忍不住了。
@Hitret id=14098


@PlaySe file=SE208
@Cg file=B21a   
@Update transition=universal rule=WIP_TB time=250
@WaitUpdate

@Talk name=悠
唔……呼，呼…………
@Hitret id=14099


@Char file=CB04_01M 

@Talk name=奈绪 voice=NO030797
休息会儿吧。
@Hitret id=14100

@Talk name=悠
不，没事……
@Hitret id=14101

@Talk name=奈绪 voice=NO030798
你太逞强反而会让身体吃不消的啊？　而且头痛起来的话就危险了。
@Hitret id=14102

@Talk name=奈绪 voice=NO030799
只要抓住感觉就会轻松许多，所以先要去习惯。
@Hitret id=14103

@Talk name=悠
嗯………
@Hitret id=14104


@ClearChar 

@Talk name=心の声
说实话我感觉很窝囊……都长这么大了还不会游泳。
@Hitret id=14105

@Talk name=心の声
难得来了泳池，我本来可以和奈绪一起开心地游、玩、闹………
@Hitret id=14106

@Talk name=心の声
但长年以来在我心中扎根的恐惧感，很难移除。
@Hitret id=14107

@Talk name=心の声
这是精神方面的问题，也就是要看我的心态……
@Hitret id=14108

@Talk name=悠
我再试一次。
@Hitret id=14109


@Char file=CB04_02M 

@Talk name=奈绪 voice=NO030800
加油哦，小悠。
@Hitret id=14110

@Talk name=悠
嗯。
@Hitret id=14111


@BlackOut
@PlaySe file=SE205

@Talk name=心の声
我闭上眼，轻轻把脸浸在水里。
@Hitret id=14112

@Talk name=奈绪 voice=NO030801
一，二……三……
@Hitret id=14113

@Talk name=心の声
奈绪在读秒。
@Hitret id=14114

@Talk name=奈绪 voice=NO030802
七，八……九………
@Hitret id=14115

@Talk name=心の声
这时候起，不论怎样都会觉得很难受。
@Hitret id=14116

@Talk name=心の声
不管如何给自己加油，身体还是不停地诉苦。
@Hitret id=14117


@PlaySe file=SE361

@Talk name=心の声
空气从我嘴巴边上漏了出来，挠我的脸颊。
@Hitret id=14118

@Talk name=心の声
不好……一定要紧闭嘴巴，不让空气漏出来。
@Hitret id=14119

@Talk name=悠
！？
@Hitret id=14120

@Talk name=心の声
我的手突然碰到了什么。
@Hitret id=14121

@Talk name=奈绪 voice=NO030803
加油，小悠……
@Hitret id=14122

@Talk name=心の声
奈绪的手盖在了我的手上。温柔地握着我，激励着我。
@Hitret id=14123

@Talk name=奈绪 voice=NO030804
十七，十八………
@Hitret id=14124

@Talk name=心の声
但多亏了她，我的心情也平静了许多。
@Hitret id=14125

@Talk name=奈绪 voice=NO030805
二十！　做到了！　小悠！
@Hitret id=14126


@PlaySe file=SE203

@Talk name=心の声
水面晃个不停。
@Hitret id=14127

@Talk name=心の声
多亏了奈绪，我把脸浸在水里浸了２０秒以上。
@Hitret id=14128

@Talk name=心の声
太好了！　虽然很胸闷，就要忍不住了。
@Hitret id=14129

@Talk name=心の声
我小心翼翼地睁开眼，往水里看。
@Hitret id=14130


@Cg file=0,174,239
@Update transition=universal rule=MOZCIR_ time=800
@WaitUpdate

@Talk name=心の声
眼前一片水色世界……奈绪在我旁边蹦跳着，为我高兴。
@Hitret id=14131

@Talk name=心の声
这样渐渐去习惯的话……我也……
@Hitret id=14132

@Talk name=心の声
想到这，苦闷感就减轻了许多。
@Hitret id=14133

@Talk name=心の声
奈绪靠近我，抚摩我的背。
@Hitret id=14134


@Char file=CB06_04S 
@Update
@MoveCamera x=0 y=128 z=112 time=0
@StopBgm fade=0

@Talk name=心の声
！？
@Hitret id=14135

@Talk name=心の声
我视线的正前方，就是奈绪的臀部。
@Hitret id=14136


@PlaySe file=SE201
@Cg file=B21a   
@Update transition=universal rule=WIP_TB time=50
@WaitUpdate
@Update
@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=75 
@WaitAction id=カメラ

@Talk name=悠
哇啊啊啊！！！
@Hitret id=14137


@PlayBgm file=BGM14
@Char file=CB04_13L 
@Update
@action id=奈緒 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=奈緒

@Talk name=奈绪 voice=NO030806
哇啊啊啊！？
@Hitret id=14138

@Talk name=心の声
就像鱼飞速从水面飞出一样，我把头抬了起来。
@Hitret id=14139

@Talk name=奈绪 voice=NO030807
啊……啊……怎、怎么了……小悠？
@Hitret id=14140

@Talk name=悠
咳……咳………没、没……没什么……突然……奈绪靠了过来……
@Hitret id=14141


@Char file=CB04_11L 

@Talk name=奈绪 voice=NO030808
呃……对不起，吓到你了吗？
@Hitret id=14142

@Talk name=悠
不……不是这样………
@Hitret id=14143


@Char file=CB04_02L 

@Talk name=奈绪 voice=NO030809
什么？　怎么了？
@Hitret id=14144

@Talk name=悠
没、没……这个……没什么大不了的……对、对了…只是吓着了………
@Hitret id=14145


@Char file=CB04_04L 

@Talk name=奈绪 voice=NO030810
哦，你在隐瞒什么？　来，和姐姐说说看？
@Hitret id=14146

@Talk name=悠
没、没什么………
@Hitret id=14147


@Update
@action id=奈緒 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=奈緒

@Talk name=奈绪 voice=NO030811
喂喂，用不着隐瞒吧？
@Hitret id=14148


@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=75 
@WaitAction id=カメラ

@Talk name=悠
哇啊啊啊！？　不、不要啊！！
@Hitret id=14149

@Talk name=心の声
奈绪从后抱住我，把体重施加在我身上。
@Hitret id=14150


@PlaySe file=SE012

@Talk name=心の声
柔软的胸部按在我身上，自认定力很强的我都要起反应了。
@Hitret id=14151

@Talk name=悠
休、休息一会吧？
@Hitret id=14152

@Talk name=奈绪 voice=NO030812
喂，想逃？　站住~！！
@Hitret id=14153


@ClearChar 

@Talk name=心の声
我松开奈绪的手，逃到了泳池边。
@Hitret id=14154

@Talk name=心の声
但是水的阻力比我预想中的大，拉不开距离。
@Hitret id=14155


@Char file=CB06_03M 

@Talk name=奈绪 voice=NO030813
想在泳池里从我手上逃脱，太天真了！
@Hitret id=14156

@Talk name=心の声
奈绪拿掉眼镜，动真格地追赶起我。
@Hitret id=14157

@Talk name=奈绪 voice=NO030814
呀！！
@Hitret id=14158


@ClearChar 
@PlaySe file=SE204

@Talk name=心の声
她迅速潜进水里，以鱼一样的速度向我接近。
@Hitret id=14159


@PlaySe file=SE201
@Char file=CB06_04L 
@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=75 
@WaitAction id=カメラ

@Talk name=奈绪 voice=NO030815
呼啊啊啊！　抓~住了☆
@Hitret id=14160

@Talk name=心の声
奈绪穿插到我前面，从正面抱住了我。
@Hitret id=14161

@Talk name=悠
！
@Hitret id=14162


@Char file=CB06_03L 

@Talk name=心の声
奈绪紧紧抱住我，让我逃不掉。
@Hitret id=14163


@PlaySe file=SE012

@Talk name=心の声
奈绪柔软的身体和接近裸体的我贴在了一起。
@Hitret id=14164


@PlaySe file=SE012

@Talk name=心の声
胸口被压得很紧，一只腿又夹进我两腿中间，让我全身都有一种难以言喻的感觉。
@Hitret id=14165

@Talk name=心の声
如果现在把奈绪甩开，我就会失去身体平衡而溺水。
@Hitret id=14166

@Talk name=心の声
奈绪只是在恶作剧………但是……我…
@Hitret id=14167

@Talk name=悠
我、我投降……奈、奈绪……
@Hitret id=14168

@Talk name=心の声
再这样下去……那就不是开玩笑了。
@Hitret id=14169


@Char file=CB06_01L 

@Talk name=奈绪 voice=NO030816
切…再多抵抗一会我也能玩得比较开心。
@Hitret id=14170


@StopBgm

@Talk name=悠
……饶了我吧………我在这可赢不了你。
@Hitret id=14171


@Char file=CB06_02L 

@Talk name=奈绪 voice=NO030817
呵呵，也是。但是，小悠总有一天也一定……
@Hitret id=14172


@Char file=CB06_11L 

@Talk name=奈绪 voice=NO030818
啊……对不起……我真是的………
@Hitret id=14173

@Talk name=心の声
奈绪这时候才终于注意到我的心情，松开了手。
@Hitret id=14174

@Talk name=奈绪 voice=NO030819
讨……讨厌……我真是的………对不起呢，小悠……
@Hitret id=14175

@Talk name=悠
啊…但是……我好像要摔倒了……最好还是能支撑我一把。
@Hitret id=14176

@Talk name=奈绪 voice=NO030820
………啊……嗯………
@Hitret id=14177

@Talk name=心の声
虽然有些害羞，但奈绪还是再一次抱住了我。
@Hitret id=14178

@Talk name=心の声
也因为刚才那恶作剧的关系，我的心脏一直在剧烈跳动。
@Hitret id=14179

@Talk name=心の声
因为我们现在是紧紧贴在一起，估计奈绪也知道了这事。
@Hitret id=14180

@Talk name=心の声
我这么动摇……不会让她觉得很怪吧……
@Hitret id=14181

@Talk name=奈绪 voice=NO030821
啊……
@Hitret id=14182

@Talk name=心の声
但是，就算我想抑制，心跳却还是不停加速。
@Hitret id=14183

@Talk name=心の声
这么近距离地感受奈绪的身体……嘴唇也轻易地就能触到……
@Hitret id=14184

@Talk name=奈绪 voice=NO030822
……能放开……了吗？
@Hitret id=14185

@Talk name=心の声
虽然一直贴着也很难为情，但真要分开了还是有些寂寞。
@Hitret id=14186

@Talk name=悠
……嗯……谢谢……
@Hitret id=14187

@Talk name=心の声
支撑着我不摔倒的奈绪慢慢从我身上离开。
@Hitret id=14188

@Talk name=心の声
隔了一层泳衣传递过来的温暖渐渐消失。
@Hitret id=14189

@Talk name=心の声
这么近距离感受着的奈绪……
@Hitret id=14190


@PlayBgm file=BGM17
@Char file=CB06_13L 
@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=75 
@WaitAction id=カメラ

@Talk name=奈绪 voice=NO030823
！！
@Hitret id=14191


@Char file=CB06_11L 

@Talk name=奈绪 voice=NO030824
…………小悠……………
@Hitret id=14192

@Talk name=心の声
奈绪正要离开，这时我搂住了她的后背，将她抱过来。
@Hitret id=14193

@Talk name=奈绪 voice=NO030825
………小悠………
@Hitret id=14194

@Talk name=心の声
奈绪一动不动地看着我。
@Hitret id=14195

@Talk name=心の声
她凝视着我，完全没有不愿意的样子。
@Hitret id=14196

@Talk name=心の声
我想更多地……感受奈绪………
@Hitret id=14197

@Talk name=心の声
总是照顾我的姐姐，奈绪。
@Hitret id=14198

@Talk name=心の声
她很可靠，总是支撑着我。
@Hitret id=14199

@Talk name=心の声
我……喜欢……这样的她。
@Hitret id=14200

@Talk name=心の声
她可能只当我是个需要照顾的弟弟。
@Hitret id=14201

@Talk name=心の声
我可能只是顺着她的温柔。
@Hitret id=14202

@Talk name=心の声
但是……就算其中有误会……我的感情也……
@Hitret id=14203

@Talk name=心の声
最后我们相互对视，谁都没有说出话来。
@Hitret id=14204


@StopBgm

@Hide
@BlackOut time=1000
@Wait time=2000 

@Change target=00_b017


