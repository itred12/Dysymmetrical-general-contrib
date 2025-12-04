--!strict
local DataHandler = {}

-- This module allows you to modify, adjust, add, and remove from the table of data stored and loaded for every player.


--[[
    This table controls the data loaded for and saved to each player. Add to it and remove from it as you wish.

    It is helpful, though not required, to also add comments for pieces of data. Just a short blurb to explain what it is and what's being saved there.

    Naming convention:
    
    > **Parent folder**: All caps, one word if you can help it.
    >
    > **First children**: "`[Name][Parentname]`", i.e., Settings/Accessibility is called "AccessibilitySettings"
    >
    > **Second children**: "`[lowercase parent name]`_`[Name]`", i.e., the "skin previews" performance setting is "performance_SkinPreviews"

    These conventions are more a recommendation than a rule– it just makes your save data structure easier to read a glance.

    Make your own convention or add to this one, if you so wish.
    
]]--
DataHandler.SaveDataStructure = {

    --- A folder containing all of the different types of achievements saved to the player.
    ACHIEVEMENTS = {
        Type = "Folder",
        Children = {

            ChallengeAchievements = {
                Type = "Folder"
            },

            CompletionistAchievements = {
                Type = "Folder"
            },

            FunAchievements = {
                Type = "Folder"
            },

            GeneralAchievements  = {
                Type = "Folder"
            },

            KillerSpecificAchievements = {
                Type = "Folder"
            },

            KillersMilestones = {
                Type = "Folder"
            },

            SurvivorSpecificAchievements = {
                Type = "Folder"
            },

            SurvivorsMilestones = {
                Type = "Folder"
            }

        }
    },

    --- A folder containing the player's equipped emotes, characters, and skins.
    EQUIPPED = {
        Type = "Folder",
        Children = {

            --- A folder containing all of the player's equipped emotes. One of these eight strings is written to with the name of the emote they have equipped, which is then read from when they click on that slot in the emote UI.
            EquippedEmotes = {

                emote_Slot1 = {
                    Type = "String"
                },
    
                emote_Slot2 = {
                    Type = "String"
                },
    
                emote_Slot3 = {
                    Type = "String"
                },
    
                emote_Slot4 = {
                    Type = "String"
                },
    
                emote_Slot5 = {
                    Type = "String"
                },
    
                emote_Slot6 = {
                    Type = "String"
                },
    
                emote_Slot7 = {
                    Type = "String"
                },
    
                emote_Slot8 = {
                    Type = "String"
                }

            },

            --- A folder containing all of the player's equipped skins. Will detail this once I'm sure how skins are stored.
            EquippedSkins = {
                Type = "Folder"
            },

            --- A string that stores the player's currently equipped killer. 
            EquippedKiller = {
                Type = "String",
                DefaultProperties = {
                    --[[
                        This determines the killer that the player starts with. 
                        
                        Will be validated when the game starts to make sure the killer this is tied to still exists– and will handle it if it doesn't, just in case you forget to change this when removing the template killer, or similar.

                        The default behavior is to replace this with the first killer it finds if the value points to a non-existent killer.
                    ]]--
                    Value = "NullexVoyd" -- Add your starting killer here
                }
            },

            --- A string that stores the player's currently equipped survivor.
            EquippedSurvivor = {
                Type = "String",
                DefaultProperties = {
                    --[[
                        This determines the survivor that new players starts with. 
                        
                        Will be validated when the game starts to make sure the survivor this is tied to still exists– and will handle it if it doesn't, just in case you forget to change this when removing the template survivor, or similar.

                        The default behavior is to replace this with the first survivor it finds if the value points to a non-existent survivor.
                    ]]--
                    Value = "Commander" -- Add your starting survivor here
                }
            }

        }

    },

    --- Contains miscellaneous data saved to the player; anything that didnt fit into any other category, really.
    MISC = {
        Type = "Folder",
        Children = {

            LastSeenLog = {
                Type = "Number"
            }

        }
    },

    --- Contains a folder where all of the killers, survivors, skins, and emotes the player purchased will be stored.
    PURCHASED = {
        Type = "Folder",
        Children = {

            --- All of the player's purchased emotes are stored here, in this folder. Will detail when I'm more certain as to exactly how this is stored.
            EmotesPurchased = {
                Type = "Folder"
            },

            --- Any killer the player owns, as well as their current level, will be stored in this folder.  The player must have a killer registered as purchased in order to store any levels gained with them!
            KillersPurchased = {
                Type = "Folder",
                Children = {

                    -- The starting killer will automatically be added here.
                    -- This will be validated similarly to the starting killer/survivor data.

                    -- If you wish to add more starting killers purchased by default, here is what it would look like:
                    --[[
                        KillerNameHere = {
                            Type = "Number"
                        }
                    ]]
                    
                }

            },

            --- Any survivor the player owns, as well as their current level, will be stored in this folder. Any survivor the player uses must be registered as purchased by them, in order for them to store experience and levels gained!
            SurvivorsPurchased = {
                Type = "Folder",
                Children = {
                    
                    -- The starting survivor will automatically be added here.
                    -- This will be validated similarly to the starting killer/survivor data.

                    -- If you wish to add more starting survivors purchased by default, here is what it would look like:
                    --[[
                        SurvivorNameHere = {
                            Type = "Number"
                        }
                    ]]

                }
            },

        }
    },

    --- All of the settings the player can modify are stored here. 
    SETTINGS = {

        --- Settings related to accessibility.
        AccessibilitySettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Accessibility",
                LayoutOrder = 4
            },

            Children = {

                accessibility_PhotosensitiveMode = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Photosensitivity Mode",
                        DisplayDescription = "Attempts to tone down certain flashing lights and effects that may trigger those with epilepsy. <br><b>WARNING: This setting isn't perfect! Even with this enabled, it's still recommended to avoid playing if you're epileptic!</b>"
                    },

                    DefaultProperties = {
                        Value = false
                    }
                }

            }

        },

        --- Settings related to performance.
        PerformanceSettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Performance",
                LayoutOrder = 3
            },

            Children = {

                performance_SkinPreviews = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Skin Previews",
                        DisplayDescription = "Toggles the 3D-model previews shown for skins in the inventory and the shop. Disabling this may improve performance.",
                        LayoutOrder =  1
                    },

                    DefaultProperties = {
                        Value = true
                    }
                } 

            },
        },

        --- Advanced/developer settings.
        AdvancedSettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Advanced",
                LayoutOrder = 7
            },

            Children = {

                advanced_ShowHitboxes = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Visible Attack Hitboxes",
                        DisplayDescription = "Toggles visibility of ability and ability-related hitboxes.",
                        LayoutOrder = 1
                    },

                    DefaultProperties = {
                        Value = false
                    }
                },

                advanced_ShowPlayerHitboxes = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Visible Collision Hitboxes",
                        DisplayDescription = "Toggles visibilty of player collision hitboxes",
                        LayoutOrder = 2
                    },
                    DefaultProperties = {
                        Value = false
                    }
                },

                advanced_SillyRagdolls = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Silly Ragdolls",
                        DisplayDescription = "Uses slightly more force when flinging ragdolls. Client-sided; the extra force is only visible to you.",
                        LayoutOrder = 3
                    },

                    DefaultProperties = {
                        Value = false
                    }
                }

            }
        },

        --- Sound settings.
        AudioSettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Audio",
                LayoutOrder = 2
            },

            Children = {

                audio_MusicVolume = {
                    Type = "Int",
                    Attributes =  {
                        DisplayTitle = "Music Volume",
                        DisplayDescription = "Controls the volume of all in-game music.",
                        LayoutOrder = 1,
                        MinValue = 0,
                        MaxValue = 200,
                        PostDisplayTitle = "%"
                    },

                    DefaultProperties = {
                        Value = 100
                    }
                },

                audio_SFXVolume = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "SFX Volume",
                        DisplayDescription = "Controls the volume of in-game sound effects.",
                        LayoutOrder = 2,
                        MinValue = 0,
                        MaxValue = 200,
                        PostDisplayTitle = "%"
                    },

                    DefaultProperties = {
                        Value = 100
                    }
                },

                audio_UISFXVolume = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "UI Volume",
                        DisplayDescription = "Controls the volume of all sounds produced by the UI (Button clicks, hover sound effect, etc.).",
                        LayoutOrder = 4,
                        MinValue = 0,
                        MaxValue = 200,
                        PostDisplayTitle = "%"
                    },
                    
                    DefaultProperties = {
                        Value = 100
                    }
                },

                audio_VoicelineVolume = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Voiceline Volume",
                        DisplayDescription = "Controls the volume of character voicelines. Set to 0 to effectively disable character voicelines.",
                        LayoutOrder = 3,
                        MinValue = 0,
                        MaxValue = 200,
                        PostDisplayTitle = "%"
                    },

                    DefaultProperties = {
                        Value = 100
                    }
                },

            }
        },

        --- Customization / visual settings.
        CustomizationSettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Customization",
                LayoutOrder = 7
            },
            -- TODO: Make these int instead of boolean, allowing the player to customize saturation/screenshake to a range rather than only enabling/disabling it?

            Children = {

                custom_ScreenDesaturation = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Screen Desaturation When Critical",
                        DisplayDescription = "Toggles the screen desaturation effect applied when you're low on health.",
                        LayoutOrder = 2
                    },

                    DefaultProperties = {
                        Value = true
                    }
                },

                custom_ScreenShakeEnabled = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Screen Shaking Enabled",
                        DisplayDescription = "Toggles screenshake on or off.",
                        LayoutOrder = 1
                    },

                    DefaultProperties = {
                        Value = true
                    }
                },

            }
        },

        --- Game-related settings.
        GameSettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Game",
                LayoutOrder = 1
            },

            Children = {

                game_AFKMode = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "AFK Mode",
                        DisplayDescription = "While enabled, prevents you from being placed into a round.",
                        LayoutOrder = 2
                    },

                    DefaultProperties = {
                        Value = false
                    }
                },

                game_FieldOfView = {
                    Type = "Number",
                    Attributes = {
                        DisplayTitle = "Field Of View",
                        DisplayDescription = "Adjusts your camera's FOV.",
                        LayoutOrder = 1,
                        MinValue = 20,
                        MaxValue = 80
                    },

                    DefaultProperties = {
                        Value = 70
                    }
                },

                game_DisableMalice = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Disable Being Killer",
                        DisplayDescription = "While enabled, malice gain is disabled, lessening your chance to become the killer.",
                        LayoutOrder = 3
                    },

                    DefaultProperties = {
                        Value = false
                    }
                }

            }

        },

        --- Miscellaneous / fun settings.
        MiscellaneousSettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Miscellaneous / Fun",
                LayoutOrder = 6
            },

            Children = {

                misc_DisableKillerIntros = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Disable Killer Intros",
                        DisplayDescription = "Enables or disables the intro cutscene played for the killer when the round begins.",
                        LayoutOrder = 3
                    },

                    DefaultProperties = {
                        Value = false
                    }
                },

                misc_HitsoundID = {
                    Type = "String",
                    Attributes = {
                        DisplayTitle = "Hitsound ID",
                        DisplayDescription = "(MEME SETTING): Plays a client-sided sound effect whenever you hit another player with an attack. Enter the Roblox ID of the sound you wish to play.",
                        LayoutOrder = 1
                    },

                    DefaultProperties = {
                        Value = ""
                    }
                },

                misc_ImageFlashOnHit = {
                    Type = "String",
                    Attributes = {
                        DisplayTitle = "Image Flash On Hit",
                        DisplayDescription = "(MEME SETTING): Flashes a client-sided image on your screen whenever you hit someone. Enter the Roblox ID of the image you wish to display.",
                        LayoutOrder = 2
                    },

                    DefaultProperties = {
                        Value = false
                    }
                },

                misc_ShowRewardNotifications = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Show Reward Notifications",
                        DisplayDescription = "Toggles the poppups displayed whenever you gain EXP or other currency.",
                        LayoutOrder = 4
                    },

                    DefaultProperties = {
                        Value = true
                    }
                }

            }
        },

        --- Privacy settings, controls what stats are displayed to other players on your profile.
        PrivacySettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Privacy",
                LayoutOrder = 5
            },

            Children = {

                privacy_HideKillerWins = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Hide Killer Wins",
                        DisplayDescription = "Toggles displaying your total killer wins to other players.",
                        LayoutOrder = 2
                    },

                    DefaultProperties = {
                        Value = false
                    }
                },

                privacy_HideCurrency = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Hide Money",
                        DisplayDescription = "Toggles displaying your total money to other players.",
                        LayoutOrder = 4
                    },

                    DefaultProperties = {
                        Value = false
                    }
                },

                privacy_HidePlaytime = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Hide Playtime",
                        DisplayDescription = "Toggles displaying your total playtime to other players.",
                        LayoutOrder = 1
                    },

                    DefaultProperties = {
                        Value = false
                    }
                },

                privacy_HideSurvivorWins = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Hide Survivor Wins",
                        DisplayDescription = "Toggles displaying your total survivor wins to other players.",
                        LayoutOrder = 3
                    },

                    DefaultProperties = {
                        Value = false
                    }
                }

            }
        }


    },

    --- All of the tracked statistics stored for the player, including things used in-game– such as money and malice.
    STATS = {

        -- Tracked statistics relevant to the player's currency.
        CurrencyStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Currency",
                LayoutOrder = 4
            },

            Children = {

                currency_Money = {
                    Type = "Int",
                    Attributes = {
                        DisplayInLeaderstats = true,
                        DisplayTitle = "Player Points",
                        LayoutOrder = 1,
                        DisplayTitlePrefix = "$"
                    },

                    DefaultProperties = {
                        Value = 5000
                    }
                },

                -- Calculated automatically according to the total value of all of the player's purchases.
                currency_NetWorth = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Net Worth",
                        LayoutOrder = 2,
                        DisplayTitlePrefix = "$"
                    }
                }

            }
        },

        -- Tracked statistics not relevant to anything in particular.
        GeneralStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "General",
                LayoutOrder = 1
            },

            Children = {

                -- Ideally we'd store this as an int, but I'll have to investigate how it functions, first...
                general_Malice = {
                    Type = "Number",
                    Attributes = {
                        DisplayInLeaderstats = true,
                        DisplayTitle = "Chance to Become Killer",
                        LayoutOrder = 2
                    },

                    DefaultProperties = {
                        Value = 1
                    }
                },

                general_TimePlayed = {
                    Type = "Number",
                    Attributes =  {
                        DisplayTitle = "Time Played",
                        FormatTime = true,
                        LayoutOrder = 1,
                        PostDisplayTitle = "[D:]H:M:S"
                    }, 
                }

            }
        },

        -- The player's tracked statistics as a killer.
        KillerStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Killer Stats",
                LayoutOrder = 3
            },

            Children = {
                
                killer_Losses = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Killer Losses",
                        LayoutOrder = 2
                    }
                },

                killer_Wins = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Killer Wins",
                        LayoutOrder = 1
                    }
                },

                killer_Kills = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Total Kills",
                        LayoutOrder = 3
                    }
                }

            }

        },

        -- The player's tracked statistics as a survivor.
        SurvivorStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Survivor Stats",
                LayoutOrder = 2
            },

            Children = {

                survivor_Losses = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Survivor Losses",
                        LayoutOrder = 2
                    }
                },

                survivor_Wins = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Survivor Wins",
                        LayoutOrder = 1
                    }
                },

                survivor_ObjectivesCompleted = {
                    Type = "Int",
                    Attributes = {
                        DisplayTitle = "Objectives Completed As Survivor",
                        LayoutOrder = 3
                    }
                }

            }


        }

    }

}

return DataHandler