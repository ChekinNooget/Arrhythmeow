-- Press Shift+F1 to display debug output in-game

--[[
misc TODO:
=============================
sprites (the hard part)
sound effects (meow meow)
metronome breaks if the game lags and the beat bars mess up? dunno if i can fix this easily
also fix metronome randomly not working sometimes ????? why the heck is this happening????? i am baffled
beating heart on the beat bars | draw a cat version (im very bad at drawing uh oh)
make it so that this all only happens if the character selected is the character.
=============================
]]--

--modules (i think that's what they're called?)
local customEntities = require "necro.game.data.CustomEntities"
local ItemBan = require "necro.game.item.ItemBan"
local Player = require "necro.game.character.Player"

local CurrentLevel = require "necro.game.level.CurrentLevel"
local RNG = require "necro.game.system.RNG"

local Music = require "necro.audio.Music"
local Sound = require "necro.audio.Sound"
local SoundGroups = require "necro.audio.SoundGroups"

--local Soundtrack = require "necro.game.data.Soundtrack" TODO set manual 60/XXX MPM (1/BPM or time between beats) for built in songs; otherwise do current method (which is take a few beats and average it)

--variables used throughout the program. idk lua so they're all local but you can prob change it to global right
local beatTime = 1 --how long between beats in seconds
local beatmap = "" --set this to beatmap every floor and then change it through shenanigans
local beatmapIndex = 1 --what beat you're currently on, used to play metronome sounds at the right time
local doesIgnoreRhythm = false --if on nobeat mode, dont play metronome sounds

--on new level, set up the new fancy beatmap
event.levelLoad.add("newLevel", {order="musicLayer"}, function(ev)
    beatmapIndex = 1 --set this for playing metronome sounds at the right time
    print(Player.getCharacterType(1))
    
    beatmap = Music.getOriginalBeatmap() --get the beatmap.
    beatTime = (beatmap[7]-beatmap[2])/5 --how long between beats. pretty scuffed tbh
    local tempBeatmap = {} -- this should be an array with trues and falses. true means you can move on the associated half-beat, false means skip it
    local tempVal --number of beats per measure

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
        for j = 0, 8, 1
        do
            --if the half-beat is true then add it to the beatmap (i don't know exactly what this does anymore :sob: good luck people who read this)
            if tempBeatmap[j] then
                beatmap[i+tempIncrement] = math.floor((beatTime*(i-1)/tempVal*4+beatTime/2*(j-1))*1000+0.5)/1000
                tempIncrement = tempIncrement + 1
            end
        end
    end
    --for i = 0, 8, 1
    --do
    --    print(beatmap[i])
    --end
end)

--replace the beatmap with the new and improvedTM beatmap, of course
event.objectUpdateRhythm.add("newBeatmap", {order="irregular"}, function(ev)
    doesIgnoreRhythm = ev.ignoreRhythm
    ev.beatmapOverride = beatmap
end)

event.tick.add("playTick", {order="musicTime"}, function(ev)
    if not doesIgnoreRhythm then --don't play metronome sounds if nobeat mode or something
        --TODO: fix num comparing with nil thing. low priority because it doesn't seem to be affecting anything else (might be the cause of the random metronome breaking bug though)
        --if music time is greater than the next beat OR within certain amount (accounting for lag sorta), play sound
        if Music.getMusicTime() >= beatmap[beatmapIndex] or (Music.getMusicTime() <= beatmap[beatmapIndex] + beatTime/8 and Music.getMusicTime() >= beatmap[beatmapIndex] - beatTime/8) then
            print(Music.getMusicTime(), beatmap[beatmapIndex])
            Sound.play("MetronomeOnBeat")
            beatmapIndex = beatmapIndex + 1
        end
    end
end)