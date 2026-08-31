


@Cg file=B27c   
@Update

@PlayEnvSe file=SE300 fade=0

@Wait time=2000 

@Cg file=B01c   
@Update
@Wait time=2000 

@Cg file=B03c   
@Char file=CA02_06M 

@Talk name=穹 voice=SR050070
………………吵死了。
@Hitret id=35274

@Talk name=心の声
在快要睡着的时候，穹发出了意味不明的抱怨。
@Hitret id=35275

@Talk name=心の声
我也不记得自己做了什么吵闹的事情，到底是说什么呢一瞬间也搞不清。
@Hitret id=35276

@Talk name=悠
……啊，青蛙的叫声么？
@Hitret id=35277

@Talk name=心の声
发觉到我们以外的声源后，我才做出了回应。
@Hitret id=35278

@Talk name=心の声
穹说的是从家门外面可以听到的，像是粗糙木板般相互摩擦发出的“咯咯”声。
@Hitret id=35279


@StopEnvSe id=SE300 fade=0
@Char file=CA02_01M 
@PlayBgm file=BGM09

@Talk name=穹 voice=SR050071
青蛙？
@Hitret id=35280

@Talk name=悠
这是在田埂里住着的青蛙声音。天女目告诉我的。
@Hitret id=35281

@Talk name=心の声
因为我曾在意过这个从傍晚起就难听的大合唱，有在这附近找过声源。
@Hitret id=35282

@Talk name=心の声
但是，实在是到处都有的声音，就在快要天黑时，遇见了天女目。
@Hitret id=35283

@Talk name=心の声
然后终于，搞清楚了半夜里吵闹的叫声正体。
@Hitret id=35284

@Talk name=悠
好像到山上那边去的话，还有“休休”像笛子一样叫的青蛙。
@Hitret id=35285

@Talk name=悠
后天就是暑假了，下次要去看看么？
@Hitret id=35286


@Char file=CA02_04M 

@Talk name=穹 voice=SR050072
怎么可能去啊。
@Hitret id=35287

@Talk name=悠
是么，是很恶心的东西呢，青蛙。
@Hitret id=35288

@Talk name=穹 voice=SR050073
……这个，想想办法解决。
@Hitret id=35289

@Talk name=悠
没办法的。有几千只青蛙在哦。
@Hitret id=35290


@Update
@action id=穹 action=ActionAdvHop width=4 height=0 cycle=100 count=5
@WaitAction id=穹

@Talk name=穹 voice=SR050074
…………………………
@Hitret id=35291

@Talk name=心の声
穹发出了打从心底感到厌恶的叹气声后，回到了自己的房间。
@Hitret id=35292


@ClearChar 

@Talk name=悠
明天就是一学期的结业日啦，早点睡觉，好好起来哦？
@Hitret id=35293

@Talk name=穹 voice=SR050075
…………………………
@Hitret id=35294

@Talk name=心の声
算了，反正也没有网络，想熬夜也不行吧。
@Hitret id=35295

@Talk name=心の声
那么，我也要早点睡了。
@Hitret id=35296

@Talk name=心の声
对穹都这样说了，自己却迟到的话，就实在太难堪了。
@Hitret id=35297



@Hide
@BlackOut time=1000

@PlaySe file=se114
@WaitSe

@Cg file=B03c   

@Talk name=悠
怎，怎么了！？
@Hitret id=35298

@Talk name=心の声
可是，刚爬进被窝就听到了巨大的声音。
@Hitret id=35299


@PlaySe file=se114

@Talk name=心の声
又来啊。
@Hitret id=35300


@Char file=CA02_05M 

@Talk name=穹 voice=SR050076
……怎么了？
@Hitret id=35301

@Talk name=悠
我这边也不知道啊……
@Hitret id=35302


@PlaySe file=se114

@Char file=CA02_08M 

@Talk name=心の声
好像是什么东西撞击的声音，从玄关那传过来的。
@Hitret id=35303

@Talk name=悠
我去看看，你在这等着。
@Hitret id=35304

@Talk name=穹 voice=SR050077
……嗯。
@Hitret id=35305


@BlackOut
@StopBgm

@Talk name=心の声
我背对着不安的穹，向玄关走去。
@Hitret id=35306

@Talk name=心の声
在这时候，门也是唦唦作响，肯定是有什么在那里。
@Hitret id=35307

@Talk name=心の声
…………………………
@Hitret id=35308

@Talk name=心の声
不会是，强盗吧？
@Hitret id=35309

@Talk name=心の声
…………………………
@Hitret id=35310

@Talk name=心の声
哈哈，怎么会呢……要是这样，也不会一直这样吵闹啊……
@Hitret id=35311

@Talk name=悠
那，那个……请问是哪位……？
@Hitret id=35312

@Talk name=心の声
…………………………
@Hitret id=35313

@Talk name=悠
那个……
@Hitret id=35314

@Talk name=声 voice=MT050465
唔……咕……
@Hitret id=35315

@Talk name=心の声
……呻吟声？
@Hitret id=35316

@Talk name=心の声
……这个套路，好像很眼熟啊……
@Hitret id=35317


@PlaySe file=se105

@Cg file=EE05a  
@Update transition=universal rule=WIP_LR time=500
@WaitUpdate
@PlayBgm file=BGM13

@Talk name=初佳 voice=MT050466
晚上好啊~~，悠君~~~。
@Hitret id=35318

@Talk name=悠
晚上好，才怪啊……
@Hitret id=35319

@Talk name=心の声
和想的一样，在那里的是醉倒了的初佳小姐。
@Hitret id=35320

@Talk name=初佳 voice=MT050467
对不起~~，我来了呢。
@Hitret id=35321

@Talk name=悠
又是联谊么？
@Hitret id=35322

@Talk name=初佳 voice=MT050468
不要说“又”啦~，我也不是天天都去的嘛~。
@Hitret id=35323

@Talk name=心の声
虽然是醉着，但是却没有像上次那么失落。
@Hitret id=35324

@Talk name=心の声
今天的联谊发生了什么好事么……
@Hitret id=35325

@Talk name=悠
能站起来吗？　需要水吗？
@Hitret id=35326

@Talk name=初佳 voice=MT050469
站不起来~，给我酒~~
@Hitret id=35327

@Talk name=悠
没有酒啊……我去拿水。
@Hitret id=35328

@Talk name=心の声
我说完后站了起来，
@Hitret id=35329


@PlaySe file=SE015

@Talk name=穹 voice=SR050078
………………………
@Hitret id=35330


@StopSe

@Talk name=心の声
穹正拿着杯子出来。
@Hitret id=35331

@Talk name=初佳 voice=MT050470
啊~，小穹~啊，晚上好~~
@Hitret id=35332

@Talk name=穹 voice=SR050079
………………………
@Hitret id=35333

@Talk name=心の声
穹依然不说话，也不回应就把杯子递了过来。
@Hitret id=35334

@Talk name=悠
那是水么？　谢谢啦。
@Hitret id=35335

@Talk name=心の声
我从穹手里接过杯子后，送到了初佳小姐的嘴边。
@Hitret id=35336

@Talk name=初佳 voice=MT050471
……嗯……嗯咕………………这是，水……
@Hitret id=35337

@Talk name=悠
我不是说过了么。
@Hitret id=35338


@Cg file=EE05b  

@Talk name=初佳 voice=MT050472
等等，你是要说我连醉的价值都没有么？
@Hitret id=35339

@Talk name=悠
不是已经足够醉了么。
@Hitret id=35340

@Talk name=心の声
……这个对话也很耳熟啊……
@Hitret id=35341

@Talk name=初佳 voice=MT050473
真是的，真是失礼啊。大家一起，说什么初佳不能喝所以少喝一点，什么的。
@Hitret id=35342

@Talk name=初佳 voice=MT050474
当我是小孩子么！
@Hitret id=35343

@Talk name=悠
这种事情，我想大概没有吧……
@Hitret id=35344

@Talk name=心の声
醉了就会这样，那些人也知道吧。
@Hitret id=35345

@Talk name=悠
在这里吵闹的话会给附近邻居添麻烦的，总之先到屋子里来吧……穹也来抬着那边。
@Hitret id=35346

@Talk name=心の声
我无视初佳小姐“你说会给谁添麻烦啊~？”的叫喊声，扶起了她的肩膀。
@Hitret id=35347

@Talk name=穹 voice=SR050080
………………………
@Hitret id=35348

@Talk name=心の声
但是穹，还是闭着嘴巴，动也不动。
@Hitret id=35349

@Talk name=悠
穹，快点……我一个人太重了……
@Hitret id=35350

@Talk name=穹 voice=SR050081
…………………………不要。
@Hitret id=35351

@Talk name=悠
说什么不要的……
@Hitret id=35352

@Talk name=穹 voice=SR050082
不许进到家里来。
@Hitret id=35353


@PlaySe file=SE015

@Talk name=心の声
留下一句刻薄的话后，穹又躲回了房间里。
@Hitret id=35354


@StopSe
@Cg file=EE05a  

@Talk name=初佳 voice=MT050475
啊哈哈~，被讨厌了的样子啊~~~
@Hitret id=35355

@Talk name=悠
对不起。我之后会说她的……
@Hitret id=35356

@Talk name=初佳 voice=MT050476
没事的没事的，给你们添麻烦了是真的……
@Hitret id=35357


@Cg file=B01c   

@Talk name=初佳 voice=MT050477
哟……呼。
@Hitret id=35358

@Talk name=心の声
别在意，这样表示着站起来的初佳小姐。
@Hitret id=35359


@Char file=CE03_02M 

@Talk name=初佳 voice=MT050478
呜呜……哇，呀啊！？
@Hitret id=35360


@Char file=CE03_06M x=200  
@Update
@wait time=500
@Move id=初佳 my=50 cycle=1000
@WaitAction id=初佳

@Talk name=心の声
但是马上又晃动起来，差点倒下。
@Hitret id=35361


@PlaySe file=se063
@WaitSe
@ClearChar 
@Update time=0
@Char file=CE03_03L 

@Talk name=悠
等……没事吧？
@Hitret id=35362

@Talk name=心の声
我慌乱的上前扶住，看来一个人是站不起来啊。
@Hitret id=35363

@Talk name=初佳 voice=MT050479
啊哈哈哈……好像不太像是没事的样子……
@Hitret id=35364

@Talk name=心の声
虽然不知道穹到底为什么拒绝，但是说的那么明确总不能无视吧。
@Hitret id=35365

@Talk name=心の声
但是让我把初佳小姐就这样赶回去，我也做不到。
@Hitret id=35366

@Talk name=初佳 voice=MT050480
对不起……很麻烦吧，真的是……对不起……
@Hitret id=35367

@Talk name=心の声
……嗯。不能放着不管。
@Hitret id=35368

@Talk name=悠
我把您送回家吧，请把路告诉我吧。
@Hitret id=35369


@Char file=CE03_11L 

@Talk name=初佳 voice=MT050481
诶诶？
@Hitret id=35370

@Talk name=悠
毕竟让醉酒的初佳小姐一个人回去什么的实在是太叫人担心了，我可做不到啊。
@Hitret id=35371


@Char file=CE03_07L 

@Talk name=初佳 voice=MT050482
诶，那是什么意思……
@Hitret id=35372


@ClearChar
@Update

@Cg file=B34c center=800,300

@EyeCatch

@Change target=00_e013b



