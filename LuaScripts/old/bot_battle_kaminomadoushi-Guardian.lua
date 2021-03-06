local frame	--現在検証中のフレーム
local search_count = 0 --初期フレームからの試行回数

--調査の限界
--超過した場合、遅すぎるので中断（手動戦闘結果より遅かったら意味がない）
local max_frame = 311000 --戦闘終了時のフレーム
local max_search = 2000 --戦闘開始から終了までのフレーム数

local try_count = 100

--botによるre-recordカウント *defualt true
movie.rerecordcounting(true)
--print("re-recordcount: " .. movie.rerecordcount())

--現在時刻で乱数を初期化
math.randomseed(os.time())

state = savestate.create(4) --ステートを作成
--savestate.load(state) --slot4をSL

try_state = savestate.create(5) --試行途中のフレームのステート

emu.speedmode("maximum")
--emu.speedmode("turbo")
--emu.speedmode("nothrottle")
--emu.speedmode("normal") --test

local result = false

function fadv(n)
	for i=1,n do 
		emu.frameadvance()
	end
end

--保存したステートから戦闘開始するための入力
function start_command()
	joypad.set(1,{A=true})
	fadv(1)
end

--通常攻撃
function weapon_attack()
	joypad.set(1,{A=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(2)
end

--防御
function guard()
	joypad.set(1,{A=true,right=true})
	fadv(2)
end

--パワードラッグ⇒No.00(主人公)
function pawor_drug00()
	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
	
end
--パワードラッグ⇒No.01(アグロス)
function pawor_drug01()
	joypad.set(1,{A=true,left=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{down=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{right=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(3)
end

--ドレン
function doren()
	joypad.set(1,{A=true,up=true})
	fadv(5)	--一覧ロード時間に若干差がある？ため1フレーム余裕を持たせる
	joypad.set(1,{up=true})
	fadv(2)
	joypad.set(1,{A=true})
	fadv(4)
	joypad.set(1,{A=true})
	fadv(3)
end

--主人公の行動
function pattern_00()
	weapon_attack()
end

--ルフィアの行動
function pattern_01()
	r = math.random(5)
	if r == 1 then
		pawor_drug01()
	elseif r == 2 then
		pawor_drug00()
	elseif r == 3 then
		doren()
	elseif r == 4 then
		weapon_attack()
	else
		guard()
	end
	
end

--アグロスの行動
function pattern_02()
	weapon_attack()
end
--なぜかたまにアグロスが指定動作以外のことをする・・・⇒課題

--ジュリナの行動
function pattern_03()
	r = math.random(4)
	if r == 1 then
		pawor_drug01()
	elseif r == 2 then
		pawor_drug00()
	elseif r == 3 then
		weapon_attack()
	else
		guard()
	end
end

--ターンを持っているキャラを判断※0x7e1434の値は隊列依存
function input_command()

	local turn = memory.readbyte(0x7e1434)
	
	--[[
		以下の隊列の場合
		00:主人公	01:アグロス
		02:ルフィア	03:ジュリナ
	]]
	--主人公のターン
	if turn == 0 then
		pattern_00()
	end
	
	--ルフィアのターン
	if turn == 2 then
		pattern_01()
	end
	
	--アグロスのターン
	if turn == 1 then
		pattern_02()
	end
	
	--ジュリナのターン
	if turn == 3 then
		pattern_03()
	end

end

--
function failure()
	
	--敵の攻撃は全体だけ？なので主人公だけで判定
	p1hp_max = memory.readword(0x7E16F0)
	p1hp = memory.readword(0x7E158F)	
	--防御低下は全体なので、主人公だけで判定
	p1def = memory.readwordsigned(0x7E1738)
	
	--ダメージなし、DEFを下げられない
	if p1hp == p1hp_max and p1def == 0 then
		return false
	end
	
	return true

end

--bot試行内容
function attempt()
	
	--開始のための入力
	start_command()

	local turn = memory.readbyte(0x7e1434)	--戦闘中ターン所有
	-- FF:誰もターン持っていない（もしくは戦闘中でない）
	-- 00:1人目, 01:2人目, 02:3人目, 03:4人目
	
	local wait = true
	--戦闘開始～だれかがターンを持つまでフレームを進める
	while wait do

		emu.frameadvance()
		turn = memory.readbyte(0x7e1434)
		if turn ~= 255 then
			wait = false
		end
	end
	
	--戦闘中の判定
	local loop = true
	while loop do
	
		--ターンがある場合行動させる
		if turn ~= 255 then
			input_command()
		end
			
		en1hp = memory.readword(0x7EE542) --敵1HP
		
		if en1hp == 0 then
			print("success, enhp is 0")
			result = true
			break
		end
		
		if failure() then
			result = false
			break
		end
		
		emu.frameadvance()
		turn = memory.readbyte(0x7e1434)
		
	end
	

end

--bot成功判定 
function success()
	return result
end

--予期せぬ動作でbotが停止した場合用はmaxフレーム超過で停止する
function callback()
	if max_frame < emu.framecount() then
		savestate.load(try_state)
	end
end
	
emu.registerafter(callback)

while true do

	savestate.load(state)	--初期ステートを読み出し
	
	fadv(search_count)	--試行フレームまで進める
	savestate.save(try_state)	--最新の試行フレームを保存しておく
	
	frame = emu.framecount()
	print("try at " .. frame-1 .. " frame, count " .. search_count)
	
	--ここに結果の判定方法を書く
	
	--botによる戦闘試行
	for i=1, try_count do
		
		--print("trying " .. i .." times")
		attempt()	--戦闘
		
		--調整終了の場合
		if success() then
			
			break
		end
		
		--失敗のため、ステートロード
		savestate.load(state)
		fadv(search_count)	--試行フレームまで進める

	end

	if success() then --乱数調整フラグが立ったら
		local state_good = savestate.create(6)
		savestate.save(state_good)	--成功状態を保存
		print("end") --終了したことを示すためにendを表示
		break --無限ループから脱出
	end
	
	search_count = search_count + 1			
	--emu.frameadvance() --1フレーム進める
	
	if search_count > max_search then
		print("search aborted, for excess of max_search")
		break
	end
	
	
end
emu.speedmode("normal")
emu.pause() --エミュレーターを一時停止