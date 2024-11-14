-- Press Shift+F1 to display debug output in-game

--[[
finished:
sprites (the hard part)
also fix metronome randomly not working sometimes ????? why the heck is this happening????? i am baffled
^^this was fixed through EXTREMELY scuffed methods. i hope to never have to fix it again
make it so that this all only happens if the character selected is the character.
^^also very scuffed ... local coop needs some work but it's fine surely

misc TODO:
=============================
quick lobby movement ?? (probably never)
sound effects (meow meow)
metronome breaks if the game lags and the beat bars mess up? dunno if i can fix this easily.
beating heart on the beat bars | draw a cat version (im very bad at drawing uh oh)
=============================
]]--

--modules (i think that's what they're called?)
local customEntities = require "necro.game.data.CustomEntities"
local ItemBan = require "necro.game.item.ItemBan"
local Player = require "necro.game.character.Player"
local PlayerList = require "necro.client.PlayerList"

local CurrentLevel = require "necro.game.level.CurrentLevel"
local RNG = require "necro.game.system.RNG"

local Music = require "necro.audio.Music"
local Sound = require "necro.audio.Sound"
local SoundGroups = require "necro.audio.SoundGroups"
local Soundtrack = require "necro.game.data.Soundtrack" --TODO set manual 60/XXX MPM (1/BPM or time between beats) for built in songs; otherwise do current method (which is take a few beats and average it)

--variables used throughout the program. idk lua so they're all local but you can prob change it to global right
local beatTime = 1 --how long between beats in seconds
local beatmap = "" --set this to beatmap every floor and then change it through shenanigans
local beatmapIndex = 1 --what beat you're currently on, used to play metronome sounds at the right time
local doesIgnoreRhythm = false --if on nobeat mode, dont play metronome sounds

local CHAR_NAME = "Arrhythmeow_Arrhythmeow"

--if host local player is the arrythmeow character, do beatmap shenanigans.
--TODO: needs fixing for local coop & different chars... ....
local function checkPlayer()
    return Player.getCharacterType(PlayerList.getLocalPlayerID()) == CHAR_NAME
end

--on new level, set up the new fancy beatmap
event.levelLoad.add("newLevel", {order="musicLayer"}, function(ev)
    beatmap = Music.getBeatmap() --get the beatmap.
    if checkPlayer() then
        beatmapIndex = 1 --set this for playing metronome sounds at the right time
        beatTime = (beatmap[7]-beatmap[2])/5 --how long between beats. pretty scuffed tbh
        local tempBeatmap = {} -- this should be an array with trues and falses. true means you can move on the associated half-beat, false means skip it
        local tempVal --number of beats per measure

        --print(Soundtrack.Song.type)

        --TODO: if boss floor, change every two measures, rather than one

        if CurrentLevel.getFloor() == 4 then
            tempVal = 3+CurrentLevel.getFloor() --TODO do this better
        else
            tempVal = 3+CurrentLevel.getFloor() --do this better
        end

        --insert the appropriate amount of "true" and "false" beats
        for i = 1, tempVal-1, 1 --minus one so that the first one can always be true
        do
            table.insert(tempBeatmap, true)
        end
        for i = 1, 6-tempVal, 1
        do
            table.insert(tempBeatmap, false)
        end

        tempBeatmap = RNG.shuffle(tempBeatmap, RNG.getDungeonSeed()) --randomize it seeded (hey wait, seeded also takes care of the multiplayer issue! (i think))
        table.insert(tempBeatmap, 1, true) --make first beat of a measure always a valid "beat" for QoL

        --each measure in the beatmap is replaced by tempVal amount of beats
        --(usually each measure has 4 beats)
        for i = 1, #beatmap/4*tempVal, tempVal
        do
            --tempIncrement keeps track of how many "trues" in the tempBeatMap we've already used
            local tempIncrement = 0
            --8 because there are 8 half-beats every measure TODO: change this to a variable for boss floors (16)
            for j = 1, 9, 1
            do
                --if the half-beat is true then add it to the beatmap (i don't know exactly what this does anymore :sob: good luck people who read this)
                if tempBeatmap[j] then
                    beatmap[i+tempIncrement] = math.floor((beatTime*(i-1)/tempVal*4+beatTime/2*(j-1))*1000+0.5)/1000
                    tempIncrement = tempIncrement + 1
                end
            end
        end
    end
end)

--replace the beatmap with the new and improvedTM beatmap, of course
--also update "is nobeat mode" status
event.objectUpdateRhythm.add("newBeatmap", {order="musicChange"}, function(ev)
    doesIgnoreRhythm = ev.ignoreRhythm
    ev.beatmapOverride = beatmap
end)

local function getBeat()
    if beatmapIndex == #beatmap then
        return beatmap[beatmapIndex]
    else
        return beatmap[beatmapIndex % #beatmap]
    end
end

event.tick.add("playTick", {order="gameSession"}, function(ev)
    --if player is arrythmeow
    if checkPlayer() then
        --don't play metronome sounds if nobeat mode or something
        if not doesIgnoreRhythm then
            --check if the stuff even exists, if so play sounds
            if Music.getMusicTime() ~= nil and getBeat() ~= nil then
                --if the music isn't fading out (if the music is just playing regularly) don't play metronome. this is EXTREMELY scuffed. why. did i do this
                if not Music.isFadingOut() then
                    local musicTimestamp = Music.getMusicTime() % Music.getMusicLength() --if the song loops, make the time loop as well!
                    --if music time is greater than the next beat OR within certain amount (accounting for lag sorta), play sound
                    if musicTimestamp >= getBeat() or (musicTimestamp <= (getBeat() + beatTime/8) and musicTimestamp >= (getBeat() - beatTime/8)) then
                        --only play sound if it's the very next beat, if it lags or something just skip it
            
                        print(Music.getMusicTime())
                        print(beatmapIndex, #beatmap, musicTimestamp)

                        --figure this out tomorrow
                        --looping sucks
                        --TODO
                        --eeee
                        if math.floor(Music.getMusicTime() / Music.getMusicLength()) >= math.floor(beatmapIndex/#beatmap) then
                            Sound.playUI("MetronomeBetweenBeat")
                            beatmapIndex = beatmapIndex + 1
                        else
                            beatmapIndex = 1
                        end
                    end
                end
            end
        end
    end
end)