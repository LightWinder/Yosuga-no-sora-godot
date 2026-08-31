



@PlaySe file=SE352
@Cg file=B17a   
@Update
@Wait time=3000 
@Cg file=B19a   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Talk name=亮平 voice=RH000038
好极！　结束了结束了。
@Hitret id=1030


@PlayBgm file=BGM03
@PlaySe file=SE403

@Talk name=心の声
铃声结束之后，教室里立刻涌起了充满解放感的喧噪。
@Hitret id=1031

@Talk name=悠
呼……这种气氛感觉真是久违了啊……
@Hitret id=1032


@Char file=CH01_07M 

@Talk name=班长 voice=KO000009
春，春日野君。
@Hitret id=1033

@Talk name=悠
啊，班长。
@Hitret id=1034

@Talk name=班长 voice=KO000010
第，第一天转学过来，感觉怎么样呢？
@Hitret id=1035

@Talk name=悠
哈哈哈……一上来就有六节课要上，确实是会累呢。
@Hitret id=1036


@Char file=CH01_03M 

@Talk name=班长 voice=KO000011
呵呵，是呢。辛苦你了。
@Hitret id=1037

@Talk name=悠
不过仅仅这样就觉得累实在是太不像样子了，得快点习惯下来呢。
@Hitret id=1038

@Talk name=心の声
这时，班长手里拿着的有着相当的量的讲义映入了我的眼中。
@Hitret id=1039

@Talk name=悠
……啊，说起来，找我有什么事吗？
@Hitret id=1040


@Char file=CH01_02M 

@Talk name=班长 voice=KO000012
啊，是的。这个，老师说要交给你的讲义。还有这个，我现在有的笔记的复印。
@Hitret id=1041

@Talk name=班长 voice=KO000013
还有就是，等下要去订做校服的订单、服装店的地图和电话号码。订做的价格你知道吧？
@Hitret id=1042

@Talk name=悠
……嗯，看看订单的话勉强应该是能明白。谢谢你了，班长，特意替我把东西送过来。
@Hitret id=1043


@Char file=CH01_07M 

@Talk name=班长 voice=KO000014
不，没事……能帮上你的话，那就足够了……
@Hitret id=1044

@Talk name=悠
哎，这个笔记，记得清楚读起来很方便呢。这可真是帮大忙了啊……说实话今天的课我完全没明白，今后要靠这个笔记加油赶上进度了。
@Hitret id=1045

@Talk name=班长 voice=KO000015
没，没，没那回事，要是不嫌弃的话我的笔记什么时候都可以借你……
@Hitret id=1046


@Char file=CF01_05M 

@Talk name=亮平 voice=RH000039
哈哈，转校生，转学第一天就这么受欢迎啊真是让人羡慕啊，你这家伙！！
@Hitret id=1047


@PlaySe file=SE009
@action id=カメラ action=ActionWave width=0, height=32, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=悠
疼，好疼！？　喂，别闹啦！
@Hitret id=1048


@Char file=CH01_01M 

@Talk name=班长 voice=KO000016
不，我不过是作为同学普通的帮一下忙而已！没别的意思！
@Hitret id=1049


@Char file=CF01_04M 

@Talk name=亮平 voice=RH000040
也就是说，要是我遇上难事的话你也会来帮我的意思？
@Hitret id=1050


@Char file=CH01_10M 

@Talk name=班长 voice=KO000017
今天你辛苦了！
@Hitret id=1051


@ClearChar id=梢
@Char file=CF01_09M 

@Talk name=亮平 voice=RH000041
喂，等下啊！！
@Hitret id=1052

@Talk name=心の声
班长她匆匆忙忙地离开了教室。
@Hitret id=1054


@Char file=CF01_01M 

@Talk name=亮平 voice=RH000042
哈~怎么说呢，一点意思都没有啊。
@Hitret id=1055

@Talk name=悠
……什么没意思？
@Hitret id=1056

@Talk name=亮平 voice=RH000043
怎么说呢，转学过来的你却意外的有一大堆认识的人，顺顺利利的就融入环境里了……该说是没有转学生特有的新鲜感呢。
@Hitret id=1057

@Talk name=悠
就算你这么说……不是说了我小时候在这边住过几次，这也是没办法的事啊。
@Hitret id=1058

@Talk name=亮平 voice=RH000044
说的也是……不过，城里长大的人的话，在这边多少会有点辛苦吧？我会帮你的，尽管放心。
@Hitret id=1059

@Talk name=悠
哈哈……那就靠你了。
@Hitret id=1060


@Char file=CF01_02M 

@Talk name=亮平 voice=RH000045
好，为了加深我们的友谊，去买点什么吃完闪人吧！
@Hitret id=1061

@Talk name=悠
啊，对不起，能不能下次再去？
@Hitret id=1062


@Char file=CF01_10M 
@Update
@Move id=亮平 my=50 cycle=1000
@WaitAction id=亮平

@Talk name=亮平 voice=RH000046
哎－什么啊。话音没落就这么不配合。
@Hitret id=1063

@Talk name=悠
不是，今天真的不早点回去不行。
@Hitret id=1064


@Char file=CF01_01M 
@Update
@Move id=亮平 y=0 cycle=0
@WaitAction id=亮平

@Talk name=亮平 voice=RH000047
嗯？　有和谁约什么事吗？
@Hitret id=1065

@Talk name=悠
也不是约定，不过是把妹妹一个人放家里实在是太担心了。
@Hitret id=1066


@StopBgm fade=0
@PlayBgm file=BGM14
@Char file=CF01_06M 
@Update
@action id=亮平 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=亮平
@Font face=36

@Talk name=亮平 voice=RH000048
妹妹！？
@Hitret id=1067

@Talk name=悠
嗯。
@Hitret id=1068

@Talk name=亮平 voice=RH000049
谁的？
@Hitret id=1069

@Talk name=悠
当然是……我的。
@Hitret id=1070


@Char file=CF01_05M 

@Talk name=亮平 voice=RH000050
呵呵~……如果是兄妹的话应该多少比较像吧……
@Hitret id=1071

@Talk name=悠
干，干嘛盯着我的脸看啊？
@Hitret id=1072


@Char file=CF01_02L 

@Talk name=亮平 voice=RH000051
哥哥……来，让我们一起回家吧！
@Hitret id=1073

@Talk name=悠
…………
@Hitret id=1074


@PlayBgm file=BGM05
@Cg file=B20a center=550,300
@Char file=CB01_01M 
@Update transition=universal rule=WIP_MOZV time=500
@WaitUpdate

@Talk name=奈绪 voice=NO000099
啊，小悠！
@Hitret id=1075


@Char file=CB01_05M 

@Talk name=奈绪 voice=NO000100
………哎呀，你也在啊……
@Hitret id=1076


@Char file=CF01_01M 

@Talk name=亮平 voice=RH000052
啊啊，悠我收下了啊。
@Hitret id=1077


@Char file=CB01_01M 

@Talk name=奈绪 voice=NO000101
小悠，这种让人恶心的家伙还是不要理比较好哦？
@Hitret id=1078

@Talk name=悠
啊哈哈哈……
@Hitret id=1079


@Char file=CF01_05M 

@Talk name=亮平 voice=RH000053
说人恶心也太失礼了吧，我明明这么值得依靠的啊。
@Hitret id=1080

@Talk name=奈绪 voice=NO000102
哼……值得依靠啊？
@Hitret id=1081


@Char file=CF01_06M 

@Talk name=亮平 voice=RH000054
别，别把我当傻子看！　你，你怎么想啊，悠？
@Hitret id=1082

@Talk name=悠
哎……嗯，嗯，这个……
@Hitret id=1083


@Char file=CB01_08M 

@Talk name=奈绪 voice=NO000103
你看，小悠一脸微妙的表情。
@Hitret id=1084


@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=亮平 voice=RH000055
喂，喂，悠，我们是死党的吧！？
@Hitret id=1085

@Talk name=瑛 voice=AK000035
啊，亮哥哥！
@Hitret id=1086


@ClearChar 
@Char file=CC01_01M 
@Char file=CD01_07M 

@Talk name=亮平 voice=RH000056
怎么了，你们也准备回去了吗？
@Hitret id=1087

@Talk name=瑛 voice=AK000036
嗯，是啊ー。
@Hitret id=1088

@Talk name=一叶 voice=KA000024
………………
@Hitret id=1089

@Talk name=瑛 voice=AK000037
反正回去的方向也一样，大家一起回去吧。
@Hitret id=1090


@Char file=CD01_01M 

@Talk name=一叶 voice=KA000025
……啊，我……
@Hitret id=1091


@ClearChar 
@Char file=CE01_11M 

@Talk name=女仆 voice=MT000001
恭，恭候您多时了……大小姐。
@Hitret id=1092

@Talk name=悠
……哎？
@Hitret id=1093

@Talk name=心の声
面对出乎意料的声音，我将视线转了过去，在那里的是一辆汽车和……
@Hitret id=1094

@Talk name=女仆 voice=MT000002
…………
@Hitret id=1095


@Char file=CD01_02M 

@Talk name=一叶 voice=KA000026
谢谢，乃木坂小姐。
@Hitret id=1096

@Talk name=心の声
怎，怎么回事？　那，那个装扮是，所谓的……女仆！？
@Hitret id=1097

@Talk name=心の声
不管怎么看都是像会在电视剧或者电影里出现的身着女仆装的女性站在那里。
@Hitret id=1098

@Talk name=心の声
现在的话，在城里的电器街是不是应该也能看到呢？
@Hitret id=1099

@Talk name=心の声
她看上去要比我们稍微年长一些。
@Hitret id=1100

@Talk name=心の声
她看上去一脸害羞，像是在在意周围的视线……不过，穿这身行头的话，倒也的确会有点不自在呢。
@Hitret id=1101

@Talk name=心の声
似乎就连操场那边的人也在往这边看的样子。
@Hitret id=1102


@ClearChar id=初佳
@Char file=CD01_02M 

@Talk name=一叶 voice=KA000027
那么，瑛，不好意思，我先走一步了。
@Hitret id=1103


@Char file=CC01_02M 

@Talk name=瑛 voice=AK000038
拜拜！　小叶。
@Hitret id=1104


@ClearChar 

@Talk name=心の声
渚同学向我们低头一行礼之后，向着车子的方向走去。
@Hitret id=1105


@Char file=CE01_03M 

@Talk name=女仆 voice=MT000003
对不起了，各位~。
@Hitret id=1106

@Talk name=心の声
一边用单手向我们道着歉，女仆跟在渚同学的后面一同离开了。
@Hitret id=1107


@ClearChar id=初佳
@Update
@PlaySe file=SE263
@WaitSe
@PlaySe file=SE260

@Talk name=心の声
然后，渚同学和女仆小姐所搭乘的汽车发出沉闷的引擎声开走了。
@Hitret id=1108


@Char file=CC01_01M 
@Char file=CF01_01M 

@Talk name=亮平 voice=RH000057
今天大小姐是有事要办啊？
@Hitret id=1109

@Talk name=瑛 voice=AK000039
嗯，好像是要去参加她爸爸开的聚餐会。
@Hitret id=1110

@Talk name=亮平 voice=RH000058
嗯，还是一如既往的大忙人啊。
@Hitret id=1111

@Talk name=悠
真厉害啊，又有车接又有女仆的……渚同学她原来是大小姐的啊。
@Hitret id=1112


@Char file=CC01_03M 

@Talk name=瑛 voice=AK000040
嗯，是啊ー。
@Hitret id=1113


@Char file=CF01_03M 

@Talk name=亮平 voice=RH000059
所谓的名人令嫒啊，奥木染的。
@Hitret id=1114

@Talk name=悠
名人……？
@Hitret id=1115

@Talk name=亮平 voice=RH000060
确实我记得是议员来的吧，大小姐她爸爸。
@Hitret id=1116

@Talk name=悠
这样啊……
@Hitret id=1117


@ClearChar id=瑛
@Char file=CF01_01M 

@Talk name=亮平 voice=RH000061
不过，你住的地方的话，社长家和政治家，家的大小姐也是遍地都是吧？
@Hitret id=1118

@Talk name=悠
不知道耶，我认识的人里面是没有。
@Hitret id=1119

@Talk name=悠
而且，我住的城市也并算不上是大都会。不过是普通的住宅街罢了。
@Hitret id=1120


@Char file=CF01_07M 

@Talk name=亮平 voice=RH000062
什么啊，没意思。
@Hitret id=1121

@Talk name=悠
哈哈，有意思的事情也不是说有就有的。
@Hitret id=1122


@Char file=CF01_01M 

@Talk name=亮平 voice=RH000063
说的也是。嗯，那么我们也速度闪人吧。
@Hitret id=1123


@Char file=CB01_01M 

@Talk name=奈绪 voice=NO000104
对呢，小悠，一起回去吧。
@Hitret id=1124


@ClearChar 

@Talk name=心の声
就这样，我上学的第一天结束了。
@Hitret id=1125

@Talk name=心の声
最一开始我还想着要是这里有那种乡下特有的封闭感的话，就糟糕了，不过今天一天和各式各样的人搭过话之后，心里存在的偏见已经消失得无影无踪，更重要的是我觉得非常的开心。
@Hitret id=1126

@Talk name=心の声
……虽然可能仅仅是因为转校生非常少见而已。
@Hitret id=1127

@Talk name=心の声
不过一到这里就立刻交到了死党……？　像是死党一样的朋友，不禁有种今后也会一帆风顺的感觉。
@Hitret id=1128

@Talk name=心の声
接下来只要穹能好好的来学校上学的话……
@Hitret id=1129


@StopBgm

@ClearChar
@Update

@Cg file=B02a   

@EyeCatch

@Change target=00_z008


