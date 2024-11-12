--this file takes care of all the setup for the actual character

--modules
local customEntities = require "necro.game.data.CustomEntities"
local SoundGroups = require "necro.audio.SoundGroups"

--list of sounds to play
SoundGroups.register {
    --metronome sounds
    --this one plays on beat
    MetronomeOnBeat = {
        sounds = {
            "mods/Arrhythmeow/sounds/en_metrognome_tick.ogg"
        },
    },
    --this sound plays if the beat is in between two normal beats
    MetronomeBetweenBeat = {
        sounds = {
            "mods/Arrhythmeow/sounds/en_metrognome_tock.ogg"
        },
    },
    --this plays if the beat is swung (like on 1-2 and deep blues)
    MetronomeSwing = {
        sounds = {
            "mods/Arrhythmeow/sounds/en_metrognome_tack.ogg" --sjhdkusgeuy
        },
    },
}

--add the character (wow so fancy)
--TODO: clean this up, figure out what items to give them
--ban rhythm shrine (is very goofy)
customEntities.extend{
    name = "Arrhythmeow",
    template = customEntities.template.player(),
    components = {
        {
            friendlyName = {
                name = "Arrhythmeow"
            },
            sprite = {
                texture = "mods/Arrhythmeow/sprites/player1_armor_body.png"
            },--[[
            cloneSprite = {
                texture = "mods/march/images/entities/marchClone.png",
                height = 27,
                offsetY = -4
            },
            bestiary = {
                image = "mods/march/images/entities/bestiary_march.png"
            },
            characterEquipmentSpriteRow = false,]]--
            initialInventory = {
                items = {
                    "ShovelBasic",
                    "WeaponObsidianDagger",
                    "Bomb",
                    "ArmorObsidian"
                }
            },
            --[[soundHit = {
                sound = "MetronomeOnBeat"
            },
            traitSmallerShops = {},
            playableCharacter = { 
                lobbyOrder = 31.01
            },
            inventoryCursedSlots = {
                slots = {
                    weapon = true
                }
            },
            inventoryBannedItems = {
                components = {
                    itemBanWeaponlocked = ItemBan.Type.FULL,
                    shrineBanWeaponlocked = ItemBan.Type.FULL,
                    itemBanNoDamage = ItemBan.Type.FULL,
                }
            },
            inventoryBannedItemTypes = {
                types = {
                    Sync_CharmThrowing = ItemBan.Type.FULL,
                    trill_throwBand = ItemBan.Type.FULL,
                    march_DischargeSpell = ItemBan.Type.LOCK,
                    FeetBootsLeaping = ItemBan.Type.GENERATION,
                    --RingRegeneration = ItemBan.Type.GENERATION
                }
            },
            textCharacterSelectionMessage = {
                text = "March Mode!\nMove near enemies to build static\n then discharge it to attack enemies."
            },]]--
        },
        {   
            sprite = {
                texture = "mods/Arrhythmeow/sprites/player1_heads.png",

            },--[[
            attachmentCopySpritePosition = {
                offsetY = -4,
                offsetZ = 4
            }]]--
        }
    }--,
    --modifier = function(entity)
    --    PlayableCharacters.addCharacterSounds(entity, "suzu")
    --end
}