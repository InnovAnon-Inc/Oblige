----------------------------------------------------------------
--  Name Generator
----------------------------------------------------------------
--
--  Oblige Level Maker (C) 2008 Andrew Apted
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
----------------------------------------------------------------

require 'util'


NAME_PATTERNS =
{
  TECH_1 =
  {
    pattern = "%4t%7a%7k%n",
    prob = 90,

    words =
    {
      t = { The=90, A=10 },

      a = { Large=10, Huge=10, Gigantic=1,
            Small=10, Tiny=2,

            Old=10, Ancient=10, Eternal=2,
            Advanced=8, Futuristic=3, Future=1,
            Fantastic=1, Incredible=1, Amazing=0.5,

            Decrepid=10, Run_Down=5,
            Ruined=5, Forgotten=7, Lost=10, Failed=5,
            Ravished=2, Broken=2, Dead=2, Deadly=4,
            Dirty=2, Filthy=1,
            Deserted=10, Abandoned=10,

            Monstrous=5, Demonic=3, Invaded=1, Overtaken=1,
            Infested=10, Haunted=3, Ghostly=5, Hellish=1,

            Eerie=4, Strange=16, Weird=2, Creepy=1,
            Dark=20, Gloomy=8, Horrible=1,
            Dismal=2, Dreaded=4, Cold=4,

            Underground=5, Subterranean=2,
            Ethereal=5, Floating=2,
            Mars=5, Saturn=5, Jupiter=5,

            Hidden=2, Secret=10, Experimental=1,
            Upper=5, Lower=5, Central=5,
            Northern=1, Southern=1, Eastern=1, Western=1,
            Inner=5, Outer=5, Innermost=1, Outermost=1,
          },

      k = { Power=10, Hi_Tech=8, Tech=1,
            Star=2, Stellar=2, Solar=2, Lunar=4,
            Space=12, Control=10, Military=10, Security=3,
            Mechanical=3, Rocket=1, Missile=2, Research=10,
            Nukage=3, Slime=3, Toxin=2, Plasma=5,
            Bio_=10, Bionic=2, Nuclear=10, Chemical=7,
            Processing=6, Refueling=3, Metal=1,
            Computer=5, Electronics=1, Electro_=1,
            Industrial=2, Engineering=2, Logic=1,
            Teleport=1, Supply=2, Cryogenic=1,
            Worm_hole=1, Black_hole=1, Robotic=1,
            Magnetic=2, Electrical=2, Proto_=1,
            Slige=1, Waste=1, Optic=1, Time=1, Chrono_=1,
            Alpha=3, Gamma=3, Photon=1, Jedi=1,
            Crystal=2,
          },

      n = { Generator=15, Plant=20, Base=30,
            Warehouse=20, Lab=10, Laboratory=2,
            Station=30, Tower=20, Center=20,
            Complex=30, Refinery=20, Factory=20,
            Depot=7, Storage=4, Anomaly=1, Area=2,
            Tunnels=3, Zone=8, Sphere=1, Gateway=10,
            Facility=10, Works=1, Outpost=1, Site=1,
            Hanger=1, Portal=2, Installation=1,
            Bunker=1, Device=2, Machine=1, Network=1,
          },
    },
  },

  TECH_2 =
  {
    pattern = "%n",
    prob = 30,

    words =
    {
      n =
      {
        ["Power Surge"]=50,
        ["Steel Foundry"]=50,
      }
    },
  },

  HELL_1 =
  {
    pattern = "%4t%7a%n%4h",
    prob = 90,

    words =
    {
      t = { The=90,
            A=10,
            ["The Devil's"]=10,
            ["Satan's"]=10,
          },

      a = { Large=10, Massive=10, Sprawling=1,
            Small=1, Endless=7,

            Old=10, Ancient=20, Eternal=1,

            Decrepid=10,
            Ruined=5, Forgotten=7, Lost=10,
            Ravished=2,
            Broken=1, Deadly=3, Barren=4,
            Dirty=2, Filthy=1,
            Stagnant=3, Rancid=5, Rotten=3,
            Burning=15, Hot=1, Melting=1,

            Blood=20, Blood_filled=3, Bloody=1,
            Blood_stained=1, Blood_soaked=1,
            Monstrous=15, Monster=4,
            Demonic=10, Demon=2,
            Haunted=10, Ghostly=15, Ghastly=2,
            Unholy=10, Godless=2, God_forsaken=1,
            Evil=30, Wicked=15, Cruel=5,

            Eerie=10, Strange=20, Weird=2, Creepy=5,
            Dark=20, Gloomy=15, Awful=3, Horrible=5,
            Dismal=8, Dreaded=8, Dank=2, Frightful=1,
            Moan_filled=2, Spooky=10,

            Underground=5, Subterranean=1,
            Hidden=1, Secret=1,
            Upper=5, Lower=5, Inner=5, Outer=5,
          },

      n = { Grotto=10, Tomb=10,
            Crypt=20, Chapel=3, Church=1,
            Graveyard=5, Cloister=1,
            Pit=7, Cavern=5, Cave=1,
            Wasteland=10, Fields=1,
            Ghetto=2, City=0.5, Well=1,
            Lair=5, Den=2, Domain=1, Gate=1,
            Valley=4, River=1, Catacombs=1,
            Palace=1, Cathedral=1, Chamber=4,
            Labyrinth=1,
          },

      h = { ["of Hell"] = 40,
            ["of Fire"] = 25,
            ["of Flames"] = 3,
            ["of Horror"] = 10,
            ["of Terror"] = 10,
            ["of Death"] = 10,
            ["of Pain"] = 15,
            ["of Fear"] = 5,
            ["of Hate"] = 5,
            ["of Limbo"] = 2,
            ["of the Damned"] = 10,
            ["of the Dead"] = 10,
            ["of Souls"] = 10,
            ["of the Undead"] = 10,
            ["of Destruction"] = 3,
            ["of Whispers"] = 2,
            ["of Twilight"] = 2,
            ["of Torture"] = 5,
            ["of Flesh"] = 2,
            ["of Essel"] = 1,
            ["of Tears"] = 1,
          },
    },
  },

  HELL_2 =
  {
    pattern = "%n",
    prob = 30,

    words =
    {
      n =
      {
        ["Skin Graft"]=50,
        ["Meltdown"]=50,
        ["Blood_stains"]=50,
      }
    },
  },
}


function Name_fixup(name)
  -- convert "_" to "-"
  name = string.gsub(name, "_ ", "-")
  name = string.gsub(name, "_",  "-")

  -- convert "A" to "AN" where necessary
  name = string.gsub(name, "^[aA] ([aAeEiIoOuU])", "An %1")

  return name
end



function Name_from_pattern(PAT)
  local name = ""

  local pos = 1

  while pos <= #PAT.pattern do
    
    local c = string.sub(PAT.pattern, pos, pos)
    pos = pos + 1

    local chance = 100

    if c ~= "%" then
      name = name .. c
    else
      assert(pos <= #PAT.pattern)
      c = string.sub(PAT.pattern, pos, pos)
      pos = pos + 1

      if string.match(c, "%d") then
        chance = (0 + c) * 10

        assert(pos <= #PAT.pattern)
        c = string.sub(PAT.pattern, pos, pos)
        pos = pos + 1
      end

      if not string.match(c, "%a") then
        error("Bad pattern: expected letter after %")
      end

      if rand_odds(chance) then
        local words = PAT.words[c]
        if not words then
          error("Pattern is missing word: " .. c)
        end

        if #name > 0 then
          name = name .. " "
        end

        local w = rand_key_by_probs(words)
        name = name .. w
      end
    end
  end

  return Name_fixup(name)
end


function Naming_test()
  for i = 1,500 do
    local pat = NAME_PATTERNS.TECH_1
    gui.debugf("Name %2d: %s\n", i, Name_from_pattern(pat))
  end
end

