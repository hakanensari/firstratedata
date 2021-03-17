[7:14 AM, 3/17/2021] Misha: Bence ben de..algo gelistirmek icin..bir frameworke yaklastim
[7:14 AM, 3/17/2021] Misha: Soyle..en basit bir giris kurali..bir tane de hard stop koyuyorum..
[7:15 AM, 3/17/2021] Misha: Hard stopa gitmezse posizyona..gunun sonunda posizyon kapaniyor
[7:16 AM, 3/17/2021] Misha: Posizyon kapanirken..posizyonun aldigi en maximum profit miktarini hesapliyorum
[7:17 AM, 3/17/2021] Misha: Buradan 2 seye bakabiliriz
[7:17 AM, 3/17/2021] Misha: 1) posizyona girdikten sonra hic profiable olmamis hisseler..bunlara ideally hic girmesek daha iyi
[7:19 AM, 3/17/2021] Misha: 2) posizyona girdikten sonra..ulastigi profitable stateden..xok fazla asagida kapatan hisseler..bunlar icin de ideally..daha refined bir exit strategy yazabiliriz
[7:19 AM, 3/17/2021] Misha: Burada yeni kurallar eklerken..o caseleri duzeltecegiz..ama overall profitability i dusurse..o yeni..yazilan kural iyi sayilmayacak
[7:20 AM, 3/17/2021] Misha: Benim algo gelistirme mantigim boyle kisaca
[7:20 AM, 3/17/2021] Misha: ***€€
[7:21 AM, 3/17/2021] Misha: Ama burda da..iki tane assumption var..ilk giris kurali..ve hard stop
[7:21 AM, 3/17/2021] Misha: Onlari degistirirsek..birsuru sey degisir
[7:22 AM, 3/17/2021] Misha: Benim anladigim..and this is deep shit😄..felsefi melsefi..assumption yapmadan..bu konuya yaklasamayiz
[7:22 AM, 3/17/2021] Misha: ***
[7:22 AM, 3/17/2021] Misha: Baska yaklasma bicimleri nasil olabilir diye dusunuyorum
[7:23 AM, 3/17/2021] Misha: Mesela..elimizdeki dataya bakip..relatifli..average volume averaj da ya da daha uatunde olan hisselerse..en cok gun ici oynayan..10 20 hisse senedini bulabiliriz
[7:23 AM, 3/17/2021] Misha: Onlar icin..en optimal para kazanma sekli ne olur diye dusunur
[7:24 AM, 3/17/2021] Misha: Overall..bu 20 case icin bir algo yazmaya calisip
[7:24 AM, 3/17/2021] Misha: Diger 800 case icin bu logic nasil..isliyor diye bakabikiriz
[7:24 AM, 3/17/2021] Misha: Boyle bir sey denemedim daha once..ama simdi yazarken aklima geldi
[7:25 AM, 3/17/2021] Misha: Onxe we define..and entry strategy..and hard exit strategy( or stop loss)
[7:25 AM, 3/17/2021] Misha: Daha onceki process e sevam ederiz
[7:26 AM, 3/17/2021] Misha: ***
[7:26 AM, 3/17/2021] Misha: Bitinci method da..entry strategy..benim earnings strategy den barrow ettigim mantik
[7:27 AM, 3/17/2021] Misha: X dakika bekle..yukari cikinxa al..asagi gidince short et
[7:27 AM, 3/17/2021] Misha: Baska birsuru yaratici giris strajileri olabilir
[7:28 AM, 3/17/2021] Misha: Mesela..jep first move always fails lafi vardir..go for the second move
[7:28 AM, 3/17/2021] Misha: Benim strateji..it goes for the first move

ABove are whatsapp messages

1) Start with an entry method( ENTRY}

2) Put a STOP( CLOSE)

3) If position does not hit the stop, cover at the end(CLOSE)

4) Calculate the max profit reached in the position before the CLOSE

5) CHeck the cases where the difference between MAX PROFIT and REALIZED PROFIT or LOSS is greatest.

Try to think of ways(rules) to get out as close to the maximum profitable state as possible.

6) Check the cases where  the position is minimally profitable or not profitable at all..before hitting the stop. 

It would be best not to enter these positions at all..since..no exit strategy can improve on these cases. Can i write some

rules to block these while not blocking profitable entries?

7) Check the cases..where the maximum unrealized profits and realized profits(losses) are greatest. Some of the cases here may overlap with cases in 6. 

So check the cases..where there was actually a high amount of unrealized profits..after which realized profit is much less than the unrealized profits. 

Looking at these cases..may give some ideas on improved  exit strategies. Can i write a rule that will make me exit as close to the best outcome as possible,

without hurting profitability of other entries?

8) Initially we have 3 rules. 1  ENtry and 2 exit rules. My typical approach is to add a rule. If the rule improves overall results, i think of it as a good rule. 



