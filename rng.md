## RNG(乱数生成器)について ##

どうもエスト1の乱数はエスト2とほぼ同じらしいですね。 エスト2のほうはかなり解析されてるみたいなので、完成版作成までに内容確認します。

↓　確認結果。

---

RNG disassembled code

次の55個の乱数を生成する。

[i:0⇒54]Ri(n+1) = Ri(n) XOR Ri+31(n)

(if i+31 > 54 then i+31-54 )
```
04382F	A2 00		LDX #$00	; "X" = 0
043831	BD 76 14	LDA $1476 "X"	; "A" = $1476+"X"
043834	5D 95 14	EOR $1495 "X"
043837	9D 76 14	STA $1476 "X"	; $1476+"X" = "A"
04383A	E8		INX		; "X" ++
04383B	E0 18		CPX #$18	; 24までは $1495とのXOR
04383D	D0 F2		BNE #$F2	? -> $043831
04383F	BD 76 14	LDA $1476 "X"	; "A" = $1476+"X"
043842	5D 5E 14	EOR $145E "X"
043845	9D 76 14	STA $1476 "X"	; $1476+"X" = "A"
043848	E8		INX		; "X" ++
043849	E0 37		CPX #$37
04384B	D0 F2		BNE #$F2	? -> $04383F
04384D	60		RTS
```

---

### エスト1の乱数格納場所 ###
乱数番号: 7E14AE (0～54、乱数消費のたびにincrement)

乱数: 7E1476-7E14AC (55 random numbers)

### エスト2TAS作者のコメント引用 ###
_Gunty wrote:_

_The RNG produces 55 number between 0 and 255 (or 00-FF) at a time. The initial values are always the same when starting the rom, and cannot be manipulated at all. These random numbers are stored in the memory addresses 7E0521-7E0557._

_Everytime a random number is 'used' by the game, an internal counter, located at 7E0559, increments by 1. This counter starts at 0 and if it reaches 54 all random numbers have been used once. If another random number is requested, the RNG produces a new set of 55 random numbers. The way this happens is through bitwise XOR operations. random number 'i' becomes 'i' XOR 'i+31' and so on._

## 乱数消費 ##

### MENU ###

### Enter Name ###

### Prologue ###

### Field ###
### Town ###
### Dungeon ###
### Battle ###

・monster moving - wobbling

モンスターグラフィックが動くものと動かないものがいる。動くものの場合、動くことによって乱数が消費される。
私が勝手にモンスターの「揺れ」と言っていたものをLufiaTASの作者は"wobbling"といっているので、今度からそう呼ぶことにしました。

## 確率 ##

### ドロップ率 ###

zidanax said:
_here's what I'm getting from my Hex Editor (the probabilities range from 0 to 255, higher means likelier) :
Wing Lion (drops Spell Potion): 5
Manticore (drops Mind Potion): 2
Werefrog (drops Great Potion): 2_

For comparison, drop rates for Might equipment:
Might Sword (from Hydra):1
Might Helmet (from Barient):2
Might Armor (from Fire Plate):2

To get a sense of how rare those drops are, here are some more common ones:
Mid Arrow (from Kobold):76
Grilled Newt (from Big Newt):25
Long Nail (from Straw Man):66