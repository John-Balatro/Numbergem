local loc_stuff = {
    descriptions = {
        gem_Number = {
            c_gem_one = {
                name = "1",
                text = {
                    "{C:mult}+#1#{} Mult",
                    "while held"
                }
            },
            c_gem_two = {
                name = "2",
                text = {
                    "{C:purple}Balances{} {C:chips}Chips{} and",
                    "{C:mult}Mult{} of selected hand"
                }
            },
            c_gem_three = {
                name = "3",
                text = {
                    "{C:gold}+3{} {C:blue}Play{} and",
                    "{C:red}Discard{} limit until",
                    "end of round"
                }
            },
            c_gem_four = {
                name = "4",
                text = {
                    "{C:money}$#1#{}",
                    "",
                    "{E:1}for a bit ..."
                }
            },
            c_gem_five = {
                name = "5",
                text = {
                    "{E:1,C:green}Five",
                }
            },
            c_gem_six = {
                name = "6",
                text = {
                    "{E:1,C:green}Five{},",
                    "then {E:1,C:green}Five{} again",
                }
            },
            c_gem_seven = {
                name = "7",
                text = {
                    "Create a {C:dark_edition}Negative{} {C:gem_number}7",
                    "at end of round when",
                    "a card is sold",
                    "{C:inactive}(triggers at most once per round)",
                }
            },
            c_gem_eight = {
                name = "8",
                text = {
                    "turns Polychrome"
                }
            },
            c_gem_nine = {
                name = "9",
                text = {
                    "{E:1,C:green}Five{} five times",
                    "at end of round",
                    "Costs {C:money}$#1#"
                }
            },
            c_gem_ten = {
                name = "10",
                text = {
                    "Create {C:attention}#1# {C:dark_edition}Negative {C:attention}8 Balls",
                    "trigger them,",
                    "then destroy them",
                    "{C:inactive}(They don't need room)"
                }
            },
            c_gem_eleven = {
                name = "11",
                text = {
                    "Create two {C:gem_number}Ones",
                    "{C:inactive}(with the Mult of the leftmost",
                    "{C:gem_number}One{C:inactive} if possible)",
                    "merge all of the {C:gem_number}Ones",
                    "they become negative"
                }
            },
            c_gem_twelve = {
                name = "12",
                text = {
                    "goes to jokers",
                }
            },
            c_gem_twelve_alt = {
                name = "12",
                text = {
                    "{X:mult,C:white}X#1#{} Mult",
                }
            },
            c_gem_thirteen = {
                name = "13",
                text = {
                    "Is actually 12.",
                }
            },
            c_gem_fourteen = {
                name = "14",
                text = {
                    "uhh i couldnt think of an effect f or this one",
                    "you figure it out"
                }
            },
            c_gem_fifteen = {
                name = "15",
                text = {
                    "Destroys #1# cards",
                }
            },
            c_gem_sixteen = {
                name = "16",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Cryptid{}",
                }
            },
            c_gem_seventeen = {
                name = "17",
                text = {
                    "Creates {C:attention}#1#{} random",
                    "{C:gem_number}Number{} cards",
                    "{C:inactive}(must have room)"
                }
            },
            c_gem_eighteen = {
                name = "18",
                text = {
                    "Creates a random {C:planet}Planet{}, then",
                    "a {C:tarot}Tarot{}, then a {C:spectral}Spectral{},",
                    "then a copy of {C:spectral}The Soul{}",
                    "{C:inactive}(must have room)"
                }
            },
            c_gem_nineteen = {
                name = "19",
                text = {
                    "{E:1,s:2,C:dark_edition}Up{}grades your deck"
                }
            },
            c_gem_twenty = {
                name = "20",
                text = {
                    "Cycles the {C:hearts}s{C:diamonds}u{C:spades}i{C:clubs}t{} of each card",
                    "in your deck"
                }
            },
            c_gem_twentyone = {
                name = "21",
                text = {
                    "{X:money,C:white,s:2}^^2{} money",
                    "{C:inactive}(Max of {C:money}$#1#{C:inactive})",
                }
            },
            c_gem_twentytwo = {
                name = "22",
                text = {
                    "{E:1}Draw #1# cards..."
                }
            },
            c_gem_twentythree = {
                name = "23",
                text = {
                    "Level up the",
                    "currently selected",
                    "hand"
                }
            },
            c_gem_twentyfour = {
                name = "24",
                text = {
                    "Creates {C:attention}a{} random",
                    "{C:dark_edition}Negative{} {C:gem_number}Number{} card",
                    "{C:inactive,s:0.4}(like the edition not a negative number you know what i mean)"
                }
            },
            c_gem_twentyfive = {
                name = "25",
                text = {
                    "{C:blue}m"
                }
            },
            c_gem_twentysix = {
                name = "26",
                text = {
                    "compares a number with table",
                }
            },
            c_gem_twentyseven = {
                name = "27",
                text = {
                    "compares a number with cdata",
                }
            },
            c_gem_twentyeight = {
                name = "28",
                text = {
                    "{E:1,C:green}Five{} when",
                    "a card is sold"
                }
            },
            c_gem_twentynine = {
                name = "29",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Celestial Pack{}",
                }
            },
            c_gem_thirty = {
                name = "30",
                text = {
                    "Creates a {V:1}Letter {C:attention}Joker{}",
                    "{C:inactive}(Must have room)"
                }
            },
            c_gem_thirtyone = {
                name = "31",
                text = {
                    "Creates a {V:1}Vowel {C:attention}Joker{}",
                    "{C:inactive}(Must have room)"
                }
            },
            c_gem_thirtytwo = {
                name = "32",
                text = {
                    "Creates a {V:1}Consonant {C:attention}Joker{}",
                    "{C:inactive}(Must have room)"
                }
            },
            c_gem_thirtythree = {
                name = "33",
                text = {
                    "Creates a {V:1}Low Value Letter {C:attention}Joker{}",
                    "{C:inactive}(Must have room)"
                }
            },
            c_gem_thirtyfour = {
                name = "34",
                text = {
                    "Creates a {V:1}High Value Letter {C:attention}Joker{}",
                    "{C:inactive}(Must have room)"
                }
            },
            c_gem_thirtyfive = {
                name = "35",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Polychrome{}",
                }
            },
            c_gem_thirtysix = {
                name = "36",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Space Joker{}",
                }
            },
            c_gem_thirtyseven = {
                name = "37",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Mini Spectral Pack{}",
                }
            },
            c_gem_thirtyeight = {
                name = "38",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Anaglyph Deck{}",
                }
            },
            c_gem_thirtynine = {
                name = "39",
                text = {
                    "{C:purple}Balances{} {C:gold}current money{}",
                    "and {C:mult}Mult{} of selected hand"
                }
            },
            c_gem_forty = {
                name = "40",
                text = {
                    "{C:purple}Balances{} {C:gold}current money{}",
                    "and {C:chips}Chips{} of selected hand"
                }
            },
            c_gem_fortyone = {
                name = "41",
                text = {
                    "Duplicate each card",
                    "held in hand"
                }
            },
            c_gem_fortytwo = {
                name = "42",
                text = {
                    {
                        "{X:chips,C:white}X#2#{} Chips",
                        "while held"
                    },
                    {
                        "Converts up to",
                        "{C:attention}#1#{} selected card",
                        "to {C:attention}42{}",
                    }
                }
            },
            c_gem_fortythree = {
                name = "43",
                text = {
                    "Trigger {C:gold}Interest{} four times"
                }
            },
            c_gem_fortyfour = {
                name = "44",
                text = {
                    "{C:purple}Swaps{} {C:chips}Chips{} and",
                    "{C:mult}Mult{} of selected hand"
                }
            },
            c_gem_fortyfive = {
                name = "45",
                text = {
                    "{C:attention}+#1#{} Shop Slots",
                    "until end of round"
                }
            },
            c_gem_fortysix = {
                name = "46",
                text = {
                    "{C:dark_edition}+#1#{} Joker Slots",
                    "until end of round"
                }
            },
            c_gem_fortyseven = {
                name = "47",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Smiley Face{}",
                }
            },
            c_gem_fortyeight = {
                name = "48",
                text = {
                    "Balance {C:attention}Ante{} and",
                    "{C:gold}current money"
                }
            },
            c_gem_fortynine = {
                name = "49",
                text = {
                    "{X:purple,C:white}..(times played){} to {C:chips}Chips{}",
                    "and {C:mult}Mult{} of selected hand"
                }
            },
            c_gem_fifty = {
                name = "50",
                text = {
                    "{X:attention,C:white}..(Round){} Round",
                    "Earn {C:gold}$#1#{} for each digit in Round"
                }
            },
            c_gem_fiftyone = {
                name = "51",
                text = {
                    "{C:green}+#1#{} free rerolls for",
                    "each card {C:red}Sold{} while",
                    "this card was held",
                    "{C:inactive}(Currently {C:green}+#2#{C:inactive})"
                }
            },
            c_gem_fiftytwo = {
                name = "52",
                text = {
                    "Earn {C:gold}$#1#",
                    "but fight {C:spectral,s:1.5,E:1}John Balatro"
                }
            },
            c_gem_fiftythree = {
                name = "53",
                text = {
                    "Shuffle all hand's",
                    "{C:chips}Chips{} and {C:mult}Mult"
                }
            },
            c_gem_fiftyfour = {
                name = "54",
                text = {
                    "Level up all currently",
                    "hidden poker hands"
                }
            },
            c_gem_fiftyfive = {
                name = "55",
                text = {
                    "{C:purple}Balance{} all hand's",
                    "{C:chips}Chips{} and {C:mult}Mult",
                }
            },
            c_gem_fiftysix = {
                name = "56",
                text = {
                    "Create {C:attention}#1# {C:dark_edition}Negative {C:gem_number}Ones"
                }
            },
            c_gem_fiftyseven = {
                name = "57",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Satellite{}",
                }
            },
            c_gem_fiftyeight = {
                name = "58",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Matador{}",
                }
            },
            c_gem_fiftynine = {
                name = "59",
                text = {
                    "Converts up to",
                    "{C:attention}#1#{} selected card",
                    "to {C:attention}Red Seal{}",
                }
            },
            c_gem_sixty = {
                name = "60",
                text = {
                    "While held, converts",
                    "{C:mult}+Mult{} into {X:chips,C:white}XChips",
                    "but  no money"
                }
            },
            c_gem_sixtyone = {
                name = "61",
                text = {
                    "{s:2}New Joker",
                }
            },
            c_gem_sixtytwo = {
                name = "62",
                text = {
                    {
                        "Give up to {C:attention}0{}",
                        "selected cards {C:mult}+#1#{} Mult",
                    },
                    {
                        "Select an additional",
                        "card for every {C:money}$#2#",
                        "earned while this is held",
                        "{C:inactive}(Currently {C:money}$#3#{C:inactive})"
                    }
                }
            },
            c_gem_sixtythree = {
                name = "63",
                text = {
                    "Creates {C:attention}a{} random",
                    "{C:dark_edition}Negative{} {C:gem_number}Number{} card",
                    "for every {C:attention}#2#{} cards",
                    "scored while this is held",
                    "{C:inactive}(Currently {C:attention}#1#{C:inactive})"
                }
            },
            c_gem_sixtyfour = {
                name = "64",
                text = {
                    {
                        "Destroy up to {C:attention}0{}",
                        "selected cards",
                    },
                    {
                        "Select an additional",
                        "card for every {C:red}#2#",
                        "cards {C:red}Sold{} while",
                        "this card was held",
                        "{C:inactive}(Currently {C:red}#1#{C:inactive})"
                    }
                }
            },
            c_gem_sixtyfive = {
                name = "65",
                text = {
                    {
                        "Convert up to {C:attention}0{}",
                        "selected cards",
                        "to Wild Cards"
                    },
                    {
                        "Select an additional",
                        "card for every {C:money}$#2#",
                        "spent while this is held",
                        "{C:inactive}(Currently {C:money}$#3#{C:inactive})"
                    }
                }
            },
            c_gem_sixtysix = {
                name = "66",
                text = {
                    "{C:chips}+#1#{} Chips",
                    "while held"
                }
            },
        },
        Enhanced = {
            m_gem_cryptid = {
                name = "Cryptid",
                text = {
                    "Create {C:attention}#1#{} copies of",
                    "the {C:attention}first card{}",
                    "in {C:attention}played hand{}",
                }
            },
            m_gem_celestialpack = {
                name = "Celestial Pack",
                text = {
                    "Create {C:attention}#1#{} {C:dark_edition}Negative{} {C:planet}Planet",
                    "cards when scored. They gain",
                    "\"When another card of this set is",
                    "used or sold, {C:red}self destructs{}\""
                }
            },
            m_gem_polychrome = {
                name = "Polychrome",
                text = {
                    "{X:mult,C:white}X#1#{} Mult"
                }
            },
            m_gem_space_joker = {
                name = "Space Joker",
                text = {
                    "{C:green}#1# in #2#{} chance to",
                    "upgrade level of",
                    "played {C:attention}poker hand{}",
                }
            },
            m_gem_spectralpack = {
                name = "Mini Spectral Pack",
                text = {
                    "Create {C:attention}#1#{} {C:dark_edition}Negative{} {C:spectral}Spectral",
                    "card when scored. They gain",
                    "\"When another card of this set is",
                    "used or sold, {C:red}self destructs{}\""
                }
            },
            m_gem_anaglyphdeck = {
                name = "Anaglyph Deck",
                text = {
                    "Create a {C:attention}Double Tag",
                    "when scored",
                }
            },
            m_gem_fortytwo = {
                name = "42",
                text = {
                    {
                        "{X:chips,C:white}X#2#{} Chips",
                        "while held in hand"
                    },
                    {
                        "Converts up to",
                        "{C:attention}#1#{} held card",
                        "to {C:attention}42{}",
                        "when scored"
                    }
                }
            },
            m_gem_smileyface = {
                name = "Smiley Face",
                text = {
                    {
                        "Is a face card"
                    }, 
                    {
                        "Gives {C:mult}+#1#{} Mult for",
                        "each played {C:attention}face card",
                        "when scored",
                    }
                }
            },
            m_gem_satellite = {
                name = "Satellite",
                text = {
                    "Earn {C:money}$#1#{} at end of",
                    "round per unique {C:planet}Planet",
                    "card used this run",
                    "when held in hand",
                    "at end of round",
                    "{C:inactive}(Currently {C:money}$#2#{C:inactive})",
                }
            },
            m_gem_matador = {
                name = "Matador",
                text = {
                    "Earn {C:money}$#1#{} for each",
                    "played {C:red}debuffed card",
                    "when scored"
                }
            },
            m_gem_redseal = {
                name = "Red Seal",
                text = {
                    "{C:attention}Retrigger{} all",
                    "scoring cards when played"
                }
            },
        },
        Joker = {
            j_gem_a = {
                name = "A",
                text = {
                    "Played {C:attention}Aces{}",
                    "give {C:mult}+#1#{} Mult",
                    "and get {C:attention}retriggered",
                },
            },
            j_gem_b = {
                name = "B",
                text = {
                    "Shops contain an",
                    "additional {C:money}$#1#",
                    "{C:attention}Buffoon Pack"
                },
            },
            j_gem_c = {
                name = "C",
                text = {
                    "{X:mult,C:white}X#1#{} Mult for every",
                    "{C:chips}100{} chips worth",
                    "of cards scored",
                    "{C:inactive}(Currently #2#/100)"
                },
            },
            j_gem_d = {
                name = "D",
                text = {
                    "{C:red,E:1}Destroy"
                },
            },
            j_gem_e = {
                name = "E",
                text = {
                    "{X:dark_edition,C:white}^#1#{} Mult"
                },
            },
            j_gem_f = {
                name = "F",
                text = {
                    "Creates a {V:1}Letter {C:attention}Joker{}",
                    "when blind is selected",
                    "{C:inactive}(must have room)"
                },
            },
            j_gem_g = {
                name = "G",
                text = {
                    "{S:1.5,X:spectral,C:white}G"
                },
            },
            j_gem_h = {
                name = "H",
                text = {
                    "{C:attention}Retrigger{} all scoring",
                    "cards except {C:attention}the first"
                },
            },
            j_gem_i = {
                name = "I",
                text = {
                    {
                        "{C:attention}Straights{} can be formed",
                        "with {C:attention}two{} fewer cards",
                    }, 
                    {
                        "{X:mult,C:white}X#1#{} Mult if played hand",
                        "contains a {C:attention}five card straight"
                    },
                },
            },
            j_gem_j = {
                name = "J",
                text = {
                    {
                        "Retriggers the {C:attention}two{}",
                        "{C:attention}Jokers{} to the right"
                    },
                    {
                        "Lose {C:money}$#1#{} when",
                        "they trigger"
                    }
                },
            },
            j_gem_k = {
                name = "K",
                text = {
                    "Creates a {C:dark_edition}Negative {C:attention}Cavendish",
                    "when {C:attention}Blind{} is selected, it has a",
                    "{X:green,C:white}X#1#{} chance to be destroyed"
                },
            },
            j_gem_l = {
                name = "L",
                text = {
                    "The {C:attention}first scoring card{}",
                    "each hand is considered {C:attention}Lucky",
                    "with a {X:green,C:white}X#1#{} chance to trigger",
                },
            },
            j_gem_m = {
                name = "M",
                text = {
                    "Creates a {C:blue}Jolly Joker",
                    "with {C:money}+$#1#{} sell value",
                    "when blind is selected",
                    "{C:inactive}(must have room)"
                }
            },
            j_gem_n = {
                name = "N",
                text = {
                    "Creates a {C:dark_edition}Negative {C:attention}j_vremade_joker",
                    "when {C:attention}Boss Blind{} is selected",
                }
            },
            j_gem_vremade_joker = {
                name = "j_vremade_joker",
                text = {
                    "{C:red,s:1.1}+#1#{} Mult",
                },
            },
            j_gem_o = {
                name = "O",
                text = {
                    "All probabilities are {C:green}1 in 2",
                }
            },
            j_gem_p = {
                name = "P",
                text = {
                    "When blind is selected,",
                    "reduce {C:attention}blind size{} by {X:purple,C:white}X#1#",
                    "for each {C:attention}Ante{}",
                    "{C:inactive}(Currently {X:purple,C:white}X#2#{C:inactive})"
                }
            },
            j_gem_q = {
                name = "Q",
                text = {
                    "Cards adjacent to",
                    "{C:attention}Queens{} held in hand",
                    "give {X:mult,C:white} X#1# {} Mult",
                },
            },
            j_gem_r = {
                name = "R",
                text = {
                    {
                        "{C:attention}+#1#{} Round when",
                        "blind is selected"
                    }, 
                    {
                        "{C:mult}+#2#{} Mult for each Round",
                        "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)"
                    }
                },
            },
            j_gem_s = {
                name = "S",
                text = {
                    "Scored and held {C:attention}6s{} and {C:attention}7s",
                    "give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
                },
            },
            j_gem_t = {
                name = "T",
                text = {
                    "{E:1,C:attention}Draw another card",
                    "when you draw a",
                    "{C:attention}Wild Card"
                }
            },
            j_gem_u = {
                name = "U",
                text = {
                    "Cards do not score",
                    "{C:mult}+#1#{} Mult for each played card"
                }
            },
            j_gem_v = {
                name = "V",
                text = {
                    "Creates a {C:attention}Voucher Tag",
                    "whenever a card is bought"
                }
            },
            j_gem_w = {
                name = "W",
                text = {
                    "Creates a {C:attention}Wheel of Fortune",
                    "when {C:attention}Blind{} is selected, it has",
                    "a {X:green,C:white}X#1#{} chance to trigger"
                }
            },
            j_gem_x = {
                name = "X",
                text = {
                    "Increases {X:mult,C:white}XMult{} triggers",
                    "by {X:mult,C:white}X#1#{} Mult, increases",
                    "by {X:mult,C:white}X#2#{} Mult per trigger"
                }
            },
            j_gem_y = {
                name = "Y",
                text = {
                    "Earn {C:gold}$#1#{} for every",
                    "{C:attention}#2#{} cards scored",
                    "{C:inactive}(Currently #3#/#2#)"
                }
            },
            j_gem_z = {
                name = "Z",
                text = {
                    "Prevents Death",
                    "but {C:red}destroys{} {C:attention}13",
                    "playing cards"
                }
            },
        },
        Spectral = {
            c_gem_zero = {
                name = "0",
                text = {
                    "Creates {C:attention}#1#{} random",
                    "{C:dark_edition}Negative{} {C:gem_number}Number{} cards",
                }
            },
            c_gem_sixtyseven = {
                name = "67",
                text = {
                    "{X:dark_edition,C:white}^#1#{} Mult",
                    "while held"
                }
            },
        },
        Other = {
            p_gem_number_normal = {
                name = "Number Pack",
                text = {
                    "Choose {C:attention}#1#{} of up to",
                    "{C:attention}#2#{} {C:dark_edition}Numbers{}",
                }
            },
            p_gem_number_jumbo = {
                name = "Jumbo Number Pack",
                text = {
                    "Choose {C:attention}#1#{} of up to",
                    "{C:attention}#2#{} {C:dark_edition}Numbers{}",
                }
            },
            p_gem_number_mega = {
                name = "Mega Number Pack",
                text = {
                    "Choose {C:attention}#1#{} of up to",
                    "{C:attention}#2#{} {C:dark_edition}Numbers{}",
                }
            },
            gem_linked = {
                name = "Linked",
                text = {
                    "When another card of this set is",
                    "used or sold, {C:red}self destructs{}"
                },
            },
        },
    },
    misc = {
        dictionary = {
            k_plus_number = "+1 Number",
            
            k_gem_number = "Number",
            b_gem_number_cards = "Numbers",
            
            k_gem_letter = "Letter",

            zenith = "Saved...",
        },
        labels = {
            gem_number = "Number",
            gem_linked = "Linked",
            gem_letter = "Letter",
        },
    }
}

return loc_stuff