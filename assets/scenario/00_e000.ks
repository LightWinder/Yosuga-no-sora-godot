



@SetParam arg=112,5	

@PlaySe file=SE352
@Cg file=B17a   
@Update
@Wait time=3000 




@Cg file=B20a   


@PlayBgm file=BGM06

@Char file=CF05_10M 

@Talk name=亮平 voice=RH050002
呜！　这到底是什么阴谋啊！
@Hitret id=33343

@Talk name=悠
怎…怎么了？　突然的……
@Hitret id=33344

@Talk name=亮平 voice=RH050003
本来体育就是两班一起上的。那么你不觉得男女体育也一起上会更好吗？
@Hitret id=33345

@Talk name=悠
……诶？
@Hitret id=33346


@Char file=CF05_03M 

@Talk name=亮平 voice=RH050004
让我们一起愉快地流下汗水！　难得的机会为什么要分开啊？
@Hitret id=33347


@Char file=CF05_08M 

@Talk name=亮平 voice=RH050005
再加上，这是能够拜见到现在快面临绝种危机的体操服的机会……
@Hitret id=33348

@Talk name=心の声
亮平手指着操场对面的女生，大声地说着不明所以的歪理。
@Hitret id=33349

@Talk name=心の声
女生们正在一团和气的玩着垒球，叽叽喳喳的叫喊着。
@Hitret id=33350

@Talk name=心の声
相比之下男生这边，有些热血的感觉。充满着压力与紧张感。
@Hitret id=33351

@Talk name=悠
你其实只是想看而已吧？
@Hitret id=33352

@Talk name=悠
确实，一起上课的话说不定更开心一些……嗯？
@Hitret id=33353


@ClearChar 

@Talk name=心の声
女生的对面，校门方向的那一边有什么……感觉轻飘飘的……那是什么啊？
@Hitret id=33354

@Talk name=亮平 voice=RH050006
想看是当然的了！　你认为我是为了什么跑到这热死人的地方来的啊！
@Hitret id=33355

@Talk name=悠
……………………………………………………
@Hitret id=33356

@Talk name=心の声
是人吗……？　那轻飘飘的衣服是……女仆服吗？　为什么会在学校里……？
@Hitret id=33357


@Char file=CF05_01M 

@Talk name=亮平 voice=RH050007
嗯？　怎么了悠。
@Hitret id=33358

@Talk name=悠
啊……啊啊，没什么。
@Hitret id=33359

@Talk name=心の声
虽然嘴上這么说，在视线一边若隐若现的白色身影却让人在意的不行。
@Hitret id=33360


@PlaySe file=se059

@Talk name=亮平 voice=RH050008
哦哟，球到这边来了。喂，悠你快去吧。
@Hitret id=33361

@Talk name=悠
…………………………………………
@Hitret id=33362

@Talk name=亮平 voice=RH050009
…………悠？
@Hitret id=33363

@Talk name=悠
对不起，亮平。稍微拜托一下！
@Hitret id=33364


@Char file=CF05_06M 
@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=亮平 voice=RH050010
什么拜托啊！　球已经过来了哇啊啊啊！？
@Hitret id=33365


@StopBgm
@BlackOut

@Cg file=B17a   

@PlayBgm file=BGM05

@Char file=CE01_03S 

@Talk name=初佳 voice=MT050001
……唔~嗯，果然穿着这衣服进学校实在是有点……
@Hitret id=33366

@Talk name=初佳 voice=MT050002
实在是有点太扎眼了啊……要是引起骚动的话说不定也会给大小姐带来麻烦啊……
@Hitret id=33367

@Talk name=初佳 voice=MT050003
呜啊，要是在外面穿件外套来就好了啊……啊~这说不定是失败了啊~
@Hitret id=33368


@ClearChar id=初佳
@Update time=0

@Talk name=心の声
这个人，是之前来接渚同学的女仆小姐啊。
@Hitret id=33369

@Talk name=心の声
因为穿着很稀奇的衣服所以我记得也很清楚。
@Hitret id=33370


@Char file=CE01_03M 

@Talk name=悠
那个，对不起……
@Hitret id=33371


@Char file=CE01_06M 
@Update
@action id=初佳 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=初佳

@Talk name=初佳 voice=MT050004
诶……啊，是！　我、我绝对不是什么可疑的人！！该说是有点事情来这吧……
@Hitret id=33372


@Char file=CE01_03M 

@Talk name=初佳 voice=MT050005
……呃……啊……是学生啊……
@Hitret id=33373

@Talk name=初佳 voice=MT050006
哈~，太好了。
@Hitret id=33374


@Char file=CE01_01M 

@Talk name=初佳 voice=MT050007
比起这个，你现在应该在上课吧？　翘课可不行哟？
@Hitret id=33375

@Talk name=心の声
女仆小姐有點像是告誡我一般的指了我的衣服又指了指操场。
@Hitret id=33376

@Talk name=心の声
可是才刚看到了那慌张的样子，总让人觉得没什么说服力啊……
@Hitret id=33377

@Talk name=悠
话说回来，从刚才开始你到底在干什么呢？
@Hitret id=33378


@Char file=CE01_05M 

@Talk name=初佳 voice=MT050008
诶、骗人！？哪里！你从哪里开始看到的！
@Hitret id=33379

@Talk name=悠
就是从刚才开始，在校门边上隐隐约约地看见了
@Hitret id=33380


@Talk name=初佳 voice=MT050009
……觉、觉得我是可疑的人于是就过来搭话了吗？
@Hitret id=33381

@Talk name=悠
我没觉得可疑啊……你是渚同学家的女仆小姐吧？
@Hitret id=33382


@Char file=CE01_03M 

@Talk name=初佳 voice=MT050010
诶、诶诶……呀咧，我和你见过脸吗？　感觉没什么印像啊……
@Hitret id=33383

@Talk name=悠
我们之前在这里遇见时不是有说过话吗。
@Hitret id=33384


@Char file=CE01_06M 

@Talk name=初佳 voice=MT050011
诶，是这样吗！？抱歉呢，我马上就会想起来的。这之前，这之前……唔嗯……
@Hitret id=33385

@Talk name=心の声
她单手制止了我继续说下去后，另一只手的手指顶着太阳穴想着，发出唔~的声音。
@Hitret id=33386

@Talk name=悠
不、不是啦，不是这样的，之前你来接渚同学的时候……
@Hitret id=33387


@Char file=CF05_01M 

@Talk name=亮平 voice=RH050011
喂，悠！　你在这种地方干什么……啊，不是初佳小姐吗。怎么了啊？
@Hitret id=33388


@Char file=CE01_01M 

@Talk name=初佳 voice=MT050012
啊呀亮平君。我是来给大小姐送东西的，遇到悠君所以稍微聊了下。
@Hitret id=33389

@Talk name=亮平 voice=RH050012
悠，你手挺快啊。不愧是城里人，对女仆马上就有反应了啊。可别搭讪哦？
@Hitret id=33390

@Talk name=初佳 voice=MT050013
诶！？　搭讪？城里人？
@Hitret id=33391

@Talk name=悠
我也不会去搭讪啦……原来你们两人是认识的啊。
@Hitret id=33392


@Char file=CC05_02M 

@Talk name=瑛 voice=AK050002
初佳姐姐呢，是小叶家的女仆小姐哦~。
@Hitret id=33393

@Talk name=亮平 voice=RH050013
什么啊，连瑛也来了啊。
@Hitret id=33394



@Talk name=瑛 voice=AK050003
你好，初佳姐姐。刚才开始就在干什么啊？　捉迷藏吗？　感觉很有意思啊~
@Hitret id=33395

@Talk name=初佳 voice=MT050014
啊，你好，小瑛。我可没有在捉迷藏哦。
@Hitret id=33396

@Talk name=心の声
虽然微妙的无视了我的疑问，但是这个女仆的名字似乎是“初佳小姐”的样子。
@Hitret id=33397

@Talk name=心の声
亮平与天女目两人跟渚同学很亲密，所以才和她认识吧。
@Hitret id=33398


@Char file=CE01_02M 

@Talk name=初佳 voice=MT050015
那边的他呢？　是没见过的面孔呢，说他是城里人是……
@Hitret id=33399

@Talk name=初佳 voice=MT050016
啊，难道说是搬到医生家的人？
@Hitret id=33400

@Talk name=瑛 voice=AK050004
就是这样，是医生家的孙子哦。
@Hitret id=33401

@Talk name=初佳 voice=MT050017
原来如此啊，这样啊，难怪和亮平不一样这么斯文啊。
@Hitret id=33402


@Char file=CF05_06M 

@Talk name=亮平 voice=RH050014
你这什么意思啊！　难道说我很粗野吗！？
@Hitret id=33403


@Char file=CE01_04M 

@Talk name=初佳 voice=MT050018
啊哈哈，对不起对不起，是玩笑啦。
@Hitret id=33404


@ClearChar id=亮平
@ClearChar id=瑛

@Talk name=心の声
说到女仆来，给人的印像是稳重跟清纯的，可是这个人感觉该说是有些轻浮呢……
@Hitret id=33405

@Talk name=悠
我叫春日野悠，和亮平他们是同一班，经常受他们照顾。
@Hitret id=33406

@Talk name=悠
多多指教……诶，那个……
@Hitret id=33407


@Char file=CE01_02M 

@Talk name=初佳 voice=MT050019
我叫乃木坂初佳。如你所见是个女仆，这样说虽然有点丢人，但现在在渚小姐家受照顾。
@Hitret id=33408

@Talk name=初佳 voice=MT050020
这边才是请多多指教呢。
@Hitret id=33409

@Talk name=瑛 voice=AK050005
这样的话，悠君和初佳姐姐也是朋友了呢。
@Hitret id=33410


@Char file=CE01_04M 

@Talk name=初佳 voice=MT050021
呵呵，是呢。
@Hitret id=33411

@Talk name=心の声
给人的感觉就像是姐姐般稳重的笑容。
@Hitret id=33412


@Char file=CE01_01M 

@Talk name=初佳 voice=MT050022
啊，对了悠君，叫我初佳就可以了。不用那么拘谨啦。
@Hitret id=33413

@Talk name=悠
啊，是的……初佳，小姐。
@Hitret id=33414

@Talk name=心の声
直接叫年长的女性的名字，感觉让人稍微有点害羞。但是，让人感觉是个宽容的、亲切的人啊。
@Hitret id=33415

@Talk name=初佳 voice=MT050023
那么，和亮平君还有小瑛是同一班就是说，和大小姐也是同一班吧？
@Hitret id=33416

@Talk name=初佳 voice=MT050024
那么这个，能不能代我交给大小姐呢？
@Hitret id=33417

@Talk name=心の声
想当然的，我伸手拿下了递过来的包裹。
@Hitret id=33418


@Char file=CE01_03M 

@Talk name=初佳 voice=MT050025
抱歉呢，真是太谢谢了。这身衣服进学校实在太扎眼了呢。
@Hitret id=33419

@Talk name=悠
啊，哈啊。
@Hitret id=33420


@Char file=CE01_04M 

@Talk name=初佳 voice=MT050026
那拜托了呢，悠君。
@Hitret id=33421


@ClearChar 

@Talk name=心の声
初佳小姐轻快的挥了挥一只手，离开了。
@Hitret id=33422

@Talk name=悠
……这样好吗，这个。
@Hitret id=33423


@Char file=CF05_01M 
@Char file=CC05_01M 

@Talk name=亮平 voice=RH050015
没什么啦？不过是个忘记带的东西吧。要真是重要的东西，就不会拜托帮忙做家事的人来送吧。
@Hitret id=33424

@Talk name=瑛 voice=AK050006
小叶一定不会在意的啦。
@Hitret id=33425

@Talk name=悠
要是那样就好了……
@Hitret id=33426


@ClearChar 

@Talk name=心の声
……帮忙家事的人吗。
@Hitret id=33427

@Talk name=心の声
乃木坂初佳小姐。
@Hitret id=33428

@Talk name=心の声
虽然打扮成女仆的样子，但是看起来总有些显得不习惯。
@Hitret id=33429

@Talk name=心の声
本业……这么说也有点奇怪，给人感觉更像邻家的大姐姐的感觉。
@Hitret id=33430

@Talk name=心の声
亮平说的“帮忙家事的人”的说法让我感觉要更合适一些。
@Hitret id=33431


@StopBgm

@ClearChar
@Update

@Cg file=B19b   

@EyeCatch

@Change target=00_e001


