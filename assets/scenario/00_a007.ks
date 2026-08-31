


@PlaySe file=SE352
@PlayBgm file=BGM06
@Cg file=B19a   

@Talk name=亮平 voice=RH010049
接下来是体育，所以得走人了。
@Hitret id=3187


@Char file=CF01_01M 

@Talk name=悠
诶？嗯，是去更衣室么。
@Hitret id=3188

@Talk name=亮平 voice=RH010050
不是，没这么正式的地方。所以男女生就分开教室换衣服了。
@Hitret id=3189

@Talk name=悠
哦，是这样啊。
@Hitret id=3190

@Talk name=亮平 voice=RH010051
这边的教室是女生用的，所以我们必须到其他地方去。
@Hitret id=3191


@Char file=CC01_02M 

@Talk name=瑛 voice=AK010043
好~。啊，是了，得把小穹接过来呢。
@Hitret id=3192

@Talk name=悠
啊，嗯，拜托了。如果不管的话，我怕她会一直待在那个教室。
@Hitret id=3193


@Char file=CF01_03M 

@Talk name=亮平 voice=RH010052
这样啊，这样不是很好么。
@Hitret id=3194


@Char file=CF01_05M 

@Talk name=亮平 voice=RH010053
一边被冷冷的目光盯着一边换衣服。
@Hitret id=3195


@ClearChar 
@Cg file=WHITE
@Update
@Cg file=SP51
@Update transition=universal rule=CLOUD_A time=1500
@WaitUpdate

@Talk name=穹 voice=SR010150
……盯…………
@Hitret id=3196

@Talk name=心の声
这个好可怕。
@Hitret id=3197


@Cg file=B19a   
@Char file=CD01_04M 
@Char file=CF01_01M 

@Talk name=一叶 voice=KA010016
中里前辈，真下流。
@Hitret id=3198


@Char file=CF01_02M 

@Talk name=亮平 voice=RH010054
是是，抱歉啦小叶。
@Hitret id=3199


@Char file=CD01_13M 

@Talk name=一叶 voice=KA010017
咳！？请，请不要这样称呼我！
@Hitret id=3200

@Talk name=亮平 voice=RH010055
哈哈哈哈，悠我们走吧。
@Hitret id=3201


@Hide
@Cg file=B18a   
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@Update
@Wait time=1000 
@Cg file=B19a   
@Char file=CA01_01M 
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate

@Talk name=穹 voice=SR010151
…………悠？
@Hitret id=3202


@Char file=CC01_02M 

@Talk name=瑛 voice=AK010044
我们来接你了，小穹。
@Hitret id=3203

@Talk name=穹 voice=SR010152
……诶？
@Hitret id=3204

@Talk name=瑛 voice=AK010045
下节课是体育，在我们的教室换衣服哦。
@Hitret id=3205

@Talk name=悠
嗯，所以穹要去那边的教室哦。麻烦你了，天女目。
@Hitret id=3206

@Talk name=瑛 voice=AK010046
嗯~一会儿见~。
@Hitret id=3207


@Char file=CC01_02M x=0  
@Char file=CA01_12M x=200  

@Talk name=穹 voice=SR010153
！？悠，悠！？
@Hitret id=3208


@ClearChar 

@Talk name=心の声
穹被天女目推着背押送出了教室。
@Hitret id=3209


@Char file=CF01_04M 

@Talk name=亮平 voice=RH010056
要真是在这儿换，也没什么关系的嘛。
@Hitret id=3210



@Talk name=悠
肯定是会被无视的，不过心情会变得很糟啊。好了，别说傻话了，快点换衣服。
@Hitret id=3211



@Hide
@BlackOut time=1000
@Wait time=1500 
@Cg file=B20a   
@Char file=CF05_10M 

@Talk name=亮平 voice=RH010057
啧……这么热，还让人跑啊……
@Hitret id=3212

@Talk name=悠
好热啊……从前这边感觉很凉爽的，现在这样跟城市完全没什么差别了啊。
@Hitret id=3213


@Char file=CF05_03M 

@Talk name=亮平 voice=RH010058
这也是拜全球变暖所赐吧。游泳池早点开放就好了。
@Hitret id=3214

@Talk name=悠
游泳池？……说起来，现在这个时期即使已经开放了也不会感觉奇怪呢。
@Hitret id=3215


@Char file=CF05_01M 

@Talk name=亮平 voice=RH010059
嗯，如果开放了的话，奈绪那家伙也是游泳部的，和她说一声下课后就可以随意使用了。
@Hitret id=3216

@Talk name=悠
啊……对啊。奈绪是游泳部的呢。
@Hitret id=3217

@Talk name=亮平 voice=RH010060
那家伙很强的，穿着泳衣感觉就更胜一筹了。
@Hitret id=3218

@Talk name=悠
诶？是这样么？
@Hitret id=3219


@Char file=CF05_05M 

@Talk name=亮平 voice=RH010061
比如平时看不到的地方啊，就会很不象话的暴露出来哦。
@Hitret id=3220

@Talk name=悠
是，是说这个啊……
@Hitret id=3221


@Char file=CF05_02M 

@Talk name=亮平 voice=RH010062
什么啊，在这装什么酷啊你这家伙！
@Hitret id=3222


@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=悠
呜哇哇哇……别，别这样……我，我投降！
@Hitret id=3223


@ClearChar 

@Talk name=心の声
在这种晒死人的日子还被人用关节技就更悲剧了。
@Hitret id=3224


@Char file=CC05_02M 

@Talk name=瑛 voice=AK010047
啊咧，今天的体育课是摔跤？
@Hitret id=3225


@Char file=CD05_01M 

@Talk name=一叶 voice=KA010018
不是哦，他们只是在做些无聊的事。
@Hitret id=3226

@Talk name=悠
疼疼疼……啊，女生今天是上什么内容？
@Hitret id=3227


@Char file=CC05_01M 

@Talk name=瑛 voice=AK010048
一会儿就开始上垒球课。
@Hitret id=3228

@Talk name=悠
啊，是这样么。
@Hitret id=3229

@Talk name=心の声
男生也一样……上同样的内容还真少见啊。
@Hitret id=3230


@ClearChar 
@Char file=CF05_01M 
@StopBgm

@Talk name=亮平 voice=RH010063
嗯？小穹呢？
@Hitret id=3231


@Char file=CA05_01M 

@Talk name=穹 voice=SR010154
…………
@Hitret id=3232


@PlayBgm file=BGM14
@Char file=CF05_02M 

@Talk name=亮平 voice=RH010064
唔呀！！小穹！！
@Hitret id=3233


@Char file=CA05_13M 

@Talk name=穹 voice=SR010155
……咿！？
@Hitret id=3234

@Talk name=心の声
亮平举着双手像跳舞般奔过去。
@Hitret id=3235


@PlaySe file=se003
@Flash color=RED enter=0 leave=500
@Char file=CF05_06M 
@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=亮平 voice=RH010065
咕哇！？
@Hitret id=3236


@ClearChar 
@Char file=CH05_04M 
@PlaySe file=se018

@Talk name=班长 voice=KO010001
是是，男生请去那边。
@Hitret id=3237

@Talk name=悠
唔哇……亮平，没关系么？
@Hitret id=3238

@Talk name=心の声
可怜的亮平被皮手套射过来的闪电般的垒球……ＫＯ了。
@Hitret id=3239


@Char file=CF05_03M 

@Talk name=亮平 voice=RH010066
真，真行啊，班长。
@Hitret id=3240


@Char file=CC05_12M 

@Talk name=瑛 voice=AK010049
……亮哥哥，好像流鼻血了哦？
@Hitret id=3241


@Char file=CF05_06M 

@Talk name=亮平 voice=RH010067
唔哇，不行……班长，你给我记着！
@Hitret id=3242


@ClearChar 

@Talk name=悠
穹，没有受伤吧？
@Hitret id=3243


@Char file=CA05_05M 

@Talk name=穹 voice=SR010156
……悠才要注意呢。
@Hitret id=3244

@Talk name=悠
那么，麻烦你们了，渚同学，还有班长。
@Hitret id=3245


@Char file=CD05_02M 

@Talk name=一叶 voice=KA010019
嗯，没关系的。
@Hitret id=3246


@StopBgm
@Char file=CH05_07M 

@Talk name=班长 voice=KO010002
……是，是……！
@Hitret id=3247


@ClearChar 

@Talk name=悠
亮平，不去保健室没关系么？
@Hitret id=3248


@PlayBgm file=BGM05
@Char file=CF05_04M 

@Talk name=亮平 voice=RH010068
啊啊，跑到保健室去的话，就看不到女生的娇态了，会亏的。
@Hitret id=3249

@Talk name=心の声
亮平捏住鼻子仰面向天。
@Hitret id=3250

@Talk name=悠
……流鼻血的时候不要面朝天比较好哦。
@Hitret id=3251


@Char file=CF05_02M 

@Talk name=亮平 voice=RH010069
嗯？是这样吗？嘛，不管怎么说止血了就好。
@Hitret id=3252

@Talk name=悠
话说……就那么想看吗？
@Hitret id=3253


@Char file=CF05_04M 

@Talk name=亮平 voice=RH010070
哦哦，想看。
@Hitret id=3254

@Talk name=心の声
自以为很帅的样子，亮平竖起大拇指。
@Hitret id=3255

@Talk name=心の声
嘛，体育课的时候视线转到女生那边时的心情我也是能够理解的……
@Hitret id=3256

@Talk name=心の声
除了亮平以外，望着女生那边的男生大有人在。
@Hitret id=3257

@Talk name=心の声
而且，一半以上是向着穹去的。
@Hitret id=3258


@Char file=CF05_01M 

@Talk name=亮平 voice=RH010071
嗯嗯，这么快人气就这么高了啊……
@Hitret id=3259


@ClearChar id=亮平

@Talk name=心の声
和穹组成一对的天女目一直在她的边上。
@Hitret id=3260

@Talk name=心の声
旁边还有渚同学和班长，多少也算能放心了……
@Hitret id=3261


@Char file=CA05_09S 

@Talk name=心の声
不过从今天垒球课开始，穹就孤零零地站在防守位上，百无聊赖的样子。
@Hitret id=3262

@Talk name=心の声
还没有习惯体操服吗，穿着运动短裤的穹有点忸忸怩怩的样子。
@Hitret id=3263

@Talk name=悠
…………
@Hitret id=3264

@Talk name=心の声
确实，转校生以这样的身姿出现……还是很在意的吧。
@Hitret id=3265

@Talk name=心の声
至于年级里的男生们，他们有没有觉得很傲气什么的我不清楚，不过还是受到了什么神秘气氛的影响么？
@Hitret id=3266

@Talk name=心の声
但是，如果他们看到亮平一个不慎重就狠狠的吃了一记，不知道又会怎么想呢……
@Hitret id=3267


@Talk name=瑛 voice=AK010050
小穹！
@Hitret id=3268


@Char file=CC05_02S 

@Talk name=心の声
天女目从中心处向着穹的方向移动。
@Hitret id=3269

@Talk name=心の声
虽然和穹的体型差不多，可是其灵敏的动作却和穹形成鲜明的对比。
@Hitret id=3270

@Talk name=悠
……但是两个人放一起看的话，总感觉穹像低年级的后辈呢。
@Hitret id=3271

@Talk name=亮平 voice=RH010072
嗯？什么？
@Hitret id=3272

@Talk name=悠
啊，我是说天女目。
@Hitret id=3273

@Talk name=亮平 voice=RH010073
哦？说来说去，你不也在看嘛。
@Hitret id=3274

@Talk name=悠
……确实，我在担心穹是不是好好在练习呢。
@Hitret id=3275


@ClearChar 
@Char file=CD05_01S 
@Char file=CH05_01S 

@Talk name=亮平 voice=RH010074
嗯，嘛，看上去有瑛跟着，而且班长和大小姐也在边上，不会有事的。
@Hitret id=3276

@Talk name=悠
啊，嗯。我也是这么想……不过还是不太放心。
@Hitret id=3277

@Talk name=心の声
……亮平意外地也有在好好看着呢。
@Hitret id=3278

@Talk name=亮平 voice=RH010075
那么！班长和大小姐如何？
@Hitret id=3279

@Talk name=悠
……如何？是什么意思？
@Hitret id=3280

@Talk name=亮平 voice=RH010076
唔。综合指数是大小姐高，不过班长也可以颁一个“羚羊美腿奖”。
@Hitret id=3281

@Talk name=悠
羚羊美腿奖是……
@Hitret id=3282

@Talk name=亮平 voice=RH010077
你注意下班长，那对意外苗条的长腿不是看点吗？
@Hitret id=3283

@Talk name=悠
……嗯，嘛，感觉是很漂亮。
@Hitret id=3284

@Talk name=亮平 voice=RH010078
大小姐果然还是自身素质高啊。那，你的基准是胸？腿？还是腰？
@Hitret id=3285

@Talk name=悠
唔，没怎么深入地考虑过……我想我会比较中意我喜欢上的人吧？
@Hitret id=3286


@ClearChar 
@Char file=CF05_03M 

@Talk name=亮平 voice=RH010079
喂喂，“喜欢喜欢的人的类型！”这种跟中学生的一样话就不要说啦。
@Hitret id=3287

@Talk name=悠
别，就算你这么说……
@Hitret id=3288



@Hide
@BlackOut time=1000
@MessageFrame type=1
@Cg file=B20a   
@Char file=CH05_11M 
@Char file=CD05_04M 

@Talk name=班长 voice=KO010003
……总觉得在说一些不着边际的话呢。
@Hitret id=3289

@Talk name=一叶 voice=KA010020
诶诶，毕竟是中里前辈这种无可救药的人哪。
@Hitret id=3290

@Talk name=班长 voice=KO010004
春日野君被奇怪的人缠上了真可怜……
@Hitret id=3291


@ClearChar 
@Char file=CC05_01M 

@Talk name=瑛 voice=AK010051
诶？亮哥哥不是很有趣嘛。是不是呢，小穹？
@Hitret id=3292


@Char file=CA05_13M 

@Talk name=穹 voice=SR010157
诶……什么？
@Hitret id=3293


@Char file=CC05_02M 

@Talk name=瑛 voice=AK010052
啊，在看着悠君啊……小穹最喜欢悠君了呢。
@Hitret id=3294


@Char file=CA05_11M 

@Talk name=穹 voice=SR010158
……人，人家才不是因为悠呢……
@Hitret id=3295


@Char file=CC05_14M 

@Talk name=瑛 voice=AK010053
哼哼，明明不需要隐瞒比较好的。
@Hitret id=3296

@Talk name=穹 voice=SR010159
真的，不是那样啦……
@Hitret id=3297


@Char file=CC05_01M 

@Talk name=瑛 voice=AK010054
害羞了哦……啊，有什么东西飞过来了。
@Hitret id=3298



@Hide
@BlackOut time=1000
@Cg file=B20a   

@Talk name=心の声 voice=SR010160
男生练习用的垒球从眼前飞了过来。
@Hitret id=3299

@Talk name=亮平 voice=RH010080
小穹，这边这边！！传球！！攻入我的心！
@Hitret id=3300

@Talk name=悠
穹！把那个球扔过来！
@Hitret id=3301

@Talk name=心の声 voice=SR010161
不知道这边情况的悠就这样挥着手……
@Hitret id=3302

@Talk name=穹 voice=SR010162
真是……嘿！！
@Hitret id=3303

@Talk name=心の声 voice=SR010163
就像要发泄一下从涌入心中的各种感情一样，把球投了回去。
@Hitret id=3304


@PlaySe file=se003
@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=150 
@WaitAction id=カメラ

@Talk name=亮平 voice=RH010081
咕哈啊！？
@Hitret id=3305

@Talk name=心の声 voice=SR010164
对着悠投出去的球，完全向着歪曲的反向飞去了。
@Hitret id=3306


@PlaySe file=se018

@Talk name=悠
……没事吧，亮平？
@Hitret id=3307

@Talk name=穹 voice=SR010165
…………
@Hitret id=3308

@Talk name=心の声 voice=SR010166
被击中的人好像倒地了。
@Hitret id=3309


@Char file=CC05_01M 

@Talk name=瑛 voice=AK010055
啊哈，小穹的方向控制得真好！
@Hitret id=3310

@Talk name=穹 voice=SR010167
并，并不是瞄准那里的……
@Hitret id=3311


@Char file=CD05_04M 

@Talk name=一叶 voice=KA010021
嘛，正好给中里前辈一个教训。
@Hitret id=3312


@Char file=CH05_08M 

@Talk name=班长 voice=KO010005
嗯嗯，不过给春日野君带来了额外的负担了……
@Hitret id=3313

@Talk name=心の声 voice=SR010168
悠让倒下的人靠着自己的肩膀，向着球场外走去。
@Hitret id=3314

@Talk name=瑛 voice=AK010056
没关系的，亮哥哥就像外表看上去的那样结实。
@Hitret id=3315

@Talk name=穹 voice=SR010169
…………嗯。
@Hitret id=3316

@Talk name=心の声 voice=SR010170
可以尽情地投球，感觉稍稍有些痛快。
@Hitret id=3317

@Talk name=心の声 voice=SR010171
并且，没打到悠真是太好了，稍微有些矛盾的心情。
@Hitret id=3318

@Talk name=心の声 voice=SR010172
不管是哪种心情，都在我的心中存在。
@Hitret id=3319

@Talk name=穹 voice=SR010173
…………
@Hitret id=3320


@StopBgm

@ClearChar
@Update

@Cg file=B19a   

@EyeCatch
@MessageFrame

@Change target=00_a008


