



@PlaySe file=SE356

@Cg file=B34a   
@PlayBgm file=BGM15

@Talk name=心の声
哦……这个焰火就是开始的信号啊。
@Hitret id=29108

@Talk name=悠
快一点，穹，大家可能已经都到了哦？
@Hitret id=29109


@Char file=CA03_01M 

@Talk name=穹 voice=SR040091
……像小孩子一样。
@Hitret id=29110

@Talk name=悠
诶，但是很快乐吧？
@Hitret id=29111

@Talk name=穹 voice=SR040092
困。
@Hitret id=29112

@Talk name=心の声
穹“呼”的伸了个可爱的懒腰，然后揉了揉眼睛。
@Hitret id=29113

@Talk name=悠
怎么，穹也因为太兴奋了而没睡好觉吗？
@Hitret id=29114


@Char file=CA03_05M 

@Talk name=穹 voice=SR040093
……太热了。
@Hitret id=29115

@Talk name=悠
这、这样啊……
@Hitret id=29116

@Talk name=心の声
虽然原本就没什么兴趣，今天看来也没什么干劲。
@Hitret id=29117

@Talk name=悠
总之快一点，天女目和渚可能已经在等了。
@Hitret id=29118

@Talk name=穹 voice=SR040094
……好好。
@Hitret id=29119


@ClearChar 

@Talk name=心の声
今天就是已经准备很久的祭典当天了。
@Hitret id=29120

@Talk name=心の声
如果是以往的话，就只在晚上进行参拜和逛逛露天小店，但今天会去稍微帮下忙。
@Hitret id=29121

@Talk name=心の声
虽然没听到要帮些什么，不过能体验舞台的后台工作也是一个宝贵的经历。
@Hitret id=29122

@Talk name=悠
……嘿咻……。
@Hitret id=29123

@Talk name=心の声
走在平时的小道上，看着路旁被用漂亮饰品装饰起来的石碑。
@Hitret id=29124

@Talk name=心の声
做这个饰品时我也帮了忙的啊，这样想着，不禁心中升起一股自豪感。
@Hitret id=29125


@PlaySe file=SE358

@Talk name=悠
双手合十，然后……啪啪，像这样。
@Hitret id=29126


@Char file=CA03_01M 

@Talk name=穹 voice=SR040095
……干嘛？
@Hitret id=29127

@Talk name=悠
稍微参拜下……这样就好了。
@Hitret id=29128

@Talk name=穹 voice=SR040096
嗯。
@Hitret id=29129

@Talk name=悠
哪，不赶快的话就要迟到了哦，穹！
@Hitret id=29130

@Talk name=穹 voice=SR040097
啊，悠………………明明是你自己停了下来的。
@Hitret id=29131


@Hide
@Cg file=BLACK
@Update transition=universal rule=WIP_RL time=500
@WaitUpdate
@Update

@Cg file=B07d   
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@Update
@Char file=CF03_01M 

@Talk name=亮平 voice=RH040178
哦，来了。
@Hitret id=29132


@Char file=CB03_01M 

@Talk name=奈绪 voice=NO040028
早上好，小悠，小穹。
@Hitret id=29133


@ClearChar id=奈緒

@Char file=CF03_02M 
@Update
@action id=亮平 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=亮平

@Talk name=亮平 voice=RH040179
唔唷唷！　小~穹！！！
@Hitret id=29134

@Talk name=穹 voice=SR040098
呀！？
@Hitret id=29135


@PlaySe file=se011
@Flash color=WHITE enter=0 leave=100
@Char file=CF03_06M 
@Update
@Move id=亮平 my=50 cycle=1000
@WaitAction id=亮平

@Talk name=亮平 voice=RH040180
呃呜呀！？
@Hitret id=29136


@clearChar id=-1

@PlaySe file=se018

@Talk name=心の声
这个吐槽的声音是……
@Hitret id=29137


@Char file=CD03_04M 
@Char file=CC06_02M 

@Talk name=一叶 voice=KA040465
都这个时候你还在做什么啊……
@Hitret id=29138

@Talk name=瑛 voice=AK040283
欢迎大家。今天多谢了。
@Hitret id=29139

@Talk name=悠
渚……和天女目，早上好，我们是不是稍微来迟了点……
@Hitret id=29140

@Talk name=心の声
渚穿着和服……可能是没怎么见过的一套装扮……
@Hitret id=29141

@Talk name=心の声
果然和气质很搭配，真漂亮啊……
@Hitret id=29142


@ClearChar id=瑛
@Char file=CD03_10M 

@Talk name=一叶 voice=KA040466
怎、怎么了，春日野君……不要像这样看着我啊……
@Hitret id=29143

@Talk name=悠
对、对不起，不知不觉就看入迷了。
@Hitret id=29144

@Talk name=一叶 voice=KA040467
看、看入迷……
@Hitret id=29145

@Talk name=悠
啊，不是……
@Hitret id=29146

@Talk name=心の声
是因为祭典气氛的原因吗，感觉情绪都变得异常了。
@Hitret id=29147

@Talk name=心の声
在参拜道路旁摆着的露天小店已经开始准备了，炒面、以及薄煎饼的香味隐约可闻。
@Hitret id=29148

@Talk name=心の声
情绪一下子就高涨起来也是没办法的事吧？
@Hitret id=29149

@Talk name=悠
对、对了！　帮忙的事，我们都要做些什么呢？
@Hitret id=29150


@Char file=CD03_02M 

@Talk name=一叶 voice=KA040468
啊，对啊，春日野君你们是……
@Hitret id=29151


@ClearChar 

@Char file=CF03_01M 

@Talk name=亮平 voice=RH040181
我们男同志一起做杂物，就是体力活之类的，有很多很多要做吧？
@Hitret id=29152

@Talk name=悠
穹呢？
@Hitret id=29153

@Talk name=亮平 voice=RH040182
我的专属秘书……
@Hitret id=29154


@PlaySe file=se011
@Flash color=WHITE enter=0 leave=100
@ClearChar id=亮平

@Char file=CD03_02M 

@Talk name=一叶 voice=KA040469
穹和我、还有依媛前辈一起来迎接宾客了。
@Hitret id=29155


@Char file=CA03_01M 

@Talk name=穹 voice=SR040099
……嗯。
@Hitret id=29156


@ClearChar id=一葉

@Char file=CC06_01M 

@Talk name=瑛 voice=AK040284
啊，还有多余的巫女服？　要穿的话来这里哦。
@Hitret id=29157


@Char file=CA03_13M 

@Talk name=穹 voice=SR040100
…………不、不用了…………
@Hitret id=29158


@ClearChar 

@Talk name=悠
说起巫女，今天除了天女目外还有其他巫女呢。
@Hitret id=29159

@Talk name=心の声
在社务所的小卖店里，坐着和天女目穿着同样巫女服，但却从没见过的人。
@Hitret id=29160

@Talk name=心の声
店深处好像也有什么人。
@Hitret id=29161


@Char file=CF03_02L 

@Talk name=亮平 voice=RH040183
呀——，这位先生，看上了巫女小姐还真是有眼光啊。
@Hitret id=29162

@Talk name=亮平 voice=RH040184
红与白的鲜明对比！　光润的黑发、娴静的举止！　清纯又可爱！
@Hitret id=29163

@Talk name=亮平 voice=RH040185
咕~~~，已经忍不住了！　这就是所谓的“萌”吧？！
@Hitret id=29164

@Talk name=悠
……呃，不要贴过来，热得难受，我可没像这样想过。
@Hitret id=29165


@ClearChar 

@Char file=CD03_04M 

@Talk name=一叶 voice=KA040470
对于这个神圣的职业你都在想些什么啊……她们只是从镇上的神社过来帮忙罢了。
@Hitret id=29166


@Char file=CD03_02M 

@Talk name=一叶 voice=KA040471
还有其他人也是，像宮司先生和居委会的人们都是来帮忙的，只有瑛一个人是没有办法举行祭典的。
@Hitret id=29167

@Talk name=悠
这个神社，平常就只有天女目在吗？
@Hitret id=29168

@Talk name=一叶 voice=KA040472
嗯，神主是瑛祖父的友人，因为这里的神社也归属到镇上，所以会每周过来一次看看。
@Hitret id=29169

@Talk name=一叶 voice=KA040473
瑛就负责神社的管理和打扫，以此为条件而住在这。
@Hitret id=29170

@Talk name=悠
诶—，是这样啊。
@Hitret id=29171

@Talk name=心の声
再次环视周围，已经有相当数量的人来了。
@Hitret id=29172

@Talk name=心の声
像这种规模的祭典，即使有我们帮忙可能也还会很辛苦吧。
@Hitret id=29173


@Char file=CB03_01M 

@Talk name=奈绪 voice=NO040029
好~好~，聊天就到此为止，现在是工作时间了哦。
@Hitret id=29174

@Talk name=奈绪 voice=NO040030
特别是渚，宾客也差不多该来了，快点吧。
@Hitret id=29175

@Talk name=一叶 voice=KA040474
啊……不好意思，穹也走吧。
@Hitret id=29176


@ClearChar 

@Char file=CC06_01M 

@Talk name=瑛 voice=AK040285
大家~，忙完后一起逛露天小店吧。
@Hitret id=29177



@Hide
@BlackOut time=1000

@Cg file=B07a   


@Talk name=悠
接下来，这种东西就行了吗……
@Hitret id=29178

@Talk name=亮平 voice=RH040186
啊啊，这样不是很好吗？
@Hitret id=29179

@Talk name=心の声
神签和护符等，社务所小卖铺里卖的东西都装在了瓦楞箱里，接着把它们搬到神社院内去。
@Hitret id=29180

@Talk name=心の声
领取了箱子，然后向着社务所院内搬运。
@Hitret id=29181

@Talk name=心の声
往常都是自己买的东西，而现在由自己来搬运，总觉得做这种工作……还挺有趣的。
@Hitret id=29182

@Talk name=心の声
我们搬过去的箱子，被从镇上请来帮忙的巫女们打开，并把里面的护符拿出来漂亮地罗列在柜台上。
@Hitret id=29183

@Talk name=心の声
在继续搬运其他各种各样的货物时，人们也陆续聚集到了接待室。
@Hitret id=29184

@Talk name=心の声
眼熟的人、和没见过的人，总之面对大批而来的人，渚和天女目都要一一问候、献茶。
@Hitret id=29185

@Talk name=心の声
看天女目恭恭敬敬的样子，我想，大概这些都是在镇里有地位的人吧。
@Hitret id=29186

@Talk name=心の声
比起那边的接待，这边的体力活说不定还要轻松些。
@Hitret id=29187

@Talk name=心の声
从社务所中，走出了几个上了年纪的老爷爷，站在门口。
@Hitret id=29188

@Talk name=心の声
都是我曾经见过的人。
@Hitret id=29189


@Char file=CD03_02M 

@Talk name=一叶 voice=KA040475
那边的几位，是这个镇的镇长和他的助手，那位是区长。
@Hitret id=29190

@Talk name=心の声
渚来到了我身边，悄悄地告诉我。
@Hitret id=29191

@Talk name=一叶 voice=KA040476
因为都和春日野大夫比较亲密，等会还是最好去打个招呼？
@Hitret id=29192

@Talk name=悠
怎么会这样，好紧张啊……
@Hitret id=29193


@Char file=CD03_03M 

@Talk name=一叶 voice=KA040477
呵呵，无论怎么看都是普通的老人吧？
@Hitret id=29194

@Talk name=悠
虽然对渚来说可能是那样……
@Hitret id=29195


@ClearChar 

@Talk name=心の声
再一次把视线投向老人们，他们已经来到了阶梯对面。
@Hitret id=29196


@StopBgm
@Char file=CK01_01S x=0  
@Char file=CJ01_01S x=-300  

@Talk name=心の声
一个穿着精致和服的男人慢慢登上阶梯。
@Hitret id=29197

@Talk name=心の声
紧紧跟在后面的是个穿着西装，身材瘦高的人。
@Hitret id=29198

@Talk name=心の声
穿和服的人中年模样，而穿西装的人感觉已经步入中老年，但两人看上去都比镇长他们年轻。
@Hitret id=29199

@Talk name=心の声
但是，对着这两个人，镇长却低着头问候着。
@Hitret id=29200

@Talk name=心の声
说起镇长，应该是镇里最了不起的人了吧，但这个人身份比镇长还要高。
@Hitret id=29201


@ClearChar 

@Char file=CD03_07M 
@PlayBgm file=BGM16

@Talk name=心の声
渚的面容也变得有些紧张。
@Hitret id=29202

@Talk name=悠
那个人是……
@Hitret id=29203

@Talk name=心の声
话刚问出口就想起来了。
@Hitret id=29204

@Talk name=心の声
跟在后面的那个人我还有印象，他就是接送渚的司机。
@Hitret id=29205

@Talk name=心の声
像是秘书之类的，然后是……
@Hitret id=29206

@Talk name=一叶 voice=KA040478
是父亲。
@Hitret id=29207

@Talk name=心の声
渚小声说着。
@Hitret id=29208


@ClearChar 

@Char file=CK01_01S 

@Talk name=心の声
也就是说，那个人也是天女目的父亲。
@Hitret id=29209

@Talk name=心の声
是被渚的情绪所感染了吧，连我都看出了她复杂的表情。
@Hitret id=29210

@Talk name=心の声
就像是既包含敬意，但又带着憎恶的这种感觉。
@Hitret id=29211


@Char file=CC06_01S 

@Talk name=瑛 voice=AK040286
这一次，又劳烦您在百忙之中抽空过来，真是十分感谢。
@Hitret id=29212

@Talk name=心の声
镇长他们的问候全部结束后，这一次轮到了天女目。
@Hitret id=29213


@Char file=CK01_04S 

@Talk name=一叶之父 voice=SH040007
今年也麻烦搞得隆重点吧。
@Hitret id=29214

@Talk name=瑛 voice=AK040287
是。
@Hitret id=29215

@Talk name=心の声
神社方的代表者和地方的权贵，给人一股这种感觉。
@Hitret id=29216

@Talk name=心の声
但无论如何也看不出是有血缘关系的亲子之间对话。
@Hitret id=29217


@ClearChar id=瑛
@Char file=CK01_01S 

@Talk name=心の声
渚的父亲和天女目打完招呼之后，发现了渚。
@Hitret id=29218

@Talk name=一叶 voice=KA040480
…………
@Hitret id=29219

@Talk name=心の声
渚面无表情的低下了头。
@Hitret id=29220

@Talk name=心の声
渚的父亲只用目光打了招呼，就和镇长、天女目他们一起走进了社务所内。
@Hitret id=29221


@ClearChar 

@Char file=CD03_07M 

@Talk name=心の声
渚投向那个背影的视线，眼神变得十分锐利。
@Hitret id=29222

@Talk name=悠
没关系吧？
@Hitret id=29223

@Talk name=一叶 voice=KA040481
诶？
@Hitret id=29224

@Talk name=悠
表情很可怕哦。
@Hitret id=29225


@StopBgm
@Char file=CD03_10M 

@Talk name=一叶 voice=KA040482
有、有吗？　……讨厌啦……我……
@Hitret id=29226

@Talk name=悠
会吓到客人的哦，摆出那种表情。
@Hitret id=29227

@Talk name=一叶 voice=KA040483
我、我会注意的啦……呐，春日野君也有自己的工作吧？　偷懒是不行的哦。
@Hitret id=29228

@Talk name=悠
嗯，这就去。
@Hitret id=29229


@Char file=CD03_03M 

@Talk name=一叶 voice=KA040484
慢走哦。加油~。
@Hitret id=29230

@Talk name=心の声
渚目送着我，她的声音又回复到了平常。
@Hitret id=29231


@ClearChar
@Update

@Cg file=B07a   

@EyeCatch


@Change target=00_d019b


