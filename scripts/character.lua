--this file takes care of all the setup for the actual character

--modules
local customEntities = require "necro.game.data.CustomEntities"
local SoundGroups = require "necro.audio.SoundGroups"

local ItemBan = require "necro.game.item.ItemBan"

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
            },
            cloneSprite = {
                texture = "mods/Arrhythmeow/sprites/arrhythmeowClone.png",
                height = 27,
                offsetX = -1,
                offsetY = 1
            },
            --[[characterEquipmentSpriteRow = false,]]--
            initialInventory = {
                items = {
                    "ShovelBasic",
                    "WeaponObsidianCat",
                    "Bomb",
                    "ArmorObsidian"
                }
            },
            inventoryBannedItems = {
                components = {
                    shrineBanRhythmlocked = ItemBan.Type.FULL,
                }
            },
            textCharacterSelectionMessage = {
                text = "Arrhythmeow Mode!\nPlay with purregular tempo."
            },
            bestiary = {
                image = "mods/Arrhythmeow/sprites/bestiary_arrhythmeow.png"
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
            },,
            inventoryBannedItemTypes = {
                types = {
                    Sync_CharmThrowing = ItemBan.Type.FULL,
                    trill_throwBand = ItemBan.Type.FULL,
                    march_DischargeSpell = ItemBan.Type.LOCK,
                    FeetBootsLeaping = ItemBan.Type.GENERATION,
                    --RingRegeneration = ItemBan.Type.GENERATION
                }
            },]]--
        },
        {   
            sprite = {
                texture = "mods/Arrhythmeow/sprites/player1_heads.png",

            },
            attachmentCopySpritePosition = {
                offsetY = -4,
                offsetZ = 4
            }
            
        },
        characterEquipmentSpriteRow = {
            defaultBodyRow = 2
        },
        equipment = {
            slotOffsets= {
                shovel = {3,3, 3,3, 3,3, 3,3},
                weapon = {10,0, 1,1, 1,2, 0,1},
                head = {3,-1, 3,0, 3,1, 3,-1},
                feet = {1,1, 1,1, 1,1, 1,1},
                torch = {0,0, 0,0, 0,0, 0,0},
                ring = {1,0, 0,1, 0,2, 1,2},
                misc = {1,-1, 1,0, 1,2, 1,0},
                hud = {0,-1, 0,-1, 0,1, 0,0}
            },
            slotMirrors= {
                head=0
            }
        }
    }--,
    --modifier = function(entity)
    --    PlayableCharacters.addCharacterSounds(entity, "suzu")
    --end
}