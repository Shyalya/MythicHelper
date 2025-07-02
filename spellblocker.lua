local addonName, _ = ...
SpellBlockerDB = SpellBlockerDB or {}
SpellBlockerBlockAllPos = SpellBlockerBlockAllPos or {}
SpellBlockerLastActiveTab = SpellBlockerLastActiveTab or nil
SpellBlockerMinimapPos = SpellBlockerMinimapPos or 45  -- Standard-Position bei 45 Grad
MythicHelper_SpecialBlockedSpellsDB = MythicHelper_SpecialBlockedSpellsDB or {}
MythicHelper_SpecialBlockedSpells = MythicHelper_SpecialBlockedSpellsDB

local SPELLS = {    WARRIOR = {        -- === ARMS SPEC ===
        { id = 0, name = "ARMS_SEPARATOR", tooltip = "Arms Spec" },
        { id = 12292, name = "Death Wish", tooltip = "Blocks Death Wish" },
        { id = 46924, name = "Bladestorm", tooltip = "Blocks Bladestorm" },
        { id = 47486, name = "Mortal Strike", tooltip = "Blocks Mortal Strike" },
        { id = 47471, name = "Execute", tooltip = "Blocks Execute" },
        { id = 7384,  name = "Overpower", tooltip = "Blocks Overpower" },
        { id = 47465, name = "Rend", tooltip = "Blocks Rend" },
        { id = 47475, name = "Slam", tooltip = "Blocks Slam" },
        { id = 676,   name = "Disarm", tooltip = "Blocks Disarm" },        -- === FURY SPEC ===
        { id = 0, name = "FURY_SEPARATOR", tooltip = "Fury Spec" },
        { id = 1719,  name = "Recklessness", tooltip = "Blocks Recklessness" },
        { id = 18499, name = "Berserker Rage", tooltip = "Blocks Berserker Rage" },
        { id = 20230, name = "Retaliation", tooltip = "Blocks Retaliation" },
        { id = 23881, name = "Bloodthirst", tooltip = "Blocks Bloodthirst" },
        { id = 1680, name = "Whirlwind", tooltip = "Blocks Whirlwind" },
        { id = 47450, name = "Heroic Strike", tooltip = "Blocks Heroic Strike" },
        { id = 47520, name = "Cleave", tooltip = "Blocks Cleave" },
        { id = 34428, name = "Victory Rush", tooltip = "Blocks Victory Rush" },
        { id = 2687,  name = "Bloodrage", tooltip = "Blocks Bloodrage" },

        -- === PROTECTION SPEC ===
        { id = 0, name = "PROTECTION_SEPARATOR", tooltip = "Protection Spec" },
        { id = 12975, name = "Last Stand", tooltip = "Blocks Last Stand" },
        { id = 23920, name = "Spell Reflection", tooltip = "Blocks Spell Reflection" },
        { id = 2565,  name = "Shield Block", tooltip = "Blocks Shield Block" },
        { id = 12809, name = "Concussion Blow", tooltip = "Blocks Concussion Blow" },
        { id = 871,   name = "Shield Wall", tooltip = "Blocks Shield Wall" },
        { id = 47488, name = "Shield Slam", tooltip = "Blocks Shield Slam" },
        { id = 47498, name = "Devastate", tooltip = "Blocks Devastate" },
        { id = 57823, name = "Revenge", tooltip = "Blocks Revenge" },
        { id = 46968, name = "Shockwave", tooltip = "Blocks Shockwave" },
        { id = 47502, name = "Thunder Clap", tooltip = "Blocks Thunder Clap" },
        { id = 355,   name = "Taunt", tooltip = "Blocks Taunt" },
        { id = 7386,  name = "Sunder Armor", tooltip = "Blocks Sunder Armor" },

        -- === UTILITY & MOBILITY ===
        { id = 0, name = "UTILITY_SEPARATOR", tooltip = "Utility & Mobility" },
        { id = 6552,  name = "Pummel", tooltip = "Blocks Pummel" },
        { id = 5246,  name = "Intimidating Shout", tooltip = "Blocks Intimidating Shout" },
        { id = 1161,  name = "Challenging Shout", tooltip = "Blocks Challenging Shout" },
        { id = 3411,  name = "Intervene", tooltip = "Blocks Intervene" },
        { id = 20252, name = "Intercept", tooltip = "Blocks Intercept" },
        { id = 47437, name = "Commanding Shout", tooltip = "Blocks Commanding Shout" },
        { id = 47436, name = "Battle Shout", tooltip = "Blocks Battle Shout" },
        { id = 100,   name = "Charge", tooltip = "Blocks Charge" },
    },
PALADIN = {
    -- === HOLY SPEC ===
    { id = 0, name = "HOLY_SEPARATOR", tooltip = "Holy Spec" },
    { id = 31842, name = "Divine Illumination", tooltip = "Blocks Divine Illumination" },
    { id = 20473, name = "Holy Shock", tooltip = "Blocks Holy Shock" },
    { id = 54428, name = "Divine Plea", tooltip = "Blocks Divine Plea" },
    { id = 31821, name = "Aura Mastery", tooltip = "Blocks Aura Mastery" },
    { id = 48782, name = "Holy Light", tooltip = "Blocks Holy Light" },
    { id = 48785, name = "Flash of Light", tooltip = "Blocks Flash of Light" },
    { id = 53563, name = "Beacon of Light", tooltip = "Blocks Beacon of Light" },
    
    { id = 4987,  name = "Cleanse", tooltip = "Blocks Cleanse" },
   

    -- === PROTECTION SPEC ===
    { id = 0, name = "PROTECTION_SEPARATOR", tooltip = "Protection Spec" },
    { id = 642,   name = "Divine Shield", tooltip = "Blocks Divine Shield" },
    { id = 498,   name = "Divine Protection", tooltip = "Blocks Divine Protection" },
    
    { id = 31935, name = "Avenger's Shield", tooltip = "Blocks Avenger's Shield" },
    { id = 20925, name = "Holy Shield", tooltip = "Blocks Holy Shield" },
    { id = 48819, name = "Consecration", tooltip = "Blocks Consecration" },
    { id = 53595, name = "Hammer of the Righteous", tooltip = "Blocks Hammer of the Righteous" },    { id = 31789, name = "Righteous Defense", tooltip = "Blocks Righteous Defense" },
 
       -- === RETRIBUTION SPEC ===
    { id = 0, name = "RETRIBUTION_SEPARATOR", tooltip = "Retribution Spec" },
    { id = 31884, name = "Avenging Wrath", tooltip = "Blocks Avenging Wrath" },
    { id = 20066, name = "Repentance", tooltip = "Blocks Repentance" },
    { id = 53385, name = "Divine Storm", tooltip = "Blocks Divine Storm" },
    { id = 35395, name = "Crusader Strike", tooltip = "Blocks Crusader Strike" },
    { id = 48806, name = "Hammer of Wrath", tooltip = "Blocks Hammer of Wrath" },
    { id = 48801, name = "Exorcism", tooltip = "Blocks Exorcism" },
    { id = 48817, name = "Holy Wrath", tooltip = "Blocks Holy Wrath" },
    { id = 10308, name = "Hammer of Justice", tooltip = "Blocks Hammer of Justice" },
    
    -- === JUDGMENTS & SEALS ===
    { id = 0, name = "JUDGMENT_SEPARATOR", tooltip = "Judgments & Seals" },
    { id = 53408, name = "Judgment of Wisdom", tooltip = "Blocks Judgment of Wisdom" },
    { id = 20271, name = "Judgment of Light", tooltip = "Blocks Judgment of Light" },
    { id = 21084, name = "Seal of Righteousness", tooltip = "Blocks Seal of Righteousness" },
    { id = 20164, name = "Seal of Justice", tooltip = "Blocks Seal of Justice" },
    { id = 20167, name = "Seal of Light", tooltip = "Blocks Seal of Light" },
    { id = 20166, name = "Seal of Wisdom", tooltip = "Blocks Seal of Wisdom" },
    { id = 20375, name = "Seal of Command", tooltip = "Blocks Seal of Command" },
    { id = 53736, name = "Seal of Vengeance", tooltip = "Blocks Seal of Vengeance" },
    { id = 31801, name = "Seal of Corruption", tooltip = "Blocks Seal of Corruption" },

     -- === HAND OF SPELLS ===
    { id = 0, name = "HAND_OF_SEPARATOR", tooltip = "Hands" },
    { id = 6940,  name = "Hand of Sacrifice", tooltip = "Blocks Hand of Sacrifice" },
    { id = 1022,  name = "Hand of Protection", tooltip = "Blocks Hand of Protection" },
    { id = 1044,  name = "Hand of Freedom", tooltip = "Blocks Hand of Freedom" },
     { id = 1038,  name = "Hand of Salvation", tooltip = "Blocks Hand of Salvation" },

    -- === BLESSINGS ===
    { id = 0, name = "BLESSING_SEPARATOR", tooltip = "Blessings" },
    { id = 20217, name = "Blessing of Kings", tooltip = "Blocks Blessing of Kings" },
    { id = 25898, name = "Greater Blessing of Kings", tooltip = "Blocks Greater Blessing of Kings" },
    { id = 48932, name = "Blessing of Might", tooltip = "Blocks Blessing of Might" },
    { id = 48934, name = "Greater Blessing of Might", tooltip = "Blocks Greater Blessing of Might" },
    { id = 48936, name = "Blessing of Wisdom", tooltip = "Blocks Blessing of Wisdom" },
    { id = 48938, name = "Greater Blessing of Wisdom", tooltip = "Blocks Greater Blessing of Wisdom" },
    { id = 20911, name = "Blessing of Sanctuary", tooltip = "Blocks Blessing of Sanctuary" },
    { id = 25899, name = "Greater Blessing of Sanctuary", tooltip = "Blocks Greater Blessing of Sanctuary" },
    

    -- === AURAS ===
    { id = 0, name = "AURA_SEPARATOR", tooltip = "Auras" },
    { id = 7294,  name = "Retribution Aura", tooltip = "Blocks Retribution Aura" },
    { id = 19746, name = "Concentration Aura", tooltip = "Blocks Concentration Aura" },
    { id = 19876, name = "Shadow Resistance Aura", tooltip = "Blocks Shadow Resistance Aura" },
    { id = 19888, name = "Frost Resistance Aura", tooltip = "Blocks Frost Resistance Aura" },
    { id = 19891, name = "Fire Resistance Aura", tooltip = "Blocks Fire Resistance Aura" },
    { id = 465,   name = "Devotion Aura", tooltip = "Blocks Devotion Aura" },
},    DEATHKNIGHT = {
        -- === BLOOD SPEC ===
        { id = 0, name = "BLOOD_SEPARATOR", tooltip = "Blood Spec" },
        { id = 55233, name = "Vampiric Blood", tooltip = "Blocks Vampiric Blood" },
        { id = 49028, name = "Dancing Rune Weapon", tooltip = "Blocks Dancing Rune Weapon" },
        { id = 48743, name = "Death Pact", tooltip = "Blocks Death Pact" },
        { id = 49016, name = "Hysteria", tooltip = "Blocks Hysteria" },
        { id = 49005, name = "Mark of Blood", tooltip = "Blocks Mark of Blood" },
        { id = 49998, name = "Death Strike", tooltip = "Blocks Death Strike" },
        { id = 55050, name = "Heart Strike", tooltip = "Blocks Heart Strike" },
        { id = 49941, name = "Blood Boil", tooltip = "Blocks Blood Boil" },
        { id = 45529, name = "Blood Tap", tooltip = "Blocks Blood Tap" },
        { id = 50842, name = "Pestilence", tooltip = "Blocks Pestilence" },
        { id = 49930, name = "Blood Strike", tooltip = "Blocks Blood Strike" },

        -- === FROST SPEC ===
        { id = 0, name = "FROST_SEPARATOR", tooltip = "Frost Spec" },
        { id = 48792, name = "Icebound Fortitude", tooltip = "Blocks Icebound Fortitude" },
        { id = 51271, name = "Unbreakable Armor", tooltip = "Blocks Unbreakable Armor" },
        { id = 47568, name = "Empower Rune Weapon", tooltip = "Blocks Empower Rune Weapon" },
        { id = 49909, name = "Icy Touch", tooltip = "Blocks Icy Touch" },
        { id = 55268, name = "Frost Strike", tooltip = "Blocks Frost Strike" },
        { id = 49020, name = "Obliterate", tooltip = "Blocks Obliterate" },
        { id = 45524, name = "Chains of Ice", tooltip = "Blocks Chains of Ice" },
        { id = 47528, name = "Mind Freeze", tooltip = "Blocks Mind Freeze" },
        { id = 51410, name = "Howling Blast", tooltip = "Blocks Howling Blast" },
        { id = 56815, name = "Rune Strike", tooltip = "Blocks Rune Strike" },

        -- === UNHOLY SPEC ===
        { id = 0, name = "UNHOLY_SEPARATOR", tooltip = "Unholy Spec" },
        { id = 49222, name = "Bone Shield", tooltip = "Blocks Bone Shield" },
        { id = 48707, name = "Anti-Magic Shell", tooltip = "Blocks Anti-Magic Shell" },
        { id = 51052, name = "Anti-Magic Zone", tooltip = "Blocks Anti-Magic Zone" },
        { id = 49039, name = "Lichborne", tooltip = "Blocks Lichborne" },
        { id = 49206, name = "Summon Gargoyle", tooltip = "Blocks Summon Gargoyle" },
        { id = 55271, name = "Scourge Strike", tooltip = "Blocks Scourge Strike" },
        { id = 49895, name = "Death Coil", tooltip = "Blocks Death Coil" },
        { id = 49938, name = "Death and Decay", tooltip = "Blocks Death and Decay" },
        { id = 47481, name = "Gnaw (Ghoul)", tooltip = "Blocks Ghoul's Gnaw" },
        { id = 46584, name = "Raise Dead", tooltip = "Blocks Raise Dead" },
        { id = 45462, name = "Plague Strike", tooltip = "Blocks Plague Strike" },

        -- === UTILITY & CONTROL ===
        { id = 0, name = "UTILITY_SEPARATOR", tooltip = "Utility & Control" },
        { id = 47476, name = "Strangulate", tooltip = "Blocks Strangulate" },
        { id = 49576, name = "Death Grip", tooltip = "Blocks Death Grip" },
        { id = 3714,  name = "Path of Frost", tooltip = "Blocks Path of Frost" },
        { id = 50977, name = "Death Gate", tooltip = "Blocks Death Gate" },
        { id = 61999, name = "Raise Ally", tooltip = "Blocks Raise Ally" },
        { id = 42650, name = "Army of the Dead", tooltip = "Blocks Army of the Dead" },
    },PRIEST = {
        -- === HOLY SPEC ===
        { id = 0, name = "HOLY_SEPARATOR", tooltip = "Holy Spec" },
        { id = 48068, name = "Renew", tooltip = "Blocks Greater Heal" },
        { id = 48063, name = "Greater Heal", tooltip = "Blocks Greater Heal" },
        { id = 48071, name = "Flash Heal", tooltip = "Blocks Flash Heal" },
        { id = 48113, name = "Prayer of Healing", tooltip = "Blocks Prayer of Healing" },
        { id = 48120, name = "Binding Heal", tooltip = "Blocks Binding Heal" },
        { id = 48072, name = "Prayer of Mending", tooltip = "Blocks Prayer of Mending" },
        { id = 48078, name = "Circle of Healing", tooltip = "Blocks Circle of Healing" },
        { id = 47788, name = "Guardian Spirit", tooltip = "Blocks Guardian Spirit" },
        { id = 64843, name = "Divine Hymn", tooltip = "Blocks Divine Hymn" },
        { id = 64901, name = "Hymn of Hope", tooltip = "Blocks Hymn of Hope" },
        { id = 6346,  name = "Fear Ward", tooltip = "Blocks Fear Ward" },
        { id = 14751, name = "Inner Focus", tooltip = "Blocks Inner Focus" },
        { id = 48123, name = "Smite", tooltip = "Blocks Smite" },
        { id = 48135, name = "Holy Fire", tooltip = "Blocks Holy Fire" },
        { id = 48089, name = "Circle of Healing", tooltip = "Blocks Circle of Healing" },

        -- === DISCIPLINE SPEC ===
        { id = 0, name = "DISCIPLINE_SEPARATOR", tooltip = "Discipline Spec" },
        { id = 33206, name = "Pain Suppression", tooltip = "Blocks Pain Suppression" },
        { id = 47750, name = "Penance", tooltip = "Blocks Penance" },
        { id = 17, name = "Power Word: Shield", tooltip = "Blocks Power Word: Shield" },
        { id = 48074, name = "Prayer of Healing", tooltip = "Blocks Prayer of Healing" },
        { id = 552, name = "Abolish Disease", tooltip = "Blocks Abolish Disease" },
        { id = 988, name = "Dispel Magic", tooltip = "Blocks Dispel Magic" },
        { id = 10060, name = "Power Infusion", tooltip = "Blocks Power Infusion" },


        -- === SHADOW SPEC ===
        { id = 0, name = "SHADOW_SEPARATOR", tooltip = "Shadow Spec" },
        { id = 47585, name = "Dispersion", tooltip = "Blocks Dispersion" },
        { id = 15487, name = "Silence", tooltip = "Blocks Silence" },
        { id = 10890, name = "Psychic Scream", tooltip = "Blocks Psychic Scream" },
        { id = 34433, name = "Shadowfiend", tooltip = "Blocks Shadowfiend" },
        { id = 15286, name = "Vampiric Embrace", tooltip = "Blocks Vampiric Embrace" },
        { id = 53023, name = "Mind Sear", tooltip = "Blocks Mind Sear" },
        { id = 48125, name = "Shadow Word: Pain", tooltip = "Blocks Shadow Word: Pain" },
        { id = 48158, name = "Shadow Word: Death", tooltip = "Blocks Shadow Word: Death" },
        { id = 48160, name = "Vampiric Touch", tooltip = "Blocks Vampiric Touch" },
        { id = 48127, name = "Mind Blast", tooltip = "Blocks Mind Blast" },
        { id = 48156, name = "Mind Flay", tooltip = "Blocks Mind Flay" },
        { id = 48300, name = "Devouring Plague", tooltip = "Blocks Devouring Plague" },
    },    MAGE = {
        -- === ARCANE SPEC ===
        { id = 0, name = "ARCANE_SEPARATOR", tooltip = "Arcane Spec" },
        { id = 12042, name = "Arcane Power", tooltip = "Blocks Arcane Power" },
        { id = 12043, name = "Presence of Mind", tooltip = "Blocks Presence of Mind" },
        { id = 12051, name = "Evocation", tooltip = "Blocks Evocation" },
        { id = 1463,  name = "Mana Shield", tooltip = "Blocks Mana Shield" },
        { id = 42897, name = "Arcane Blast", tooltip = "Blocks Arcane Blast" },
        { id = 42921, name = "Arcane Barrage", tooltip = "Blocks Arcane Barrage" },
        { id = 42846, name = "Arcane Missiles", tooltip = "Blocks Arcane Missiles" },
        { id = 2139,  name = "Counterspell", tooltip = "Blocks Counterspell" },

        -- === FIRE SPEC ===
        { id = 0, name = "FIRE_SEPARATOR", tooltip = "Fire Spec" },
        { id = 11129, name = "Combustion", tooltip = "Blocks Combustion" },
        { id = 42833, name = "Fireball", tooltip = "Blocks Fireball" },
        { id = 42873, name = "Fire Blast", tooltip = "Blocks Fire Blast" },
        { id = 42859, name = "Scorch", tooltip = "Blocks Scorch" },
        { id = 42891, name = "Pyroblast", tooltip = "Blocks Pyroblast" },
        { id = 42950, name = "Dragon's Breath", tooltip = "Blocks Dragon's Breath" },
        { id = 42945, name = "Blast Wave", tooltip = "Blocks Blast Wave" },
        { id = 42926, name = "Flame Strike", tooltip = "Blocks Flame Strike" },
        { id = 55360, name = "Living Bomb", tooltip = "Blocks Living Bomb" },
     

        -- === FROST SPEC ===
        { id = 0, name = "FROST_SEPARATOR", tooltip = "Frost Spec" },
        { id = 45438, name = "Ice Block", tooltip = "Blocks Ice Block" },
        { id = 12472, name = "Icy Veins", tooltip = "Blocks Icy Veins" },
        { id = 11958, name = "Cold Snap", tooltip = "Blocks Cold Snap" },
        { id = 31687, name = "Summon Water Elemental", tooltip = "Blocks Water Elemental" },
        { id = 44572, name = "Deep Freeze", tooltip = "Blocks Deep Freeze" },
        { id = 42842, name = "Frostbolt", tooltip = "Blocks Frostbolt" },
        { id = 42914, name = "Ice Lance", tooltip = "Blocks Ice Lance" },
        { id = 42931, name = "Cone of Cold", tooltip = "Blocks Cone of Cold" },
        { id = 42917, name = "Frost Nova", tooltip = "Blocks Frost Nova" },

        -- === GENERAL/UTILITY ===
        { id = 0, name = "UTILITY_SEPARATOR", tooltip = "General & Utility" },
        { id = 55342, name = "Mirror Image", tooltip = "Blocks Mirror Image" },
        { id = 1459,  name = "Arcane Intellect", tooltip = "Blocks Arcane Intellect" },
        { id = 61316, name = "Dalaran Brilliance", tooltip = "Blocks Dalaran Brilliance" },
        { id = 130,   name = "Slow Fall", tooltip = "Blocks Slow Fall" },
        { id = 475,   name = "Remove Curse", tooltip = "Blocks Remove Curse" },
        { id = 43010, name = "Fire Ward", tooltip = "Blocks Fire Ward" },
        { id = 43012, name = "Frost Ward", tooltip = "Blocks Frost Ward" },
    },WARLOCK = {
        -- === AFFLICTION SPEC ===
        { id = 0, name = "AFFLICTION_SEPARATOR", tooltip = "Affliction Spec" },
        { id = 47813, name = "Corruption", tooltip = "Blocks Corruption" },
        { id = 47836, name = "Seed of Corruption", tooltip = "Blocks Seed of Corruption" },
        { id = 47843, name = "Unstable Affliction", tooltip = "Blocks Unstable Affliction" },
        { id = 47855, name = "Drain Life", tooltip = "Blocks Drain Life" },
        { id = 47857, name = "Drain Soul", tooltip = "Blocks Drain Soul" },
        { id = 5138,  name = "Drain Mana", tooltip = "Blocks Drain Mana" },

        -- === DEMONOLOGY SPEC ===
        { id = 0, name = "DEMONOLOGY_SEPARATOR", tooltip = "Demonology Spec" },
        { id = 47241, name = "Metamorphosis", tooltip = "Blocks Metamorphosis" },
        { id = 18708, name = "Fel Domination", tooltip = "Blocks Fel Domination" },
        { id = 47193, name = "Demonic Empowerment", tooltip = "Blocks Demonic Empowerment" },
        { id = 48020, name = "Demonic Circle: Teleport", tooltip = "Blocks Demonic Circle: Teleport" },
        { id = 47996, name = "Intercept (Felguard)", tooltip = "Blocks Felguard's Intercept" },
        { id = 59671, name = "Challenging Howl", tooltip = "Blocks Voidwalker's Challenging Howl" },
        { id = 19647, name = "Spell Lock", tooltip = "Blocks Felhunter's Spell Lock" },
        { id = 691,   name = "Summon Felhunter", tooltip = "Blocks Summon Felhunter" },
        { id = 712,   name = "Summon Succubus", tooltip = "Blocks Summon Succubus" },
        { id = 1122,  name = "Summon Infernal", tooltip = "Blocks Summon Infernal" },
        { id = 18540, name = "Summon Doomguard", tooltip = "Blocks Summon Doomguard" },
        { id = 30146, name = "Summon Felguard", tooltip = "Blocks Summon Felguard" },
        { id = 697,   name = "Summon Voidwalker", tooltip = "Blocks Summon Voidwalker" },
        { id = 688,   name = "Summon Imp", tooltip = "Blocks Summon Imp" },

        -- === DESTRUCTION SPEC ===
        { id = 0, name = "DESTRUCTION_SEPARATOR", tooltip = "Destruction Spec" },
        { id = 47809, name = "Shadow Bolt", tooltip = "Blocks Shadow Bolt" },
        { id = 47811, name = "Immolate", tooltip = "Blocks Immolate" },
        { id = 47838, name = "Incinerate", tooltip = "Blocks Incinerate" },
        { id = 47825, name = "Soul Fire", tooltip = "Blocks Soul Fire" },
        { id = 47827, name = "Shadowburn", tooltip = "Blocks Shadowburn" },
        { id = 47847, name = "Shadowfury", tooltip = "Blocks Shadowfury" },
        { id = 47897, name = "Shadowflame", tooltip = "Blocks Shadowflame" },
        { id = 59172, name = "Chaos Bolt", tooltip = "Blocks Chaos Bolt" },
        { id = 18093, name = "Pyroclasm", tooltip = "Blocks Pyroclasm" },
        { id = 5676,  name = "Searing Pain", tooltip = "Blocks Searing Pain" },

        -- === CURSES & DEBUFFS ===
        { id = 0, name = "CURSES_SEPARATOR", tooltip = "Curses & Debuffs" },
        { id = 47865, name = "Curse of Elements", tooltip = "Blocks Curse of Elements" },
        { id = 47878, name = "Curse of Weakness", tooltip = "Blocks Curse of Weakness" },
        { id = 18223, name = "Curse of Exhaustion", tooltip = "Blocks Curse of Exhaustion" },
        { id = 1714,  name = "Curse of Tongues", tooltip = "Blocks Curse of Tongues" },
        { id = 47864, name = "Curse of Agony", tooltip = "Blocks Curse of Agony" },
        { id = 47867, name = "Curse of Doom", tooltip = "Blocks Curse of Doom" },
        

        -- === UTILITY & CONTROL ===
        { id = 0, name = "UTILITY_SEPARATOR", tooltip = "Utility & Control" },
        { id = 47883, name = "Soulshatter", tooltip = "Blocks Soulshatter" },
        { id = 47860, name = "Death Coil", tooltip = "Blocks Death Coil" },
        { id = 47891, name = "Shadow Ward", tooltip = "Blocks Shadow Ward" },
        { id = 5782,  name = "Fear", tooltip = "Blocks Fear" },
        { id = 5484,  name = "Howl of Terror", tooltip = "Blocks Howl of Terror" },
        { id = 710,   name = "Banish", tooltip = "Blocks Banish" },
        { id = 698,   name = "Ritual of Summoning", tooltip = "Blocks Ritual of Summoning" },
    },    ROGUE = {
        -- === ASSASSINATION SPEC ===
        { id = 0, name = "ASSASSINATION_SEPARATOR", tooltip = "Assassination Spec" },
        { id = 48666, name = "Mutilate", tooltip = "Blocks Mutilate" },
        { id = 48660, name = "Hemorrhage", tooltip = "Blocks Hemorrhage" },
        { id = 48676, name = "Garrote", tooltip = "Blocks Garrote" },
        { id = 48691, name = "Ambush", tooltip = "Blocks Ambush" },
        { id = 48657, name = "Backstab", tooltip = "Blocks Backstab" },
        { id = 48672, name = "Rupture", tooltip = "Blocks Rupture" },
        { id = 57993, name = "Envenom", tooltip = "Blocks Envenom" },
        { id = 5938,  name = "Shiv", tooltip = "Blocks Shiv" },
        { id = 8647,  name = "Expose Armor", tooltip = "Blocks Expose Armor" },

        -- === COMBAT SPEC ===
        { id = 0, name = "COMBAT_SEPARATOR", tooltip = "Combat Spec" },
        { id = 13877, name = "Blade Flurry", tooltip = "Blocks Blade Flurry" },
        { id = 51690, name = "Killing Spree", tooltip = "Blocks Killing Spree" },
        { id = 48638, name = "Sinister Strike", tooltip = "Blocks Sinister Strike" },
        { id = 48668, name = "Eviscerate", tooltip = "Blocks Eviscerate" },
        { id = 51723, name = "Fan of Knives", tooltip = "Blocks Fan of Knives" },
        { id = 48674, name = "Deadly Throw", tooltip = "Blocks Deadly Throw" },
        { id = 57934, name = "Tricks of the Trade", tooltip = "Blocks Tricks of the Trade" },
        { id = 6774,  name = "Slice and Dice", tooltip = "Blocks Slice and Dice" },
        { id = 1966,  name = "Feint", tooltip = "Blocks Feint" },

        -- === SUBTLETY SPEC ===
        { id = 0, name = "SUBTLETY_SEPARATOR", tooltip = "Subtlety Spec" },
        { id = 14185, name = "Preparation", tooltip = "Blocks Preparation" },
        { id = 51713, name = "Shadow Dance", tooltip = "Blocks Shadow Dance" },
        { id = 36554, name = "Shadowstep", tooltip = "Blocks Shadowstep" },
        { id = 31224, name = "Cloak of Shadows", tooltip = "Blocks Cloak of Shadows" },
        { id = 11327, name = "Vanish", tooltip = "Blocks Vanish" },
        { id = 1784,  name = "Stealth", tooltip = "Blocks Stealth" },
        { id = 14183, name = "Premeditation", tooltip = "Blocks Premeditation" },
        { id = 1725,  name = "Distraction", tooltip = "Blocks Distraction" },
        { id = 921,   name = "Pick Pocket", tooltip = "Blocks Pick Pocket" },

        -- === CONTROL & UTILITY ===
        { id = 0, name = "CONTROL_SEPARATOR", tooltip = "Control & Utility" },
        { id = 5277,  name = "Evasion", tooltip = "Blocks Evasion" },
        { id = 1766,  name = "Kick", tooltip = "Blocks Kick" },
        { id = 2094,  name = "Blind", tooltip = "Blocks Blind" },
        { id = 408,   name = "Kidney Shot", tooltip = "Blocks Kidney Shot" },
        { id = 51722, name = "Dismantle", tooltip = "Blocks Dismantle" },
        { id = 51724, name = "Sap", tooltip = "Blocks Sap" },
        { id = 1833,  name = "Cheap Shot", tooltip = "Blocks Cheap Shot" },
        { id = 1776,  name = "Gouge", tooltip = "Blocks Gouge" },
        { id = 1842,  name = "Disarm Trap", tooltip = "Blocks Disarm Trap" },
        { id = 1804,  name = "Pick Lock", tooltip = "Blocks Pick Lock" },
        { id = 13750, name = "Adrenaline Rush", tooltip = "Blocks Adrenaline Rush" },
        { id = 14177, name = "Cold Blood", tooltip = "Blocks Cold Blood" },

        -- === POISONS ===
        { id = 0, name = "POISONS_SEPARATOR", tooltip = "Poisons" },
        { id = 2823,  name = "Deadly Poison", tooltip = "Blocks Deadly Poison" },
        { id = 3408,  name = "Crippling Poison", tooltip = "Blocks Crippling Poison" },
        { id = 5761,  name = "Mind-numbing Poison", tooltip = "Blocks Mind-numbing Poison" },
        { id = 8679,  name = "Wound Poison", tooltip = "Blocks Wound Poison" },
    },HUNTER = {
        -- === BEAST MASTERY SPEC ===
        { id = 0, name = "BEAST_MASTERY_SEPARATOR", tooltip = "Beast Mastery Spec" },
        { id = 19574, name = "Bestial Wrath", tooltip = "Blocks Bestial Wrath" },
        { id = 34477, name = "Misdirection", tooltip = "Blocks Misdirection" },
        { id = 53271, name = "Master's Call", tooltip = "Blocks Master's Call" },
        { id = 19577, name = "Intimidation", tooltip = "Blocks Intimidation" },
        { id = 1515,  name = "Tame Beast", tooltip = "Blocks Tame Beast" },
        { id = 883,   name = "Call of the Wild", tooltip = "Blocks Call of the Wild" },
        { id = 6991,  name = "Feed Pet", tooltip = "Blocks Feed Pet" },
        { id = 982,   name = "Revive Pet", tooltip = "Blocks Revive Pet" },
        { id = 2641,  name = "Dismiss Pet", tooltip = "Blocks Dismiss Pet" },
        { id = 1462,  name = "Beast Lore", tooltip = "Blocks Beast Lore" },
        { id = 61684, name = "Dash", tooltip = "Blocks Pet Dash" },
        { id = 61685, name = "Charge", tooltip = "Blocks Pet Charge" },

        -- === MARKSMANSHIP SPEC ===
        { id = 0, name = "MARKSMANSHIP_SEPARATOR", tooltip = "Marksmanship Spec" },
        { id = 3045,  name = "Rapid Fire", tooltip = "Blocks Rapid Fire" },
        { id = 23989, name = "Readiness", tooltip = "Blocks Readiness" },
        { id = 19503, name = "Scatter Shot", tooltip = "Blocks Scatter Shot" },
        { id = 34490, name = "Silencing Shot", tooltip = "Blocks Silencing Shot" },
        { id = 49050, name = "Aimed Shot", tooltip = "Blocks Aimed Shot" },
        { id = 49052, name = "Steady Shot", tooltip = "Blocks Steady Shot" },
        { id = 49045, name = "Arcane Shot", tooltip = "Blocks Arcane Shot" },
        { id = 49048, name = "Multi-Shot", tooltip = "Blocks Multi-Shot" },
        { id = 61006, name = "Kill Shot", tooltip = "Blocks Kill Shot" },
        { id = 58434, name = "Volley", tooltip = "Blocks Volley" },
        { id = 19801, name = "Tranquilizing Shot", tooltip = "Blocks Tranquilizing Shot" },
        { id = 1978,  name = "Serpent Sting", tooltip = "Blocks Serpent Sting" },

        -- === SURVIVAL SPEC ===
        { id = 0, name = "SURVIVAL_SEPARATOR", tooltip = "Survival Spec" },
        { id = 19263, name = "Deterrence", tooltip = "Blocks Deterrence" },
        { id = 49012, name = "Wyvern Sting", tooltip = "Blocks Wyvern Sting" },
        { id = 53209, name = "Chimera Shot", tooltip = "Blocks Chimera Shot" },
        { id = 60053, name = "Explosive Shot", tooltip = "Blocks Explosive Shot" },
        { id = 60192, name = "Freezing Arrow", tooltip = "Blocks Freezing Arrow" },
        { id = 49001, name = "Serpent Sting", tooltip = "Blocks Serpent Sting" },
        { id = 49067, name = "Explosive Trap", tooltip = "Blocks Explosive Trap" },
        { id = 13809, name = "Frost Trap", tooltip = "Blocks Frost Trap" },
        { id = 49056, name = "Immolation Trap", tooltip = "Blocks Immolation Trap" },
        { id = 34600, name = "Snake Trap", tooltip = "Blocks Snake Trap" },
        { id = 1499,  name = "Freezing Trap", tooltip = "Blocks Freezing Trap" },
        { id = 14326, name = "Scare Beast", tooltip = "Blocks Scare Beast" },
        { id = 5116,  name = "Concussive Shot", tooltip = "Blocks Concussive Shot" },

        -- === UTILITY & MOBILITY ===
        { id = 0, name = "UTILITY_SEPARATOR", tooltip = "Utility & Mobility" },
        { id = 53338, name = "Hunter's Mark", tooltip = "Blocks Hunter's Mark" },
        { id = 781,   name = "Disengage", tooltip = "Blocks Disengage" },
        { id = 5384,  name = "Feign Death", tooltip = "Blocks Feign Death" },
        { id = 1543,  name = "Flare", tooltip = "Blocks Flare" },
        { id = 136,   name = "Mend Pet", tooltip = "Blocks Mend Pet" },
        { id = 6197,  name = "Eagle Eye", tooltip = "Blocks Eagle Eye" },
        { id = 1002,  name = "Eyes of the Beast", tooltip = "Blocks Eyes of the Beast" },
        { id = 2974,  name = "Wing Clip", tooltip = "Blocks Wing Clip" },

        -- === ASPECTS ===
        { id = 0, name = "ASPECTS_SEPARATOR", tooltip = "Aspects" },
        { id = 5118,  name = "Aspect of the Cheetah", tooltip = "Blocks Aspect of the Cheetah" },
        { id = 13159, name = "Aspect of the Pack", tooltip = "Blocks Aspect of the Pack" },
        { id = 20043, name = "Aspect of the Wild", tooltip = "Blocks Aspect of the Wild" },
        { id = 13165, name = "Aspect of the Hawk", tooltip = "Blocks Aspect of the Hawk" },
        { id = 34074, name = "Aspect of the Viper", tooltip = "Blocks Aspect of the Viper" },
        { id = 61648, name = "Aspect of the Dragonhawk", tooltip = "Blocks Aspect of the Dragonhawk" },
        { id = 13161, name = "Aspect of the Beast", tooltip = "Blocks Aspect of the Beast" },
    },SHAMAN = {
        -- === ELEMENTAL SPEC ===
        { id = 0, name = "ELEMENTAL_SEPARATOR", tooltip = "Elemental Spec" },
        { id = 16166, name = "Elemental Mastery", tooltip = "Blocks Elemental Mastery" },
        { id = 59159, name = "Thunderstorm", tooltip = "Blocks Thunderstorm" },
        { id = 49271, name = "Chain Lightning", tooltip = "Blocks Chain Lightning" },
        { id = 49238, name = "Lightning Bolt", tooltip = "Blocks Lightning Bolt" },
        { id = 49230, name = "Earth Shock", tooltip = "Blocks Earth Shock" },
        { id = 49233, name = "Flame Shock", tooltip = "Blocks Flame Shock" },
        { id = 49236, name = "Frost Shock", tooltip = "Blocks Frost Shock" },
        { id = 60043, name = "Lava Burst", tooltip = "Blocks Lava Burst" },

        -- === ENHANCEMENT SPEC ===
        { id = 0, name = "ENHANCEMENT_SEPARATOR", tooltip = "Enhancement Spec" },
        { id = 30823, name = "Shamanistic Rage", tooltip = "Blocks Shamanistic Rage" },
        { id = 51533, name = "Feral Spirit", tooltip = "Blocks Feral Spirit" },
        { id = 57994, name = "Wind Shear", tooltip = "Blocks Wind Shear" },
        { id = 17364, name = "Stormstrike", tooltip = "Blocks Stormstrike" },
        { id = 60103, name = "Lava Lash", tooltip = "Blocks Lava Lash" },
        { id = 8232,  name = "Windfury Weapon", tooltip = "Blocks Windfury Weapon" },
        { id = 8024,  name = "Flametongue Weapon", tooltip = "Blocks Flametongue Weapon" },
        { id = 8033,  name = "Frostbrand Weapon", tooltip = "Blocks Frostbrand Weapon" },

        -- === RESTORATION SPEC ===
        { id = 0, name = "RESTORATION_SEPARATOR", tooltip = "Restoration Spec" },
        { id = 16188, name = "Nature's Swiftness", tooltip = "Blocks Nature's Swiftness" },
        { id = 49273, name = "Healing Wave", tooltip = "Blocks Healing Wave" },
        { id = 49276, name = "Lesser Healing Wave", tooltip = "Blocks Lesser Healing Wave" },
        { id = 49277, name = "Greater Healing Wave", tooltip = "Blocks Greater Healing Wave" },
        { id = 55459, name = "Chain Heal", tooltip = "Blocks Chain Heal" },
        { id = 61301, name = "Riptide", tooltip = "Blocks Riptide" },
        { id = 974,   name = "Earth Shield", tooltip = "Blocks Earth Shield" },
        { id = 58757, name = "Healing Stream Totem", tooltip = "Blocks Healing Stream Totem" },
        { id = 58656, name = "Healing Rain", tooltip = "Blocks Healing Rain" },
        { id = 546,   name = "Water Walking", tooltip = "Blocks Water Walking" },

        -- === TOTEMS & UTILITY ===
        { id = 0, name = "TOTEMS_SEPARATOR", tooltip = "Totems & Utility" },
        { id = 16191, name = "Mana Tide Totem", tooltip = "Blocks Mana Tide Totem" },
        { id = 8143,  name = "Tremor Totem", tooltip = "Blocks Tremor Totem" },
        { id = 8177,  name = "Grounding Totem", tooltip = "Blocks Grounding Totem" },
        { id = 2062,  name = "Earth Elemental Totem", tooltip = "Blocks Earth Elemental Totem" },
        { id = 2894,  name = "Fire Elemental Totem", tooltip = "Blocks Fire Elemental Totem" },
        { id = 8071,  name = "Stoneskin Totem", tooltip = "Blocks Stoneskin Totem" },
        { id = 8075,  name = "Strength of Earth Totem", tooltip = "Blocks Strength of Earth Totem" },
        { id = 526,   name = "Cure Poison", tooltip = "Blocks Cure Poison" },
        { id = 51886, name = "Cleanse Spirit", tooltip = "Blocks Cleanse Spirit" },
        { id = 51514, name = "Hex", tooltip = "Blocks Hex" },
        { id = 2484,  name = "Earthbind Totem", tooltip = "Blocks Earthbind Totem" },
        { id = 2825,  name = "Bloodlust", tooltip = "Blocks Bloodlust" },
        { id = 32182, name = "Heroism", tooltip = "Blocks Heroism" },
    },
    -- Für Druide
DRUID = {
    -- === BALANCE SPEC ===
    { id = 0, name = "BALANCE_SEPARATOR", tooltip = "Balance Spec" },
    { id = 48463, name = "Moonfire", tooltip = "Blocks Moonfire" },
    { id = 48465, name = "Starfire", tooltip = "Blocks Starfire" },
    { id = 48461, name = "Wrath", tooltip = "Blocks Wrath" },
    { id = 48468, name = "Insect Swarm", tooltip = "Blocks Insect Swarm" },
    { id = 53201, name = "Starfall", tooltip = "Blocks Starfall" },
    { id = 50516, name = "Typhoon", tooltip = "Blocks Typhoon" },
    { id = 16914, name = "Hurricane", tooltip = "Blocks Hurricane" },

    -- === FERAL SPEC ===
    { id = 0, name = "FERAL_SEPARATOR", tooltip = "Feral Spec" },
    { id = 50334, name = "Berserk", tooltip = "Blocks Berserk" },
    { id = 61336, name = "Survival Instincts", tooltip = "Blocks Survival Instincts" },
    { id = 22812, name = "Barkskin", tooltip = "Blocks Barkskin" },
    { id = 33357, name = "Dash", tooltip = "Blocks Dash" },
    { id = 5211,  name = "Bash", tooltip = "Blocks Bash" },
    { id = 22570, name = "Maim", tooltip = "Blocks Maim" },
    { id = 48564, name = "Mangle (Cat)", tooltip = "Blocks Mangle (Cat)" },
    { id = 48566, name = "Mangle (Bear)", tooltip = "Blocks Mangle (Bear)" },
    { id = 48572, name = "Shred", tooltip = "Blocks Shred" },
    { id = 49800, name = "Rip", tooltip = "Blocks Rip" },
    { id = 48574, name = "Rake", tooltip = "Blocks Rake" },
    { id = 48577, name = "Ferocious Bite", tooltip = "Blocks Ferocious Bite" },
    { id = 48579, name = "Lacerate", tooltip = "Blocks Lacerate" },
    { id = 6807,  name = "Maul", tooltip = "Blocks Maul" },
    { id = 768,   name = "Cat Form", tooltip = "Blocks Cat Form" },
    { id = 5487,  name = "Bear Form", tooltip = "Blocks Bear Form" },
    { id = 9634,  name = "Dire Bear Form", tooltip = "Blocks Dire Bear Form" },

    -- === RESTORATION SPEC ===
    { id = 0, name = "RESTORATION_SEPARATOR", tooltip = "Restoration Spec" },
    { id = 17116, name = "Nature's Swiftness", tooltip = "Blocks Nature's Swiftness" },
    { id = 18562, name = "Swiftmend", tooltip = "Blocks Swiftmend" },
    { id = 29166, name = "Innervate", tooltip = "Blocks Innervate" },
    { id = 9863,  name = "Tranquility", tooltip = "Blocks Tranquility" },
    { id = 48438, name = "Wild Growth", tooltip = "Blocks Wild Growth" },
    { id = 48441, name = "Rejuvenation", tooltip = "Blocks Rejuvenation" },
    { id = 48443, name = "Regrowth", tooltip = "Blocks Regrowth" },
    { id = 48378, name = "Healing Touch", tooltip = "Blocks Healing Touch" },
    { id = 50464, name = "Nourish", tooltip = "Blocks Nourish" },
    { id = 48451, name = "Lifebloom", tooltip = "Blocks Lifebloom" },
    { id = 16870, name = "Clearcasting", tooltip = "Blocks Clearcasting" },

    -- === UTILITY & FORMS ===
    { id = 0, name = "UTILITY_SEPARATOR", tooltip = "Utility & Forms" },
    { id = 53307, name = "Thorns", tooltip = "Blocks Thorns" },
    { id = 2893,  name = "Abolish Poison", tooltip = "Blocks Abolish Poison" },
    { id = 8946,  name = "Cure Poison", tooltip = "Blocks Cure Poison" },
    { id = 2782,  name = "Remove Curse", tooltip = "Blocks Remove Curse" },
    { id = 1126,  name = "Mark of the Wild", tooltip = "Blocks Mark of the Wild" },
    { id = 21849, name = "Gift of the Wild", tooltip = "Blocks Gift of the Wild" },
    { id = 783,   name = "Travel Form", tooltip = "Blocks Travel Form" },
    { id = 40120, name = "Swift Flight Form", tooltip = "Blocks Swift Flight Form" },
    { id = 1066,  name = "Aquatic Form", tooltip = "Blocks Aquatic Form" },
    { id = 24858, name = "Moonkin Form", tooltip = "Blocks Moonkin Form" },
},
}

-- SavedVariables initialisieren
local function InitDB()
    -- Prüfe, ob SpellBlockerDB existiert - wenn nicht, erstelle es
    if not SpellBlockerDB then 
        SpellBlockerDB = {} 
    end
    
    -- Previous State für Vergleich initialisieren
    if not SpellBlockerPreviousState then
        SpellBlockerPreviousState = {}
    end
    
    -- Für jede Klasse die DB initialisieren
    for className, spells in pairs(SPELLS) do
        if not SpellBlockerDB[className] then 
            SpellBlockerDB[className] = {} 
        end
        if not SpellBlockerPreviousState[className] then
            SpellBlockerPreviousState[className] = {}
        end        for _, spell in ipairs(spells) do
            if spell.id and spell.id > 0 then  -- Ignoriere Separatoren (ID = 0)
                if SpellBlockerDB[className][spell.id] == nil then
                    -- Standardeinstellung: Zauber NICHT blockieren
                    SpellBlockerDB[className][spell.id] = false
                end            -- PreviousState mit aktuellem State initialisieren
                SpellBlockerPreviousState[className][spell.id] = SpellBlockerDB[className][spell.id]
            end
        end
    end
end

-- Hilfsfunktionen (müssen vor ihrer ersten Verwendung definiert werden)
local function GetBlockedSpellsForClass(class)
    local blockedSpells = {}
    local already = {}

    -- SpellBlockerDB
    if SpellBlockerDB[class] then
        for _, spell in ipairs(SPELLS[class]) do
            if spell.id and spell.id > 0 and SpellBlockerDB[class][spell.id] then
                table.insert(blockedSpells, spell.id)
                already[spell.id] = true
            end
        end
    end
    -- SpecialBlockedSpells
    if MythicHelper_SpecialBlockedSpells and MythicHelper_SpecialBlockedSpells[class] then
        for spellId in pairs(MythicHelper_SpecialBlockedSpells[class]) do
            if not already[spellId] then
                table.insert(blockedSpells, spellId)
            end
        end
    end
    return blockedSpells
end

-- Funktion zum Erstellen des SS-Befehls für eine Klasse korrigieren
local function CreateSpellBlockCommand(class)
    local blockedSpells = GetBlockedSpellsForClass(class)
    if #blockedSpells == 0 then
        return nil -- Keine blockierten Spells
    end
    
    -- Beachte das Leerzeichen nach dem ss
    local command = "ss +"  -- Kein Doppelpunkt, mit Leerzeichen
    for i, spellId in ipairs(blockedSpells) do
        command = command .. spellId
        if i < #blockedSpells then
            command = command .. ","
        end
    end
    
    -- Standardmäßig ein Array zurückgeben
    return {command}
end

-- Aktualisiere auch die SendBlockCommandsToGroup Funktion (global verfügbar):
function SendBlockCommandsToGroup()
    -- Prüfe, ob wir in einer Gruppe oder Raid sind
    local numMembers = GetNumRaidMembers()
    local isRaid = (numMembers > 0)
    local inGroup = true
    
    if not isRaid then
        numMembers = GetNumPartyMembers()
        if numMembers == 0 then
            inGroup = false
            -- Auch wenn wir allein sind, aktualisieren wir trotzdem die Zauber für den Spieler
            print("|cFFFF0000SpellBlocker:|r You are not in a group/raid. Commands will only affect you.")
        end
    end
    
    -- Sammele Spieler nach Klasse
    local playersByClass = {}
    
    if inGroup then
        -- Verarbeite alle Gruppenmitglieder
        for i = 1, numMembers do
            local unit = isRaid and "raid"..i or "party"..i
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            
            if name and class then
                if not playersByClass[class] then
                    playersByClass[class] = {}
                end
                table.insert(playersByClass[class], name)
            end
        end
    end
    
    -- IMMER den eigenen Spieler hinzufügen, unabhängig vom Gruppenstatus
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    
    if not playersByClass[playerClass] then
        playersByClass[playerClass] = {}
    end
    table.insert(playersByClass[playerClass], playerName)
    
    -- Sende Befehle an alle Spieler
    local totalMessages = 0
    
    -- Erstelle Kommandos für alle Klassen, für die wir Änderungen haben
    local allClassCommands = {}
    for className, spells in pairs(SPELLS) do
        allClassCommands[className] = CreateSpellBlockCommand(className)
    end
    
    -- Sende nur Kommandos an Klassen, die wir gefunden haben
    for class, players in pairs(playersByClass) do
        local commands = allClassCommands[class]
        if commands and #commands > 0 then
            for _, playerName in ipairs(players) do
                for _, command in ipairs(commands) do
                    SendChatMessage(command, "WHISPER", nil, playerName)
                    totalMessages = totalMessages + 1
                end
            end
        end
    end
    
    print("|cFF00FF00SpellBlocker:|r " .. totalMessages .. " spell commands sent.")
end

-- Funktion zum Zurücksetzen aller Blocklisten für alle Klassen
function ResetAllBlockLists()
    -- Sammele Spieler nach Klasse
    local playersByClass = {}
    local numMembers = GetNumRaidMembers()
    local isRaid = (numMembers > 0)

    if not isRaid then
        numMembers = GetNumPartyMembers()
    end

    -- Verarbeite alle Gruppenmitglieder
    if numMembers > 0 then
        for i = 1, numMembers do
            local unit = isRaid and "raid"..i or "party"..i
            local name = UnitName(unit)
            local _, class = UnitClass(unit)
            if name and class then
                if not playersByClass[class] then
                    playersByClass[class] = {}
                end
                table.insert(playersByClass[class], name)
            end
        end
    end

    -- Eigenen Spieler immer hinzufügen
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    if not playersByClass[playerClass] then
        playersByClass[playerClass] = {}
    end
    table.insert(playersByClass[playerClass], playerName)

    -- Für jede Klasse einen Reset-Befehl mit einer beispielhaften SpellID senden
    local totalMessages = 0
    for class, players in pairs(playersByClass) do
        -- Finde die erste gültige SpellID für diese Klasse
        local resetSpellId = nil
        for _, spell in ipairs(SPELLS[class]) do
            if spell.id > 0 then
                resetSpellId = spell.id
                break
            end
        end

        if resetSpellId then
            local resetCommand = "ss -" .. resetSpellId
            for _, playerName in ipairs(players) do
                SendChatMessage(resetCommand, "WHISPER", nil, playerName)
                totalMessages = totalMessages + 1
            end
        end
    end

    -- Status in der DB zurücksetzen (SpellBlockerDB und ggf. SpecialBlockedSpells)
    for className, spells in pairs(SPELLS) do
        if not SpellBlockerDB[className] then
            SpellBlockerDB[className] = {}
        end
        for _, spell in ipairs(spells) do
            if spell.id > 0 then
                SpellBlockerDB[className][spell.id] = false
            end
        end
    end
    -- Auch alle Special-Blocks entfernen, falls vorhanden
    if MythicHelper_SpecialBlockedSpells then
        for k in pairs(MythicHelper_SpecialBlockedSpells) do
            MythicHelper_SpecialBlockedSpells[k] = nil
        end
    end

    -- UI aktualisieren
    RefreshClassSpellDisplay()

    print("|cFF00FF00SpellBlocker:|r " .. totalMessages .. " reset commands sent. All spell blocks removed.")
end

-- Optionsfenster
local optionsFrame = CreateFrame("Frame", "SpellBlockerOptions", UIParent)
optionsFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
optionsFrame:SetBackdropColor(0,0,0,1)
optionsFrame:SetSize(620, 550)  -- Deutlich größer für bessere Übersicht
optionsFrame:SetPoint("CENTER")
optionsFrame:SetMovable(true)
optionsFrame:EnableMouse(true)
optionsFrame:RegisterForDrag("LeftButton")
optionsFrame:SetScript("OnDragStart", optionsFrame.StartMoving)
optionsFrame:SetScript("OnDragStop", optionsFrame.StopMovingOrSizing)
optionsFrame:Hide()
optionsFrame.title = optionsFrame:CreateFontString(nil, "OVERLAY")
optionsFrame.title:SetFontObject("GameFontHighlight")
optionsFrame.title:SetPoint("TOP", optionsFrame, "TOP", 0, -10)
optionsFrame.title:SetText("SpellBlocker Options")


-- Schließen-Button (X) mit eindeutigem Namen und höherem Frame Level
local closeBtn = CreateFrame("Button", "SpellBlockerCloseButton", optionsFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -5, -5)
closeBtn:SetFrameLevel(optionsFrame:GetFrameLevel() + 10) -- Höheres Frame Level
closeBtn:SetScript("OnClick", function()
    optionsFrame:Hide()
end)

-- OK-Button unten rechts
local okBtn = CreateFrame("Button", "SpellBlockerOkButton", optionsFrame, "UIPanelButtonTemplate")
okBtn:SetSize(80, 22)
okBtn:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -20, 20)
okBtn:SetFrameLevel(optionsFrame:GetFrameLevel() + 10) -- Höheres Frame Level
okBtn:SetText("OK")
okBtn:SetScript("OnClick", function()
    optionsFrame:Hide()
end)

-- Klassen-Tabs im Optionsfenster hinzufügen
local playerClass = select(2, UnitClass("player"))
local currentClass = playerClass  -- Nutze die Spielerklasse als Standard
local tabs = {}
local tabsById = {} -- Neue globale Variable für Tabs nach ID
local currentPlayer = nil -- Wird den Spielernamen speichern
local tabHeight = 24
-- Get group members function
local function GetGroupMembers()
    local members = {}
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    
    -- Always add yourself first
    table.insert(members, {
        name = playerName,
        class = playerClass,
        unit = "player"
    })
    
    -- Check if in raid
    local numRaidMembers = GetNumRaidMembers()
    if numRaidMembers > 0 then
        for i = 1, numRaidMembers do
            local name = UnitName("raid"..i)
            if name and name ~= playerName then -- Avoid duplicating player
                local _, class = UnitClass("raid"..i)
                table.insert(members, {
                    name = name,
                    class = class,
                    unit = "raid"..i
                })
            end
        end
    else
        -- Check if in party
        local numPartyMembers = GetNumPartyMembers()
        if numPartyMembers > 0 then
            for i = 1, numPartyMembers do
                local name = UnitName("party"..i)
                if name then
                    local _, class = UnitClass("party"..i)
                    table.insert(members, {
                        name = name,
                        class = class,
                        unit = "party"..i
                    })
                end
            end
        end
    end
    
    return members
end
-- Alle Tabs erstellen und am oberen Rand des Fensters platzieren
local function CreatePlayerTabs()
    -- Clear existing tabs
    for _, tab in ipairs(tabs) do
        tab:Hide()
        tab:SetParent(nil)
    end
    tabs = {}
    tabsById = {}
    
    local tabWidth = 40
    local tabHeight = 40
    local x = 20
    
    -- Get current group members
    local members = GetGroupMembers()
    
    -- Create a tab for each group member
    for i, member in ipairs(members) do
        local classData = member.class
        local playerName = member.name
        
        local tab = CreateFrame("Button", "SpellBlockerTab_"..playerName, optionsFrame)
        tab:SetSize(tabWidth, tabHeight)
        tab:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", x, -35)
        tab.class = classData
        tab.playerName = playerName
        
        -- Class icon coordinates
        local classCoords = {
            WARRIOR     = {0, 0.25, 0, 0.25},
            PALADIN     = {0, 0.25, 0.5, 0.75},
            DEATHKNIGHT = {0.25, 0.5, 0.5, 0.75},
            PRIEST      = {0.5, 0.75, 0.25, 0.5},
            MAGE        = {0.25, 0.5, 0, 0.25},
            WARLOCK     = {0.75, 1, 0.25, 0.5},
            ROGUE       = {0.5, 0.75, 0, 0.25},
            HUNTER      = {0, 0.25, 0.25, 0.5},
            SHAMAN      = {0.25, 0.5, 0.25, 0.5},
            DRUID       = {0.75, 1, 0, 0.25}
        }
        
        -- Class icon as tab
        local texture = tab:CreateTexture(nil, "ARTWORK")
        texture:SetTexture("Interface\\TargetingFrame\\UI-CLASSES-CIRCLES")
        if classCoords[classData] then
            texture:SetTexCoord(unpack(classCoords[classData]))
        else
            -- Default texture coordinates if class not found
            texture:SetTexCoord(0, 1, 0, 1)
        end
        texture:SetAllPoints(tab)
        tab.texture = texture
        
        -- Highlight for mouseover
        tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
        
        -- Selection border
        local border = tab:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        border:SetBlendMode("ADD")
        border:SetAllPoints(tab)
        border:Hide()
        tab.border = border
        
        -- Click handler
        tab:SetScript("OnClick", function(self)
            currentPlayer = self.playerName
            currentClass = self.class
            SpellBlockerLastActiveTab = currentClass  -- Keep tracking class for compatibility
            
            for _, t in ipairs(tabs) do
                t.border:Hide()
            end
            self.border:Show()
            RefreshClassSpellDisplay()
        end)
        
        -- Show player name on hover
        tab:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.playerName, 1, 1, 1)
            GameTooltip:AddLine(self.class, 0.7, 0.7, 1)
            GameTooltip:Show()
        end)
        
        tab:SetScript("OnLeave", function() 
            GameTooltip:Hide() 
        end)
        
        -- Auto-select first tab
        if i == 1 then
            tab.border:Show()
            currentPlayer = playerName
            currentClass = classData
        end
        
        table.insert(tabs, tab)
        tabsById[playerName] = tab
        
        x = x + tabWidth + 5
    end
end

-- Function to check if all spells of a class are blocked
local function AreAllSpellsBlocked(class)
    -- Safety check
    if not SPELLS[class] or not SpellBlockerDB or not SpellBlockerDB[class] then
        return false
    end
      for _, spell in ipairs(SPELLS[class]) do
        if spell and spell.id and spell.id > 0 and not SpellBlockerDB[class][spell.id] then  -- Ignoriere Separatoren
            return false
        end
    end
    return true
end

-- Toggle-Button für die aktuelle Klasse aktualisieren (global verfügbar)
function UpdateToggleButton()
    local toggleBtn = _G["SpellBlockerToggleAll_"..currentClass]
    if toggleBtn then
        if AreAllSpellsBlocked(currentClass) then            toggleBtn:SetText("Unblock All " .. currentClass .. " Spells")
        else
            toggleBtn:SetText("Block All " .. currentClass .. " Spells")
        end
    end
end

-- Funktion zum Erstellen der Spell-Icons für jede Klasse
local function CreateSpellIcons(class)
    -- Zuerst alle vorhandenen Icons entfernen
    local existingIcons = {optionsFrame:GetChildren()}
    for _, child in ipairs(existingIcons) do
        if child.isSpellIcon and child:GetName() ~= "SpellBlockerHealOnlyBtn" and child:GetName() ~= "SpellBlockerToggleAll_"..class then
            child:Hide()
            child:SetParent(nil)
        end
    end    -- Dann neue Icons für die aktuelle Klasse erstellen
    local y = -80  -- Reduzierte Startposition unter den Tabs (war -120)
    local iconSize = 32  -- Kleinere Icons für bessere Übersicht
    local iconPadding = 10
    local iconsPerRow = 12
    
    -- Fortlaufende Icon-Position
    local currentRow = 0
    local currentCol = 0
    local regularIconCount = 0
      -- Make sure SPELLS[class] exists before iterating
    if not SPELLS[class] then return end
    
    for i, spell in ipairs(SPELLS[class]) do
        -- Skip if spell is nil
        if spell then            -- If it's a separator (check for all separator types)
            if spell.id == 0 and spell.name and string.find(spell.name, "_SEPARATOR") then
            -- Neue Zeile beginnen und moderaten Abstand einbauen
            currentCol = 0
            currentRow = currentRow + 0.8  -- Reduziert von 1.5 auf 0.8 für weniger Platz vor dem Separator
            
            -- Erstelle den Separator-Frame
            local separatorFrame = CreateFrame("Frame", nil, optionsFrame)
            separatorFrame.isSpellIcon = true
            separatorFrame:SetSize(iconSize*iconsPerRow + (iconsPerRow-1)*iconPadding, 20)
            separatorFrame:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 20, y - currentRow*(iconSize+iconPadding))
            
            -- Füge eine Linie hinzu
            local line = separatorFrame:CreateTexture(nil, "BACKGROUND")
            line:SetTexture(0.5, 0.5, 0.5, 0.5)
            line:SetSize(iconSize*iconsPerRow + (iconsPerRow-1)*iconPadding, 1)
            line:SetPoint("CENTER", separatorFrame, "CENTER")
              -- Beschriftung des Separators
            local text = separatorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("CENTER", separatorFrame, "CENTER")            -- Dynamische Beschriftung basierend auf dem Separator-Namen
            local separatorTexts = {
                HOLY_SEPARATOR = "Holy",
                DISCIPLINE_SEPARATOR = "Discipline", 
                SHADOW_SEPARATOR = "Shadow",
                ARCANE_SEPARATOR = "Arcane",
                FIRE_SEPARATOR = "Fire",
                FROST_SEPARATOR = "Frost",
                UTILITY_SEPARATOR = "Utility",
                PROTECTION_SEPARATOR = "Protection",
                RETRIBUTION_SEPARATOR = "Retribution",
                JUDGMENT_SEPARATOR = "Judgments & Seals",
                BLESSING_SEPARATOR = "Blessings",
                AURA_SEPARATOR = "Auras",
                BLOOD_SEPARATOR = "Blood",
                UNHOLY_SEPARATOR = "Unholy",
                ARMS_SEPARATOR = "Arms",
                FURY_SEPARATOR = "Fury",
                ELEMENTAL_SEPARATOR = "Elemental",
                ENHANCEMENT_SEPARATOR = "Enhancement",                
                RESTORATION_SEPARATOR = "Restoration",
                TOTEMS_SEPARATOR = "Totems & Utility",
                BALANCE_SEPARATOR = "Balance",
                FERAL_SEPARATOR = "Feral",
                BEAST_MASTERY_SEPARATOR = "Beast Mastery",
                MARKSMANSHIP_SEPARATOR = "Marksmanship",
                SURVIVAL_SEPARATOR = "Survival",
                ASPECTS_SEPARATOR = "Aspects",
                AFFLICTION_SEPARATOR = "Affliction",
                DEMONOLOGY_SEPARATOR = "Demonology",
                DESTRUCTION_SEPARATOR = "Destruction",
                CURSES_SEPARATOR = "Curses & Debuffs",
                ASSASSINATION_SEPARATOR = "Assassination",
                COMBAT_SEPARATOR = "Combat",
                SUBTLETY_SEPARATOR = "Subtlety",
                CONTROL_SEPARATOR = "Control & Utility",
                POISONS_SEPARATOR = "Poisons",
                HAND_OF_SEPARATOR = "Hand of Spells"
            }
            
            text:SetText(separatorTexts[spell.name] or "Unknown")
            
            -- Nach dem Separator weniger Platz lassen
            currentRow = currentRow + 0.5  -- Reduziert von 1.0 auf 0.5 für weniger Platz nach dem Separator
        else
            -- Reguläres Spell-Icon
            local btn = CreateFrame("Button", nil, optionsFrame)
            btn:SetSize(iconSize, iconSize)
            btn:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 
                20 + currentCol*(iconSize+iconPadding), 
                y - currentRow*(iconSize+iconPadding))
            btn.isSpellIcon = true
            
            -- Schöner Rahmen für die Icons
            btn:SetBackdrop({
                edgeFile = "Interface\\Buttons\\UI-ActionButton-Border",
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0)  -- Invisible by default            
            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints()
            local spellTexture
            if spell and spell.id then
                spellTexture = select(3, GetSpellInfo(spell.id))
            end
            if spellTexture then
                icon:SetTexture(spellTexture)
            else
                -- Use a default question mark texture when spell info is missing
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end            btn.icon = icon
            if spell and spell.id then
                btn.spellId = spell.id
            else
                btn.spellId = 0  -- Fallback to a safe default
            end
              local function UpdateIcon()
                local isBlocked = SpellBlockerDB and SpellBlockerDB[class] and SpellBlockerDB[class][spell.id]
                local isSpecialBlocked = MythicHelper_SpecialBlockedSpells and MythicHelper_SpecialBlockedSpells[class] and MythicHelper_SpecialBlockedSpells[class][spell.id]
                    if isBlocked or isSpecialBlocked then
                        icon:SetDesaturated(true)
                        btn:SetAlpha(0.5)
                    else
                        icon:SetDesaturated(false)
                        btn:SetAlpha(1)
                    end
            end
            UpdateIcon()
              btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if not self.spellId then
                    GameTooltip:SetText("Unknown Spell", 1, 1, 1)
                    return
                end
                local spellLink = GetSpellLink(self.spellId)
                if spellLink then
                    GameTooltip:SetHyperlink(spellLink)
                else
                    local name = select(1, GetSpellInfo(self.spellId))
                    GameTooltip:SetText(name or "Unknown Spell", 1, 1, 1)
                end
                -- Spezial-Block-Hinweis ergänzen
                 local isSpecialBlocked = MythicHelper_SpecialBlockedSpells and MythicHelper_SpecialBlockedSpells[class] and MythicHelper_SpecialBlockedSpells[class][spell.id]
                    if isSpecialBlocked then
                        GameTooltip:AddLine("Blocked by Special-Button", 1, 0.2, 0.2)
                    end

                    GameTooltip:Show()
            end)            
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            btn:SetScript("OnClick", function(self)
    if not SpellBlockerDB[class] then SpellBlockerDB[class] = {} end
    local newState = not SpellBlockerDB[class][spell.id]
    SpellBlockerDB[class][spell.id] = newState
    -- Synchronisiere mit SpecialBlockedSpells
    MythicHelper_SpecialBlockedSpells[class] = MythicHelper_SpecialBlockedSpells[class] or {}
    if newState then
        MythicHelper_SpecialBlockedSpells[class][spell.id] = true
    else
        MythicHelper_SpecialBlockedSpells[class][spell.id] = nil
    end
    -- HIER speichern:
    MythicHelper_SpecialBlockedSpellsDB = MythicHelper_SpecialBlockedSpells
    UpdateIcon()
    UpdateToggleButton()
end)
              -- Position für nächstes Icon
            currentCol = currentCol + 1
            if currentCol >= iconsPerRow then
                currentCol = 0
                currentRow = currentRow + 1
            end
              regularIconCount = regularIconCount + 1
            end -- End of if spell.id == 0... else block
        end -- End of if spell then block
    end -- End of for i, spell loop
    
    -- Toggle-Button für alle Spells dieser Klasse
    local toggleBtn = CreateFrame("Button", "SpellBlockerToggleAll_"..class, optionsFrame)
    toggleBtn:SetSize(48, 48)
    -- Neue Position: Direkt über dem OK-Button
    toggleBtn:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -20, 80)  -- 60 Pixel über dem OK-Button
    toggleBtn.isSpellIcon = true -- Markieren für späteres Erkennen

    -- Icon je nach Klasse setzen
    local classCoords = {
        WARRIOR     = {0, 0.25, 0, 0.25},
        PALADIN     = {0, 0.25, 0.5, 0.75},  -- Korrigiert
        DEATHKNIGHT = {0.25, 0.5, 0.5, 0.75},  -- Korrigiert für DK 
        PRIEST      = {0.5, 0.75, 0.25, 0.5},
        MAGE        = {0.25, 0.5, 0, 0.25},
        WARLOCK     = {0.75, 1, 0.25, 0.5},
        ROGUE       = {0.5, 0.75, 0, 0.25},
        HUNTER      = {0, 0.25, 0.25, 0.5},  -- Korrigiert
        SHAMAN      = {0.25, 0.5, 0.25, 0.5},  -- Korrigiert für Shaman
        DRUID       = {0.75, 1, 0, 0.25}
    }
    
    -- Klassenicon im Hintergrund
    local bgTexture = toggleBtn:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetTexture("Interface\\TargetingFrame\\UI-CLASSES-CIRCLES")
    bgTexture:SetTexCoord(unpack(classCoords[class]))
    bgTexture:SetAllPoints()

    -- Highlight für Mouseover
    toggleBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

    -- Text-Label für klarere Funktion - jetzt horizontal zentriert
    local label = toggleBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("BOTTOM", toggleBtn, "BOTTOM", 0, -15)
    label:SetText("Toggle All")  -- Geändert zu "Toggle All" (kürzer)
    
    toggleBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if AreAllSpellsBlocked(class) then
            GameTooltip:SetText("Unblock All " .. class .. " Spells")
        else
            GameTooltip:SetText("Block All " .. class .. " Spells")
        end
        GameTooltip:Show()
    end)
    toggleBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Klick-Handler bleibt gleich
    toggleBtn:SetScript("OnClick", function()
    local shouldBlock = not AreAllSpellsBlocked(class)
    for _, spell in ipairs(SPELLS[class]) do
        if not SpellBlockerDB[class] then SpellBlockerDB[class] = {} end
        if spell and spell.id and spell.id > 0 then
            SpellBlockerDB[class][spell.id] = shouldBlock
            MythicHelper_SpecialBlockedSpells[class] = MythicHelper_SpecialBlockedSpells[class] or {}
            if shouldBlock then
                MythicHelper_SpecialBlockedSpells[class][spell.id] = true
            else
                MythicHelper_SpecialBlockedSpells[class][spell.id] = nil
            end
        end
    end
    -- HIER speichern:
    MythicHelper_SpecialBlockedSpellsDB = MythicHelper_SpecialBlockedSpells
    CreateSpellIcons(class)
    UpdateToggleButton()
end)
end -- End of the CreateSpellIcons function

-- Funktion zum Aktivieren des Heal-Only-Modus für Heilerklassen
local function IsHealerClass(class)
    return class == "PRIEST" or class == "PALADIN" or class == "SHAMAN" or class == "DRUID"
end

-- Variable für den Heal-Only-Mode Status
local healOnlyModeActive = false

-- Funktion um das Aussehen des Heal-Only-Buttons zu aktualisieren
local function UpdateHealOnlyButtonAppearance()
    local healOnlyBtn = _G["SpellBlockerHealOnlyBtn"]
    if healOnlyBtn then
        if healOnlyModeActive then
            -- Aktiv: grünlicher Glow
            healOnlyBtn:SetNormalTexture("Interface\\Icons\\spell_holy_heal")
        else
            -- Inaktiv: normales Icon
            healOnlyBtn:SetNormalTexture("Interface\\Icons\\spell_holy_holybolt")
        end
    end
end

local function ToggleHealOnlyMode()
    if not IsHealerClass(currentClass) then
        print("|cFFFF0000SpellBlocker:|r Heal Only Mode is only available for healer classes.")
        return
    end
    
    if healOnlyModeActive then
        -- Heal Only Mode deaktivieren - alle Spells wieder freigeben
        local count = 0
        for _, spell in ipairs(SPELLS[currentClass]) do
            if spell.id and spell.id > 0 then
                if not SpellBlockerDB[currentClass] then SpellBlockerDB[currentClass] = {} end
                SpellBlockerDB[currentClass][spell.id] = false
                count = count + 1
            end
        end
        
        healOnlyModeActive = false
        RefreshClassSpellDisplay()
        print("|cFF00FF00SpellBlocker:|r Heal Only Mode deactivated for " .. currentClass .. ". All " .. count .. " spells unblocked.")
    else
        -- Heal Only Mode aktivieren
        local count = 0
        
        -- Definiere welche Specs für jede Heilerklasse als "Heilung" gelten
        local healingSpecs = {
            PRIEST = {"HOLY_SEPARATOR", "DISCIPLINE_SEPARATOR"},
            PALADIN = {"HOLY_SEPARATOR"},
            SHAMAN = {"RESTORATION_SEPARATOR", "TOTEMS_SEPARATOR"}, -- Totems hinzugefügt
            DRUID = {"RESTORATION_SEPARATOR"}
        }
        
        local currentSpec = nil
        local isHealingSpec = false
        
        -- Nur für die aktuelle Klasse anwenden
        for _, spell in ipairs(SPELLS[currentClass]) do
            -- Prüfe ob es ein Separator ist
            if spell.id == 0 and spell.name and string.find(spell.name, "_SEPARATOR") then
                currentSpec = spell.name
                -- Prüfe ob die aktuelle Spec eine Heilungsspec ist
                isHealingSpec = false
                if healingSpecs[currentClass] then
                    for _, healSpec in ipairs(healingSpecs[currentClass]) do
                        if currentSpec == healSpec then
                            isHealingSpec = true
                            break
                        end
                    end
                end
            else
                -- Regulärer Zauber
                if spell.id and spell.id > 0 then
                    if not SpellBlockerDB[currentClass] then SpellBlockerDB[currentClass] = {} end
                    
                    -- Heilungsspecs (inkl. Totems für Shaman) nicht blocken, alle anderen blocken
                    if isHealingSpec then
                        SpellBlockerDB[currentClass][spell.id] = false
                    else
                        SpellBlockerDB[currentClass][spell.id] = true
                        count = count + 1
                    end
                end
            end
        end
          healOnlyModeActive = true
        RefreshClassSpellDisplay()
        print("|cFF00FF00SpellBlocker:|r Heal Only Mode activated for " .. currentClass .. ". " .. count .. " damage spells blocked.")
    end
    
    -- Button visuell aktualisieren
    UpdateHealOnlyButtonAppearance()
end


-- Erstelle den "Heal Only" Button
local healOnlyBtn = CreateFrame("Button", "SpellBlockerHealOnlyBtn", optionsFrame) -- Wichtig: an optionsFrame anhängen!
healOnlyBtn:SetSize(48, 48)
healOnlyBtn:SetFrameStrata("MEDIUM")
healOnlyBtn:EnableMouse(true)
healOnlyBtn:SetNormalTexture("Interface\\Icons\\spell_holy_holybolt") -- Heilungs-Icon
healOnlyBtn.isSpellIcon = true -- Wichtig damit er nicht gelöscht wird

-- Positioniere den Heal Only-Button über dem Toggle All-Button
healOnlyBtn:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -20, 140) -- 60 Pixel über dem Toggle All Button

-- Schriftart für das Label
local healLabel = healOnlyBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
healLabel:SetPoint("BOTTOM", healOnlyBtn, "BOTTOM", 0, -15)
healLabel:SetText("Heal Only")

-- Tooltip
healOnlyBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if healOnlyModeActive then
        GameTooltip:SetText("Heal Only Mode (Active)", 1, 1, 1)
        GameTooltip:AddLine("Click to deactivate and unblock all spells", 1, 0.7, 0)
    else
        GameTooltip:SetText("Heal Only Mode", 1, 1, 1)
        GameTooltip:AddLine("Blocks damage spells for " .. currentClass, 0, 1, 0)
        GameTooltip:AddLine("Healing spells remain unblocked", 0.7, 0.7, 1)
    end
    GameTooltip:Show()
end)
healOnlyBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Klick-Funktion
healOnlyBtn:SetScript("OnClick", function()
    ToggleHealOnlyMode()
    -- SendBlockCommandsToGroup() removed - now only main button sends to group
end)

-- Function to update tabs when group changes
local function UpdatePlayerTabs()
    -- Save currently selected player if any
    local selectedPlayer = currentPlayer
    
    CreatePlayerTabs()
    
    -- Try to restore selection
    if selectedPlayer and tabsById[selectedPlayer] then
        tabsById[selectedPlayer]:Click()
    else
        -- Default to first tab if previous selection not found
        if #tabs > 0 then
            tabs[1]:Click()
        end
    end
    
    RefreshClassSpellDisplay()
end

-- Add group update event handling
local function RegisterGroupEvents()
    local groupFrame = CreateFrame("Frame")
    groupFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    groupFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    groupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    groupFrame:SetScript("OnEvent", function(self, event, ...)
        UpdatePlayerTabs()
    end)
end

-- Funktion zum Aktualisieren der Anzeige für die aktuelle Klasse
function RefreshClassSpellDisplay()
    -- Erstelle die Spell-Icons für die aktuelle Klasse
    CreateSpellIcons(currentClass)
    
    -- Aktualisiere den Toggle-Button Text
    UpdateToggleButton()
    
    -- Heal-Only Button nur für Heilerklassen anzeigen
    if IsHealerClass(currentClass) then
        healOnlyBtn:Show()
        -- Button-Aussehen aktualisieren
        UpdateHealOnlyButtonAppearance()
    else
        healOnlyBtn:Hide()
        -- Heal-Only-Mode zurücksetzen wenn zu nicht-Heiler-Klasse gewechselt wird
        healOnlyModeActive = false
    end
end

-- Füge einen OnShow-Handler für das optionsFrame hinzu direkt nach der Definition des okBtn:

optionsFrame:SetScript("OnShow", function()
    UpdatePlayerTabs()
end)

-- Füge am Ende des Files diesen Event-Handler hinzu:
-- Addon-Initialisierung 
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)    if event == "ADDON_LOADED" and arg1 == "spellblocker" then
        -- DB initialisieren
        InitDB()
          -- Register group change events
        RegisterGroupEvents()    end
end) -- End of f:SetScript("OnEvent", function(self, event, arg1)...










