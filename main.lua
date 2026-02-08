local Numbergem = SMODS.current_mod

Numbergem.optional_features = {
    retrigger_joker = true,
    post_trigger = true,
    quantum_enhancements = true,
}

local function eventify(fn, count)
    if count and count > 1 then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0,
            blocking = true,
            func = function()
                eventify(fn, count - 1)
                return true
            end
        }))
    else
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.05,
            blocking = true,
            func = function()
                fn()
                return true
            end
        }))
    end
end

local function suppress_error_message(fn)
    -- lol ??
    -- this is so the hand limit api doesnt shout at me when you Five too much
    local sem = sendErrorMessage
    sendErrorMessage = function(message, logger, ...) end
    fn()
    sendErrorMessage = sem
end

-- I HATE THIS but its for Saving Purposes so its fine probably ...
Numbergem.end_of_rounds = {
    ["three"] = function(n)
        return function (self, context)
            suppress_error_message( function () 
                SMODS.change_play_limit(-n)
                SMODS.change_discard_limit(-n)
            end )

            return { message = "-3" }
        end
    end,
    ["four"] = function (n)
        return function (self, context)
            return { message = "-4", dollars = n }
        end
    end,
    ["five_money"] = function (n)
        return function (self, context)
            return { message = "Fived!", dollars = n }
        end
    end,
    ["five_csl_first"] = function (n)
        return function (self, context)
            suppress_error_message( function () 
                SMODS.change_play_limit(n)
                SMODS.change_discard_limit(-n)
            end )
            Numbergem.add_end_of_round("five_csl_second", 4)
            return { message = "Fived!" }
        end
    end,
    ["five_csl_second"] = function (n)
        return function (self, context)
            suppress_error_message( function () 
                SMODS.change_play_limit(n)
                SMODS.change_discard_limit(-n)
            end )
            Numbergem.add_end_of_round("five_csl_third", 5)
            return { message = "Fived!" }
        end
    end,
    ["five_csl_third"] = function (n)
        return function (self, context)
            suppress_error_message( function () 
                SMODS.change_play_limit(-n)
                SMODS.change_discard_limit(n)
            end )
            -- Numbergem.add_end_of_round("five_csl_fourth", 5)
            return { message = "Fived!" }
        end
    end,
    ["seven"] = function (n)
        return function (self, context)
            eventify ( function () 
                SMODS.add_card({ set = 'gem_Number', key = "c_gem_seven", edition = "e_negative" })
            end )
            return { message = "7" }
        end
    end,
    ["nine"] = function (n)
        return function (self, context)
            Numbergem.five(n)
            return { message = "9" }
        end
    end,
    ["fortyfive"] = function (n)
        return function (self, context)
            change_shop_size(-n)
            
            return { message = "-45" }
        end
    end,
    ["fortysix"] = function (n)
        return function (self, context)
            eventify( function () G.jokers.config.card_limit = G.jokers.config.card_limit - n end )
            
            return { message = "-46" }
        end
    end,
}

local start_run = Game.start_run
function Game:start_run(args)
    start_run(self, args)

    if not self.GAME.end_of_rounds then
        self.GAME.end_of_rounds = {}
    end
end

local d_eors = {}
local IS_END_OF_ROUNDING = false

Numbergem.add_end_of_round = function(fn, n)
    if not IS_END_OF_ROUNDING then
        G.GAME.end_of_rounds[#G.GAME.end_of_rounds + 1] = { fn, n }
    else
        d_eors[#d_eors + 1] = { fn, n }
    end
end


Numbergem.calculate = function(self, context)
    if context.end_of_round and context.main_eval then
        local effects = {}
        IS_END_OF_ROUNDING = true

        for _, fn in ipairs(G.GAME.end_of_rounds) do
            local fn = Numbergem.end_of_rounds[fn[1]](fn[2])
            local res = fn(self, context)
            if res then effects[#effects + 1] = res end
        end

        IS_END_OF_ROUNDING = false

        G.GAME.end_of_rounds = d_eors
        d_eors = {}

        return SMODS.merge_effects(effects)
    end
    -- somethingcom wtf is this SMODS.has_enhancement(v, "m_gem_redseal")
    if context.repetition and context.cardarea == G.play then
        local retriggers, my_pos, full_hand = {}, 0, context.scoring_hand or context.full_hand or G.play.cards
        for k, v in pairs(full_hand) do
            if v == context.other_card then
                my_pos = k
            end
            if SMODS.has_enhancement(v, "m_gem_redseal") then
                for kk, vv in pairs(full_hand) do
                    if vv ~= v then
                        retriggers[kk] = {repetitions = (retriggers[kk] and retriggers[kk].repetitions or 0) + 1}
                    end
                end
            end
        end
        if retriggers[my_pos] then
            return {repetitions = retriggers[my_pos].repetitions, message_card = context.other_card}
        end
    end
end

SMODS.Atlas({ 
    key = "numbers", 
    atlas_table = "ASSET_ATLAS", 
    path = "numbers.png",
    px = 71, 
    py = 95 
})

SMODS.ConsumableType({
    key = "gem_Number",
    primary_colour = HEX("d14f81"),
    secondary_colour = HEX("d14f81"),
    collection_rows = { 0, 1, 0 },
    shop_rate = 67, -- New Meme
    loc_txt = {},
    default = "c_gem_one",
    can_stack = true,
    can_divide = true,
})

-- SMODS.Booster {
--     key = "number_normal_1",
--     weight = 0.6,
--     kind = 'gem_Number',
--     cost = 4,
--     pos = { x = 0, y = 4 },
--     config = { extra = 5, choose = 1 },
--     group_key = "k_number_pack",
--     draw_hand = true,
--     loc_vars = function(self, info_queue, card)
--         local cfg = (card and card.ability) or self.config
--         return {
--             vars = { cfg.choose, cfg.extra },
--             key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end. Remove this if your booster doesn't have artwork variants like vanilla
--         }
--     end,
--     ease_background_colour = function(self)
--         ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
--     end,
--     create_card = function(self, card, i)
--         return {
--             set = "gem_Number",
--             area = G.pack_cards,
--             skip_materialize = true,
--             soulable = true,
--             key_append =
--             "gem_num"
--         }
--     end,
-- }

-- SMODS.Booster {
--     key = "number_normal_2",
--     weight = 0.6,
--     kind = 'gem_Number',
--     cost = 4,
--     pos = { x = 0, y = 4 },
--     config = { extra = 5, choose = 1 },
--     group_key = "k_number_pack",
--     draw_hand = true,
--     loc_vars = function(self, info_queue, card)
--         local cfg = (card and card.ability) or self.config
--         return {
--             vars = { cfg.choose, cfg.extra },
--             key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end. Remove this if your booster doesn't have artwork variants like vanilla
--         }
--     end,
--     ease_background_colour = function(self)
--         ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
--     end,
--     create_card = function(self, card, i)
--         return {
--             set = "gem_Number",
--             area = G.pack_cards,
--             skip_materialize = true,
--             soulable = true,
--             key_append =
--             "gem_num"
--         }
--     end,
-- }

-- SMODS.Booster {
--     key = "number_jumbo_1",
--     weight = 0.4,
--     kind = 'gem_Number',
--     cost = 6,
--     pos = { x = 0, y = 4 },
--     config = { extra = 8, choose = 1 },
--     group_key = "k_number_pack",
--     draw_hand = true,
--     loc_vars = function(self, info_queue, card)
--         local cfg = (card and card.ability) or self.config
--         return {
--             vars = { cfg.choose, cfg.extra },
--             key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end. Remove this if your booster doesn't have artwork variants like vanilla
--         }
--     end,
--     ease_background_colour = function(self)
--         ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
--     end,
--     create_card = function(self, card, i)
--         return {
--             set = "gem_Number",
--             area = G.pack_cards,
--             skip_materialize = true,
--             soulable = true,
--             key_append =
--             "gem_num"
--         }
--     end,
-- }

-- SMODS.Booster {
--     key = "number_mega_1",
--     weight = 0.4,
--     kind = 'gem_Number',
--     cost = 8,
--     pos = { x = 0, y = 4 },
--     config = { extra = 8, choose = 2 },
--     group_key = "k_number_pack",
--     draw_hand = true,
--     loc_vars = function(self, info_queue, card)
--         local cfg = (card and card.ability) or self.config
--         return {
--             vars = { cfg.choose, cfg.extra },
--             key = self.key:sub(1, -3), -- This uses the description key of the booster without the number at the end. Remove this if your booster doesn't have artwork variants like vanilla
--         }
--     end,
--     ease_background_colour = function(self)
--         ease_background_colour_blind(G.STATES.SPECTRAL_PACK)
--     end,
--     create_card = function(self, card, i)
--         return {
--             set = "gem_Number",
--             area = G.pack_cards,
--             skip_materialize = true,
--             soulable = true,
--             key_append =
--             "gem_num"
--         }
--     end,
-- }


SMODS.Consumable {
    key = 'zero',
    set = 'Spectral',
    soul_set = "gem_Number",
    pos = { x = 1, y = 0 },
    soul_pos = { x = 2, y = 0 },
    atlas = "gem_numbers",
    config = { extra = { numbers = 10 } },
    unlocked = true,
    discovered = true,
    no_collection = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.numbers } }
    end,
    use = function(self, card, area, copier)
        for i = 1, card.ability.extra.numbers do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('timpani')
                    SMODS.add_card({ set = 'gem_Number', edition = "e_negative" })
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'one',
    set = 'gem_Number',
    pos = { x = 3, y = 0 },
    atlas = "gem_numbers",
    config = { extra = { mult = 1 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
    keep_on_use = true,
    can_use = function(self, card)
        return card.area == G.pack_cards
    end
}

SMODS.Consumable {
    key = 'two',
    set = 'gem_Number',
    pos = { x = 4, y = 0 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    use = function(self, card, area, copier)
        local handname, _, _, _, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

        local chips = G.GAME.hands[handname]["chips"]
        local mult = G.GAME.hands[handname]["mult"]
        local mid = math.floor(chips + mult) / 2
        
        local chips_mod = math.floor(mid - chips)
        local mult_mod = math.floor(mid - mult)

        SMODS.upgrade_poker_hands {
            hands = { handname },
            func = function(n, hand, parameter)
                if parameter == "chips" then
                    return chips + chips_mod
                elseif parameter == "mult" then
                    return mult + mult_mod
                end
                return n
            end
        }

        eventify ( function () G.hand:unhighlight_all() end )
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= 1
    end
}

SMODS.Consumable {
    key = 'three',
    set = 'gem_Number',
    pos = { x = 5, y = 0 },
    atlas = "gem_numbers",
    config = { extra = { csl = 3 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.csl } }
    end,
    use = function(self, card, area, copier)
        suppress_error_message( function () 
            SMODS.change_play_limit(card.ability.extra.csl)
            SMODS.change_discard_limit(card.ability.extra.csl)
        end )

        local n = card.ability.extra.csl

        Numbergem.add_end_of_round ( "three", n )
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'four',
    set = 'gem_Number',
    pos = { x = 6, y = 0 },
    atlas = "gem_numbers",
    config = { extra = { money = 27 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money } }
    end,
    use = function(self, card, area, copier)
        local n = card.ability.extra.money

        ease_dollars(n)

        Numbergem.add_end_of_round ( "four", -n )
    end,
    can_use = function(self, card)
        return true
    end
}

Numbergem.five = function(times)
    local should_discard_hand = false
    if #G.hand.cards == 0 then
        SMODS.draw_cards(5)
        should_discard_hand = true
    else
        eventify( function()
            local any_selected = nil
            local _cards = {}
            for _, playing_card in ipairs(G.hand.cards) do
                _cards[#_cards + 1] = playing_card
            end
            for i = 1, 2 do
                if G.hand.cards[i] then
                    local selected_card, card_index = pseudorandom_element(_cards, 'five')
                    G.hand:add_to_highlighted(selected_card, true)
                    table.remove(_cards, card_index)
                    any_selected = true
                    play_sound('card1', 1)
                end
            end
            if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
        end, 2)
        eventify( function () SMODS.draw_cards(3) end, 3 )
    end
    
    eventify( function ()
        for _, enhancement in ipairs({"m_gold", "m_glass", "m_steel", "m_bonus", "m_mult", "m_lucky", "m_wild", "m_stone"}) do
            eventify( function () 
                local _cards = {}
                for _, playing_card in ipairs(G.hand.cards) do
                    if not playing_card.five_discarded then
                        _cards[#_cards + 1] = playing_card
                    end
                end
                if G.hand.cards[1] then
                    local selected_card, card_index = pseudorandom_element(_cards, 'five')
                    eventify( function()
                        play_sound('tarot1')
                        selected_card:juice_up(0.3, 0.5)
                    end )
                    eventify( function()
                        selected_card:flip()
                        play_sound('card1', 1.15)
                        selected_card:juice_up(0.3, 0.3)
                    end )
                    eventify( function()
                        selected_card:set_ability(enhancement)
                    end )
                    eventify( function()
                        selected_card:flip()
                        play_sound('card1', 1.15)
                        selected_card:juice_up(0.3, 0.3)
                    end )
                end
            end )
        end

        eventify( function ()
            for i = 1, 1 do
                for i = 1, #G.hand.cards do
                    local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            G.hand.cards[i]:flip()
                            play_sound('card1', percent)
                            G.hand.cards[i]:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand:shuffle('aajk')
                        play_sound('cardSlide1', 0.85)
                        return true
                    end,
                }))
                delay(0.15)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand:shuffle('aajk')
                        play_sound('cardSlide1', 1.15)
                        return true
                    end
                }))
                delay(0.15)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.hand:shuffle('aajk')
                        play_sound('cardSlide1', 1)
                        return true
                    end
                }))
                for i = 1, #G.hand.cards do
                    local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.15,
                        func = function()
                            G.hand.cards[i]:flip()
                            play_sound('tarot2', percent, 0.6)
                            G.hand.cards[i]:juice_up(0.3, 0.3)
                            return true
                        end
                    }))
                end
            end
            for i = 1, #G.hand.cards do
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('card1', percent)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
                local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.05,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('card1', percent)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
                local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.05,
                    func = function()
                        G.hand.cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        G.hand.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end
                }))
            end
        end )
    end, 5 )

    eventify( function() ease_dollars(5) end, 5)
    Numbergem.add_end_of_round( "five_money", -4 )
    suppress_error_message( function () 
        SMODS.change_play_limit(-1)
        SMODS.change_discard_limit(1)
    end )
    Numbergem.add_end_of_round( "five_csl_first", 2 )

    eventify( function()
        G.FUNCS.draw_from_hand_to_discard()
    end, 40 )
    eventify( function()
        G.deck:shuffle('wow')
    end, 40 )

    if times > 1 then eventify( function () Numbergem.five(times - 1) end, 11 ) end
end

SMODS.Consumable {
    key = 'five',
    set = 'gem_Number',
    pos = { x = 7, y = 0 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        Numbergem.five(1)
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'six',
    set = 'gem_Number',
    pos = { x = 8, y = 0 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        Numbergem.five(2)
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'seven',
    set = 'gem_Number',
    pos = { x = 9, y = 0 },
    atlas = "gem_numbers",
    config = { extra = { active = true } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card and card.ability.extra.active then
            card.ability.extra.active = false
            Numbergem.add_end_of_round ( "seven", 1 )
            return { message = localize("k_active_ex") }
        end
        if context.end_of_round then
            card.ability.extra.active = true
        end
    end,
    keep_on_use = true,
    can_use = function(self, card)
        return card.area == G.pack_cards
    end
}

SMODS.Consumable {
    key = 'eight',
    set = 'gem_Number',
    pos = { x = 0, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        card:set_edition({ polychrome = true }, true)
        eventify( function () 
            card:set_edition({ polychrome = true }, true)
        end )
        card:juice_up(0.3, 0.5)
    end,
    keep_on_use = function(self, card)
        return true
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'nine',
    set = 'gem_Number',
    pos = { x = 1, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { cost = 5 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cost } }
    end,
    use = function(self, card, area, copier)
        ease_dollars(-card.ability.extra.cost)
        Numbergem.add_end_of_round ( "nine", 5 )
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'ten',
    set = 'gem_Number',
    pos = { x = 2, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { balls = 6 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.balls } }
    end,
    use = function(self, card, area, copier)
        local cards = {}
        for i = 1, card.ability.extra.balls do
            local other_card = SMODS.add_card({ key = "j_8_ball", edition = "e_negative" })
            cards[#cards + 1] = other_card

            eventify( function () 
                if SMODS.pseudorandom_probability(card, 'ten_8ball', 1, 4) then
                    other_card:juice_up()
                    card_eval_status_text(other_card, 'extra', nil, 1, nil, localize('k_plus_tarot'))
                    SMODS.add_card {
                        set = 'Tarot',
                        key_append = 'ten_eight_ball'
                    }
                end
            end )
        end

        eventify( function () SMODS.destroy_cards(cards) end, 2 )
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'eleven',
    set = 'gem_Number',
    pos = { x = 3, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local leftmost_mult = 1
        for _, card in ipairs(G.consumeables.cards) do
            if card.config.center.key == "c_gem_one" then
                if leftmost_mult == 1 then
                    leftmost_mult = card.ability.extra.mult
                end
            end
        end
        for i = 1, 2 do
            local other_card = SMODS.add_card({ set = 'gem_Number', key = "c_gem_one" })
            other_card.ability.extra.mult = leftmost_mult
        end

        local total_mult = 0
        eventify( function()
            local cards = {}
            for _, card in ipairs(G.consumeables.cards) do
                if card.config.center.key == "c_gem_one" then
                    if total_mult ~= 0 then
                        cards[#cards + 1] = card
                    end
                    total_mult = total_mult + card.ability.extra.mult
                end
            end
            for _, card in ipairs(G.consumeables.cards) do
                if card.config.center.key == "c_gem_one" then
                    card.ability.extra.mult = total_mult
                    card:set_edition({ negative = true })
                end
            end
            SMODS.destroy_cards ( cards )
        end, 2)
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twelve',
    set = 'gem_Number',
    pos = { x = 4, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { timesmult = 1.8 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.timesmult }, key = card.area == G.jokers and 'c_gem_twelve_alt' or 'c_gem_twelve' }
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.area == G.jokers and context.cardarea == G.jokers then
            return {
                xmult = card.ability.extra.timesmult
            }
        end
    end,
    use = function(self, card, area, copier)
        if area == G.consumeables then
            G.consumeables:remove_card(card)
            G.jokers:emplace(card)
        end
    end,
    keep_on_use = function(self, card)
        return true
    end,
    can_use = function(self, card)
        return card.area ~= G.jokers
    end
}

SMODS.Consumable {
    key = 'thirteen',
    set = 'gem_Number',
    pos = { x = 5, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { timesmult = 1.8 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.timesmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.area == G.jokers and context.cardarea == G.jokers then
            return {
                xmult = card.ability.extra.timesmult
            }
        end
    end,
    use = function(self, card, area, copier)
        if area == G.consumeables then
            G.consumeables:remove_card(card)
            G.jokers:emplace(card)
            card:set_ability(G.P_CENTERS["c_gem_twelve"])
        end
    end,
    keep_on_use = function(self, card)
        return true
    end,
    can_use = function(self, card)
        return card.area ~= G.jokers
    end
}
function create_UIBox_fourteen(card)
    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = function()
            G.REFRESH_ALERTS = true
            return true
        end,
    }))
    local t = create_UIBox_generic_options({
        no_back = true,
        colour = HEX("04200c"),
        outline_colour = G.C.BLUE,
        contents = {
            {
                n = G.UIT.R,
                nodes = {
                    create_text_input({
                        colour = G.C.GREEN,
                        hooked_colour = darken(copy_table(G.C.GREEN), 0.3),
                        w = 4.5,
                        h = 1,
                        max_length = 2500,
                        extended_corpus = true,
                        prompt_text = "???",
                        ref_table = G,
                        ref_value = "NG_ENTERED_ACE",
                        keyboard_offset = 1,
                    }),
                },
            },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    UIBox_button({
                        colour = G.C.GREEN,
                        button = "c14",
                        label = { "run it" },
                        minw = 4.5,
                        focus_args = { snap_to = true },
                    }),
                },
            },
        },
    })
    return t
end
function create_UIBox_fourteen_two(card)
    G.E_MANAGER:add_event(Event({
        blockable = false,
        func = function()
            G.REFRESH_ALERTS = true
            return true
        end,
    }))
    local t = create_UIBox_generic_options({
        no_back = true,
        colour = HEX("04200c"),
        outline_colour = G.C.BLUE,
        contents = {
            {
                n = G.UIT.R,
                nodes = {
                    {n=G.UIT.T, config={text = "i cannot be bothered running that", scale = 0.6, colour = G.C.UI.WHITE, shadow = true}},
                },
            },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    UIBox_button({
                        colour = G.C.GREEN,
                        button = "c142",
                        label = { "heres 6 bucks" },
                        minw = 4.5,
                        focus_args = { snap_to = true },
                    }),
                },
            },
        },
    })
    return t
end

G.FUNCS.c14 = function()
    G.NG_CHOOSE_ACE:remove()
    G.NG_ENTERED_ACE = nil

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 5,
        blocking = true,
        func = function()
            G.NG_ENTERED_ACE = ""
            G.NG_CHOOSE_ACE = UIBox({
                definition = create_UIBox_fourteen_two(card),
                config = {
                    align = "bmi",
                    offset = { x = 0, y = G.ROOM.T.y + 29 },
                    major = G.jokers,
                    bond = "Weak",
                    instance_type = "POPUP",
                },
            })
            return true
        end
    }))

end

G.FUNCS.c142 = function()
    G.NG_CHOOSE_ACE:remove()
    G.NG_ENTERED_ACE = nil

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 2,
        blocking = true,
        func = function()
            ease_dollars(6)
            return true
        end
    }))

end

SMODS.Consumable {
    key = 'fourteen',
    set = 'gem_Number',
    pos = { x = 6, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card)
        G.NG_ENTERED_ACE = ""
        G.NG_CHOOSE_ACE = UIBox({
            definition = create_UIBox_fourteen(card),
            config = {
                align = "bmi",
                offset = { x = 0, y = G.ROOM.T.y + 29 },
                major = G.jokers,
                bond = "Weak",
                instance_type = "POPUP",
            },
        })
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fifteen',
    set = 'gem_Number',
    pos = { x = 7, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { cards = 3 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,
    use = function(self, card)
        eventify ( function () G.hand:unhighlight_all() end )
        -- pound of flesh modified
        local cards = {}
        for i, v in pairs(G.playing_cards) do if not SMODS.is_eternal(v) then cards[#cards+1] = v end end
        local num = card.ability.extra.cards
        pseudoshuffle(cards, "number_fifteen")
        for i = 1, num do
            local card = cards[i]
            card.area:remove_card(card)
            G.hand:emplace(card)
            delay(1)
            eventify( function() play_sound('timpani') end )
            SMODS.destroy_cards(card)
        end
        delay(2)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= 3
    end
}

SMODS.Consumable {
    key = 'sixteen',
    set = 'gem_Number',
    pos = { x = 8, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_cryptid")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'cryptid',
    pos = { x = 5, y = 5 },
    atlas = "Tarot",
    prefix_config = { atlas = false },
    weight = 0,
    config = { copies = 2 },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.copies } }
    end,
    no_mod_badges = true,
    calculate = function(self, card, context)
        -- vremade dna
        if context.main_scoring and context.cardarea == G.play then
            local cards = {}
            for i = 1, card.ability.copies do
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local card_copied = copy_card(context.full_hand[1], nil, nil, G.playing_card)
                cards[#cards + 1] = card_copied
                card_copied:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, card_copied)
                G.hand:emplace(card_copied)
                card_copied.states.visible = nil

                G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.25,
                blocking = true,
                    func = function()
                        card_copied:start_materialize()
                        return true
                    end
                }))
            end
            return {
                message = localize('k_copied_ex'),
                colour = G.C.CHIPS,
                func = function() -- This is for timing purposes, it runs after the message
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            SMODS.calculate_context({ playing_card_added = true, cards = cards })
                            return true
                        end
                    }))
                end
            }
        end
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
    end
}

SMODS.Consumable {
    key = 'seventeen',
    set = 'gem_Number',
    pos = { x = 9, y = 1 },
    atlas = "gem_numbers",
    config = { extra = { numbers = 2 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.numbers } }
    end,
    use = function(self, card, area, copier)
        for i = 1, math.min(card.ability.extra.numbers, G.consumeables.config.card_limit - #G.consumeables.cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        SMODS.add_card({ set = 'gem_Number' })
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return (G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit) or
            (card.area == G.consumeables)
    end
}
SMODS.Consumable {
    key = 'eighteen',
    set = 'gem_Number',
    pos = { x = 0, y = 2 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local sets = { "Planet", "Tarot", "Spectral", "soul", "Planet", "Tarot", "Spectral", "soul", "Planet", "Tarot", "Spectral", "soul" }
        for i = 1, math.min(4, G.consumeables.config.card_limit - #G.consumeables.cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        if sets[i] == "soul" then
                            SMODS.add_card({ key = "c_soul" })
                        else
                            SMODS.add_card({ set = sets[i] })
                        end
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return (G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit) or
            (card.area == G.consumeables)
    end
}

SMODS.Consumable {
    key = 'nineteen',
    set = 'gem_Number',
    pos = { x = 1, y = 2 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        for i = 1,200 do
            eventify( function () 
                play_sound('timpani', (i / 100) + 0.1, 0.5)
                G.deck.VT.y = G.deck.VT.y - 0.007
                G.deck.T.y = G.deck.T.y - 0.007
            end )
        end
        G.GAME.numbergem_times_upgraded = (G.GAME.numbergem_times_upgraded or 0) + 1
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twenty',
    set = 'gem_Number',
    pos = { x = 2, y = 2 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local suit_map = {
            ["Hearts"] = "Diamonds",
            ["Diamonds"] = "Spades",
            ["Spades"] = "Clubs",
            ["Clubs"] = "Hearts",
            -- compat for paperback and bunco
            ["paperback_Crowns"] = "paperback_Stars",
            ["paperback_Stars"] = "paperback_Crowns",
            ["bunc_Fleurons"] = "bunc_Halberds",
            ["bunc_Halberds"] = "bunc_Fleurons",
        }
        for _, v in pairs(G.playing_cards or {}) do
            if suit_map[v.base.suit] then
                SMODS.change_base(v, suit_map[v.base.suit])
            end
        end
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twentyone',
    set = 'gem_Number',
    pos = { x = 3, y = 2 },
    atlas = "gem_numbers",
    config = { extra = { max = 2 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.max } }
    end,
    use = function(self, card, area, copier)
        local money_gain = G.GAME.dollars ^ G.GAME.dollars - G.GAME.dollars
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                card:juice_up(0.3, 0.5)
                ease_dollars(math.max(0, math.min(money_gain, card.ability.extra.max)), true)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twentytwo',
    set = 'gem_Number',
    pos = { x = 4, y = 2 },
    atlas = "gem_numbers",
    config = { extra = { cards = 4 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,
    use = function(self, card, area, copier)
        local should_discard = #G.hand.cards == 0
        SMODS.draw_cards(card.ability.extra.cards)
        if should_discard then
            eventify( function()
                G.FUNCS.draw_from_hand_to_discard()
            end, 2 )
        end
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twentythree',
    set = 'gem_Number',
    pos = { x = 5, y = 2 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local handname, _, _, _, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

        SMODS.upgrade_poker_hands {
            hands = { handname }
        }

        eventify ( function () G.hand:unhighlight_all() end )
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= 1
    end
}

SMODS.Consumable {
    key = 'twentyfour',
    set = 'gem_Number',
    pos = { x = 6, y = 2 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        for i = 1, 1 do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('timpani')
                    SMODS.add_card({ set = 'gem_Number', edition = "e_negative" })
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twentyfive',
    set = 'gem_Number',
    pos = { x = 7, y = 2 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        play_sound('timpani')
        SMODS.add_card { key = pseudorandom_element({"j_zany", "j_mad", "j_crazy", "j_droll", "j_sly", "j_wily", "j_clever", "j_devious", "j_crafty"}, '25') }
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twentysix',
    set = 'gem_Number',
    pos = { x = 8, y = 2 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        eventify ( function () G.hand:unhighlight_all() end )
        -- pound of flesh modified
        local cards = {}
        for i, v in pairs(G.playing_cards) do cards[#cards+1] = v end
        local num = 1
        pseudoshuffle(cards, "number_twentysix")
        for i = 1, num do
            local card = cards[i]
            card:set_seal("Gold", nil, true)
        end
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twentyseven',
    set = 'gem_Number',
    pos = { x = 9, y = 2 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        eventify ( function () G.hand:unhighlight_all() end )
        -- pound of flesh modified
        local cards = {}
        for i, v in pairs(G.playing_cards) do cards[#cards+1] = v end
        local num = 1
        pseudoshuffle(cards, "number_twentyseven")
        for i = 1, num do
            local card = cards[i]
            card:set_seal("Red", nil, true)
        end
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'twentyeight',
    set = 'gem_Number',
    pos = { x = 0, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card then
            Numbergem.five(1)
        end
    end,
    keep_on_use = true,
    can_use = function(self, card)
        return card.area == G.pack_cards
    end
}

SMODS.Consumable {
    key = 'twentynine',
    set = 'gem_Number',
    pos = { x = 1, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_celestialpack")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'celestialpack',
    pos = { x = 0, y = 1 },
    atlas = "Booster",
    prefix_config = { atlas = false },
    weight = 0,
    config = { cards = 3 },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.cards } }
    end,
    no_mod_badges = true,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local effs = {}
            for i = 1, card.ability.cards do
                effs[#effs + 1] = {
                    message = localize("k_plus_planet"),
                    func = function ()
                        eventify( function () 
                            local planet_card = SMODS.add_card { 
                                set = "Planet",
                                edition = "e_negative",
                            }
                            planet_card.ability.gem_linked = true
                        end )
                    end
                }
            end
            return SMODS.merge_effects(effs)
        end
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
    end
}

SMODS.Sticker {
    key = "linked",
    badge_colour = HEX '721324',
    pos = { x = 99, y = 99 },
    rate = 0,
    no_collection = true,
    apply = function(self, card, val)
        card.ability[self.key] = val
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and context.consumeable.ability.set == card.ability.set and not context.consumeable.prevent_linked_loop then
            card.prevent_linked_loop = true
            SMODS.destroy_cards{card}
        end
        if context.selling_card and context.card.ability.set == card.ability.set and not context.card.prevent_linked_loop then
            card.prevent_linked_loop = true
            SMODS.destroy_cards{card}
        elseif context.joker_type_destroyed and context.card.ability.set == card.ability.set and not context.card.prevent_linked_loop then
            card.prevent_linked_loop = true
            SMODS.destroy_cards{card}
        end
    end
}

SMODS.Atlas({ 
    key = "letterjokers", 
    atlas_table = "ASSET_ATLAS", 
    path = "letterjokers.png",
    px = 71, 
    py = 78 
})

SMODS.Rarity {
    key = "letter",
    default_weight = 0,
    badge_colour = HEX("a9683b")
}

SMODS.ObjectType {
    key = "letter_joker_all"
}
SMODS.ObjectType {
    key = "letter_joker_vowel"
}
SMODS.ObjectType {
    key = "letter_joker_consonant"
}
SMODS.ObjectType {
    key = "letter_joker_low_value"
}
SMODS.ObjectType {
    key = "letter_joker_high_value"
}

local scmbs = SMODS.create_mod_badges

function SMODS.create_mod_badges(obj, badges, ...)
    if not SMODS.config.no_mod_badges and obj and obj.mod and obj.mod.display_name and not obj.no_mod_badges and
        obj.mod == SMODS.Mods.numbergem and obj.rarity and obj.rarity == "gem_letter" then
        local mods = {"Lettergem"}
        for i, mod in ipairs(mods) do
            local mod_name = "Lettergem"
            local size = 0.9
            local font = G.LANG.font
            local max_text_width = 2 - 2*0.05 - 4*0.03*size - 2*0.03
            local calced_text_width = 0
            -- Math reproduced from DynaText:update_text
            for _, c in utf8.chars(mod_name) do
                local tx = font.FONT:getWidth(c)*(0.33*size)*G.TILESCALE*font.FONTSCALE + 2.7*1*G.TILESCALE*font.FONTSCALE
                calced_text_width = calced_text_width + tx/(G.TILESIZE*G.TILESCALE)
            end
            local scale_fac = 1
                -- calced_text_width > max_text_width and max_text_width/calced_text_width
                -- or 1
            badges[#badges + 1] = {n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = HEX("a9683b"), r = 0.1, minw = 2, minh = 0.36, emboss = 0.05, padding = 0.03*size}, nodes={
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                  {n=G.UIT.O, config={object = DynaText({string = 'Lettergem', colours = {G.C.WHITE},float = true, shadow = true, offset_y = -0.05, silent = true, spacing = 1*scale_fac, scale = 0.33*size*scale_fac, marquee = false, maxw = max_text_width})}},
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                }}
            }}
        end
        return nil
    end
    scmbs(obj, badges, ...)
end

SMODS.Joker {
    key = "a",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        letter_joker_vowel = true,
        -- letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 0, y = 0 },
    config = { extra = { mult = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 14 then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.repetition and context.cardarea == G.play and context.other_card:get_id() == 14 then
            return {
                repetitions = 1
            }
        end
    end,
}

SMODS.Joker {
    key = "b",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 3 * 2,
    pos = { x = 1, y = 0 },
    config = { extra = { cost = 7 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cost } }
    end,
    calculate = function(self, card, context)
        if context.starting_shop and not card.ability.triggered then
            card.ability.triggered = true
            local other_card = SMODS.add_booster_to_shop("p_buffoon_normal_1")
            other_card.base_cost = card.ability.extra.cost
            other_card:set_cost()
            return nil, true
        end
        if context.end_of_round then card.ability.triggered = nil end
    end,
}

SMODS.Joker {
    key = "c",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    no_collection = true,
    rarity = "gem_letter",
    cost = 3 * 2,
    pos = { x = 2, y = 0 },
    config = { extra = { xmult = 5, counter = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult, card.ability.extra.counter } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            if context.other_card.ability and context.other_card.ability.effect == 'Stone Card' then
                card.ability.extra.counter = card.ability.extra.counter + (50 + card.ability.perma_bonus)
            else
                card.ability.extra.counter = card.ability.extra.counter + (context.other_card.base.nominal + context.other_card.ability.perma_bonus)
            end
            local effects = {}
            while card.ability.extra.counter >= 100 do
                card.ability.extra.counter = card.ability.extra.counter - 100
                effects[#effects + 1] = { xmult = card.ability.extra.xmult } 
            end
            return SMODS.merge_effects(effects)
        end
    end,
}

SMODS.Joker {
    key = "d",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 2 * 2,
    pos = { x = 3, y = 0 },
    config = { extra = { cards_per_round = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            local cards = {}
            for i, v in pairs(G.playing_cards) do if not SMODS.is_eternal(v) then cards[#cards+1] = v end end
            local num = card.ability.extra.cards_per_round
            pseudoshuffle(cards, "letter_d")
            for i = 1, num do
                local card = cards[i]
                card.area:remove_card(card)
                SMODS.destroy_cards(card)
            end
        end
    end,
}

SMODS.Joker {
    key = "e",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        letter_joker_vowel = true,
        -- letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 4, y = 0 },
    config = { extra = { emult = 1.4 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.emult } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            if Talisman or Cryptid then
                return {
                    emult = card.ability.extra.emult
                }
            else
                return {
                    message = "^"..card.ability.extra.emult.." Mult",
                    colour = G.C.DARK_EDITION,
                    func = function()
                        mult = mod_mult(mult ^ card.ability.extra.emult)
                    end
                }
            end
        end
    end,
}

SMODS.Joker {
    key = "f",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 4 * 2,
    pos = { x = 5, y = 0 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = { HEX "a9683b" } } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            local jokers_to_create = math.min(1,
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, jokers_to_create do
                        SMODS.add_card {
                            set = 'letter_joker_all',
                        }
                        G.GAME.joker_buffer = 0
                    end
                    return true
                end
            }))
            return {
                message = localize('k_plus_joker'),
                colour = G.C.BLUE,
            }
        end
    end,
}

SMODS.Sound {
    key = "g_riff",
    path = "g.ogg",
    pitch = 1.0
}

SMODS.Joker {
    key = "g",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 2 * 2,
    pos = { x = 6, y = 0 },
    config = { extra = { xmult = 1.01 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            return {
                message = "G",
                colour = G.C.DARK_EDITION,
                sound = "gem_g_riff",
                pitch = 1,
            }
        end
        if context.individual and context.cardarea == G.play then
            return {
                message = "G",
                colour = G.C.DARK_EDITION,
                remove_default_message = true,
                xmult = card.ability.extra.xmult,
                sound = "gem_g_riff",
                pitch = 1,
            }
        end
    end,
}

SMODS.Joker {
    key = "h",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 4 * 2,
    pos = { x = 7, y = 0 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card ~= context.scoring_hand[1] then
            return {
                repetitions = 1
            }
        end
    end,
}

SMODS.Joker {
    key = "i",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        letter_joker_vowel = true,
        -- letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 8, y = 0 },
    config = { extra = { straight_mult = 2 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.straight_mult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            for _, hand in pairs(context.poker_hands["Straight"]) do
                if #hand >= 5 then
                    return {
                        xmult = card.ability.extra.straight_mult
                    }
                end
            end
        end
    end,
}

local smods_four_fingers_ref = SMODS.four_fingers
function SMODS.four_fingers(hand_type)
    local val = smods_four_fingers_ref(hand_type)
    if next(SMODS.find_card('j_gem_i')) and hand_type == "straight" then
        return math.max(1, val - 2)
    end
    return val
end

SMODS.Joker {
    key = "j",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        -- letter_joker_low_value = true,
        letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 8 * 2,
    pos = { x = 0, y = 1 },
    config = { extra = { money_per = 0.5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money_per } }
    end,
    calculate = function(self, card, context)
        if context.retrigger_joker_check then
            for i = 1, #G.jokers.cards do
                if (G.jokers.cards[i] == card and G.jokers.cards[i + 1] == context.other_card) or
                (G.jokers.cards[i] == card and G.jokers.cards[i + 2] == context.other_card) then
                    return {
                        repetitions = 1
                    }
                end
            end
        end
        if context.post_trigger then
            for i = 1, #G.jokers.cards do
                if (G.jokers.cards[i] == card and G.jokers.cards[i + 1] == context.other_card) or
                (G.jokers.cards[i] == card and G.jokers.cards[i + 2] == context.other_card) then
                    return {
                        dollars = -card.ability.extra.money_per
                    }
                end
            end
        end
    end,
}

SMODS.Joker {
    key = "k",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        -- letter_joker_low_value = true,
        letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 5 * 2,
    pos = { x = 1, y = 1 },
    config = { extra = { odds = 500 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            local other_card = SMODS.add_card {
                set = 'Joker',
                key = 'j_cavendish',
                edition = "e_negative",
            }
            other_card.ability.extra.odds = math.floor(other_card.ability.extra.odds / card.ability.extra.odds)
            return {
                message = localize('k_plus_joker'),
                colour = G.C.BLUE,
            }
        end
    end,
}

SMODS.Joker {
    key = "l",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 2, y = 1 },
    config = { extra = { odds = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.check_enhancement and #G.play.cards > 0 then
            local _, _, _, scoring_hand = G.FUNCS.get_poker_hand_info(G.play.cards)
            if context.other_card == scoring_hand[1] then
                return {
                    m_lucky = true,
                }
            end
        end
        if context.mod_probability and #G.play.cards > 0 then
            local _, _, _, scoring_hand = G.FUNCS.get_poker_hand_info(G.play.cards)
            if context.trigger_obj == scoring_hand[1] then
                return {
                    numerator = context.numerator * card.ability.extra.odds,
                    denominator = context.denominator
                }
            end
        end
    end,
}

SMODS.Joker {
    key = "m",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 3 * 2,
    pos = { x = 3, y = 1 },
    config = { extra = { price = 3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.price } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
            local jokers_to_create = math.min(1,
                G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer))
            G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, jokers_to_create do
                        local other_card = SMODS.add_card {
                            set = 'Joker',
                            key = 'j_jolly',
                        }
                        other_card.ability.extra_value = (other_card.ability.extra_value or 0) + card.ability.extra.price
                        other_card:set_cost()
                        G.GAME.joker_buffer = 0
                    end
                    return true
                end
            }))
            return {
                message = localize('k_plus_joker'),
                colour = G.C.BLUE,
            }
        end
    end,
}

SMODS.Joker {
    key = "n",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 4, y = 1 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and context.blind.boss then
            SMODS.add_card {
                set = 'Joker',
                key = 'j_gem_vremade_joker',
                edition = "e_negative",
            }
            return {
                message = localize('k_plus_joker'),
                colour = G.C.BLUE,
            }
        end
    end,
}

SMODS.Joker {
    key = "vremade_joker",
    pos = { x = 0, y = 0 },
    rarity = 1,
    blueprint_compat = true,
    cost = 2,
    discovered = true,
    no_collection = true,
    config = { extra = { mult = 4 }, },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end,
    in_pool = function(self, args)
        return false
    end,
    no_mod_badges = true,
}

SMODS.Joker {
    key = "o",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        letter_joker_vowel = true,
        -- letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 5, y = 1 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.fix_probability then
            return {
                numerator = 1,
                denominator = 2,
            }
        end
    end,
}

SMODS.Joker {
    key = "p",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 3 * 2,
    pos = { x = 6, y = 1 },
    config = { extra = { per_ante = 0.9 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.per_ante, card.ability.extra.per_ante ^ G.GAME.round_resets.ante } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not card.getting_sliced then
            local amount = G.GAME.blind.chips * (card.ability.extra.per_ante ^ G.GAME.round_resets.ante)
            amount = amount - amount%(10^math.floor(math.log10(amount)-1))
            G.GAME.blind.chips = amount
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            return {
                message = "Reduced!"
            }
        end
    end,
}

SMODS.Joker {
    key = "q",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        -- letter_joker_low_value = true,
        letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 10 * 2,
    pos = { x = 7, y = 1 },
    config = { extra = { xmult = 1.3 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                local is_adjacent = false
                for i = 1, #G.hand.cards do
                    if (G.hand.cards[i]:get_id() == 12 and G.hand.cards[i - 1] == context.other_card) or
                    (G.hand.cards[i]:get_id() == 12 and G.hand.cards[i + 1] == context.other_card) then
                        return {
                            x_mult = card.ability.extra.xmult
                        }
                    end
                end
                
            end
        end
    end,
}

SMODS.Joker {
    key = "r",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 8, y = 1 },
    config = { extra = { rounds_per = 1, mult_per = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_per, card.ability.extra.mult_per, card.ability.extra.mult_per * G.GAME.round } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            eventify( function() ease_round( card.ability.extra.rounds_per ) end )
            return {
                message = "+"..card.ability.extra.rounds_per.." Rounds"
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult_per * (G.GAME.round or 0)
            }
        end
    end,
}

SMODS.Joker {
    key = "s",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 0, y = 2 },
    config = { extra = { chips = 6, mult = 7 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.individual and not context.end_of_round and 
            (context.cardarea == G.play or context.cardarea == G.hand) and
            (context.other_card:get_id() == 6 or context.other_card:get_id() == 7) then
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult
            }
        end
    end,
}

SMODS.Joker {
    key = "t",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 1, y = 2 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.hand_drawn then
            local extra_cards = 0
            for _, other_card in pairs(context.hand_drawn) do
                if SMODS.has_enhancement(other_card, 'm_wild') then
                    extra_cards = extra_cards + 1
                end
            end
            if extra_cards > 0 then SMODS.draw_cards(extra_cards) end
        end
        if context.other_drawn then
            local extra_cards = 0
            for _, other_card in pairs(context.other_drawn) do
                if SMODS.has_enhancement(other_card, 'm_wild') then
                    extra_cards = extra_cards + 1
                end
            end
            if extra_cards > 0 then SMODS.draw_cards(extra_cards) end
        end
    end,
}

SMODS.Joker {
    key = "u",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        letter_joker_vowel = true,
        -- letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 1 * 2,
    pos = { x = 2, y = 2 },
    config = { extra = { mult = 13 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.modify_scoring_hand and not context.blueprint then
            return {
                remove_from_hand = true,
            }
        end
        if context.joker_main then
            local effects = {}
            for _, other_card in ipairs(G.play.cards) do
                if not other_card.debuff then
                    effects[#effects + 1] = {
                        mult = card.ability.extra.mult,
                        message_card = other_card
                    }
                end
            end
            return SMODS.merge_effects(effects)
        end
    end,
}

SMODS.Joker {
    key = "v",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 4 * 2,
    pos = { x = 3, y = 2 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.buying_card then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag('tag_voucher'))
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end)
            }))
            return nil, true -- This is for Joker retrigger purposes
        end
    end,
}

SMODS.Joker {
    key = "w",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 4 * 2,
    pos = { x = 4, y = 2 },
    config = { extra = { odds = 0.8 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                func = (function()
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local other_card = SMODS.add_card {
                                -- set = 'Joker',
                                key = 'c_wheel_of_fortune',
                            }
                            other_card.ability.extra = math.floor(other_card.ability.extra / card.ability.extra.odds)
                            G.GAME.consumeable_buffer = 0
                            return true
                        end
                    }))
                    SMODS.calculate_effect({ message = localize('k_plus_tarot'), colour = G.C.PURPLE },
                        context.blueprint_card or card)
                    return true
                end)
            }))
            return nil, true -- This is for Joker retrigger purposes
        end
    end,
}

SMODS.Joker {
    key = "x",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        -- letter_joker_low_value = true,
        letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 8 * 2,
    pos = { x = 5, y = 2 },
    config = { extra = { current_increase = 0, scale_increase = 0.02 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.current_increase, card.ability.extra.scale_increase } }
    end,
    calculate = function(self, card, context)
    end,
}

local scalcieff = SMODS.calculate_individual_effect
SMODS.calculate_individual_effect = function(effect, scored_card, key, amount, from_edition)
    if key == "x_mult" or key == "xmult" or key == "Xmult" or key == "x_mult_mod" or key == "Xmult_mod" then
        local bonus = 0
        for _, card in ipairs(SMODS.find_card("j_gem_x")) do
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = "current_increase",
                scalar_value = "scale_increase"
            })
            bonus = bonus + card.ability.extra.current_increase
        end
        amount = amount + bonus
    end
    return scalcieff(effect, scored_card, key, amount, from_edition)
end

SMODS.Joker {
    key = "y",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        letter_joker_vowel = true,
        letter_joker_consonant = true, -- lol?
        letter_joker_low_value = true,
        -- letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 4 * 2,
    pos = { x = 6, y = 2 },
    config = { extra = { dollars = 10, card_total = 13, cards_scored = 0 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.card_total, card.ability.extra.cards_scored } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.cards_scored = card.ability.extra.cards_scored + 1
            local effects = {}
            while card.ability.extra.cards_scored >= card.ability.extra.card_total do
                card.ability.extra.cards_scored = card.ability.extra.cards_scored - card.ability.extra.card_total
                effects[#effects + 1] = { dollars = card.ability.extra.dollars } 
            end
            return SMODS.merge_effects(effects)
        end
    end,
}

SMODS.Joker {
    key = "z",
    atlas = "gem_letterjokers",
    display_size = { h = 78 },
    pools = {
        letter_joker_all = true,
        -- letter_joker_vowel = true,
        letter_joker_consonant = true,
        -- letter_joker_low_value = true,
        letter_joker_high_value = true,
    },
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    no_collection = true,
    rarity = "gem_letter",
    cost = 10 * 2,
    pos = { x = 7, y = 2 },
    config = { extra = { } },
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.game_over and context.main_eval and #G.playing_cards >= 13 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('tarot1')
                    return true
                end
            }))
            local cards = {}
            for i, v in pairs(G.playing_cards) do if not SMODS.is_eternal(v) then cards[#cards+1] = v end end
            local num = 13
            pseudoshuffle(cards, "letter_d")
            for i = 1, num do
                local card = cards[i]
                card.area:remove_card(card)
                SMODS.destroy_cards(card)
            end
            return {
                message = localize('k_saved_ex'),
                saved = 'zenith',
                colour = G.C.RED
            }
        end
    end,
}

SMODS.Consumable {
    key = 'thirty',
    set = 'gem_Number',
    pos = { x = 2, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = { HEX "a9683b" } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'letter_joker_all' })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end
}

SMODS.Consumable {
    key = 'thirtyone',
    set = 'gem_Number',
    pos = { x = 3, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = { HEX "a9683b" } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'letter_joker_vowel' })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end
}

SMODS.Consumable {
    key = 'thirtytwo',
    set = 'gem_Number',
    pos = { x = 4, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = { HEX "a9683b" } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'letter_joker_consonant' })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end
}

SMODS.Consumable {
    key = 'thirtythree',
    set = 'gem_Number',
    pos = { x = 5, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = { HEX "a9683b" } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'letter_joker_low_value' })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end
}

SMODS.Consumable {
    key = 'thirtyfour',
    set = 'gem_Number',
    pos = { x = 6, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { colours = { HEX "a9683b" } } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'letter_joker_high_value' })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end
}

SMODS.Consumable {
    key = 'thirtyfive',
    set = 'gem_Number',
    pos = { x = 7, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_polychrome")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'polychrome',
    pos = { x = 1, y = 0 },
    atlas = "centers",
    prefix_config = { atlas = false },
    weight = 0,
    config = { x_mult = 1.5 },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.x_mult } }
    end,
    no_mod_badges = true,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('polychrome', nil, card.ARGS.send_to_shader)
        end
    end
}

SMODS.Consumable {
    key = 'thirtysix',
    set = 'gem_Number',
    pos = { x = 8, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_space_joker")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'space_joker',
    pos = { x = 3, y = 5 },
    atlas = "Joker",
    prefix_config = { atlas = false },
    weight = 0,
    config = { extra = { odds = 4 } },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'space_joker_enh')
        return { vars = { numerator, denominator } }
    end,
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.play and SMODS.pseudorandom_probability(card, 'space_joker_enh', 1, card.ability.extra.odds) then
            return {
                level_up = true,
                message = localize('k_level_up_ex')
            }
        end
    end,
    no_mod_badges = true,
}

SMODS.Consumable {
    key = 'thirtyseven',
    set = 'gem_Number',
    pos = { x = 9, y = 3 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_spectralpack")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'spectralpack',
    pos = { x = 0, y = 4 },
    atlas = "Booster",
    prefix_config = { atlas = false },
    weight = 0,
    config = { cards = 1 },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.cards } }
    end,
    no_mod_badges = true,
    display_size = { w = 71 * 0.7, h = 95 * 0.7 },
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local effs = {}
            for i = 1, card.ability.cards do
                effs[#effs + 1] = {
                    message = localize("k_plus_spectral"),
                    func = function ()
                        eventify( function () 
                            local planet_card = SMODS.add_card { 
                                set = "Spectral",
                                edition = "e_negative",
                            }
                            planet_card.ability.gem_linked = true
                        end )
                    end
                }
            end
            return SMODS.merge_effects(effs)
        end
    end,
    draw = function(self, card, layer)
        if (layer == 'card' or layer == 'both') and card.sprite_facing == 'front' then
            card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
        end
    end
}

SMODS.Consumable {
    key = 'thirtyeight',
    set = 'gem_Number',
    pos = { x = 0, y = 4 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_anaglyphdeck")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'anaglyphdeck',
    pos = { x = 2, y = 4 },
    atlas = "centers",
    prefix_config = { atlas = false },
    weight = 0,
    config = { },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    no_mod_badges = true,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag('tag_double'))
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end)
            }))
            return nil, true -- This is for Joker retrigger purposes
        end
    end,
}

SMODS.Consumable {
    key = 'thirtynine',
    set = 'gem_Number',
    pos = { x = 1, y = 4 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local handname, _, _, _, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

        local money = G.GAME.dollars
        local mult = G.GAME.hands[handname]["mult"]
        local mid = math.floor(money + mult) / 2
        
        local money_mod = math.floor(mid - money)
        local mult_mod = math.floor(mid - mult)

        SMODS.upgrade_poker_hands {
            hands = { handname },
            func = function(n, hand, parameter)
                if parameter == "mult" then
                    return mult + mult_mod
                end
                return n
            end
        }

        ease_dollars( money_mod )

        eventify ( function () G.hand:unhighlight_all() end )
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= 1
    end
}

SMODS.Consumable {
    key = 'forty',
    set = 'gem_Number',
    pos = { x = 2, y = 4 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local handname, _, _, _, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

        local money = G.GAME.dollars
        local chips = G.GAME.hands[handname]["chips"]
        local mid = math.floor(money + chips) / 2
        
        local money_mod = math.floor(mid - money)
        local chips_mod = math.floor(mid - chips)

        SMODS.upgrade_poker_hands {
            hands = { handname },
            func = function(n, hand, parameter)
                if parameter == "chips" then
                    return chips + chips_mod
                end
                return n
            end
        }

        ease_dollars( money_mod )

        eventify ( function () G.hand:unhighlight_all() end )
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= 1
    end
}

SMODS.Consumable {
    key = 'fortyone',
    set = 'gem_Number',
    pos = { x = 3, y = 4 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local cards = {}
        local len = #G.hand.cards
        for i = 1, len do
            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
            local card_copied = copy_card(G.hand.cards[i], nil, nil, G.playing_card)
            cards[#cards + 1] = card_copied
            card_copied:add_to_deck()
            G.deck.config.card_limit = G.deck.config.card_limit + 1
            table.insert(G.playing_cards, card_copied)
            G.hand:emplace(card_copied)
            card_copied.states.visible = nil

            G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.25,
            blocking = true,
                func = function()
                    card_copied:start_materialize()
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            func = function()
                SMODS.calculate_context({ playing_card_added = true, cards = cards })
                return true
            end
        }))
    end,
    can_use = function(self, card)
        return #G.hand.cards >= 1
    end
}


SMODS.Consumable {
    key = 'fortytwo',
    set = 'gem_Number',
    pos = { x = 4, y = 4 },
    atlas = "gem_numbers",
    config = { extra = { xchips = 1.2 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1, card.ability.extra.xchips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                xchips = card.ability.extra.xchips
            }
        end
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_fortytwo")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'fortytwo',
    pos = { x = 4, y = 4 },
    atlas = "gem_numbers",
    -- prefix_config = { atlas = false },
    weight = 0,
    config = { h_x_chips = 1.2 },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    -- no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1, card.ability.h_x_chips } }
    end,
    no_mod_badges = true,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local _cards = {}
            for _, playing_card in ipairs(G.hand.cards) do
                if not SMODS.has_enhancement(playing_card, 'm_gem_fortytwo') then
                    _cards[#_cards + 1] = playing_card
                end
            end
            if G.hand.cards[1] and _cards[1] then
                local selected_card, card_index = pseudorandom_element(_cards, '42')
                eventify( function()
                    play_sound('tarot1')
                    selected_card:juice_up(0.3, 0.5)
                end )
                eventify( function()
                    selected_card:flip()
                    play_sound('card1', 1.15)
                    selected_card:juice_up(0.3, 0.3)
                end )
                eventify( function()
                    selected_card:set_ability("m_gem_fortytwo")
                end )
                eventify( function()
                    selected_card:flip()
                    play_sound('card1', 1.15)
                    selected_card:juice_up(0.3, 0.3)
                end )
            end
        end
    end,
}

SMODS.Consumable {
    key = 'fortythree',
    set = 'gem_Number',
    pos = { x = 5, y = 4 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        for i = 1, 4 do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    local money_gain_once = G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)
                    play_sound('timpani')
                    card:juice_up(0.3, 0.5)
                    ease_dollars(money_gain_once)
                    return true
                end
            }))
        end
        delay(0.6)
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fortyfour',
    set = 'gem_Number',
    pos = { x = 6, y = 4 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    use = function(self, card, area, copier)
        local handname, _, _, _, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

        local chips = G.GAME.hands[handname]["chips"]
        local mult = G.GAME.hands[handname]["mult"]
        
        local chips_mod = math.floor(mult - chips)
        local mult_mod = math.floor(chips - mult)

        SMODS.upgrade_poker_hands {
            hands = { handname },
            func = function(n, hand, parameter)
                if parameter == "chips" then
                    return chips + chips_mod
                elseif parameter == "mult" then
                    return mult + mult_mod
                end
                return n
            end
        }

        eventify ( function () G.hand:unhighlight_all() end )
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= 1
    end
}

SMODS.Consumable {
    key = 'fortyfive',
    set = 'gem_Number',
    pos = { x = 7, y = 4 },
    atlas = "gem_numbers",
    config = { extra = { shop_slots = 3 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.shop_slots } }
    end,
    use = function(self, card, area, copier)
        change_shop_size(card.ability.extra.shop_slots)

        local n = card.ability.extra.shop_slots

        Numbergem.add_end_of_round ( "fortyfive", n )
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fortysix',
    set = 'gem_Number',
    pos = { x = 8, y = 4 },
    atlas = "gem_numbers",
    config = { extra = { joker_slots = 2 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.joker_slots } }
    end,
    use = function(self, card, area, copier)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.joker_slots

        local n = card.ability.extra.joker_slots

        Numbergem.add_end_of_round ( "fortysix", n )
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fortyseven',
    set = 'gem_Number',
    pos = { x = 9, y = 4 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_smileyface")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'smileyface',
    pos = { x = 6, y = 15 },
    atlas = "Joker",
    prefix_config = { atlas = false },
    weight = 0,
    config = { extra = { mult = 5 } },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local effs = {}
            for _, other_card in ipairs(G.play.cards) do
                if other_card:is_face(false) then
                    effs[#effs + 1] = {
                        mult = card.ability.extra.mult,
                        card = other_card
                    }
                end
            end
            return SMODS.merge_effects(effs)
        end
    end,
    no_mod_badges = true,
}

local card_is_face_ref = Card.is_face
function Card:is_face(from_boss)
    return card_is_face_ref(self, from_boss) or (SMODS.has_enhancement(self, 'm_gem_smileyface'))
end

SMODS.Consumable {
    key = 'fortyeight',
    set = 'gem_Number',
    pos = { x = 0, y = 5 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local ante = G.GAME.round_resets.ante
        local money = G.GAME.dollars
        local mid = math.floor(ante + money) / 2
        
        local ante_mod = math.floor(mid - ante)
        local money_mod = math.floor(mid - money)

        ease_ante(ante_mod)
        ease_dollars(money_mod)
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante + ante_mod
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fortynine',
    set = 'gem_Number',
    pos = { x = 1, y = 5 },
    atlas = "gem_numbers",
    config = { extra = {} },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local handname, _, _, _, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)

        local concat = G.GAME.hands[handname].played
        local times = 10^(math.floor(math.log10(concat)) + 1)
        if concat == 0 then times = 10 end

        local chips = G.GAME.hands[handname]["chips"]
        local mult = G.GAME.hands[handname]["mult"]

        SMODS.upgrade_poker_hands {
            hands = { handname },
            func = function(n, hand, parameter)
                if parameter == "chips" then
                    return chips * times + concat
                elseif parameter == "mult" then
                    return mult * times + concat
                end
                return n
            end
        }

        eventify ( function () G.hand:unhighlight_all() end )
    end,
    can_use = function(self, card)
        return #G.hand.highlighted >= 1
    end
}

SMODS.Consumable {
    key = 'fifty',
    set = 'gem_Number',
    pos = { x = 2, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { money_per_round = 1 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.money_per_round } }
    end,
    use = function(self, card, area, copier)
        local round = (G.GAME.round or 0)
        local times = 10^(math.floor(math.log10(round)) + 1)
        if concat == 0 then times = 10 end

        local dollars = (math.floor(math.log10(round)) + 1) * 2
        if round == 0 then dollars = 1 end
        if round == inf or dollars > 308 then dollars = 308 end

        ease_round(round * times)
        ease_dollars(dollars * card.ability.extra.money_per_round)
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fiftyone',
    set = 'gem_Number',
    pos = { x = 3, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { my_rerolls = 0, rerolls_per = 2 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rerolls_per, card.ability.extra.my_rerolls } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card then
            card.ability.extra.my_rerolls = card.ability.extra.my_rerolls + card.ability.extra.rerolls_per
            return {
                message = localize("k_upgrade_ex")
            }
        end
    end,
    use = function(self, card, area, copier)
        if card.ability.extra.my_rerolls > 0 then
            G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls + card.ability.extra.my_rerolls, 0)
            calculate_reroll_cost(true)
        end
    end,
    can_use = function(self, card)
        return card.ability.extra.my_rerolls > 0
    end
}

SMODS.Consumable {
    key = 'fiftyone',
    set = 'gem_Number',
    pos = { x = 3, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { my_rerolls = 0, rerolls_per = 2 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rerolls_per, card.ability.extra.my_rerolls } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card then
            card.ability.extra.my_rerolls = card.ability.extra.my_rerolls + card.ability.extra.rerolls_per
            return {
                message = localize("k_upgrade_ex")
            }
        end
    end,
    use = function(self, card, area, copier)
        if card.ability.extra.my_rerolls > 0 then
            G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls + card.ability.extra.my_rerolls, 0)
            calculate_reroll_cost(true)
        end
    end,
    can_use = function(self, card)
        return card.ability.extra.my_rerolls > 0
    end
}

SMODS.Consumable {
    key = 'fiftytwo',
    set = 'gem_Number',
    pos = { x = 4, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { dollars = 10 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    use = function(self, card, area, copier)
        BATTLES.battle_intro_timer = 2.0
        ease_dollars(card.ability.extra.dollars)
    end,
    can_use = function(self, card)
        return true
    end
}
_G.BATTLES = {}

BATTLES.battle_intro_timer = -1
BATTLES.battle_timer = 0
BATTLES.ui_offset_from_bottom_of_screen = 0
BATTLES.state = 0
BATTLES.SWOON_FADE_OUT = 0.

SMODS.Sound({
	key = "music_john",
	path = "music_john.ogg",
    pitch = 1.0,
    volume = 1.0,
    sync = false,
	select_music_track = function()
		return (
      G.GAME.in_battle
    )
	end,
})

local sounds = {
  "snd_tensionhorn",
  "snd_weaponpull",
  "snd_swoon",
}

for _, v in pairs(sounds) do
  SMODS.Sound({
    key = v,
    path = v..".ogg",
  })
end

local images = {}

local img_paths = {
    ["fight"] = Numbergem.path .. "/gurt/unsuspicious/subfolders/dontworry/fight.png",
    ["john"] = Numbergem.path .. "/gurt/unsuspicious/subfolders/dontworry/john.png",
    ["johnaura"] = Numbergem.path .. "/gurt/unsuspicious/subfolders/dontworry/johnaura.png",
    ["swoon"] = Numbergem.path .. "/gurt/unsuspicious/subfolders/dontworry/swoon.png",
}

for k, v in pairs(img_paths) do
    -- from yahimod lol
    local file_data = assert(NFS.newFileData(v),("Epic fail"))
    local tempimagedata = assert(love.image.newImageData(file_data),("Epic fail 2"))
    --print ("LTFNI: Successfully loaded " .. fn)
    images[k] = (assert(love.graphics.newImage(tempimagedata),("Epic fail 3")))
end

function crossed_thresh ( val, dt, thresh )
  return val < thresh and val + dt > thresh
end

local loveupdatehook = love.update
function love.update( dt )
  if BATTLES.battle_intro_timer > 0 then
    BATTLES.battle_intro_timer = BATTLES.battle_intro_timer - dt
    if crossed_thresh(BATTLES.battle_intro_timer, dt, 1.4) then
      play_sound('gem_snd_tensionhorn', 1, 0.8)
    end
    if crossed_thresh(BATTLES.battle_intro_timer, dt, 1.1) then
      play_sound('gem_snd_tensionhorn', 1.1, 0.8)
    end
    if crossed_thresh(BATTLES.battle_intro_timer, dt, 0.5) then
      play_sound('gem_snd_weaponpull', 1.0, 0.8)
    end
    if BATTLES.battle_intro_timer <= 0 then
      G.GAME.in_battle = true
      BATTLES.battle_timer = 0
      BATTLES.ui_offset_from_bottom_of_screen = 0
    end
  end
  loveupdatehook( dt )
  if G.GAME.in_battle then
    BATTLES.battle_timer = BATTLES.battle_timer + dt

    local width, height = love.graphics.getDimensions()

    local target_battle_ui_height_thingy = 0.3
    BATTLES.ui_offset_from_bottom_of_screen =
      BATTLES.ui_offset_from_bottom_of_screen +
        (
          target_battle_ui_height_thingy - BATTLES.ui_offset_from_bottom_of_screen
        ) * (1 - math.pow(0.01, dt))
  end
end

local lovedrawhook = love.draw
function love.draw()
    lovedrawhook()

    if G.GAME.in_battle then
        local coverup_opacity = math.min(BATTLES.battle_timer * 7, 0.7)
        local width, height = love.graphics.getDimensions()

        love.graphics.setColor(0,0,0.1,coverup_opacity)
        love.graphics.rectangle("fill",0,0,width,height)

        -- local xmult = math.sin(BATTLES.battle_timer * 1.6) * 0.2 + 0.4
        -- love.graphics.setColor(1,1,1,math.sin(BATTLES.battle_timer * 1.5) * 0.1 + 0.3)
        -- love.graphics.polygon("fill", {
        --     0, 0,
        --     width * xmult * 2, height,
        --     width * xmult, height,
        -- })
        -- love.graphics.polygon("fill", {
        --     width, 0,
        --     width * ( 1 - xmult * 2 ), height,
        --     width * ( 1 - xmult     ), height,
        -- })

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill",0,height * (1 - BATTLES.ui_offset_from_bottom_of_screen),width,height * (BATTLES.ui_offset_from_bottom_of_screen))
        love.graphics.setColor(1,0,0,1)
        love.graphics.rectangle("fill",0,height * (1 - BATTLES.ui_offset_from_bottom_of_screen),width, 2)
        love.graphics.setColor(1,0,0,1)
        love.graphics.rectangle("fill",width / 2 - 162,height * (1 - BATTLES.ui_offset_from_bottom_of_screen) - 22,324,44)
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill",width / 2 - 160,height * (1 - BATTLES.ui_offset_from_bottom_of_screen) - 20,320,40)
        local timer_off = BATTLES.battle_timer * 0.2
        for i = 0,7 do
            local z = i / 7
            local off = math.fmod(timer_off + z, 1.0)
            love.graphics.setColor(1,0,0,1-off)
            love.graphics.rectangle("fill",width / 2 - 160 + off * off * 60,height * (1 - BATTLES.ui_offset_from_bottom_of_screen) - 20,2,40)
            love.graphics.rectangle("fill",width / 2 + 160 - off * off * 60,height * (1 - BATTLES.ui_offset_from_bottom_of_screen) - 20,2,40)
        end
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(images.fight, width / 2 + 160 - 120,height * (1 - BATTLES.ui_offset_from_bottom_of_screen) - 15)

        love.graphics.setColor(1,1,1,1)
        love.graphics.print("* John.",math.floor(width / 2 - 320),math.floor(height * (1 - BATTLES.ui_offset_from_bottom_of_screen) + 40))
        love.graphics.print("(press z or something)",math.floor(width / 2 - 320),math.floor(height * (1 - BATTLES.ui_offset_from_bottom_of_screen) + 120))
        love.graphics.print("YOU 200/200",math.floor(width / 2 - 160 + 60),math.floor(height * (1 - BATTLES.ui_offset_from_bottom_of_screen) - 10))

        local _xscale = love.graphics.getWidth()/1920
        local _yscale = love.graphics.getHeight()/1080

        local jbx = math.sin(BATTLES.battle_timer * 0.2) * 384*_xscale
        local jby = math.sin(BATTLES.battle_timer * 0.4) * 140*_xscale
        love.graphics.setColor(1,1,1,math.sin(BATTLES.battle_timer * 1) * 0.2 + 0.6)
        love.graphics.draw(images.johnaura, width / 2 - 192*_xscale + jbx, height* (BATTLES.ui_offset_from_bottom_of_screen * 2.5 - 0.5) + jby,0,_xscale,_yscale)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(images.john, width / 2 - 192*_xscale + jbx, height* (BATTLES.ui_offset_from_bottom_of_screen * 2.5 - 0.5) + jby,0,_xscale,_yscale)
    end

    if BATTLES.SWOON_FADE_OUT > 0.01 then
        BATTLES.SWOON_FADE_OUT = BATTLES.SWOON_FADE_OUT * 0.999
        local _xscale = love.graphics.getWidth()/1920
        local _yscale = love.graphics.getHeight()/1080
        love.graphics.setColor(1,1,1,BATTLES.SWOON_FADE_OUT)
        love.graphics.draw(images.swoon, 0, 0, 0,_xscale,_yscale)
    end
end

local lkp = love.keypressed
function love.keypressed( key, ... )
    lkp(key, ...)

    if key == "z" then
        G.GAME.in_battle = false
        BATTLES.SWOON_FADE_OUT = 1.0
        play_sound('gem_snd_swoon', 1, 1.5)
    end
end

SMODS.Consumable {
    key = 'fiftythree',
    set = 'gem_Number',
    pos = { x = 5, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local nums = {}
        local hands = {}
        for key, hand in pairs(G.GAME.hands) do
            if hand.visible then
                hands[#hands + 1] = key
                nums[#nums + 1] = {hand.chips}
                nums[#nums + 1] = {hand.mult}
            end
        end

        -- print(#nums)

        pseudoshuffle(nums, pseudoseed('fiftythree'))

        SMODS.upgrade_poker_hands {
            hands = hands,
            func = function(n, hand, parameter)
                local index = nil
                for i, v in ipairs(hands) do
                    if v == hand then
                        index = i
                    end
                end

                if index ~= nil then
                    if parameter == "chips" then
                        return nums[index * 2 - 1][1]
                    elseif parameter == "mult" then
                        return nums[index * 2][1]
                    end
                end
                return n
            end
        }
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fiftyfour',
    set = 'gem_Number',
    pos = { x = 6, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local hands = {}
        for key, hand in pairs(G.GAME.hands) do
            if not hand.visible then
                hands[#hands + 1] = key
            end
        end

        SMODS.upgrade_poker_hands {
            hands = hands,
        }
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fiftyfive',
    set = 'gem_Number',
    pos = { x = 7, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    use = function(self, card, area, copier)
        local total_chips = 0
        local total_mult = 0
        local hands = {}
        for key, hand in pairs(G.GAME.hands) do
            if hand.visible then
                hands[#hands + 1] = key
                total_chips = total_chips + hand.chips
                total_mult = total_mult + hand.mult
            end
        end

        total_chips = math.floor(total_chips / #hands * 2)
        total_mult = math.floor(total_mult / #hands * 2)

        SMODS.upgrade_poker_hands {
            hands = hands,
            func = function(n, hand, parameter)
                local index = nil
                for i, v in ipairs(hands) do
                    if v == hand then
                        index = i
                    end
                end

                if index ~= nil then
                    if parameter == "chips" then
                        return total_chips
                    elseif parameter == "mult" then
                        return total_mult
                    end
                end
                return n
            end
        }
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fiftysix',
    set = 'gem_Number',
    pos = { x = 8, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { ones = 4 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.ones } }
    end,
    use = function(self, card, area, copier)
        for i = 1, 4 do
            local other_card = SMODS.add_card({ set = 'gem_Number', key = "c_gem_one", edition = "e_negative" })
        end
    end,
    can_use = function(self, card)
        return true
    end
}

SMODS.Consumable {
    key = 'fiftyseven',
    set = 'gem_Number',
    pos = { x = 9, y = 5 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_satellite")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'satellite',
    pos = { x = 8, y = 7 },
    atlas = "Joker",
    prefix_config = { atlas = false },
    weight = 0,
    config = { extra = { dollars = 1 } },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        local planets_used = 0
        for k, v in pairs(G.GAME.consumeable_usage) do if v.set == 'Planet' then planets_used = planets_used + 1 end end
        return { vars = { card.ability.extra.dollars, planets_used * card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if context.playing_card_end_of_round and context.cardarea == G.hand then
            local planets_used = 0
            for k, v in pairs(G.GAME.consumeable_usage) do
                if v.set == 'Planet' then planets_used = planets_used + 1 end
            end
            return planets_used > 0 and { dollars = planets_used * card.ability.extra.dollars} or nil
        end
    end,
    no_mod_badges = true,
}

SMODS.Consumable {
    key = 'fiftyeight',
    set = 'gem_Number',
    pos = { x = 0, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_matador")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'matador',
    pos = { x = 4, y = 5 },
    atlas = "Joker",
    prefix_config = { atlas = false },
    weight = 0,
    config = { extra = { dollars = 8 } },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            local effs = {}
            for _, other_card in ipairs(G.play.cards) do
                if other_card.debuff then
                    effs[#effs + 1] = {
                        dollars = card.ability.extra.dollars,
                        card = other_card
                    }
                end
            end
            return SMODS.merge_effects(effs)
        end
    end,
    no_mod_badges = true,
}

SMODS.Consumable {
    key = 'fiftynine',
    set = 'gem_Number',
    pos = { x = 1, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { 1 } }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_gem_redseal")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted == 1
    end
}

SMODS.Enhancement {
    key = 'redseal',
    pos = { x = 5, y = 4 },
    atlas = "centers",
    prefix_config = { atlas = false },
    weight = 0,
    config = { extra = { } },
    replace_base_card = true,
    no_rank = true,
    no_suit = true,
    always_scores = true,
    no_collection = true,
    no_badge = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { } }
    end,
    calculate = function(self, card, context)
    end,
    no_mod_badges = true,
}

SMODS.Consumable {
    key = 'sixty',
    set = 'gem_Number',
    pos = { x = 2, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { }
    end,
    calculate = function(self, card, context)
        if context.buying_card and context.buying_self then
            eventify( function () ease_dollars( 0 ) end )
        end
    end,
    keep_on_use = true,
    can_use = function(self, card)
        return card.area == G.pack_cards
    end
}

local ed = ease_dollars
ease_dollars = function(mod, instant, ...)
    if next(SMODS.find_card("c_gem_sixty")) then
        if G.GAME.dollars ~= 0 then
            ed(-G.GAME.dollars, instant, ...)
        end
    else
        ed(mod, instant, ...)
    end
end

-- second hook. lmao even
local scalcieff = SMODS.calculate_individual_effect
SMODS.calculate_individual_effect = function(effect, scored_card, key, amount, from_edition)
    if next(SMODS.find_card("c_gem_sixty")) then
        if key == "mult" or key == "h_mult" or key == "mult_mod" then
            if key == "mult_mod" then
                effect["mult_mod"] = nil
                effect["message"] = nil
            end
            amount = (1 + amount)
            key = "xchips"
        end
    end
    return scalcieff(effect, scored_card, key, amount, from_edition)
end

SMODS.Consumable {
    key = 'sixtyone',
    set = 'gem_Number',
    pos = { x = 3, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { }
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('timpani')
                SMODS.add_card({ set = 'Joker' })
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        delay(0.6)
    end,
    can_use = function(self, card)
        return G.jokers and #G.jokers.cards < G.jokers.config.card_limit
    end
}

SMODS.Consumable {
    key = 'sixtytwo',
    set = 'gem_Number',
    pos = { x = 4, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { mult_bonus = 4, money_earned = 0, money_per = 8 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_bonus, card.ability.extra.money_per, card.ability.extra.money_earned } }
    end,
    calculate = function(self, card, context)
        if context.money_altered and context.amount > 0 then
            card.ability.extra.money_earned = card.ability.extra.money_earned + context.amount
        end
    end,
    use = function(self, card, area, copier)
      for i = 1, #G.hand.highlighted do
        o_card = G.hand.highlighted[i]
        o_card.ability.perma_mult = (o_card.ability.perma_mult or 0) + card.ability.extra.mult_bonus
        local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
          trigger = 'after',
          delay = 0.15,
          func = function()
            play_sound('multhit1', percent, 0.6); G.hand.highlighted[i]
              :juice_up(
                0.3, 0.3); return true
          end
        }))
      end
    end,
    can_use = function(self, card)
        return #G.hand.highlighted ~= 0 and #G.hand.highlighted <= math.floor( card.ability.extra.money_earned / card.ability.extra.money_per )
    end
}

SMODS.Consumable {
    key = 'sixtythree',
    set = 'gem_Number',
    pos = { x = 5, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { cards_scored = 0, cards_per = 10 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards_scored, card.ability.extra.cards_per } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            card.ability.extra.cards_scored = card.ability.extra.cards_scored + 1
        end
    end,
    use = function(self, card, area, copier)
        for i = 1, math.floor( card.ability.extra.cards_scored / card.ability.extra.cards_per ) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    play_sound('timpani')
                    SMODS.add_card({ set = 'gem_Number', edition = "e_negative" })
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end,
    can_use = function(self, card)
        return card.ability.extra.cards_scored >= card.ability.extra.cards_per
    end
}

SMODS.Consumable {
    key = 'sixtyfour',
    set = 'gem_Number',
    pos = { x = 6, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { sells = 0, sells_per = 2 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sells, card.ability.extra.sells_per } }
    end,
    calculate = function(self, card, context)
        if context.selling_card and context.card ~= card then
            card.ability.extra.sells = card.ability.extra.sells + 1
        end
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                SMODS.destroy_cards(G.hand.highlighted)
                return true
            end
        }))
        delay(0.3)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted ~= 0 and #G.hand.highlighted <= math.floor( card.ability.extra.sells / card.ability.extra.sells_per )
    end
}

SMODS.Consumable {
    key = 'sixtyfive',
    set = 'gem_Number',
    pos = { x = 7, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { money_earned = 0, money_per = 10 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { nil, card.ability.extra.money_per, card.ability.extra.money_earned } }
    end,
    calculate = function(self, card, context)
        if context.money_altered and context.amount < 0 then
            card.ability.extra.money_earned = card.ability.extra.money_earned - context.amount
        end
    end,
    use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        for i = 1, #G.hand.highlighted do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('card1', percent)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        delay(0.2)
        for i = 1, #G.hand.highlighted do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.hand.highlighted[i]:set_ability("m_wild")
                    return true
                end
            }))
        end
        for i = 1, #G.hand.highlighted do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    G.hand.highlighted[i]:flip()
                    play_sound('tarot2', percent, 0.6)
                    G.hand.highlighted[i]:juice_up(0.3, 0.3)
                    return true
                end
            }))
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end
        }))
        delay(0.5)
    end,
    can_use = function(self, card)
        return #G.hand.highlighted ~= 0 and #G.hand.highlighted <= math.floor( card.ability.extra.money_earned / card.ability.extra.money_per )
    end
}
SMODS.Consumable {
    key = 'sixtysix',
    set = 'gem_Number',
    pos = { x = 8, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { chips = 66 } },
    unlocked = true,
    discovered = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips
            }
        end
    end,
    keep_on_use = true,
    can_use = function(self, card)
        return card.area == G.pack_cards
    end
}

SMODS.Consumable {
    key = 'sixtyseven',
    set = 'Spectral',
    soul_set = "gem_Number",
    pos = { x = 0, y = 0 },
    soul_pos = { x = 9, y = 6 },
    atlas = "gem_numbers",
    config = { extra = { emult = 67 } },
    unlocked = true,
    discovered = true,
    no_collection = true,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.emult } }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main then
            if Talisman or Cryptid then
                return {
                    emult = card.ability.extra.emult
                }
            else
                return {
                    message = "^"..card.ability.extra.emult.." Mult",
                    colour = G.C.DARK_EDITION,
                    func = function()
                        mult = mod_mult(mult ^ card.ability.extra.emult)
                    end
                }
            end
        end
    end,
    keep_on_use = true,
    can_use = function(self, card)
        return card.area == G.pack_cards
    end
}