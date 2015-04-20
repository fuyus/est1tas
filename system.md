# キャラクターのステータスについて(Status) #

## 基本ステータス(base status) ##
|Stat|Meaning|effects|
|:---|:------|:------|
|ATP|STR + Weapon/Ring ATP|increases damage by Attack|
|DFP|STR/4(round down) + AGL/4(round down) + protectors/Ring DFP|decrease damage by Attack/Physical Skill/Item|

|STR|strength, increases by level up/stat potion(みなもと)|added to ATP|
|AGL|how fast the charactor's turn comes|next turn comes quickly, No detail|
|MGR|Magic Resistance|decreases damage by Spell|
|装備重量(WGT)|Weight of Equipments|less weight charactor can move quickly after input command|

AGLと装備重量がどの程度影響するかの詳細は不明。
ロジックはわからないにしても、どの程度の差で、どのくらい行動回数に影響があるかはデータ取りしてみるべき。

## レベルアップの仕様(level up) ##

・キャラクターごとに、あるレベルでのステータス基本値が決まっている。このため、レベルによりステータスの上限と下限があることになる。

・レベルアップ時の上昇量はレベルごとのステータス基本値に近づくように上昇する。（上限を超えてしまう場合はどんなに乱数を変えてレベルアップさせてもステータスが上がらない。下限についても然り。）つまりステータス上昇量はあまり気にしなくても、ちゃんと育つ。ステータスが気になる場合は最終レベル(99)付近で調整すればいい。

・装備品によるステータス補正は、レベルアップでのステータス上昇と無関係。

・みなもとを使用して上昇したステータスは、レベルアップでのステータス上昇と無関係。（らしい。Forum情報なので検証必要）

# 各計算式(math) #

## ステータス変動(status bonus) ##

`変動値 = 基本ステータス値 * 変動率 / 2 * [乱数]  - 使用前のステ変動値 / 変動率`

`[stat bonus gain] = ( [Basic stat value] * [effect rate] / 2 * [random rate] ) - [current stat bonus] / [effect rate]`

変動値は2キャラクターが行動・もしくは変動しているキャラが行動するごとに12.5%減衰する。

e.g.
|Spell/Item|Effect Rate[%]|Bonus Stat|
|:---------|:-------------|:---------|
|ラム(Pear CIder)|7 |ATP|
|ウォッカ(Sour Cider)|20|ATP|
|ジン(Lime Cider)|26|ATP|
|リキュール(Plum Cider)|38|ATP|
|タプローズ(Apple Cider)|50|ATP|
|トゥイーク(Trick)|50|ATP|
|パワードラッグ(Power Gourd)|57|ATP|
|ディレクト(Courage)|60|DFP|
|ドレン(Drain)|-80|DFP|
|ドリッド(Dread)|-66|DFP|
|フェイク(Fake)|45|AGL|