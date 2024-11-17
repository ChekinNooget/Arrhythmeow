-- Press Shift+F1 to display debug output in-game

--[[
finished:
sprite (the hard part)
also fix metronome randomly not working sometimes ????? why the heck is this happening????? i am baffled
^^this was fixed through EXTREMELY scuffed methods. i hope to never have to fix it again
make it so that this all only happens if the character selected is the character.
^^also very scuffed ... local coop needs some work but it's fine surely
song loop ^_^ yay
metronome breaks if the game lags and the beat bars mess up? dunno if i can fix this easily.
^^dunno if this is fixed but it prob is bc other thing is fixed too
ban rhythm shrine (i dont know if this works but it probably does tbhtbhtbh)

misc TODO:
=============================
more sprites
quick lobby movement switching ?? (probably never)
sound effects (meow meow)
beating heart on the beat bars | draw a cat version (im very bad at drawing uh oh)
can't move right away if beatmapOverride is on. maybe workaround for now is set first beat to .1 seconds, but this is bad.
sprite sometimes breaks in lobby when mod first enable
the metronome MAY break if the game lags just as the song loops. unsure, but for now ill keep it in min d
=============================
]]--

--modules (i think that's what they're called?)
local Player = require "necro.game.character.Player"
local PlayerList = require "necro.client.PlayerList"

local CurrentLevel = require "necro.game.level.CurrentLevel"
local RNG = require "necro.game.system.RNG"

local Music = require "necro.audio.Music"
local Sound = require "necro.audio.Sound"

--variables used throughout the program. idk lua so they're all local but you can prob change it to global right
local beatTime = 1 --how long between beats in seconds
local beatmap = "" --set this to beatmap every floor and then change it through shenanigans
local beatmapIndex = 1 --what beat you're currently on, used to play metronome sounds at the right time
local doesIgnoreRhythm = false --if on nobeat mode, dont play metronome sounds
local shouldBeScuffedBeatmap = false --change beatmap in a scuffed way if this is true

local CHAR_NAME = "Arrhythmeow_Arrhythmeow"

--if host local player is the arrythmeow character, do beatmap shenanigans.
--TODO: needs fixing for local coop & different chars... ....
local function checkPlayer()
    return Player.getCharacterType(PlayerList.getLocalPlayerID()) == CHAR_NAME
end

local function setScuffedBeatmap()--how long between beats
    beatmap = Music.getBeatmap() --get the beatmap.
    beatTime = (beatmap[7]-beatmap[3])/4
end

event.musicTrack.add("musicTest", {order="replaySkipMute"}, function(ev)
    shouldBeScuffedBeatmap = false
    beatmap = Music.getBeatmap() --get the beatmap.

    local FLOOR_BPMS = {{115, 130, 140}, {130, 140, 150}, {135, 145, 155}, {130, 145, 160}, {130, 140, 155}}
    local BOSS_BPMS = {120, 175, 123, 126, 140, 140, 160, 120, 150, 125, 145}

    if checkPlayer() then
       if ev.type == "boss" then
            --if boss is not a regular boss, set beatmap automatically, otherwise set manually
            if ev.boss < 1 or ev.boss > 11 then
                shouldBeScuffedBeatmap = true
            else
                beatTime = 60/BOSS_BPMS[ev.boss]
            end
        elseif ev.type == "zone" then
            --if not a regular floor set beatmap manually
            if ev.zone < 1 or ev.zone > 5 or ev.floor < 1 or ev.floor > 3 then
                shouldBeScuffedBeatmap = true
            else
                beatTime = 60/FLOOR_BPMS[ev.zone][ev.floor]
            end
        elseif ev.type == "training" then
            beatTime = 60/120 --watch your step bpm
        elseif ev.type == "tutorial" then
            beatTime = 60/100 --tombtorial bpm
        else
            shouldBeScuffedBeatmap = true
        end
    end
end)

--on new level, set up the new fancy beatmap
event.levelLoad.add("newLevel", {order="musicLayer"}, function(ev)
    --only change beatmap if char
    if checkPlayer() then
        --set new beatmap using old beatmap
        if shouldBeScuffedBeatmap then
            setScuffedBeatmap()
        end

        beatmap = Music.getBeatmap() --get the beatmap !!
        beatmapIndex = 1 --set this for playing metronome sounds at the right time
        local inputMapping = {} -- this should be an array with trues and falses. true means you can move on the associated half-beat, false means skip it
        local swingMapping = {} -- true means that note should be swung
        local playerInputsPerMeasure --number of beats per measure

        --if boss floor, do *special* beatmap tomfoolery
        if CurrentLevel.isBoss() then
            if CurrentLevel.getBossType() == 1 then -- king conga
                playerInputsPerMeasure = 9
                inputMapping = {true, true, false, true, true, true, false, true, true, false, true, false, true, false, false, false}
            elseif CurrentLevel.getBossType() == 2 then --death metal
                playerInputsPerMeasure = 2
                inputMapping = {true, true, false}
            elseif CurrentLevel.getBossType() == 3 then --deep blues
                playerInputsPerMeasure = 3
                inputMapping = {true, true, true, false}
                swingMapping = {false, true, false, false}
            elseif CurrentLevel.getBossType() == 4 then --coral riff
                playerInputsPerMeasure = 11
                inputMapping = {true, false, true, false, true, true, true, false, true, false, true, false, true, true, true, true}
            elseif CurrentLevel.getBossType() == 9 then --fortissimole
                playerInputsPerMeasure = 3
                inputMapping = {true, false, true, true}
            else --if a misc boss, just do a boring pattern
                playerInputsPerMeasure = 5
                inputMapping = {true, false, true, true, true, false, true, false}
            end
        else --if a regular floor just randomize it. booooring
            playerInputsPerMeasure = 3+CurrentLevel.getFloor() -- 4 on X-1, up to 6 on X-3

            --insert the appropriate amount of "true" and "false" beats
            for i = 1, playerInputsPerMeasure-1, 1 --minus one so that the first one can always be true
            do
                table.insert(inputMapping, true)
            end
            for i = 1, 8-playerInputsPerMeasure, 1
            do
                table.insert(inputMapping, false)
            end

            inputMapping = RNG.shuffle(inputMapping, RNG.getDungeonSeed()) --randomize it seeded (hey wait, seeded also takes care of the multiplayer issue! (i think))
            table.insert(inputMapping, 1, true) --make first beat of a measure always a valid "beat" for QoL
        
            --add swing to certain songs. currently unused
            --[[local swingStages = {{false, true, false}, {true, false, true}, {false, true, false}, {false, false, false}, {false, true, false}} --if a level has a song in swing tempo. in format swingStages[zone][floor]
            if CurrentLevel.getMusic().type == "zone" then
                if swingStages[CurrentLevel.getMusic().zone][CurrentLevel.getMusic().floor] then
                    swingMapping = {false, false, false, false, false, false, false, false}
                    for i = 2, #swingMapping, 2 do
                        if inputMapping[i] then
                            swingMapping[i] = true
                        end
                    end
                end
            end]]--
        end

        --each measure in the beatmap is replaced by playerInputsPerMeasure amount of beats
        --(usually each measure has 4 beats)
        for i = 1, #beatmap*2*playerInputsPerMeasure/#inputMapping, playerInputsPerMeasure
        do
            --tempIncrement keeps track of how many "trues" in the inputMapping we've already used
            local tempIncrement = 0
            --8 because there are 8 half-beats every measure
            for j = 1, #inputMapping, 1
            do
                --if the half-beat is true then add it to the beatmap (i don't know exactly what this does anymore :sob: good luck people who read this)
                if inputMapping[j] then
                    --this allows for swing notes if swingMapping has anything in it. otherwise ignore
                    local tempMultiplier = 1
                    if swingMapping[j] and j%2 == 0 then
                        tempMultiplier = 4/3
                    end
                    --do fancy math stuff (help) to add the relevant beat
                    beatmap[i+tempIncrement] = math.floor((beatTime*(i-1)/playerInputsPerMeasure/2*#inputMapping + beatTime/2*(j-1)*tempMultiplier)*1000+0.5)/1000
                    tempIncrement = tempIncrement + 1
                end
            end
        end

        --beatmap[1] = 0.1 --this is so that the player can move right away when the level loads. not sure why beatmapOverride disables moving right away but this is a fix for now\
    end
end)

--replace the beatmap with the new and improvedTM beatmap, of course
--also update "is nobeat mode" status
event.objectUpdateRhythm.add("newBeatmap", {order="musicChange"}, function(ev)
    if checkPlayer() then
        doesIgnoreRhythm = ev.ignoreRhythm
        ev.beatmapOverride = beatmap
    end
end)

local function getBeat(beatNumber) --get the modulo of the beat so that it works on song loop as well
    if beatNumber % #beatmap == 0 then
        return beatmap[#beatmap]
    else
        return beatmap[beatNumber % #beatmap]
    end
end

event.tick.add("playTick", {order="gameSession"}, function(ev)
    --if player is arrythmeow
    if checkPlayer() then
        --don't play metronome sounds if nobeat mode or something
        if not doesIgnoreRhythm then
            --check if the stuff even exists, if so play sounds
            if Music.getMusicTime() ~= nil and getBeat(beatmapIndex) ~= nil then
                local musicTimestamp = Music.getMusicTime() % Music.getMusicLength() --if the song loops, make the time loop as well!
                --if the music isn't fading out (if the music is just playing regularly) don't play metronome. this is EXTREMELY scuffed. why. did i do this
                if not Music.isFadingOut() then--if music time is greater than the next beat OR within certain amount (accounting for lag sorta), play sound
                    if (musicTimestamp <= (getBeat(beatmapIndex) + beatTime/8) and musicTimestamp >= (getBeat(beatmapIndex) - beatTime/8)) then
                        --play sound, increase index
                        Sound.playUI("MetronomeBetweenBeat")
                        beatmapIndex = beatmapIndex + 1
                    else
                        --this makes sure that the index still increases even if the game lags and doesn't track for a short while
                        --also checks to make sure that if the song loops it doesn't ascend to infinity
                        if getBeat(beatmapIndex + 1) < musicTimestamp and math.floor((beatmapIndex + 1) / #beatmap) <= math.floor(Music.getMusicTime() / Music.getMusicLength()) then
                            beatmapIndex = beatmapIndex + 1
                        end
                    end
                end
            end
        end
    end
end)