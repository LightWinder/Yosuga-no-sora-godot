


@PlayBgm file=BGM05
@Cg file=B17a   

@Talk name=心の声
没有哪天比今天更让我觉得离下课如此之慢了。
@Hitret id=38571

@Talk name=心の声
几次我都想要从学校偷跑出去，但是一想到这样会给初佳小姐添麻烦就算了。
@Hitret id=38572

@Talk name=心の声
不去做自己应该做的事情的人，可能会被讨厌的因素也包括在里面。
@Hitret id=38573

@Talk name=心の声
因为初佳小姐，在这方面是很认真的人。
@Hitret id=38574

@Talk name=心の声
所以，
@Hitret id=38575


@Hide
@Cg file=B17b   
@Update
@PlaySe file=SE352

@Cg file=B19b   

@Talk name=心の声
等到所以的课程都结束，以往的会合时间也结束后，我飞奔出了教室。
@Hitret id=38576


@Hide
@Cg file=BLACK
@MessageFrame type=1
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@Update
@Cg file=B19b   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate

@Char file=CH01_04S 

@Talk name=班长 voice=KO050006
春日野君，今天是你扫除值日……
@Hitret id=38577


@Char file=CF01_03S 

@Talk name=亮平 voice=RH050367
哎呀委员长，这个就让我来做吧，所以就放他一马吧？
@Hitret id=38578


@Char file=CH01_01S 

@Talk name=班长 voice=KO050007
中里同学……？　明明平时都是率先跑掉的……
@Hitret id=38579


@Char file=CF01_06S 

@Talk name=亮平 voice=RH050368
什么！？　是说有把我这个教室美化委员会事务局长丢下，扫除这个教室的家伙么！
@Hitret id=38580


@ClearChar 
@Char file=CC01_02S 

@Talk name=瑛 voice=AK050140
啊~，我经常在扫除哦~？
@Hitret id=38581


@Char file=CD01_01S 

@Talk name=一叶 voice=KA050097
瑛是太简单就接受了啊……
@Hitret id=38582

@Talk name=瑛 voice=AK050141
不能放着有麻烦的人不管的哦~。
@Hitret id=38583


@Char file=CD01_06S 

@Talk name=一叶 voice=KA050098
不是有麻烦，只是想偷懒而已吧！
@Hitret id=38584


@Char file=CF01_02S 

@Talk name=亮平 voice=RH050369
算了算了大小姐，这里总之先稳便一点……
@Hitret id=38585


@ClearChar 
@Char file=CH01_11S 

@Talk name=班长 voice=KO050008
……认同你们做春日野君的代理，所以赶快扫除吧。
@Hitret id=38586


@ClearChar 

@Char file=CF01_02S 
@Char file=CC01_04S 

@Talk name=亮平 voice=RH050370
太好了！　那么就马上开始吧！
@Hitret id=38587


@Update
@action id=瑛 action=ActionAdvJump height=30 cycle=300 count=1
@WaitAction id=瑛

@Talk name=瑛 voice=AK050142
哇~！　扫除扫除啊！！　好了，小叶也一起！
@Hitret id=38588


@ClearChar 
@Char file=CD01_04S 

@Talk name=一叶 voice=KA050099
为什么连我也……反正也没事干就算了……
@Hitret id=38589


@ClearChar 

@Char file=CF01_08M 

@Talk name=亮平 voice=RH050371
……加油啊，悠……
@Hitret id=38590


@StopBgm

@Hide
@BlackOut time=1000
@MessageFrame

@Change target=00_e034b



