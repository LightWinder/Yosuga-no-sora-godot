



@PlayEnvSe file=SE301
@Cg file=B01a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=悠
好了…………算是搞定了吧？
@Hitret id=22865

@Talk name=心の声
我罕有地用扫把打扫了玄关，并撒了撒水。
@Hitret id=22866

@Talk name=心の声
虽然刚洒过水，空气不免是湿湿的，不过这应该能凉爽几分。
@Hitret id=22867

@Talk name=心の声
那么接下来……该干什么呢………
@Hitret id=22868


@Char file=CC01_02M 

@Talk name=瑛 voice=AK021166
你好！
@Hitret id=22869

@Talk name=悠
咦，怎么了，瑛？　今天是返校日吗？
@Hitret id=22870

@Talk name=瑛 voice=AK021167
不是，天太热了，我想去游泳池。
@Hitret id=22871

@Talk name=悠
啊，好啊！
@Hitret id=22872

@Talk name=瑛 voice=AK021168
悠君和小穹也一起来吗？　小叶也来哦~。
@Hitret id=22873

@Talk name=悠
不知道穹去不去呢，我先去问问。
@Hitret id=22874


@Char file=CD01_07M 

@Talk name=一叶 voice=KA020414
啊……啊……追上你了…………
@Hitret id=22875


@Char file=CC01_03M 

@Talk name=瑛 voice=AK021169
啊，小叶真快啊！　明明不用急啊。
@Hitret id=22876


@Char file=CD01_05M 

@Talk name=一叶 voice=KA020415
我说你啊，人家来你那玩，你却突发奇想！
@Hitret id=22877

@Talk name=悠
总，总之先进来吧。我得准备下，先喝杯茶吧。
@Hitret id=22878


@Char file=CC01_01M 

@Talk name=瑛 voice=AK021170
可以吗？　谢谢！
@Hitret id=22879

@Talk name=悠
大家一起去吗？　亮平也来吗？
@Hitret id=22880


@Char file=CD01_07M 

@Talk name=一叶 voice=KA020416
才不可能叫他来。
@Hitret id=22881

@Talk name=悠
这………这样啊………
@Hitret id=22882

@Talk name=心の声
还，还是等会偷偷给他打个电话好吧………
@Hitret id=22883



@Talk name=悠
那么，我马上去准备了。
@Hitret id=22884


@StopEnvSe id=SE301 fade=0

@Hide
@BlackOut time=1000
@Wait time=1000 
@Cg file=B12a   
@Char file=CC01_01M 
@Char file=CD01_01M 
@Update transition=universal rule=WIP_MOZTB time=500
@WaitUpdate
@PlayBgm file=BGM05

@Talk name=悠
哇……这么晒，每天上个学估计都要晒黑……
@Hitret id=22885

@Talk name=瑛 voice=AK021171
小叶真好，有太阳伞。
@Hitret id=22886

@Talk name=一叶 voice=KA020417
我不是给了你一把吗？　来，过来我这。
@Hitret id=22887

@Talk name=瑛 voice=AK021172
悠君不一起过来吗？
@Hitret id=22888

@Talk name=悠
三，三个人就太勉强了吧。
@Hitret id=22889

@Talk name=心の声
太阳当头照，晒得估计都能在路的那边看到海市蜃楼了。
@Hitret id=22890

@Talk name=心の声
在毒辣的太阳下，我们朝着学校走去。
@Hitret id=22891

@Talk name=心の声
说是反正现在是暑假，打太阳伞也没问题。渚同学撑起了她那把漂亮的黑阳伞。
@Hitret id=22892

@Talk name=悠
话说，说起太阳伞，以前印象中总觉得是白色的，现在好像黑色的多啊。
@Hitret id=22893


@Char file=CC01_02M 

@Talk name=瑛 voice=AK021173
好像说，黑色的能吸收太阳发出的电波哦。
@Hitret id=22894

@Talk name=一叶 voice=KA020418
应该是容易吸收紫外线吧？　不过最近的经过去ＵＶ加工之后，好像白色的好点。
@Hitret id=22895


@Char file=CD01_02M 

@Talk name=一叶 voice=KA020419
瑛，防晒霜涂好了吗？　就算不容易晒黑也要涂上，免得晒伤皮肤哦？
@Hitret id=22896

@Talk name=瑛 voice=AK021174
马上就要游泳了，所以没有涂哦。
@Hitret id=22897


@Char file=CD01_04M 

@Talk name=一叶 voice=KA020420
你真是的………
@Hitret id=22898

@Talk name=一叶 voice=KA020421
春日野君也是，即使是男生，也不能随随便便哦？
@Hitret id=22899

@Talk name=悠
嗯，嗯……我会注意的。
@Hitret id=22900


@Char file=CC01_14L 

@Talk name=瑛 voice=AK021175
小叶突然摆姐姐架子呢。
@Hitret id=22901


@Char file=CD01_07M 

@Talk name=一叶 voice=KA020422
我可听见了。
@Hitret id=22902


@PlaySe file=se011
@Flash color=WHITE enter=0 leave=100
@Char file=CC01_09M 
@Update
@Move id=瑛 my=40 cycle=1000
@WaitAction id=瑛

@Talk name=瑛 voice=AK021176
呜啊呜！？
@Hitret id=22903


@Char file=CD01_01M 

@Talk name=一叶 voice=KA020423
话说回来，穹身体不舒服吗？最近很热，是不是热出病了……
@Hitret id=22904

@Talk name=悠
咦？　啊，不是，应该说她经常这样吧……
@Hitret id=22905

@Talk name=悠
１．游泳太麻烦。２．太热了不想出门。３．走回来太麻烦。你觉得是哪个？
@Hitret id=22906


@Char file=CC01_03M 
@Update
@Move id=瑛 y=0 cycle=1000
@WaitAction id=瑛

@Talk name=瑛 voice=AK021177
第４个！　因为小叶太可怕！
@Hitret id=22907


@Char file=CD01_12M 

@Talk name=一叶 voice=KA020424
真，真失礼啊！　我可从来没这么使坏过！
@Hitret id=22908

@Talk name=悠
三个都是答案。因为最近实在太热了。她一直就抱着风扇在哪吹，我都担心那风扇要坏掉了。
@Hitret id=22909


@Char file=CD01_04M 

@Talk name=一叶 voice=KA020425
不过，这也可能是疲劳的原因哦。
@Hitret id=22910


@Char file=CC01_02M 

@Talk name=瑛 voice=AK021178
啊，这样的话，下次我给小穹做斗志料理好了。
@Hitret id=22911

@Talk name=悠
谢谢啊，这可帮大忙了。
@Hitret id=22912

@Talk name=一叶 voice=KA020426
你和春日野君都受得了啊。我就受不了热。
@Hitret id=22913

@Talk name=瑛 voice=AK021179
是吗？　我最喜欢雪糕了，所以最喜欢夏天哦！
@Hitret id=22914


@Char file=CD01_03M 

@Talk name=一叶 voice=KA020427
说什么啊，冬天你不也一样吃吗。
@Hitret id=22915


@StopBgm

@ClearChar
@Update

@Cg file=B21a   

@EyeCatch  


@Talk name=悠
………啊，看到了。奈绪！！
@Hitret id=22916


@PlayBgm file=BGM06
@Char file=CB04_02M 

@Talk name=奈绪 voice=NO020131
真稀罕，小悠会来我这啊。
@Hitret id=22917

@Talk name=悠
因为天气太热，她们说要去游泳池。
@Hitret id=22918

@Talk name=奈绪 voice=NO020132
是啊，这天气真是热死人了。今天没有其他人，你们随便玩吧。
@Hitret id=22919

@Talk name=悠
谢谢啊，奈绪。
@Hitret id=22920

@Talk name=瑛 voice=AK021180
啊，奈绪姐姐！
@Hitret id=22921

@Talk name=一叶 voice=KA020428
喂！　在这别跑，危险啊？
@Hitret id=22922


@Char file=CC04_02M 
@Char file=CD04_01M 

@Talk name=奈绪 voice=NO020133
欢迎，尽情玩吧。
@Hitret id=22923

@Talk name=一叶 voice=KA020429
抱歉，我们突然跑来打扰。
@Hitret id=22924


@Char file=CB04_01M 

@Talk name=奈绪 voice=NO020134
没事，反正我也闲着。
@Hitret id=22925


@Char file=CC04_04M 

@Talk name=瑛 voice=AK021181
那么就马上下水吧！　而且我都出汗了，快点，快点！
@Hitret id=22926


@Char file=CD04_07M 

@Talk name=一叶 voice=KA020430
不行，先做准备运动。
@Hitret id=22927


@Char file=CC04_06M 

@Talk name=瑛 voice=AK021182
切………
@Hitret id=22928


@ClearChar 
@Char file=CB04_02M 

@Talk name=奈绪 voice=NO020135
我也来游游泳吧，难得大家都来了。
@Hitret id=22929


@Char file=CB06_01M 

@Talk name=心の声
奈绪摘下眼镜，和我们一起做起准备运动来。
@Hitret id=22930


@Char file=CC04_04M 

@Talk name=瑛 voice=AK021183
好，做完了！　看招！！！
@Hitret id=22931


@ClearChar id=瑛
@PlaySe file=SE204
@Char file=CD04_04M 

@Talk name=一叶 voice=KA020431
啊啊，瑛真是的。
@Hitret id=22932

@Talk name=瑛 voice=AK021184
凉凉的很舒服哦！　快来嘛！
@Hitret id=22933


@Char file=CB06_03M 

@Talk name=奈绪 voice=NO020136
那么我也来……看招！！
@Hitret id=22934


@ClearChar id=奈緒
@Update
@PlaySe file=SE204
@WaitSe
@PlaySe file=SE202

@Talk name=心の声
看奈绪干劲十足的跳入水中，然后突然游了25米出去。
@Hitret id=22935

@Talk name=悠
渚同学也去游泳吧。我就随便凉快下。
@Hitret id=22936


@Char file=CD04_02M 

@Talk name=一叶 voice=KA020432
来，给你这个，春日野君。
@Hitret id=22937

@Talk name=心の声
说着突然把一对蓝色的板状物塞到我跟前。
@Hitret id=22938

@Talk name=悠
咦？　游泳板？
@Hitret id=22939

@Talk name=一叶 voice=KA020433
难得来了，就练习下游泳如何？反正没有外人，用不着害羞哦。
@Hitret id=22940

@Talk name=悠
嗯，嗯………
@Hitret id=22941

@Talk name=心の声
在泳池比较浅的地方，我还能勉强站得住。不过当我想到还要从那里往更深的地方游时，单单站在在那就觉得就变得憋气了。
@Hitret id=22942

@Talk name=心の声
不过渚同学这么说也是出于好意，或许努力试试也好。
@Hitret id=22943

@Talk name=一叶 voice=KA020434
我们也陪你练，加油！　能大家一起玩才开心呢，所以，请拿出勇气来。
@Hitret id=22944

@Talk name=悠
好的……我试试看。
@Hitret id=22945


@StopBgm fade=0

@Talk name=亮平 voice=RH020429
………你是什么时候开始对她言听计从的啊？
@Hitret id=22946


@PlayBgm file=BGM13
@Char file=CD04_12M 
@Update
@action id=一葉 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=一葉

@Talk name=一叶 voice=KA020435
咦！？
@Hitret id=22947


@Char file=CF04_03M 

@Talk name=亮平 voice=RH020430
这么有趣的事，不叫上我就开始了，真不够义气啊。
@Hitret id=22948

@Talk name=一叶 voice=KA020436
呃！？　中里前辈，你怎么在这？
@Hitret id=22949

@Talk name=亮平 voice=RH020431
有个有良心的人向我密告了。他恳求我说：请务必要来！　
@Hitret id=22950

@Talk name=一叶 voice=KA020437
难道是瑛？
@Hitret id=22951


@Char file=CC04_02M 

@Talk name=瑛 voice=AK021185
啊！　亮哥哥！　你来了啊！　我本来想叫上你的啊，但是小叶说不行。
@Hitret id=22952


@Char file=CD04_06M 
@Update
@action id=一葉 action=ActionAdvHop width=35 height=2 cycle=150 count=2
@WaitAction id=一葉
@Font face=36

@Talk name=一叶 voice=KA020438
瑛！！！
@Hitret id=22953


@ClearChar id=瑛
@Char file=CF04_05M 

@Talk name=亮平 voice=RH020432
哦？
@Hitret id=22954


@Char file=CD04_11M 

@Talk name=一叶 voice=KA020439
我，我不知道你在说什么……
@Hitret id=22955

@Talk name=心の声
对不起，渚同学，是我报了信………
@Hitret id=22956

@Talk name=亮平 voice=RH020433
这个嘛，难得来了，我就好好地慢慢地，审问你的身体好了？
@Hitret id=22957


@Char file=CD04_13M 
@Update
@action id=一葉 action=ActionAdvHop width=35 height=2 cycle=150 count=2
@WaitAction id=一葉

@Talk name=一叶 voice=KA020440
啊！？　你，你别过来！！
@Hitret id=22958


@Char file=CF04_04M 

@Talk name=亮平 voice=RH020434
给我站住！！
@Hitret id=22959

@Talk name=一叶 voice=KA020441
我不要！！
@Hitret id=22960

@Talk name=心の声
渚同学把手上拿着的游泳板朝亮平扔了过去。
@Hitret id=22961


@PlaySe file=se008
@Char file=CF04_06M 
@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=亮平 voice=RH020435
呃！？
@Hitret id=22962


@ClearChar id=亮平
@PlaySe file=SE204
@Char file=CD04_05M 

@Talk name=一叶 voice=KA020442
啊，啊………啊………
@Hitret id=22963


@Char file=CB06_13M 

@Talk name=奈绪 voice=NO020137
哇！？　什，什什什，什么！？
@Hitret id=22964

@Talk name=心の声
亮平刚好在奈绪转身游回来的时候沉了下去。
@Hitret id=22965

@Talk name=悠
你没事吧，亮平？
@Hitret id=22966

@Talk name=亮平 voice=RH020436
后事………拜托了………邀请我来，真的很高兴，悠……呃………………
@Hitret id=22967

@Talk name=悠
亮平ーーー！！
@Hitret id=22968

@Talk name=心の声
紧握的拳头只竖起一根大拇指，亮平就这样沉入水中。
@Hitret id=22969


@Char file=CB06_08M 

@Talk name=奈绪 voice=NO020138
真是的，又来了个吵吵闹闹的。你就这样沉下去别浮起来了！
@Hitret id=22970

@Talk name=心の声
就像是要结果了亮平一样，奈绪把手上拿着的塑料瓶朝他扔了过去。
@Hitret id=22971


@PlaySe file=SE204
@StopBgm

@Talk name=悠
真……真过分………
@Hitret id=22972


@PlayBgm file=BGM14
@Char file=CD04_06M 

@Talk name=一叶 voice=KA020443
把这家伙叫来的是春日野君吧？
@Hitret id=22973

@Talk name=悠
啊！？　对，对不起！！　人家是我朋友嘛，不叫上他有点过意不去………
@Hitret id=22974

@Talk name=一叶 voice=KA020444
就因为会变成这样，我才不想叫他来！！
@Hitret id=22975


@ClearChar 
@Char file=CC04_02L 

@Talk name=瑛 voice=AK021186
悠君我们逃吧！！
@Hitret id=22976

@Talk name=悠
咦！？
@Hitret id=22977

@Talk name=瑛 voice=AK021187
对不起啊，小叶，是我拜托悠君报信的~！
@Hitret id=22978


@ClearChar 
@Char file=CD04_07M 

@Talk name=一叶 voice=KA020445
啊，瑛！！
@Hitret id=22979

@Talk name=心の声
我们手牵手沿着泳池边逃走了。
@Hitret id=22980


@Char file=CD04_05M 

@Talk name=一叶 voice=KA020446
给我站住！！
@Hitret id=22981


@ClearChar 

@Talk name=心の声
不过，渚同学气势汹汹地从后面追来。
@Hitret id=22982


@Char file=CC04_14M 

@Talk name=瑛 voice=AK021188
啊哈，小叶好快啊。好！　悠君，抓好我！
@Hitret id=22983

@Talk name=悠
咦！？
@Hitret id=22984


@BlackOut

@Talk name=心の声
还没反应过来就被瑛拉着，跳进了泳池中。
@Hitret id=22985


@PlaySe file=SE204

@Talk name=悠
哇啊！？　啊，啊哇哇哇哇哇哇哇！！！
@Hitret id=22986

@Talk name=心の声
一急起来，我闭上眼睛和嘴边也就算了，可是我和瑛却开始往下沉。
@Hitret id=22987

@Talk name=心の声
四周混杂着咕噜咕噜的泡泡声，我无所适从地缩成了一团。
@Hitret id=22988


@Cg file=B21a   
@Update transition=universal rule=WIP_BT time=500
@WaitUpdate

@Talk name=心の声
不过，感觉突然一下子浮了起来，我的头也伸出了水面。
@Hitret id=22989

@Talk name=瑛 voice=AK021189
悠君，抓住这个！
@Hitret id=22990

@Talk name=心の声
我拼命地抓住眼前的这个游泳板。
@Hitret id=22991

@Talk name=瑛 voice=AK021190
快游~！
@Hitret id=22992

@Talk name=心の声
我就想刚开始学游泳的小孩子一样，笨拙地用脚拼命地踢着水。
@Hitret id=22993


@Char file=CD04_06S 

@Talk name=一叶 voice=KA020447
你们两个！　给我站住！
@Hitret id=22994

@Talk name=心の声
泳池边传来渚同学生气的声音，而我已经无暇顾及这个。
@Hitret id=22995

@Talk name=瑛 voice=AK021191
啊哈哈，悠君，游得很好啊！
@Hitret id=22996

@Talk name=心の声
同样用脚踢着水的瑛跟了过来，为了不让我溺水而撑着我。
@Hitret id=22997

@Talk name=心の声
为了不让渚同学追上，我们一直游到了泳池的正中间。
@Hitret id=22998

@Talk name=悠
到，到这里应该就没问题了吧？
@Hitret id=22999


@Char file=CD04_12S 

@Talk name=一叶 voice=KA020448
喂，喂，太危险了吧？　春日野君还不会游泳吧？
@Hitret id=23000


@ClearChar 
@Char file=CC04_14L 

@Talk name=瑛 voice=AK021192
啊，对了。
@Hitret id=23001

@Talk name=悠
咦！？　怎，怎么这样！！
@Hitret id=23002

@Talk name=心の声
瑛毫不负责地笑了笑。
@Hitret id=23003


@Char file=CC04_02L 

@Talk name=瑛 voice=AK021193
我开玩笑的☆
@Hitret id=23004


@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=悠
！！！！！！
@Hitret id=23005


@ClearChar 
@PlaySe file=SE201

@Talk name=心の声
就在这时，我大腿中间突然有什么东西伸了进来。然后一股强大的力量把我往上推。
@Hitret id=23006

@Talk name=悠
咦，什，什么！？
@Hitret id=23007


@Char file=CF04_03L 

@Talk name=亮平 voice=RH020437
哼，哼哼………让你久等了悠！！
@Hitret id=23008

@Talk name=悠
！！！　亮平！！　你还活着啊？
@Hitret id=23009

@Talk name=亮平 voice=RH020438
奈绪的瓶子扔得还真疼啊……挚友有难前来相助了哦！
@Hitret id=23010

@Talk name=心の声
亮平把我搭在他肩膀上，慢慢地举了起来。视野突然升高了，我慌慌张张地抓住了亮平的头。
@Hitret id=23011

@Talk name=悠
哇，哇啊……你不要紧？　不重吗？
@Hitret id=23012


@Char file=CF04_02L 

@Talk name=亮平 voice=RH020439
这点程度没事！　哦……慢慢来慢慢来！
@Hitret id=23013

@Talk name=心の声
亮平就这样搭着我，朝着渚同学所在的反方向的泳池边缘走去。
@Hitret id=23014


@ClearChar 
@Char file=CC04_04M 

@Talk name=瑛 voice=AK021194
真帅啊，我也要背背！
@Hitret id=23015


@Char file=CF04_05M 

@Talk name=亮平 voice=RH020440
啊，瑛也要吗？　要和我一起吗？
@Hitret id=23016

@Talk name=瑛 voice=AK021195
嗯，我要我要！！
@Hitret id=23017


@ClearChar 
@Char file=CD04_06M 
@PauseBgm

@Talk name=一叶 voice=KA020449
你打算干什么啊？
@Hitret id=23018


@RestartBgm
@Char file=CF04_06M 

@Talk name=亮平 voice=RH020441
呜啊！？　你什么时候绕到我们这边来了！？
@Hitret id=23019


@Char file=CB06_06M 

@Talk name=奈绪 voice=NO020139
你走这么慢，人家肯定绕得过去啦。
@Hitret id=23020

@Talk name=一叶 voice=KA020450
瑛！　春日野君！　做好心理准备没有？
@Hitret id=23021

@Talk name=悠
呜………
@Hitret id=23022


@ClearChar 
@Char file=CC04_14M 

@Talk name=瑛 voice=AK021196
喵~☆
@Hitret id=23023


@Char file=CD04_06M 

@Talk name=一叶 voice=KA020451
装可爱也没用！！　给我觉悟吧！
@Hitret id=23024


@PlaySe file=se006
@ClearChar 
@Char file=CF04_10L 
@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=亮平 voice=RH020442
喂，为什么是我啊！？　啊啊啊啊啊！？
@Hitret id=23025


@ClearChar id=亮平
@PlaySe file=se011
@Flash color=WHITE enter=0 leave=100
@Char file=CC04_09M 
@Update time=0
@Update
@Move id=瑛 my=650 cycle=1000
@WaitAction id=瑛

@Talk name=瑛 voice=AK021197
喵——！！！
@Hitret id=23026


@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=150 
@WaitAction id=カメラ
@PlaySe file=SE204

@Talk name=悠
！！！！
@Hitret id=23027


@ClearChar 

@Talk name=心の声
渚同学愤怒的一脚踢到了亮平，失去平衡的我把瑛也一起扯进了水里。
@Hitret id=23028


@ClearChar
@Update

@Cg file=B21a   
@EyeCatch  

@Talk name=瑛 voice=AK021198
啊，恢复意识了吗？
@Hitret id=23029


@PlayBgm file=BGM03
@Char file=CC04_02L 

@Talk name=悠
？　啊……嗯………咦？　我好像………
@Hitret id=23030

@Talk name=瑛 voice=AK021199
由于小叶的原因，悠君反身掉进泳池里溺水了，晕倒了一会儿。
@Hitret id=23031

@Talk name=悠
是，是这样啊………
@Hitret id=23032

@Talk name=心の声
亮平被踢翻的时候，我最后看到的景色是蔚蓝的天空和耀眼的太阳。
@Hitret id=23033

@Talk name=悠
咦？
@Hitret id=23034

@Talk name=心の声
我才发现，原来我正枕这瑛的膝盖躺着。
@Hitret id=23035

@Talk name=悠
啊……谢谢……我，我已经没事了。
@Hitret id=23036

@Talk name=瑛 voice=AK021200
不是啊，难得有这机会，再稍微享受一下如何？
@Hitret id=23037

@Talk name=悠
咦………嗯………
@Hitret id=23038

@Talk name=心の声
我把脸靠在她光滑的大腿上。瑛一边觉得痒痒的，一边抚摸着我的头发。
@Hitret id=23039


@Char file=CC04_11L 

@Talk name=瑛 voice=AK021201
啊……悠君……这样很痒。
@Hitret id=23040

@Talk name=悠
啊，对不起……不过，这滑溜溜的感觉很舒服。
@Hitret id=23041

@Talk name=瑛 voice=AK021202
嗯……是吗？　啊……不行……
@Hitret id=23042

@Talk name=瑛 voice=AK021203
嗯………刚，刚好，来帮你淘淘耳朵好吗？
@Hitret id=23043

@Talk name=悠
不，不用，这个就算了……暂时让我就这样躺着就好。
@Hitret id=23044

@Talk name=心の声
还是第一次有这种待遇，害我的心一直怦怦地跳。柔软的大腿很舒适，如果闭上眼睛的话，估计很快就又会睡着了。
@Hitret id=23045


@Char file=CC04_02L 

@Talk name=瑛 voice=AK021204
真是有趣啊……刚才。
@Hitret id=23046

@Talk name=悠
嗯……自从上次去海边玩，就没闹过这么欢了。
@Hitret id=23047

@Talk name=瑛 voice=AK021205
悠君，刚才游得不错哦。照这样练习的话，很快就可以和我们一起游泳了。
@Hitret id=23048

@Talk name=悠
是吗？　那么我可就得加油了。
@Hitret id=23049


@Char file=CC04_03L 

@Talk name=瑛 voice=AK021206
追着玩也蛮好玩的，希望以后还有这样的机会。
@Hitret id=23050

@Talk name=悠
被渚同学追的话，我可就免了。
@Hitret id=23051


@Char file=CC04_02L 

@Talk name=瑛 voice=AK021207
啊哈哈，是啊。
@Hitret id=23052

@Talk name=悠
……瑛，不觉得重吗？　会不会把你的腿压麻了？
@Hitret id=23053

@Talk name=瑛 voice=AK021208
不会，我没事。要是腿麻了的话，就换我枕这悠君的膝盖休息好了。
@Hitret id=23054

@Talk name=悠
嗯，可以啊。瑛很轻，应该何时何地都行。
@Hitret id=23055

@Talk name=瑛 voice=AK021209
呵呵，那么就现在开始好吗？
@Hitret id=23056


@StopBgm

@Talk name=一叶 voice=KA020452
不行。
@Hitret id=23057


@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=悠
咦！？
@Hitret id=23058


@ClearChar 

@Talk name=心の声
我慌忙跳了起来。
@Hitret id=23059

@Talk name=心の声
对了，今天大家都来了游泳池！！！！
@Hitret id=23060


@PlayBgm file=BGM05
@Char file=CF04_06M 

@Talk name=亮平 voice=RH020443
你……你们…………什么时候开始……
@Hitret id=23061


@Char file=CD04_07M 

@Talk name=一叶 voice=KA020453
真是一不留神就又粘一块去了………
@Hitret id=23062


@Char file=CB04_13M 

@Talk name=奈绪 voice=NO020140
我，我还不知道啊…………
@Hitret id=23063

@Talk name=悠
咦！？　你，你们都看到了？
@Hitret id=23064


@Char file=CF04_10M 

@Talk name=亮平 voice=RH020444
我明明还以为悠只是在气氛上受欢迎，不是会做错这种事的家伙……
@Hitret id=23065


@Char file=CD04_04M 

@Talk name=一叶 voice=KA020454
行，行动前你们也要稍微注意下周围啊！
@Hitret id=23066

@Talk name=奈绪 voice=NO020141
真令人惊讶………
@Hitret id=23067

@Talk name=悠
不，不是………这，这是………啊，瑛？
@Hitret id=23068


@ClearChar 
@Char file=CC04_14M 

@Talk name=瑛 voice=AK021210
啊哈！　穿帮了？
@Hitret id=23069

@Talk name=悠
………我说，这，这样好吗！？
@Hitret id=23070


@ClearChar 
@Char file=CF04_01M 

@Talk name=亮平 voice=RH020445
你先冷静下来，悠。具体什么回事慢慢说就好。
@Hitret id=23071


@Char file=CB04_13M 

@Talk name=奈绪 voice=NO020142
总，总之，是要恭喜你吧，小悠？
@Hitret id=23072

@Talk name=悠
这，这别问我啊。
@Hitret id=23073


@Char file=CD04_04M 

@Talk name=一叶 voice=KA020455
…………笨蛋…………
@Hitret id=23074



@Hide
@BlackOut time=1000
@Wait time=2000 
@PlayBgm file=BGM07

@Cg file=EZ01b

@Char file=CB10_01L x=156 y=-80 order=950
@Char file=CC10_01L x=-240 y=85 order=940
@Char file=CD10_01L x=-414 y=62 order=930
@Char file=CF10_01L x=-64 y=-70 order=920
@Update transition=universal rule=WIP_RL time=500
	@action id=奈緒 action=ActionAdvWave width=0 height=6 cycle=1500 count=-1
	@action id=瑛 action=ActionAdvWave width=0 height=3 cycle=1000 count=-1
	@action id=一葉 action=ActionAdvWave width=0 height=3 cycle=1500 count=-1
	@action id=亮平 action=ActionAdvWave width=0 height=2 cycle=1300 count=-1

@BgScroll file=EZ01b mx=800 my=0 cycle=80000

@Talk name=亮平 voice=RH020446
不是啦，话说回来这确实让人吃惊啊！
@Hitret id=23075

@Talk name=奈绪 voice=NO020143
什么时候开始的啊？
@Hitret id=23076

@Talk name=瑛 voice=AK021211
是最近吧。
@Hitret id=23077

@Talk name=悠
……………………………………
@Hitret id=23078

@Talk name=心の声
咦，明明是我和瑛交往的事，为啥撇开我，他们自己就热闹起来了。
@Hitret id=23079

@Talk name=亮平 voice=RH020447
真见外啊。瑛，我不是叫你要首先跟我商量的吗？
@Hitret id=23080

@Talk name=瑛 voice=AK021212
对不起啊，亮哥哥。
@Hitret id=23081


@Char file=CD10_02L
@update
	@action id=一葉 action=ActionAdvWave width=0 height=3 cycle=1500 count=-1

@Talk name=一叶 voice=KA020456
你哪有说过这种话。
@Hitret id=23082

@Talk name=奈绪 voice=NO020144
不过他们两个也真可爱。渚同学也这么觉得吧？
@Hitret id=23083

@Talk name=一叶 voice=KA020457
咦，咦？　是，是这样吗？
@Hitret id=23084

@Talk name=奈绪 voice=NO020145
小瑛被人抢走了，不甘心吧？
@Hitret id=23085

@Talk name=一叶 voice=KA020458
才，才没有那回事…………
@Hitret id=23086

@Talk name=亮平 voice=RH020448
大小姐…你伤心的话就让我……
@Hitret id=23087

@Talk name=一叶 voice=KA020459
不要！
@Hitret id=23088

@Talk name=亮平 voice=RH020449
不是啦。我是想告诉那些暗恋大小姐的人说，大小姐和瑛已经分开，现在已经是自由身了，这样你就能向他们寻求安慰了嘛……
@Hitret id=23089

@Talk name=一叶 voice=KA020460
更加不要！！
@Hitret id=23090

@Talk name=悠
……………………………………
@Hitret id=23091

@Talk name=心の声
估计这一阵子，都会被这么逗着玩吧……
@Hitret id=23092

@Talk name=心の声
倒是处于事件中心的瑛却一副平常没事的样子，在那笑着。
@Hitret id=23093

@Talk name=心の声
反正这事也是总有一天要说的，虽然以这种方式穿帮了，不过大家都没有恶意，应该这样就算很好了吧。
@Hitret id=23094

@Talk name=亮平 voice=RH020450
悠！　快过来！　让你也来加入话题。
@Hitret id=23095

@Talk name=悠
不，不用了……我就在这………
@Hitret id=23096

@Talk name=亮平 voice=RH020451
喂，喂，别闹别扭啦。不过是交了个女朋友，男人之间的友情可不会就这么消失了吧。
@Hitret id=23097

@Talk name=悠
亮平………
@Hitret id=23098

@Talk name=亮平 voice=RH020452
这段时间又有话题可以讨论了。
@Hitret id=23099

@Talk name=悠
呜呜呜………………
@Hitret id=23100


@Cg file=B12b   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@Char file=CF01_01M 

@Talk name=亮平 voice=RH020453
好了，我就到此了。大家再见！
@Hitret id=23101


@Char file=CC01_02M 

@Talk name=瑛 voice=AK021213
亮哥哥，以后再一起玩哦！
@Hitret id=23102


@Char file=CD01_07M 

@Talk name=一叶 voice=KA020461
暑假结束前我可都不想再见到他了。
@Hitret id=23103


@ClearChar 
@Char file=CF01_02L 

@Talk name=亮平 voice=RH020454
悠，不错嘛。
@Hitret id=23104

@Talk name=心の声
亮平搂着我的肩膀，在耳边轻声说到。
@Hitret id=23105

@Talk name=悠
亮平………
@Hitret id=23106


@Char file=CF01_01L 

@Talk name=亮平 voice=RH020455
你的话，应该没问题。你可是我看中的男人。别让我失望了哦？
@Hitret id=23107

@Talk name=悠
嗯。
@Hitret id=23108


@Char file=CF01_01M 

@Talk name=亮平 voice=RH020456
那么，过几天再一起玩吧！　要是不叫上我的话，可就会像今天这样哦，大小姐？
@Hitret id=23109


@Char file=CD01_07M 

@Talk name=一叶 voice=KA020462
下次我们出远门，好让你追不上。
@Hitret id=23110


@Char file=CF01_05M 

@Talk name=亮平 voice=RH020457
你可别以为线人只有这两个哦？
@Hitret id=23111


@Char file=CD01_12M 
@Update
@action id=一葉 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=一葉

@Talk name=一叶 voice=KA020463
什么！？
@Hitret id=23112


@Char file=CF01_04M 

@Talk name=亮平 voice=RH020458
再见啦！！
@Hitret id=23113


@ClearChar id=亮平
@Char file=CB01_06M 

@Talk name=奈绪 voice=NO020146
真是的，吵闹的家伙。
@Hitret id=23114


@ClearChar 
@Char file=CC01_02M 

@Talk name=瑛 voice=AK021214
那么悠君，再见啦。
@Hitret id=23115


@Char file=CD01_02M 

@Talk name=一叶 voice=KA020464
我也失陪了。
@Hitret id=23116

@Talk name=悠
今天我也很开心，有很多事都要多谢你们了。
@Hitret id=23117

@Talk name=瑛 voice=AK021215
啊哈是啊！
@Hitret id=23118


@Char file=CD01_04M 

@Talk name=一叶 voice=KA020465
我，偶然还是想一个人享受下清净。那么就，再见。
@Hitret id=23119


@Char file=CC01_04M 

@Talk name=瑛 voice=AK021216
再见！
@Hitret id=23120


@ClearChar 
@Char file=CB01_01M 

@Talk name=奈绪 voice=NO020147
那么，我们也回去吧。
@Hitret id=23121

@Talk name=悠
嗯。
@Hitret id=23122



@Hide
@BlackOut time=1000
@Wait time=1500 
@Cg file=B01b   
@Char file=CB01_01M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=奈绪 voice=NO020148
我说……你们的事对小穹说了吗？
@Hitret id=23123

@Talk name=悠
……………还没有。
@Hitret id=23124


@Char file=CB01_02M 

@Talk name=奈绪 voice=NO020149
啊……把最难办的留到了最后啊。
@Hitret id=23125

@Talk name=悠
不过，瑛的话，穹也会接受的。
@Hitret id=23126


@Char file=CB01_05M 

@Talk name=奈绪 voice=NO020150
…………是啊……………
@Hitret id=23127

@Talk name=悠
嗯？　怎么了？
@Hitret id=23128


@Char file=CB01_01M 

@Talk name=奈绪 voice=NO020151
不，没事………没什么………
@Hitret id=23129

@Talk name=奈绪 voice=NO020152
小悠也在绽放青春啊。
@Hitret id=23130

@Talk name=悠
是，是吗…………
@Hitret id=23131


@Char file=CB01_02M 

@Talk name=奈绪 voice=NO020153
好好干……我支持你。
@Hitret id=23132

@Talk name=悠
谢谢你，奈绪。
@Hitret id=23133


@Char file=CB01_05M 

@Talk name=奈绪 voice=NO020154
…………真羡慕啊………
@Hitret id=23134

@Talk name=悠
咦……………
@Hitret id=23135


@Char file=CB01_01M 

@Talk name=奈绪 voice=NO020155
没事………自言自语而已。
@Hitret id=23136

@Talk name=悠
？
@Hitret id=23137

@Talk name=奈绪 voice=NO020156
那么，我就到此了。
@Hitret id=23138

@Talk name=悠
嗯，今天这么多人来打扰了，抱歉啊。
@Hitret id=23139


@Char file=CB01_03M 

@Talk name=奈绪 voice=NO020157
没事，蛮开心的。而且还能听到这么有趣的事。
@Hitret id=23140

@Talk name=悠
别，别这样嘛………人家真的很不好意思。
@Hitret id=23141

@Talk name=奈绪 voice=NO020158
抱歉抱歉！　那么再见吧！
@Hitret id=23142


@ClearChar 

@Talk name=心の声
奈绪回去的路上回头了数遍。
@Hitret id=23143

@Talk name=心の声
不过，好像稍微有点消沉的样子，是我看错了吗？
@Hitret id=23144

@Talk name=心の声
是因为我们闹过头了吗………
@Hitret id=23145

@Talk name=心の声
话说回来，我也是累了。
@Hitret id=23146

@Talk name=心の声
不过，要是瑛再让我枕着她大腿躺一躺的话，我想这点疲劳很快就会消失掉的。
@Hitret id=23147

@Talk name=心の声
脸颊上还有一点痒痒的感觉，用手摸了摸，马上又微热起来。
@Hitret id=23148


@StopBgm
@EyeCatch type=DATE 

@Change target=00_c022


