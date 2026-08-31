


@PlaySe file=SE356

@Cg file=B27a   
@PlayBgm file=BGM06

@Talk name=心の声
今天是祭典的日子。
@Hitret id=35026

@Talk name=心の声
天女目说要去做事的，其实只是单纯的帮忙而已。
@Hitret id=35027

@Talk name=心の声
也不是只有天女目一个人，镇上的那边也来了好几个宫司和巫女，看来是要举行相当规模的祭典。
@Hitret id=35028

@Talk name=心の声
说起这之前的祭典，也就是到晚上去参拜或者逛逛夜店什么的而已，所以从准备开始看还是觉得稍微有意思的。
@Hitret id=35029


@Cg file=B34a center=800,300
@Char file=CA03_01M 

@Talk name=穹 voice=SR050062
……为什么连我也……
@Hitret id=35030

@Talk name=悠
不要这么说嘛。祭典什么的很久都没参与了吧？　不高兴下怎么行呢。
@Hitret id=35031

@Talk name=心の声
在向神社的路上，看着四处都被装饰着，自己的情绪也逐渐高昂起来。
@Hitret id=35032

@Talk name=穹 voice=SR050063
……像小孩一样。
@Hitret id=35033


@Char file=CF03_01M 
@Char file=CA03_13M 

@Talk name=亮平 voice=RH050107
你说什么！？
@Hitret id=35034

@Talk name=穹 voice=SR050064
呀啊。
@Hitret id=35035

@Talk name=悠
唔哇……亮，亮平……！？
@Hitret id=35036


@Char file=CF03_03M 

@Talk name=亮平 voice=RH050108
哇啊，今天的小穹也是特别的可爱啊！
@Hitret id=35037


@Char file=CA03_08M 

@Talk name=穹 voice=SR050065
咦……
@Hitret id=35038

@Talk name=亮平 voice=RH050109
轻飘飘的褶边很适合你哦。大哥哥我想抱着你都……唔哇哇！！
@Hitret id=35039


@PlaySe file=se006
@Update
@action id=亮平 action=ActionAdvHop width=35 height=2 cycle=150 count=2
@WaitAction id=亮平
@Update

@Update
@Move id=亮平 my=800 cycle=1200
@WaitAction id=亮平
@Update

@PlaySe file=se018

@Talk name=心の声
亮平就保持着那个动作，然后直接摔到了地面上。
@Hitret id=35040

@Talk name=心の声
登场突然，退场也跟着突然吧。
@Hitret id=35041


@ClearChar id=亮平
@Char file=CB03_01M x=-200 
@Char file=CA03_08M x=200 

@Talk name=奈绪 voice=NO050042
真是的，一没注意就这个样子。小穹，没事吧？
@Hitret id=35042

@Talk name=穹 voice=SR050066
唔，唔嗯……
@Hitret id=35043

@Talk name=悠
谢谢了，奈绪。奈绪也是要去天女目那里么？
@Hitret id=35044

@Talk name=奈绪 voice=NO050043
也算吧。顺便一说这个也是。
@Hitret id=35045

@Talk name=心の声
奈绪说着“这个”时，用脚尖戳了戳倒在地上的亮平。
@Hitret id=35046

@Talk name=心の声
虽然觉得有些残忍，不过用那种方法吓人的话有点惩罚也是应该的。
@Hitret id=35047

@Talk name=心の声
被戳着的亮平，受刺激后慢慢爬了起来。
@Hitret id=35048


@ClearChar 

@Char file=CF03_04M 

@Talk name=亮平 voice=RH050110
呵呵……在救出公主大人之前，有邪恶的魔女阻碍是约定俗成的啊……
@Hitret id=35049

@Talk name=悠
说这种奇怪的话，是因为打到了头吗……
@Hitret id=35050


@ClearChar 
@Char file=CA03_04M 
@Char file=CB03_01M 

@Talk name=穹 voice=SR050067
……好恶心。
@Hitret id=35051

@Talk name=奈绪 voice=NO050044
真是个笨蛋。在一起的话说不定会被笨蛋感染，我们先去神社吧。
@Hitret id=35052

@Talk name=悠
也是呢，天女目也等着呢。
@Hitret id=35053


@ClearChar id=奈緒
@Char file=CF03_01M 

@Talk name=亮平 voice=RH050111
顺便一提我和悠是杂用。主要是担当力量型工作。
@Hitret id=35054


@Char file=CF03_03M 

@Talk name=亮平 voice=RH050112
详细的情况等到了再说吧，穹是我的秘书兼恋人吧？
@Hitret id=35055

@Talk name=穹 voice=SR050068
回去了。
@Hitret id=35056

@Talk name=悠
也好。
@Hitret id=35057


@Char file=CF03_06M 

@Talk name=亮平 voice=RH050113
玩笑！　这是玩笑啦所以别回去！　我说悠你也干吗也一起这样啊！
@Hitret id=35058

@Talk name=悠
因为打从心底觉得你很无聊。
@Hitret id=35059

@Talk name=亮平 voice=RH050114
怎，怎么一脸坦然的说出这么过分的话啊？　你……
@Hitret id=35060



@Hide
@BlackOut time=1000

@Cg file=B07d   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=心の声
到达神社时已经完全是祭典的样子了，参拜的路上摆满了露天店。
@Hitret id=35061

@Talk name=心の声
似乎是已经开始准备了，四周散发着炒面与可丽饼的香味，祭典的氛围气已经活跃起来了。
@Hitret id=35062


@Char file=CC06_01M 

@Talk name=瑛 voice=AK050058
欢迎大家！　明明这么忙还麻烦你们真的很不好意思。
@Hitret id=35063

@Talk name=悠
没事没事。我好像也不知怎么的兴奋起来了，这就是所谓的祭典吧？
@Hitret id=35064


@Char file=CD03_03M 

@Talk name=一叶 voice=KA050044
太感谢了。那么，依媛同学和穹同学请到这边来帮忙接待客人。
@Hitret id=35065

@Talk name=瑛 voice=AK050059
悠君和亮哥哥，就把社务所里要卖的东西搬出来吧。
@Hitret id=35066


@ClearChar 
@Char file=CF03_01S 
@Char file=CA03_01S 
@Char file=CB03_01S 

@Talk name=亮平 voice=RH050115
哦哦，包在我们身上！
@Hitret id=35067

@Talk name=奈绪 voice=NO050045
了解了……小穹，走吧。
@Hitret id=35068

@Talk name=穹 voice=SR050069
…………嗯。
@Hitret id=35069



@Hide
@BlackOut time=1000

@Cg file=B07a   

@Talk name=悠
那么，这些都是好东西吧……
@Hitret id=35070


@Char file=CF03_01M 

@Talk name=亮平 voice=RH050116
啊啊，搬这些就行了吧？
@Hitret id=35071

@Talk name=心の声
我们在社务所的贩卖台里，把神签啊守护符什么的，都抱起来运走。
@Hitret id=35072

@Talk name=心の声
从镇上来的巫女们在里面利索的整理准备着。
@Hitret id=35073

@Talk name=心の声
然后，在应接室里，慢慢的人都聚集了起来。
@Hitret id=35074

@Talk name=心の声
有些偶尔见过的脸，没想到都是照顾镇上的人啊区长啊什么之类的。
@Hitret id=35075

@Talk name=心の声
对方似乎也知道我爷爷的事情，说以前在诊察以外，也经常有向爷爷商量过事情啊受过照顾什么的。
@Hitret id=35076

@Talk name=心の声
然后，对我们的事情就好像是对待自己的孙子一样，疼爱着。
@Hitret id=35077

@Talk name=亮平 voice=RH050117
哦，总算，主要的登场了啊。
@Hitret id=35078


@ClearChar 
@Char file=CJ01_01S x=-300  
@Char file=CK01_01S x=0  

@Talk name=心の声
一脸严肃的，穿着和服的男人出现了。
@Hitret id=35079

@Talk name=心の声
在他后面，不远不近地跟着一个高瘦的人。
@Hitret id=35080

@Talk name=亮平 voice=RH050118
那就是，大小姐的老爹。
@Hitret id=35081

@Talk name=悠
诶，渚同学的？
@Hitret id=35082

@Talk name=亮平 voice=RH050119
啊啊，是议员，这里的大人物。
@Hitret id=35083

@Talk name=悠
…………是这样啊。
@Hitret id=35084

@Talk name=心の声
就是说，那个人就是初佳小姐的雇主吧。
@Hitret id=35085

@Talk name=心の声
因为是做着议员所以能感受到一股威严的气息。
@Hitret id=35086

@Talk name=悠
……啊………你好…………
@Hitret id=35087

@Talk name=亮平 voice=RH050120
好~。
@Hitret id=35088

@Talk name=心の声
注意到我们的渚同学父亲轻轻点了点头。
@Hitret id=35089


@ClearChar 
@Char file=CC06_01S 
@Char file=CD03_01S 

@Talk name=瑛 voice=AK050060
难得各位抽空过来，真是感谢。
@Hitret id=35090


@ClearChar 

@Talk name=心の声
表示欢迎，天女目和渚同学为两人带路，通过应接室。里面的人一起站了起来，一个个打招呼。
@Hitret id=35091

@Talk name=心の声
就算只通过这一点，也能让人明白渚同学的父亲在这个小镇上，有着多大的权利。
@Hitret id=35092


@Char file=CE02_01M 

@Talk name=初佳 voice=MT050408
怎样，帮忙如何了？
@Hitret id=35093


@Char file=CF03_01M 

@Talk name=亮平 voice=RH050121
哦哦，初佳小姐……啊，明明是祭典穿的却没一点女人味啊。像浴衣啊浴衣啊浴衣什么的……
@Hitret id=35094

@Talk name=初佳 voice=MT050409
真失礼啊，我平常穿的衣服已经很有女人味了。
@Hitret id=35095

@Talk name=亮平 voice=RH050122
不啊不啊不啊，难得的好日子！　有魅力的女性就该打扮得更有魅力吧！
@Hitret id=35096

@Talk name=亮平 voice=RH050123
这是包含悠在内的，所有男性的愿望！
@Hitret id=35097

@Talk name=悠
别把我卷进来啊！
@Hitret id=35098


@Char file=CE02_04M 

@Talk name=初佳 voice=MT050410
嘿诶，悠君也喜欢浴衣啊？　那么，小瑛穿的是巫女服吧？　也很兴奋的吧？
@Hitret id=35099

@Talk name=悠
我不是那种爱好啦！
@Hitret id=35100


@Char file=CF03_02M 

@Talk name=亮平 voice=RH050124
那么悠就是女仆派啦。太好了呢，初佳小姐。
@Hitret id=35101


@Char file=CE02_03M 

@Talk name=初佳 voice=MT050411
悠君啊，是意外的“高玩”啊……
@Hitret id=35102

@Talk name=悠
所以说不是啦！亮平也不要随便乱说啊！
@Hitret id=35103

@Talk name=亮平 voice=RH050125
啊哈哈，对不起对不起。但是看你这么生气的否定就是说……
@Hitret id=35104

@Talk name=悠
亮平！
@Hitret id=35105

@Talk name=亮平 voice=RH050126
啊哈哈哈哈……
@Hitret id=35106


@ClearChar 
@Char file=CG01_03M 

@Talk name=八寻 voice=YH050114
哦哦，小鬼们都在闹啊！
@Hitret id=35107

@Talk name=悠
啊，八寻小姐。你好……等等你手里拿的是……日本酒，么？
@Hitret id=35108

@Talk name=心の声
不会吧，打算从大中午就开始喝？
@Hitret id=35109

@Talk name=八寻 voice=YH050115
出席村子的聚会，总不能空手去吧。
@Hitret id=35110

@Talk name=亮平 voice=RH050127
哦，拿了不错的东西呢。我等下也一起……
@Hitret id=35111


@Char file=CG01_06M 

@Talk name=八寻 voice=YH050116
笨蛋，小鬼滚一边去。先说好，要是真来了我轰飞你们。
@Hitret id=35112


@Char file=CE02_12M 

@Talk name=初佳 voice=MT050412
等等，那不是“泽娘”的纯米大吟酿么！　连我都没有喝过啊！
@Hitret id=35113

@Talk name=八寻 voice=YH050117
渚家的老爹也来了，总不能拿太差的东西去吧。
@Hitret id=35114


@Char file=CE02_09M 

@Talk name=初佳 voice=MT050413
你啊，就只在我决定不会去喝酒的时候，才会做这样的事情……
@Hitret id=35115

@Talk name=亮平 voice=RH050128
初佳小姐也去喝不就行了。乱入进去谁也不会在意的啦。
@Hitret id=35116


@Char file=CG01_03M 

@Talk name=八寻 voice=YH050118
这样的话，我来帮忙也可以哦？
@Hitret id=35117

@Talk name=心の声
呜嘻嘻，笑着的八寻小姐，仿佛是看透了初佳小姐不会说“好”一样。
@Hitret id=35118

@Talk name=心の声
……嗯？　那么说，初佳小姐也是来工作的？
@Hitret id=35119

@Talk name=悠
说起来，刚才好像看见了渚同学的父亲，初佳小姐是来照顾的么？
@Hitret id=35120


@Char file=CE02_11M 

@Talk name=八寻 voice=YH050119
啊哈哈哈……喂悠，这真是好笑的笑话啊。
@Hitret id=35121

@Talk name=心の声
为，为什么要笑？
@Hitret id=35122

@Talk name=心の声
初佳小姐红着脸什么也不说，而亮平则是捂住嘴像是要忍住笑一样。
@Hitret id=35123

@Talk name=心の声
只有我一个人满头的问号。
@Hitret id=35124

@Talk name=初佳 voice=MT050414
今，今天，不是祭典么？　屋子里的人也都出门去了，所以就早点把工作做完了。
@Hitret id=35125

@Talk name=初佳 voice=MT050415
所以是自由时间哦。
@Hitret id=35126

@Talk name=心の声
像是在教小孩一样的语气，但是总感觉像在隐瞒什么……
@Hitret id=35127


@Char file=CG01_01M 

@Talk name=八寻 voice=YH050120
就算是地方不上座的祭典，也算是公家的行事哦。身旁的打理当然是由秘书来做啰。
@Hitret id=35128

@Talk name=亮平 voice=RH050129
看啊，老爷子的背后有个大叔吧？　就是那个人哦。
@Hitret id=35129

@Talk name=悠
啊啊……恩，有呢。那个人是秘书啊。
@Hitret id=35130

@Talk name=悠
那么，为什么不去喝酒呢？
@Hitret id=35131


@Char file=CE02_03M 

@Talk name=初佳 voice=MT050416
那，那是……
@Hitret id=35132

@Talk name=八寻 voice=YH050121
从这家伙的酒品就知道啦。
@Hitret id=35133

@Talk name=悠
啊…………啊啊，原来如此……
@Hitret id=35134


@Char file=CE02_10M 

@Talk name=初佳 voice=MT050417
我求求你了别这样同意啊~……我会伤心的……
@Hitret id=35135

@Talk name=悠
但，但是不喝酒的话还是很可靠的，让初佳小姐帮忙也没什么啊。
@Hitret id=35136

@Talk name=初佳 voice=MT050418
呜呜~，悠君是好孩子呢……真的……
@Hitret id=35137


@Char file=CG01_03M 

@Talk name=八寻 voice=YH050122
半吊子的温柔，只会伤人而已。
@Hitret id=35138


@ClearChar id=初佳
@Char file=CF03_01M 

@Talk name=亮平 voice=RH050130
我就一直在担心，像悠这种老好人会不会被啥坏家伙给缠上呢。
@Hitret id=35139


@Char file=CG01_01M 

@Talk name=八寻 voice=YH050123
吃一次苦那小子就会清醒的，就是这样。
@Hitret id=35140

@Talk name=亮平 voice=RH050131
我也算是亲友啊，这样的话于心不忍。
@Hitret id=35141

@Talk name=心の声
……连我都被开始乱说了……
@Hitret id=35142


@ClearChar 
@Char file=CE02_01M 

@Talk name=初佳 voice=MT050419
那个恶人，不就是耍我们高兴的你们么。
@Hitret id=35143


@Char file=CE02_01L 

@Talk name=初佳 voice=MT050420
悠君，不要管这些人，我们走吧。
@Hitret id=35144

@Talk name=心の声
我也不知道该怎么回应，就这样被初佳小姐牵着手走掉了。
@Hitret id=35145

@Talk name=心の声
背后回响着八寻小姐欢快的“没错哦”的笑声。
@Hitret id=35146


@StopBgm

@Hide
@BlackOut time=1000

@Change target=00_e012b



