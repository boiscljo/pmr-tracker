--[[----------------------------------------------------------
    LCL
------------------------------------------------------------]]
function ch1Required()
    return itemStage("spirit_requirements") <= 1 or hasItem("ch1_lcl")
end
function ch2Required()
    return itemStage("spirit_requirements") <= 1 or hasItem("ch2_lcl")
end
function ch3Required()
    return itemStage("spirit_requirements") <= 1 or hasItem("ch3_lcl")
end
function ch4Required()
    return itemStage("spirit_requirements") <= 1 or hasItem("ch4_lcl")
end
function ch5Required()
    return itemStage("spirit_requirements") <= 1 or hasItem("ch5_lcl")
end
function ch6Required()
    return itemStage("spirit_requirements") <= 1 or hasItem("ch6_lcl")
end
function ch7Required()
    return itemStage("spirit_requirements") <= 1 or hasItem("ch7_lcl")
end

--[[----------------------------------------------------------
    Dungeon Entrances
------------------------------------------------------------]]
function DungeonAccessible(dungeon)
    local entranceAccessibleFn = {
        KoopaBrosFortressEntranceAccess,
        DryDryRuinsEntranceAccess,
        TubbaCastleEntranceAccess,
        ToyBoxEntranceAccess,
        VolcanoEntranceAccess,
        FlowerFieldsGateAccess,
        CrystalPalaceEntranceAccess
    }

    if hasItem("dungeon_setting") then
        for i=1,7,1 do
            local dungeon_entrance = "ch"..i.."_dungeon_0"
            if itemStage(dungeon_entrance) == dungeon then
                return entranceAccessibleFn[i]()
            end
        end

        return false
    end

    return entranceAccessibleFn[dungeon]()
end

--[[----------------------------------------------------------
    Prologue Region Access
------------------------------------------------------------]]
function GoombaVillageAccess()
    if hasItem("start_goomba") then
        return true
    end
    if ToadTownAccess() then
        local open_prologue = hasItem("open_prologue")
        local boots = hasItem("boots")
        local hammer2 = hasItem("hammer2")
        if open_prologue and canClimbShortLedges() and canBreakYellowBlocks() then
            return true
        elseif boots and hammer2 then
            return true
        end
    end
    return false
end

function GoombaRoadAccess()
    if ToadTownAccess() and hasItem("open_prologue") and canClimbShortLedges() then
        return true
    elseif GoombaVillageAccess() and canBreakYellowBlocks() then
        return true
    end
    return false
end

function BlueHousePipeAccess()
    return ToadTownAccess() and canClimbShortLedges() and (hasItem("oddkey_base") or hasItem("open_blue_house"))
end

function ToadTownAccess()
    -- start == ToadTown or start == YoshisIsland
    if hasItem("start_toadtown") or hasItem("start_yoshi") then
        return true
    -- start == DryDryOutpost and boots
    elseif hasItem("start_desert") and hasItem("boots") then
        return true
    -- start == GoombaVillage and (bombette or hammer) and (parakarry or boots)
    elseif hasItem("start_goomba") and canBreakYellowBlocks() and canClimbShortLedges() then
        return true
    end

    return false
end

--[[----------------------------------------------------------
    Chapter 1 Region Access
------------------------------------------------------------]]
function KoopaVillageAccess()
    return ToadTownAccess() and canBreakYellowBlocks() and canClimbShortLedges()
end

function KoloradoAccess()
    if DryDryDesertAccess() or (hasItem("mamar") and KoopaVillageAccess()) then
        return true
    end
    return false
end

function KoopaBrosFortressEntranceAccess()
    return KoopaVillageAccess() and kooper()
end

function KoopaBrosFortressAccess()
    return DungeonAccessible(1)
end

--[[----------------------------------------------------------
    Chapter 2 Region Access
------------------------------------------------------------]]
function DryDryDesertAccess()
    if hasItem("start_desert") then
        return true
    end
    -- Toad Town -> Desert
    if ToadTownAccess() then
        local boots = hasItem("boots")

        -- can access the desert through the sewers
        if boots and hasItem("hammer2") then
            return true
        end

        -- can traverse mt rugged to get to the desert
        return (hasItem("open_mt_rugged") or bombette()) and boots and parakarry()
    end

    return false
end

function FrontMtRuggedAccess()
    if hasItem("start_desert") and canClimbShortLedges() then
        return true
    end
    -- TODO: first check if Desert Start
    if ToadTownAccess() then
        local boots = hasItem("boots")
        local from_train = (hasItem("open_mt_rugged") or bombette())
        local from_sewers = boots and hasItem("hammer2")
        return from_train or from_sewers
    end

    return false
end

function MtRuggedAccess()
    if hasItem("start_desert") and canClimbShortLedges() then
        return true
    end
    -- TODO: first check if Desert Start
    if ToadTownAccess() then
        local boots = hasItem("boots")
        local from_train = (hasItem("open_mt_rugged") or bombette()) and boots
        local from_sewers = boots and hasItem("hammer2")
        return from_train or from_sewers
    end

    return false
end

function DryDryRuinsEntranceAccess()
    return DryDryDesertAccess() and hasItem("pulse_stone")
end

function DryDryRuinsAccess()
    return DungeonAccessible(2)
end

--[[----------------------------------------------------------
    Chapter 3 Region Access
------------------------------------------------------------]]
function ClosedForest()
    return not hasItem("open_forest")
end

function BoosMansionPipeRoomAccess()
    if ToadTownAccess() then
        if hasItem("boots2") then
            return true
        else
            return sushie() and bombette() and BlueHousePipeAccess()
        end
    end
    return false
end

function BoosMansionAccess()
    if ToadTownAccess() then
        local forest_pass = hasItem("forest_pass_base") or hasItem("open_forest")
        local mansion_room = ((BoosMansionPipeRoomAccess() and hasItem("boots")) or forest_pass)
        -- logically need boots to enter mansion
        if hasItem("boots") then
            return mansion_room
        elseif parakarry() then
            return AccessibilityLevel.SequenceBreak
        end
    end
    return false
end

function OutsideBoosMansionAccess()
    if ToadTownAccess() then
        local forest_pass = hasItem("forest_pass_base") or hasItem("open_forest")
        local mansion_room = (BoosMansionPipeRoomAccess() or forest_pass)
        return mansion_room
    end
    return false
end

function ForeverForestAccess()
    if ToadTownAccess() then
        local boots = hasItem("boots")
        local forest_pass = hasItem("forest_pass_base") or hasItem("open_forest")

        if forest_pass then
            return true
        elseif (BoosMansionPipeRoomAccess() and boots) then
            return AccessibilityLevel.SequenceBreak
        end
    end
    return false
end

function GustyGulchAccess()
    if hasItem("boo_portrait_base") and hasItem("boots") then
        return BoosMansionAccess()
    end
    return false
end

function TubbaCastleEntranceAccess()
    if parakarry() then
        return GustyGulchAccess()
    end
    return false
end

function TubbaCastleAccess()
    return DungeonAccessible(3)
end

--[[----------------------------------------------------------
    Chapter 4 Region Access
------------------------------------------------------------]]
function ToyBoxEntranceAccess()
    return ToadTownAccess() and (bow() or hasItem("open_toy_box")) and (hasItem("boots") or parakarry())
end

function ToyBoxAccess()
    return DungeonAccessible(4)
end

function ToyBoxPinkAccess()
    return ToyBoxAccess() and ToyBoxEntranceAccess() and hasItem("boots") and hasItem("toy_train_base")
end

function ToyBoxGreenAccess()
    if ToyBoxPinkAccess() then
        if cookingAvailable() and hasItem("cakemix") and hasItem("cake") then
            return true
        elseif hasItem("cake") or (hasItem("cakemix") and hasItem("cake")) then
            return AccessibilityLevel.SequenceBreak -- out of logic
        end
    end
    return false
end

function ToyBoxRedAccess()
    if hasItem("hammer") then
        local green = ToyBoxGreenAccess()
        if green then
            if hasItem("mystery_note_base") and hasItem("dictionary_base") then
                return green
            else
                return AccessibilityLevel.SequenceBreak -- out of logic
            end
        end
    end
    return false
end

--[[----------------------------------------------------------
    Chapter 5 Region Access
------------------------------------------------------------]]
function YoshisIslandAccess()
    if hasItem("start_yoshi") then
        return true
    end

    local boots = hasItem("boots")
    local boots2 = hasItem("boots2")
    local hammer = hasItem("hammer")
    local bombette = bombette()

    -- Whale
    if hasItem("open_whale") or ((boots2 or hammer or bombette) and watt()) then
        return true
    -- shortcut pipe through blue house
    elseif BlueHousePipeAccess() and bombette and boots then
        return true
    -- shortcut pipe through main sewer entrance
    elseif boots2 and sushie() then
        return true
    end
    return false
end

function VolcanoEntranceAccess()
    return YoshisIslandAccess() and sushie() and hasItem("jade_raven_base") and hasItem("boots") and hasItem("hammer")
end

function VolcanoAccess()
    return DungeonAccessible(5)
end

--[[----------------------------------------------------------
    Chapter 6 Region Access
------------------------------------------------------------]]
function FlowerFieldsGateAccess()
    local seed_count = itemCount("seed1") + itemCount("seed2") + itemCount("seed3") + itemCount("seed4")
    return ToadTownAccess() and ((itemStage("seeds") >= itemCount("required_seeds")) or (seed_count >= itemCount("required_seeds")))
end

function FlowerFieldsAccess()
    return DungeonAccessible(6)
end

--[[----------------------------------------------------------
    Chapter 7 Region Access
------------------------------------------------------------]]
function ShiverCityAccess()
    if ToadTownAccess() then
        -- bridge room access
        if (BlueHousePipeAccess() and bombette()) or (hasItem("boots2") and sushie()) then
            -- cross already open bridge
            if hasItem("open_ch7_bridge") then
                return canClimbShortLedges()
            -- activate bridge
            elseif hasItem("boots3") then
                return hiddenBlocks()
            end
        end
    end
    return false
end

function ShiverMountainAccess()
    local a = ShiverCityAccess()
    if hasItem("warehouse_key") and hasItem("scarf") and hasItem("bucket") then
        return a
    end
    return false
end

function ShiverMountainPart2Access()
    local a = ShiverMountainAccess()
    if kooper() then
        return a
    end
    return false
end

function CrystalPalaceEntranceAccess()
    local a = ShiverMountainPart2Access()
    if hasItem("star_stone") then
        return a
    end
    return false
end

function CrystalPalaceAccess()
    return DungeonAccessible(7)
end

--[[----------------------------------------------------------
    Chapter 8 Region Access
------------------------------------------------------------]]
function SpecificSpiritRequirementsMet()
    if  (hasItem("ch1_lcl") and not hasItem("eldstar")) or 
        (hasItem("ch2_lcl") and not hasItem("mamar")) or 
        (hasItem("ch3_lcl") and not hasItem("skolar")) or 
        (hasItem("ch4_lcl") and not hasItem("muskular")) or 
        (hasItem("ch5_lcl") and not hasItem("misstar")) or 
        (hasItem("ch6_lcl") and not hasItem("klevar")) or 
        (hasItem("ch7_lcl") and not hasItem("kalmar")) then
        return false
    end
    return true
end


function StarHavenAccess()
    if ToadTownAccess() and hasItem("boots") then
        if itemCount("power_star") >= itemCount("sw_powerstars") then
            if (hasItem("sr_any") and itemCount("star_spirit") >= itemCount("sw_spirits")) or
                (itemStage("spirit_requirements") > 0 and SpecificSpiritRequirementsMet()) then
                return true
            end
        end
    end
    return false
end

function BowsersCastle2Access()
    if StarHavenAccess() then
        if itemCount("ch8_key") >= 2 and bombette() and bow() and parakarry() and lakilester() and watt() then
            return true
        elseif itemCount("ch8_key") >= 1 and hasItem("bc_shortened") then
            return true
        elseif itemCount("ch8_key") >= 1 then
            return AccessibilityLevel.SequenceBreak -- out of logic
        end
    end
    return AccessibilityLevel.None
end

function BowsersCastle3Access()
    local a = BowsersCastle2Access()
    if sushie() and hasItem("boots3") and a ~= AccessibilityLevel.None then
        if itemCount("ch8_key") >= 4 then
            return a
        elseif itemCount("ch8_key") >= 3 and hasItem("bc_shortened") then
            return a
        elseif itemCount("ch8_key") >= 3 then
            return AccessibilityLevel.SequenceBreak
        end
    end
    return AccessibilityLevel.None
end

function PeachsCastleAccess()
    local a = BowsersCastle3Access()
    if hasItem("bc_bossrush") and StarHavenAccess() then
        return true
    end
    if a ~= AccessibilityLevel.None then
        if itemCount("ch8_key") >= 5 then
            return a
        elseif itemCount("ch8_key") >= 4 and hasItem("bc_shortened") then
            return a
        elseif itemCount("ch8_key") >= 4 then
            return AccessibilityLevel.SequenceBreak
        end
    end
    return false
end

function BeamAccess()
    if itemCount("power_star") >= itemCount("sb_powerstars") then
        if (hasItem("sr_any") and itemCount("star_spirit") >= itemCount("sb_spirits")) or
            (itemStage("spirit_requirements") > 0 and SpecificSpiritRequirementsMet()) then
            return true
        end
    end
    return false
end
