--!strict
local DataHandler = {}

-- This module allows you to modify, adjust, add, and remove from the table of data stored and loaded for every player.


--[[
    This table controls the data loaded for and saved to each player. Add to it and remove from it as you wish.

    It is helpful, though not required, to also add comments for pieces of data. Just a short blurb to explain what it is and what's being saved there.
]]--
DataHandler.SaveDataStructure = {

    --- A folder containing all of the different types of achievements saved to the player.
    Achievements = {
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
    Equipped = {
        Type = "Folder",
        Children = {

            --- A folder containing all of the player's equipped emotes. One of these eight strings is written to with the name of the emote they have equipped, which is then read from when they click on that slot in the emote UI.
            EquippedEmotes = {

                Emote1 = {
                    Type = "String"
                },
    
                Emote2 = {
                    Type = "String"
                },
    
                Emote3 = {
                    Type = "String"
                },
    
                Emote4 = {
                    Type = "String"
                },
    
                Emote5 = {
                    Type = "String"
                },
    
                Emote6 = {
                    Type = "String"
                },
    
                Emote7 = {
                    Type = "String"
                },
    
                Emote8 = {
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
    Misc = {
        Type = "Folder",
        Children = {

            LastSeenLog = {
                Type = "Number"
            }

        }
    },

    --- Contains a folder where all of the killers, survivors, skins, and emotes the player purchased will be stored.
    Purchased = {
        Type = "Folder",
        Children = {

            --- All of the player's purchased emotes are stored here, in this folder. Will detail when I'm more certain as to exactly how this is stored.
            PurchasedEmotes = {
                Type = "Folder"
            },

            --- Any killer the player owns, as well as their current level, will be stored in this folder.  The player must have a killer registered as purchased in order to store any levels gained with them!
            PurchasedKillers = {
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
            PurchasedSurvivors = {
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
    Settings = {

        --- Settings related to accessibility.
        AccessibilitySettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Accessibility",
                LayoutOrder = 4
            },

            Children = {

                PhotosensitiveMode = {
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

                SkinPreviews = {
                    Type = "Boolean",
                    Attributes = {
                        DisplayTitle = "Skin Previews",
                        DisplayDescription = "Enables/Disables the 3D-model previews shown for skins in the inventory and the shop.",
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

                ShowHitboxes = {},

                ShowPlayerHitboxes = {},

                SillyRagdolls = {}

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

                MusicVolume = {},

                SFXVolume = {},

                UISFXVolume = {},

                VoicelineVolume = {},

            }
        },

        --- Customization / visual settings.
        CustomizationSettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Customization",
                LayoutOrder = 7
            },

            Children = {

                ScreenDesaturation = {},

                ScreenShakeEnabled = {},

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

                AFKMode = {},

                FieldOfView = {},

                DisableMalice = {}

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

                DisableKillerIntros = {},

                HitsoundID = {},

                ImageFlashOnHit = {},

                ShowRewardNotifications = {}

            }
        },

        --- Privacy settings, controls what is displayed to other players.
        PrivacySettings = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Privacy",
                LayoutOrder = 5
            },

            Children = {

                HideKillerWins = {},

                HideCurrency = {},

                HidePlaytime = {},

                HideSurvivorWins = {}

            }
        }


    },

    --- All of the statistics stored for the player.
    Stats = {

        CurrencyStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Currency",
                LayoutOrder = 4
            },

            Children = {

                Money = {},

                NetWorth = {}

            }
        },

        GeneralStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "General",
                LayoutOrder = 1
            },

            Children = {

                Malice = {},

                TimePlayed = {
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

        KillerStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Killer Stats",
                LayoutOrder = 3
            },

            Children = {
                
                KillerLosses = {},

                KillerWins = {},

                Kills = {}

            }

        },

        SurvivorStats = {
            Type = "Folder",
            Attributes = {
                DisplayTitle = "Survivor Stats",
                LayoutOrder = 2
            },

            Children = {

                SurvivorLosses = {},

                SurvivorWins = {},

                ObjectivesCompleted = {}

            }


        }

    }

}

return DataHandler