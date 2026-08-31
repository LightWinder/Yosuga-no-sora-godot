



@Cg file=B21a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@PlayBgm file=BGM03

@Talk name=心の声
我靠着更衣室的门发呆。
@Hitret id=14802

@Talk name=心の声
嘴上还留有接吻时的感觉。
@Hitret id=14803

@Talk name=心の声
之后……
@Hitret id=14804

@Talk name=心の声
感觉到有人，我们急忙分开。
@Hitret id=14805

@Talk name=心の声
来到泳池的是老师。没被他看到我们亲热的场面，算是放下了心。
@Hitret id=14806

@Talk name=心の声
老师只是过来看了看泳池的情况，马上就回去了。
@Hitret id=14807

@Talk name=心の声
泳池就只剩下我们俩，感觉有些尴尬，于是准备先换一下衣服。
@Hitret id=14808


@PlaySe file=se018

@Talk name=悠
！？　什、什么？
@Hitret id=14809

@Talk name=心の声
游泳部的房间里传来巨大的声响。
@Hitret id=14810

@Talk name=悠
………奈绪？　没事吧？
@Hitret id=14811

@Talk name=奈绪 voice=NO031090
啊，嗯……没事ー………
@Hitret id=14812

@Talk name=悠
……？？？　在做什么呢？　好像传来一阵很大的声音……
@Hitret id=14813


@Char file=CB04_01M 

@Talk name=奈绪 voice=NO031091
抱歉让你吓了一跳……我在找这个。
@Hitret id=14814


@Talk name=心の声
奈绪从房间出来，把游泳镜递给了我。
@Hitret id=14815

@Talk name=悠
这是………
@Hitret id=14816

@Talk name=奈绪 voice=NO031092
这是多下来没人用的，所以给小悠了。
@Hitret id=14817

@Talk name=悠
呃，可以吗？　不是用经费买的吗？
@Hitret id=14818

@Talk name=奈绪 voice=NO031093
没事的，有人能用它才更好。
@Hitret id=14819

@Talk name=悠
谢谢，我会好好用的。
@Hitret id=14820

@Talk name=奈绪 voice=NO031094
呵呵，不用客气。
@Hitret id=14821


@Char file=CB04_02L 

@Talk name=奈绪 voice=NO031095
我看看……小悠带上它还合适吗？
@Hitret id=14822

@Talk name=悠
！…………啊……
@Hitret id=14823

@Talk name=心の声
奈绪轻轻探出身来，靠近了我。
@Hitret id=14824

@Talk name=心の声
然后她把泳镜温柔地按在我眼睛上，确认着位置。
@Hitret id=14825

@Talk name=奈绪 voice=NO031096
好了，看来没事了。
@Hitret id=14826

@Talk name=悠
嗯………是呢。
@Hitret id=14827

@Talk name=心の声
奈绪看着我的时候，胸也一起按在了我身上。
@Hitret id=14828

@Talk name=奈绪 voice=NO031097
剩下的就自己调一下带子的长度吧。
@Hitret id=14829

@Talk name=悠
知道了。奈绪，真的谢谢了。
@Hitret id=14830

@Talk name=奈绪 voice=NO031098
不用不用………啊，抱歉，让你久等了……
@Hitret id=14831

@Talk name=悠
不用……慢一点没关系的。
@Hitret id=14832


@StopBgm

@Talk name=奈绪 voice=NO031099
我马上去换衣服……啊………
@Hitret id=14833


@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=150 
@WaitAction id=カメラ
@Char file=CB04_13L 

@Talk name=心の声
奈绪脚一滑，眼看就要摔倒。
@Hitret id=14834

@Talk name=悠
啊呀……没事吧……？
@Hitret id=14835


@Char file=CB04_11L 

@Talk name=奈绪 voice=NO031100
啊…谢谢……这里总是容易滑……
@Hitret id=14836

@Talk name=心の声
我抱着奈绪，身体僵掉了。
@Hitret id=14837

@Talk name=心の声
脑里又回想起刚才的接吻。
@Hitret id=14838

@Talk name=奈绪 voice=NO031101
………啊………小悠………
@Hitret id=14839

@Talk name=心の声
我抱住奈绪姐的双手又增加了几分力道。
@Hitret id=14840


@PlayBgm file=BGM18
@Char file=CB04_11L 

@Talk name=奈绪 voice=NO031102
…………小，小悠………
@Hitret id=14841

@Talk name=心の声
奈绪姐已经完全感觉到我的心跳了吧。
@Hitret id=14842

@Talk name=心の声
从刚才开始，我的脉搏就已经砰砰地跳个不停了。
@Hitret id=14843

@Talk name=心の声
湿润的泳衣，将奈绪姐的线条完美地显现在我的眼前，我的目光已经被深深地吸引住了。
@Hitret id=14844

@Talk name=悠
…………奈绪姐………
@Hitret id=14845

@Talk name=悠
………对不起…………
@Hitret id=14846

@Talk name=奈绪 voice=NO031103
………没关系的……
@Hitret id=14847

@Talk name=心の声
奈绪姐冲我露出一个微笑，抚摸着我的脸颊。
@Hitret id=14848

@Talk name=心の声
然后……闭上双眼，向我的脸慢慢靠近。
@Hitret id=14849


@BlackOut

*recollect

@if exp="IsRecollect()"
	@Cg file=BLACK
@endif

@PlayBgm file=BGM18

@Talk name=奈绪 voice=NO031104
…………嗯…………
@Hitret id=14850

@Talk name=心の声
我们不停地亲吻着对方。
@Hitret id=14851

@Talk name=心の声
柔软湿润的双唇，很快就让我沉浸在这份快要融化般的感觉中。
@Hitret id=14852


@Cg file=EB10a  

@Talk name=悠
………奈绪姐…………
@Hitret id=14853

@Talk name=心の声
奈绪姐慢慢地躺在长椅上，然后盯着我的脸。
@Hitret id=14854

@Talk name=心の声
可能是还有些紧张吧，她的身体有些僵硬。
@Hitret id=14855

@Talk name=悠
………嗯………
@Hitret id=14856

@Talk name=心の声
为了让她放松身体，我亲吻着她。
@Hitret id=14857

@Talk name=奈绪 voice=NO031105
嗯……啾………
@Hitret id=14858

@Talk name=心の声
刚刚游过泳有些冰冷的身体，能够清楚地感觉到嘴唇的温暖。
@Hitret id=14859

@Talk name=心の声
我将自己的腿塞进奈绪姐的两腿中间，让她劈起一条腿，然后趴在她的身上。
@Hitret id=14860

@Talk name=奈绪 voice=NO031106
小悠………
@Hitret id=14861

@Talk name=心の声
和那时正好相反，这回轮到我在奈绪姐的上面了。
@Hitret id=14862

@Talk name=心の声
奈绪姐有些羞涩地闭上双眼，慢慢地放松着身体。
@Hitret id=14863

@Talk name=心の声
她的身材发育的很好，和以前相比更有女性的魅力了。
@Hitret id=14864

@Talk name=心の声
一上来就摸她的胸部我怕有些不妥，所以只好从大腿外侧开始抚摸她。
@Hitret id=14865

@Talk name=奈绪 voice=NO031107
啊……嗯………
@Hitret id=14866

@Talk name=心の声
奈绪姐扭动着身体，娇喘着。
@Hitret id=14867

@Talk name=奈绪 voice=NO031108
小悠……你可以……摸你喜欢的地方哦？
@Hitret id=14868

@Talk name=奈绪 voice=NO031109
比如说这里……还有胸部……一切随你喜欢……嗯……
@Hitret id=14869

@Talk name=悠
啊……奈绪姐……
@Hitret id=14870

@Talk name=奈绪 voice=NO031110
嗯……可以的……小悠………
@Hitret id=14871

@Talk name=心の声
在奈绪姐的引导下，我把手伸向她两腿中间的那个部位。
@Hitret id=14872

@Talk name=心の声
泳衣由于吸收了水分紧贴在身体上，能够清楚地看到鼓起来的那部分。
@Hitret id=14873

@Talk name=心の声
我用整只手抚摸着她的私处。
@Hitret id=14874

@Talk name=奈绪 voice=NO031111
嗯……啊啊……嗯……你好温柔……小悠……
@Hitret id=14875

@Talk name=奈绪 voice=NO031112
再用点力也没关系的？　啊…嗯…我不要紧的…
@Hitret id=14876

@Talk name=奈绪 voice=NO031113
嗯！　啊啊…那…那里……是我敏感的地方…嗯唔！
@Hitret id=14877

@Talk name=奈绪 voice=NO031114
啊……嗯……对……把手放在阴唇上……试着去爱抚它……
@Hitret id=14878

@Talk name=奈绪 voice=NO031115
啊哈……嗯……啊嗯……哈，哈，哈………
@Hitret id=14879

@Talk name=心の声
当我的指尖碰到那个热乎乎的地方时，还以为是奈绪姐尿尿了呢，不过好像并不是这样。
@Hitret id=14880

@Talk name=心の声
位于阴阜部位的小突起……也就是她的尿道口，随着爱抚越来越热乎了。
@Hitret id=14881

@Talk name=心の声
我时而抚摸，时而用指尖去戳，奈绪姐则弓着腰想要从我手里逃出去。
@Hitret id=14882

@Talk name=悠
这里，好热乎啊……奈绪姐……好像已经湿了……
@Hitret id=14883

@Talk name=奈绪 voice=NO031116
嗯……啊……被小悠爱抚……感觉很舒服……嗯唔……哈，哈……
@Hitret id=14884

@Talk name=奈绪 voice=NO031117
不过……感觉有一些痒……嗯啊……啊……
@Hitret id=14885

@Talk name=悠
看你的腰都开始扭动起来了。
@Hitret id=14886

@Talk name=奈绪 voice=NO031118
呵呵，是啊……嗯……再抚摸一下上面那个地方…
@Hitret id=14887

@Talk name=悠
嗯……是这里吗……
@Hitret id=14888

@Talk name=奈绪 voice=NO031119
啊……嗯呜……对，就是那里……尿道口上面的部位……啊……那里……啊啊……嗯……有感觉了……
@Hitret id=14889

@Talk name=心の声
由于受到了刺激，奈绪姐抓住我的手，让我停下了动作。
@Hitret id=14890

@Talk name=奈绪 voice=NO031120
哈，哈……对不起……刺激得太强烈了，吓着我了……你再抚摸一次……嗯嗯……啊……
@Hitret id=14891

@Talk name=奈绪 voice=NO031121
啊……很，很好……这里……叫做阴蒂……是女孩子敏感的地方……嗯……你知道吗？
@Hitret id=14892

@Talk name=悠
哎……名，名称我还是知道的……啊，那个……
@Hitret id=14893

@Talk name=奈绪 voice=NO031122
呵呵……小悠挺适合逗着玩的呢……喂，继续…抚摸吧？
@Hitret id=14894

@Talk name=悠
嗯……
@Hitret id=14895

@Talk name=心の声
我继续爱抚着奈绪姐告诉我的那个部位。虽然隔着一层泳衣不知道是什么样子，不过确实能隐约看到一个小突起。
@Hitret id=14896

@Talk name=奈绪 voice=NO031123
啊……嗯……嗯……啊……好……很好……啊，很舒服……嗯……
@Hitret id=14897

@Talk name=奈绪 voice=NO031124
嗯……啊……啊…好热…我的那里已经热起来了……
@Hitret id=14898

@Talk name=奈绪 voice=NO031125
嗯…啊……舒服得连腰都挺起来了……啊…好害羞…
@Hitret id=14899

@Talk name=奈绪 voice=NO031126
嗯……嗯唔……啊……小悠……摸我的胸部……
@Hitret id=14900

@Talk name=悠
嗯……
@Hitret id=14901

@Talk name=心の声
从外表一看就知道是一对巨乳。每当我爱抚阴蒂的时候，都被这对波光粼粼的巨乳吸引着视线。
@Hitret id=14902

@Talk name=心の声
老实说，平时直勾勾地盯着人家的胸部会被讨厌的，所以我没怎么仔细看过这个部位。
@Hitret id=14903

@Talk name=心の声
不过，现在这对巨乳就摆在我触手可得的地方。
@Hitret id=14904

@Talk name=心の声
我先是用手掌整个覆盖住她的乳房。
@Hitret id=14905

@Talk name=心の声
然后慢慢地去揉，我还以为会有一些硬呢，不过却比我想象的更富有弹性，也很柔软。
@Hitret id=14906

@Talk name=心の声
如此柔软的地方竟然还能保持着形状，真是不可思议。
@Hitret id=14907

@Talk name=奈绪 voice=NO031127
嗯……啊……呵呵，突然就展开攻势吗？
@Hitret id=14908

@Talk name=悠
啊……对不起……
@Hitret id=14909

@Talk name=奈绪 voice=NO031128
没关系……不要紧的……尽情地揉吧……我对自己胸部的柔软性还是有自信的……嗯……嗯……
@Hitret id=14910

@Talk name=奈绪 voice=NO031129
啊……对，就是这样……做圆周运动，会很舒服的……
@Hitret id=14911

@Talk name=奈绪 voice=NO031130
嗯，嗯……啊…哈，哈……胸部不会掉下来的，用力揉吧？　啊嗯……啊哈……
@Hitret id=14912

@Talk name=心の声
我一边画着圆，一边使劲揉着她的胸部，即使用手改变乳房的形状，松开手又变回了原来的样子。
@Hitret id=14913

@Talk name=心の声
这就是所谓的收放自如，张弛有度吧。看着如此波光魅影的乳房，让我更加难以按耐住心中的兴奋。
@Hitret id=14914

@Talk name=心の声
记得以前揉她胸部的时候还略有保守，不敢这么用力的，像这样随心所欲的揉还真算是一种感动呢。
@Hitret id=14915

@Talk name=奈绪 voice=NO031131
嗯……啊……啊呜……啊…乳头…挺起来了……
@Hitret id=14916

@Talk name=心の声
的确，隔着一层泳衣都能感觉到两个小突起。我用手捏住乳头，试着给于刺激。
@Hitret id=14917

@Talk name=奈绪 voice=NO031132
嗯啊……啊…乳头都挺起来了……啊…嗯……我越来越起性了……嗯！
@Hitret id=14918

@Talk name=奈绪 voice=NO031133
啊啊…小悠……嗯…啊……继续捏它…
@Hitret id=14919

@Talk name=奈绪 voice=NO031134
啊…啊呜嗯！　嗯……啊……啊哈……啊！！
@Hitret id=14920

@Talk name=奈绪 voice=NO031135
每当你捏乳头的时候……全身都火辣辣的…啊，嗯…哈，啊……
@Hitret id=14921

@Talk name=奈绪 voice=NO031136
呜……胸口有些难受……
@Hitret id=14922

@Talk name=悠
啊……没事吧？　是我太用力了吗？
@Hitret id=14923

@Talk name=奈绪 voice=NO031137
不是……啾……嗯……是小悠爱抚的太舒服了…泳衣都觉得有点紧了……等我把泳衣脱了。
@Hitret id=14924


@Cg file=EB10b  

@Talk name=奈绪 voice=NO031138
嗯……咻……啊……呜……只露出一边，有点害羞……
@Hitret id=14925

@Talk name=心の声
奈绪姐把上半身的吊带脱下，一个乳头挺立的乳房立刻摇曳在我眼前。
@Hitret id=14926

@Talk name=心の声
真大……我再次惊叹不已。没有了胸垫的支撑每当奈绪姐动的时候，胸部都不停地摇曳着。
@Hitret id=14927

@Talk name=悠
……真美啊……嗯……啾……
@Hitret id=14928

@Talk name=奈绪 voice=NO031139
啊……嗯，嗯……啊啊……就是这样…用舌头舔……啊……嗯呜！　嗯唔……
@Hitret id=14929

@Talk name=奈绪 voice=NO031140
嗯呼……啊啊……像是在做梦……小悠……竟然在拼命吸我的乳头……嗯呜！　啊……啊啊……
@Hitret id=14930

@Talk name=奈绪 voice=NO031141
讨厌啦……小悠…嗯，嗯呜！　啊……啊呜…这些……你都是从哪儿学来的……
@Hitret id=14931

@Talk name=悠
不是……学来的……我只是按照我想的去做而已……嗯，啾…嗯……
@Hitret id=14932

@Talk name=奈绪 voice=NO031142
啊呜……啊……啊啊……被你一脸可爱的表情吸吮着胸部……嗯……真是舒服极了……
@Hitret id=14933

@Talk name=奈绪 voice=NO031143
啊呼……啊，嗯……小悠……你太可爱了……
@Hitret id=14934

@Talk name=奈绪 voice=NO031144
嗯……嗯……啊啊……我喜欢你……小悠……
@Hitret id=14935

@Talk name=心の声
我沿着乳晕舔舐着她，时不时用舌尖刺激她的乳头，她都会发出娇嫩的喘息声。
@Hitret id=14936

@Talk name=心の声
奈绪姐像哄着婴儿似的轻轻地抱着我，温柔地抚摸着我的头。
@Hitret id=14937

@Talk name=心の声
我沉浸在这气氛中，像一个吃奶的婴儿似的，一边吸吮着乳头，一边发出声音。
@Hitret id=14938

@Talk name=奈绪 voice=NO031145
嗯……啊……不要发出啾啾的声音啦……听起来好下流………啊啊……嗯……
@Hitret id=14939

@Talk name=奈绪 voice=NO031146
真，真是的……嗯……啊……你这样做…我会害羞的…嗯……啊啊！　啊嗯！
@Hitret id=14940

@Talk name=奈绪 voice=NO031147
啊……啊嗯……你再怎么吸吮……也…也不会吸出奶水来的……啊啊……啊……嗯……
@Hitret id=14941

@Talk name=奈绪 voice=NO031148
呼，哈，哈…嗯……呀……啊，呜！　嗯，呜！啊……嗯，呜……别，别咬嘛……啊……
@Hitret id=14942

@Talk name=奈绪 voice=NO031149
呼……不，不过……啊啊！　就像被虐待似的……嗯……浑身都抽搐了……啊，嗯！
@Hitret id=14943

@Talk name=心の声
奈绪姐紧紧地把我抱在胸前。
@Hitret id=14944

@Talk name=悠
呜……呜……我好痛苦……奈绪姐……
@Hitret id=14945

@Talk name=奈绪 voice=NO031150
啊，哈，哈……小悠……太刺激了……
@Hitret id=14946

@Talk name=心の声
紧贴在她的胸脯上，感觉有点痒痒的。不过，温暖的触感却能够让我心境平和。
@Hitret id=14947

@Talk name=奈绪 voice=NO031151
真是个……乱来的孩子……啾……嗯……
@Hitret id=14948

@Talk name=心の声
我从乳沟间看着奈绪姐的脸，她一瞬间露出生气的表情，然后又直起身子亲吻了我。
@Hitret id=14949

@Talk name=悠
我来继续服侍你……因为我还想听奈绪姐可爱的声音。
@Hitret id=14950

@Talk name=奈绪 voice=NO031152
咦……小，小悠？　啊……嗯……啊啊！
@Hitret id=14951

@Talk name=心の声
我用手抓住她的胸部刺激着乳头，然后用舌头一圈一圈地舔舐并湿润着她的乳头。
@Hitret id=14952

@Talk name=心の声
然后剩下的一只手一路向下，顺着泳衣的缝隙把手指伸了进去。
@Hitret id=14953

@Talk name=心の声
此时，她热乎乎的私处，已经湿润得滑溜溜的。
@Hitret id=14954

@Talk name=心の声
我用手扒开贴在身体上的阴毛，用手指玩弄着刚刚爱抚过的部位。
@Hitret id=14955

@Talk name=奈绪 voice=NO031153
嗯，呜……啊……手，手指……放进来了……我的那里……嗯，呜……啊啊……呀啊……已经湿乎乎了…
@Hitret id=14956

@Talk name=奈绪 voice=NO031154
嗯，啊……啊……那，那里……啊……啊，啊……阴…阴蒂那里……嗯，呜……啊……
@Hitret id=14957

@Talk name=奈绪 voice=NO031155
啊……嗯，呜……嗯，啊……啊……哈，哈……麻……麻嗖嗖的……啊……嗯……
@Hitret id=14958

@Talk name=心の声
我上下抚摸着她的阴唇，粘稠炙热的爱液和我的手指缠绵在一起。
@Hitret id=14959

@Talk name=心の声
简直像手指反过来被爱抚似的，我小心翼翼地活动着手指。
@Hitret id=14960

@Talk name=心の声
我把中指轻轻地插进她的洞府中。那一瞬间，我的中指被紧紧地夹住了。
@Hitret id=14961

@Talk name=心の声
奈绪姐的阴道内很热，粗糙的粘膜摩擦着我的手指。
@Hitret id=14962

@Talk name=心の声
我用中指的指腹刺激着她的阴道内壁，慢慢地重复着抽插动作。
@Hitret id=14963

@Talk name=奈绪 voice=NO031156
嗯，啊……啊……啊，嗯……啊……我的那里……啊……被摩擦的好舒服……啊……啊，呜……啊……
@Hitret id=14964

@Talk name=心の声
我虽然想更强烈地刺激她，可她的阴道口却紧紧夹住我的手指。
@Hitret id=14965

@Talk name=心の声
无奈的我只好爱抚着奈绪姐的阴道口附近小幅度地抽插着。
@Hitret id=14966

@Talk name=奈绪 voice=NO031157
嗯……啊……啊啊！　啊……那里……有感觉了……啊啊…那里被你攻破的话……嗯呜……身体会瘫软的…
@Hitret id=14967

@Talk name=奈绪 voice=NO031158
啊……快，快住手……小悠……嗯啊！
@Hitret id=14968

@Talk name=奈绪 voice=NO031159
啊……啊，呜……啊……唔……啊……啊啊！
@Hitret id=14969

@Talk name=奈绪 voice=NO031160
感，感觉太爽了…啊啊！！　啊……唔啊！！
@Hitret id=14970

@Talk name=心の声
此时的奈绪姐就像失禁了似的，嗞，嗞地从尿道口的地方飞溅出好多水花。
@Hitret id=14971

@Talk name=心の声
随着我对她阴道的刺激，她的腰也开始浮动，抽搐。
@Hitret id=14972

@Talk name=奈绪 voice=NO031161
啊……啊！　嗯呜呜！　手，手指……快停下…啊呜……啊……啊，啊嗯！！
@Hitret id=14973

@Talk name=心の声
我正在用手摩擦的地方可能就是奈绪姐的弱点部位吧，奈绪姐一边按住我的手，一边冲我连连摇头。
@Hitret id=14974

@Talk name=心の声
我没有理会她，继续刺激着那个部位。
@Hitret id=14975

@Talk name=奈绪 voice=NO031162
嗯啊……唔啊……啊，啊啊！　不，不行！要……要去了……啊啊！！
@Hitret id=14976

@Talk name=奈绪 voice=NO031163
哈，哈，哈…好像失禁了似的……嗯唔…啊！
@Hitret id=14977

@Talk name=奈绪 voice=NO031164
嗯…啊啊…你，你再继续这样的话…嗯，呜啊！
@Hitret id=14978

@Talk name=奈绪 voice=NO031165
呜……啊……小，小悠……我…嗯！
@Hitret id=14979

@Talk name=奈绪 voice=NO031166
啊，啊嗯！　啊，啊，嗯，嗯嗯！！
@Hitret id=14980

@Talk name=奈绪 voice=NO031167
要……要……要去了，啊嗯……啊……
@Hitret id=14981


@Flash color=WHITE enter=0 leave=1000

@Talk name=奈绪 voice=NO031168
啊……啊哈……嗯……啊啊啊啊啊啊啊！！
@Hitret id=14982

@Talk name=奈绪 voice=NO031169
啊啊啊………啊……啊，哈……哈，哈，哈，哈…
@Hitret id=14983

@Talk name=奈绪 voice=NO031170
嗯……呜呜……啊………
@Hitret id=14984

@Talk name=心の声
奈绪姐的身体弯成一个大大的弓字形。连她躺着的长椅都歪向了一旁。
@Hitret id=14985

@Talk name=心の声
茫然若失，向后仰着身子的奈绪姐慢慢放松了身体。
@Hitret id=14986

@Talk name=心の声
奈绪姐的私处就像发洪水似的，爱液不停地往外涌，连被爱液浸湿的泳衣都变得厚重了。
@Hitret id=14987

@Talk name=心の声
和刚才游泳池里的消毒水味儿不同，现在飘散在四周的，是一股芳香的气息。
@Hitret id=14988

@Talk name=心の声
嗅着奈绪姐爱液和汗水掺混在一起的味道，我仍然兴奋着。
@Hitret id=14989

@Talk name=奈绪 voice=NO031171
讨厌……小悠……你真是硬来……
@Hitret id=14990

@Talk name=悠
我看奈绪姐挺舒服的……所以就……
@Hitret id=14991

@Talk name=奈绪 voice=NO031172
……你什么时候成了女性杀手了？
@Hitret id=14992

@Talk name=悠
啊……不，那个………
@Hitret id=14993

@Talk name=奈绪 voice=NO031173
呵呵，开玩笑的……
@Hitret id=14994

@Talk name=心の声
奈绪姐摇摇晃晃地坐了起来，双手捧着我的脸颊，然后是长长的一吻。
@Hitret id=14995

@Talk name=奈绪 voice=NO031174
嗯……啾……嗯………嗯……哈，哈……
@Hitret id=14996

@Talk name=奈绪 voice=NO031175
下面该轮到小悠了……这里……鼓鼓的，很痛苦吧？
@Hitret id=14997

@Talk name=悠
啊……嗯……是，是的……啊……
@Hitret id=14998

@Talk name=奈绪 voice=NO031176
呵呵……一脸羞涩的表情……真可爱……啾…
@Hitret id=14999

@Talk name=悠
奈绪姐………
@Hitret id=15000

@Talk name=心の声
按照奈绪姐所说的，我勃起自己的阳具，那跃跃欲试的劲头仿佛要冲破裤子的枷锁似的。
@Hitret id=15001

@Talk name=心の声
奈绪姐只是轻轻地抚摸了几下，就舒服的整个腰都瘫软了下来。
@Hitret id=15002

@Talk name=心の声
这势头……估计会一触即发。
@Hitret id=15003

@Talk name=奈绪 voice=NO031177
小悠……来吧……
@Hitret id=15004

@Talk name=悠
嗯……奈绪姐，用手扶着墙。
@Hitret id=15005

@Talk name=奈绪 voice=NO031178
哎……啊，好的………
@Hitret id=15006

@Talk name=心の声
在长椅上做的话，怕承受不住两个人的重量。
@Hitret id=15007


@BlackOut

@Talk name=奈绪 voice=NO031179
像这样？
@Hitret id=15008

@Talk name=心の声
奈绪姐把手伏在更衣室的墙壁上，朝我回过头。
@Hitret id=15009

@Talk name=悠
嗯……我从后面插你。
@Hitret id=15010

@Talk name=奈绪 voice=NO031180
啊……嗯……啊……我是不是全脱了比较好？
@Hitret id=15011

@Talk name=悠
那……就把胸部露出来吧。
@Hitret id=15012

@Talk name=奈绪 voice=NO031181
嗯……好的……请欣赏吧……嘿咻……
@Hitret id=15013

@Talk name=心の声
奈绪姐用双手把泳衣脱到腰的位置，摇摇欲坠的胸部立刻显现在我眼前。
@Hitret id=15014

@Talk name=心の声
我从后面抱住奈绪姐，紧紧抓住她的胸部。
@Hitret id=15015

@Talk name=悠
啾……嗯……咻噜……咻哺……
@Hitret id=15016

@Talk name=奈绪 voice=NO031182
啊啊……嗯……小悠很喜欢胸部呢……
@Hitret id=15017

@Talk name=悠
因为奈绪姐的胸部……又丰满又柔软……摸起来很让人兴奋……
@Hitret id=15018

@Talk name=奈绪 voice=NO031183
呵呵……啊，嗯……诚实就好……尽情地摸吧？不过要是比这再丰满的话，生活会很不方便的……嗯……
@Hitret id=15019

@Talk name=悠
奈绪姐……我要来了………
@Hitret id=15020

@Talk name=奈绪 voice=NO031184
这里……让小悠弄得已经充分湿润了…可以的…
@Hitret id=15021

@Talk name=悠
嗯……那我来了……嗯…唔……
@Hitret id=15022

@Talk name=心の声
我解开拉链，掏出了硬挺挺的那个东西。
@Hitret id=15023

@Talk name=心の声
奈绪姐用手撑开自己的私处，我把自己那不断抽搐着的阳具慢慢地插了进去。
@Hitret id=15024

@Talk name=奈绪 voice=NO031185
哇……好热……小悠的……嗯，啊……啊……插，插进来了……嗯，唔………
@Hitret id=15025

@Talk name=心の声
被爱液润湿的阴道，很轻松地就吞没了我的阳具。
@Hitret id=15026


@Cg file=EB11a  

@Talk name=奈绪 voice=NO031186
嗯，唔……啊，啊……呜……啊，啊……
@Hitret id=15027

@Talk name=奈绪 voice=NO031187
啊……哈，哈，哈……好大……啊………嗯……啊……哈，哈……在里面抽搐着……
@Hitret id=15028

@Talk name=奈绪 voice=NO031188
啊…小悠的那个……已经插到深处了……嗯……
@Hitret id=15029

@Talk name=心の声
我一口气将自己的阳具插到底。
@Hitret id=15030

@Talk name=心の声
紧绷绷的阴道内壁和粘膜刺激着我的阳具，比刚才手指感觉到的还要强烈。
@Hitret id=15031

@Talk name=悠
唔……只是插进去……就已经………
@Hitret id=15032

@Talk name=心の声
由于太舒服了，我停了下来。
@Hitret id=15033

@Talk name=心の声
以前是这种感觉吗？
@Hitret id=15034

@Talk name=心の声
我回想起以前。
@Hitret id=15035

@Talk name=心の声
和奈绪姐第一次做爱的时候，还没明白怎么回事，就已经射了。
@Hitret id=15036

@Talk name=心の声
那时舒服的感觉多少还残留在我的记忆里。然而现在比当时还要强烈的快感，充分蔓延至我的全身。
@Hitret id=15037

@Talk name=心の声
这是因为我和奈绪姐心意相通……身心都融为一体的缘故吗？
@Hitret id=15038

@Talk name=心の声
爱抚着奈绪姐，感受着快感带来的那份喜悦。以及吸附着我阳具时的那份惬意。
@Hitret id=15039

@Talk name=心の声
现在的我和奈绪姐可能比以前融合的更紧密。
@Hitret id=15040

@Talk name=奈绪 voice=NO031189
嗯？　小悠……你可以抽动的……嗯……
@Hitret id=15041

@Talk name=悠
嗯……太舒服了……我都要射了……
@Hitret id=15042

@Talk name=奈绪 voice=NO031190
呵呵，没关系，我陪你做到你满足为止……
@Hitret id=15043

@Talk name=悠
……身，身体会撑不住的……
@Hitret id=15044

@Talk name=奈绪 voice=NO031191
慢慢来就可以了……没必要那么勉强的？
@Hitret id=15045

@Talk name=悠
嗯……也是……这又不代表是最后一次……
@Hitret id=15046

@Talk name=奈绪 voice=NO031192
嗯……啊……以后我们也要尽情享受？
@Hitret id=15047

@Talk name=心の声
我抓住奈绪姐的腰，慢慢地抽出，然后又插到深处。
@Hitret id=15048

@Talk name=奈绪 voice=NO031193
嗯……啊……啊哈……啊啊……
@Hitret id=15049

@Talk name=奈绪 voice=NO031194
这样慢节奏的做……嗯，啊……哈…也很舒服呢……
@Hitret id=15050

@Talk name=奈绪 voice=NO031195
嗯…嗯，呼……啊，啊……腰都……自己动起来了…
@Hitret id=15051

@Talk name=奈绪 voice=NO031196
啊啊……啊，啊哈……嗯，嗯……小悠的那个在里面发出嗞嗞的声音。
@Hitret id=15052

@Talk name=奈绪 voice=NO031197
啊，哈……啊哈嗯，啊哈，啊嗯！
@Hitret id=15053

@Talk name=心の声
抽插的节奏虽然很慢，但是我却能细致入微地用龟头刺激奈绪姐深处的那个敏感部位。
@Hitret id=15054

@Talk name=心の声
咕哝，咕哝，爱液从我们融合的那个部位不住地往外涌，就像失禁了似的顺着奈绪姐的大腿向下流淌。
@Hitret id=15055

@Talk name=心の声
每当我插入的时候，奈绪姐的身体都会向后仰，丰满地胸部也不停地摇曳。
@Hitret id=15056

@Talk name=心の声
看她胸部摇得如此自由奔放，我生怕会弄疼了她。
@Hitret id=15057

@Talk name=奈绪 voice=NO031198
嗯…嗯，呼……嗯啊…啊…啊，啊……小悠！嗯呜……啊……那，那是……
@Hitret id=15058

@Talk name=悠
你的后背真美……嗯啾……嗯……
@Hitret id=15059

@Talk name=奈绪 voice=NO031199
嗯啊…啊……小悠在吻我的后背……嗯……啊啊…
@Hitret id=15060

@Talk name=奈绪 voice=NO031200
啊啊……抽搐了……嗯啊……啊……再……亲吻一次那里…嗯……
@Hitret id=15061

@Talk name=奈绪 voice=NO031201
啊……连，连脖子都……嗯呜……啊…
@Hitret id=15062

@Talk name=奈绪 voice=NO031202
小悠……好像我身体敏感的部位……你全都知道似的…
@Hitret id=15063

@Talk name=心の声
这次，我用手牢牢抓住奈绪姐摇曳的胸部。然后，一边揉着她的胸，一边继续抽插。
@Hitret id=15064

@Talk name=奈绪 voice=NO031203
啊嗯……嗯……小，小悠……
@Hitret id=15065

@Talk name=奈绪 voice=NO031204
嗯，嗯唔……哈，哈……啊……胸……小悠在揉我的胸……嗯，嗯呜……哈，哈……
@Hitret id=15066

@Talk name=奈绪 voice=NO031205
嗯啊…嗯……嗯唔……啊，呀…不可以…捏乳头…啊……啊，啊……啊，啊！　嗯呜……
@Hitret id=15067

@Talk name=奈绪 voice=NO031206
啊……嗯唔……啊，啊……那，那里是弱点……身，身体要瘫软了……啊啊……啊嗯！
@Hitret id=15068

@Talk name=悠
不许你逃哦……嗯啾……
@Hitret id=15069

@Talk name=奈绪 voice=NO031207
啊嗯……小悠你真坏……又吻我的后背……啊嗯……
@Hitret id=15070

@Talk name=心の声
忍受不住乳头被玩弄所带来的快感，奈绪姐正要逃走，我则继续亲吻她的后背，给与刺激。
@Hitret id=15071

@Talk name=奈绪 voice=NO031208
嗯呼……啊…胸部竟然这么有感觉……嗯啊…
@Hitret id=15072

@Talk name=奈绪 voice=NO031209
身体上…敏感的部位…啊……好像被小悠…哈，哈……开发出来好多好多……嗯…唔……
@Hitret id=15073

@Talk name=奈绪 voice=NO031210
啊……嗯呜……小悠……真的很喜欢胸部呢……啊嗯……嗯……
@Hitret id=15074

@Talk name=悠
看到胸部摇摇欲坠的样子，不知不觉就把手伸出去了。
@Hitret id=15075

@Talk name=奈绪 voice=NO031211
啊……啊嗯……啊！　哈……在揉得用力一点…
@Hitret id=15076

@Talk name=奈绪 voice=NO031212
让它改变形状……嗯呜……啊啊！　啊哈！
@Hitret id=15077

@Talk name=心の声
我用力揉搓着奈绪姐的胸部，改变着胸部的形状，同时用手去捏，时而用手去揪她的乳头。
@Hitret id=15078

@Talk name=心の声
在我强烈的爱抚下，奈绪姐的胸部紧紧吸附在我的手掌中，感觉沉甸甸的。
@Hitret id=15079

@Talk name=心の声
而且，每当奈绪姐一边娇喘着一边后仰的时候，阴道内壁都会产生小小的痉挛，在粘膜的刺激下包裹着我的阳具。
@Hitret id=15080

@Talk name=悠
唔……快要到极限了………
@Hitret id=15081

@Talk name=奈绪 voice=NO031213
嗯……哈……我也是……在小悠犀利的攻势下…又快要去了……嗯……
@Hitret id=15082

@Talk name=悠
我们一起去……在坚持一会儿……拜托了。
@Hitret id=15083

@Talk name=奈绪 voice=NO031214
嗯……好啊……直到最后都一起，爽到极限。
@Hitret id=15084

@Talk name=心の声
我再次抓起奈绪姐的腰，小幅度地抽插。
@Hitret id=15085

@Talk name=奈绪 voice=NO031215
啊，啊嗯，啊，啊，啊，啊嗯！
@Hitret id=15086

@Talk name=奈绪 voice=NO031216
很，很舒服……啊……嗯…那里……很舒服…嗯！
@Hitret id=15087

@Talk name=心の声
我们融合的部位飞溅出的爱液，啪嗒啪嗒地落在混凝土地板上，弄得满是污垢。
@Hitret id=15088

@Talk name=心の声
在封闭的更衣室内，充满了我们做爱时散发的热气，像个蒸笼似的，热得直冒汗。
@Hitret id=15089

@Talk name=心の声
刚游完泳时的凉爽感已经荡然无存，此时，大汗淋漓的我们不停地重复着性交的动作。
@Hitret id=15090

@Talk name=奈绪 voice=NO031217
小，小悠，啊嗯……啊，啊嗯……啊…啊嗯！
@Hitret id=15091

@Talk name=奈绪 voice=NO031218
哈，哈，哈……小悠的……好，好硬……快，快要去了？　嗯……啊啊……
@Hitret id=15092

@Talk name=奈绪 voice=NO031219
我……我已经……嗯呜…啊……啊！！
@Hitret id=15093

@Talk name=奈绪 voice=NO031220
啊，啊嗯……啊……嗯，嗯，嗯呜！！　小悠……我喜欢你……我最喜欢你了……
@Hitret id=15094

@Talk name=悠
啊啊，我也……喜欢……奈绪姐……嗯……
@Hitret id=15095

@Talk name=奈绪 voice=NO031221
吻，吻我……啾…嗯唔……嗯唔，嗯嗯呜！！
@Hitret id=15096

@Talk name=奈绪 voice=NO031222
啊呼…嗯…啊啊…脑子里……模模糊糊的…嗯…快要站不住了……啊嗯……啊啊……
@Hitret id=15097

@Talk name=心の声
奈绪姐的手被汗水浸湿，有些扶不住墙面了。
@Hitret id=15098

@Talk name=心の声
我则专心致志地抽动着自己的腰，除此之外什么都不去想。
@Hitret id=15099

@Talk name=心の声
为了防止她摔倒，我用手支撑住她肥大的臀部，把暂时拔出来的阳具又插了进去。
@Hitret id=15100

@Talk name=奈绪 voice=NO031223
恩呜呜……啊，啊啊，啊哈……啊呜呜！
@Hitret id=15101

@Talk name=奈绪 voice=NO031224
啊…嗯……啊啊……小悠…我……我……已…经…
@Hitret id=15102

@Talk name=悠
嗯……去吧……我们一起……唔……唔！！
@Hitret id=15103

@Talk name=心の声
还想再继续感觉她，一直到最后的最后……
@Hitret id=15104

@Talk name=心の声
我颤抖着腰，体内的精液就像在寻找着出口似的蓄势待发。
@Hitret id=15105

@Talk name=心の声
不过……还差一点………
@Hitret id=15106

@Talk name=奈绪 voice=NO031225
嗯呜……啊嗯，啊哈，啊嗯，啊，啊啊啊啊！！
@Hitret id=15107

@Talk name=奈绪 voice=NO031226
啊，哈，哈……嗯呜……嗯，嗯，嗯！！
@Hitret id=15108

@Talk name=奈绪 voice=NO031227
对，对不起……我……嗯呜呜……啊，啊啊！
@Hitret id=15109

@Talk name=奈绪 voice=NO031228
要…去了……啊……嗯呜…啊，嗯唔唔！！
@Hitret id=15110

@Talk name=奈绪 voice=NO031229
小悠……来，来吧！！　在我的里面……嗯，全都射出来！！
@Hitret id=15111

@Talk name=奈绪 voice=NO031230
啊，啊啊……给我吧……嗯唔唔！！全都……射出来！！！
@Hitret id=15112

@Talk name=奈绪 voice=NO031231
啊呜……嗯呜……啊……啊啊……啊哈……
@Hitret id=15113

@Talk name=奈绪 voice=NO031232
嗯呜，嗯，啊，啊，啊，啊啊啊！！
@Hitret id=15114

@Talk name=奈绪 voice=NO031233
………嗯，嗯唔，嗯，嗯呜呜！！
@Hitret id=15115

@Talk name=奈绪 voice=NO031234
要，要去了……啊啊……啊啊！　嗯呜呜呜…
@Hitret id=15116

@Talk name=悠
唔……奈绪姐……！！！
@Hitret id=15117

@Talk name=奈绪 voice=NO031235
啊，啊！　啊啊！　嗯啊啊！！！
@Hitret id=15118


@Cg file=EB11b  
@Flash color=WHITE enter=0 leave=1000

@Talk name=奈绪 voice=NO031236
啊………嗯呜……啊哈啊啊啊啊啊啊啊！！
@Hitret id=15119

@Talk name=奈绪 voice=NO031237
……啊哈ー……啊啊……啊哈……啊ー………
@Hitret id=15120

@Talk name=奈绪 voice=NO031238
嗯呜……啊，啊啊……哈，哈，哈……嗯…
@Hitret id=15121

@Talk name=奈绪 voice=NO031239
进……进来了……在我的里面……热热的………
@Hitret id=15122

@Talk name=心の声
最后插入的一瞬间，我把精子注射进奈绪姐的洞府深处。
@Hitret id=15123

@Talk name=心の声
从射精的一瞬间开始我就下意识地浮动着腰，简直像是要让奈绪姐受精似的，将射入的精子推向更深处。
@Hitret id=15124

@Talk name=奈绪 voice=NO031240
啊……哈，啊……嗯唔……哈，哈，哈……
@Hitret id=15125

@Talk name=奈绪 voice=NO031241
呜……啊……
@Hitret id=15126

@Talk name=悠
奈，奈绪姐……唔………
@Hitret id=15127


@BlackOut


@Talk name=心の声
失去力气的奈绪姐，像是要跪倒在地上似的。
@Hitret id=15128

@Talk name=心の声
我强忍着疲惫的身躯，享受完最后一丝快感后也放松了身体。
@Hitret id=15129

@Talk name=心の声
我抱着奈绪姐的腰，就这样保持着融合的状态，慢慢地坐在地上。
@Hitret id=15130

@Talk name=心の声
融合的部位在不停地痉挛着。
@Hitret id=15131

@Talk name=心の声
虽然很微弱，但奈绪姐的阴道内壁仍旧刺激着我的阳具。
@Hitret id=15132

@Talk name=奈绪 voice=NO031242
小悠……太好了……
@Hitret id=15133

@Talk name=悠
我也是……嗯……啾……
@Hitret id=15134

@Talk name=奈绪 voice=NO031243
嗯……啾……
@Hitret id=15135

@Talk name=心の声
我们一言不发地抱在一起，回味着余韵。
@Hitret id=15136

@Talk name=心の声
能和心爱的人这样依偎在一起，心中就充满了幸福的感觉。
@Hitret id=15137

@Talk name=心の声
以前和奈绪姐缠绵在一起的时候又是怎样的呢？
@Hitret id=15138

@Talk name=心の声
那时……只是按照奈绪姐说的去做而已，可能还不是太清楚吧。
@Hitret id=15139

@Talk name=心の声
不过……想不到时过境迁还能和奈绪姐发展成恋爱的关系，令我的心情无比喜悦
@Hitret id=15140


@Recollect id=62

@Talk name=奈绪 voice=NO031244
做得真痛快呢………小悠……
@Hitret id=15141

@Talk name=悠
嗯……欣赏到了奈绪姐许多可爱的表情呢。
@Hitret id=15142

@Talk name=奈绪 voice=NO031245
我也是，听到了小悠好多好多可爱的声音呢。
@Hitret id=15143

@Talk name=悠
啊……是吗？
@Hitret id=15144

@Talk name=奈绪 voice=NO031246
嗯，母性本能都被你激发出来了…真是太可爱了。
@Hitret id=15145

@Talk name=奈绪 voice=NO031247
这份感情……我会好好珍惜的。
@Hitret id=15146

@Talk name=悠
我也是……
@Hitret id=15147

@Talk name=奈绪 voice=NO031248
谢谢你……小悠。我好喜欢你……
@Hitret id=15148

@Talk name=悠
我也……很喜欢奈绪姐。
@Hitret id=15149

@Talk name=奈绪 voice=NO031249
我真的……太高兴了……能和小悠心意相通……嗯…啾…
@Hitret id=15150

@Talk name=心の声
我们又是一个长长的深吻，为了互相加深感情。
@Hitret id=15151

@Talk name=心の声
炙热的身体冰冷了下来、直到刚才为止那种酷热难耐的感觉逐渐消失了，我们拥抱在一起感受着对方的体温。
@Hitret id=15152


@StopBgm

@ClearChar
@Update

@Cg file=B12b   

@EyeCatch
@Change target=00_b022


