--- STEAMODDED HEADER
--- MOD_NAME: at Mod
--- MOD_ID: atMod
--- MOD_AUTHOR: [at]
--- MOD_DESCRIPTION: Add a joker.

----------------------------------------------
------------MOD CODE -------------------------

function in_list(value, list)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

-- these seem kinda weird since they're always true? Might be a steamodded thing
local config = {
    recursive_joker = true,
    twilight_joker = true
}

function SMODS.INIT.atMod()

    local at_mod = SMODS.findModByID('atMod')

    SMODS.Sprite:new('j_overkill', at_mod.path, 'jokers.png', 71, 95, 'asset_atli'):register()
    SMODS.Sprite:new('j_reverse', at_mod.path, 'jokers.png', 71, 95, 'asset_atli'):register()
    SMODS.Sprite:new('j_recursive', at_mod.path, 'jokers.png', 71, 95, 'asset_atli'):register()
    SMODS.Sprite:new('j_twilight', at_mod.path, 'jokers.png', 71, 95, 'asset_atli'):register()
    SMODS.Sprite:new('j_promissory', at_mod.path, 'jokers.png', 71, 95, 'asset_atli'):register()
    SMODS.Sprite:new('centers', at_mod.path, 'decks.png', 71, 95, 'asset_atli'):register()

    local loc_overkill = {
        ['name'] = 'Overkill Joker',
        ['text'] = {
            [1] = 'If a single hand',
            [2] = 'beats the {C:attention}Blind{}, this Joker',
            [3] = 'gains {X:mult,C:white}X#1#{} Mult',
            [4] = '{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)'
        }
    }
    local loc_reverse = {
        ['name'] = 'Reverse Card',
        ['text'] = {
            [1] = 'Gains {C:mult}+#1#{} Mult if hand',
            [2] = "triggers the Boss Blind's ability",
            [3] = '{C:inactive}(Currently {C:mult}+#2#{C:inactive})'
        }
    }
    local loc_recursive = {
        ['name'] = 'Recursive Joker',
        ['text'] = {
            [1] = 'If played hand is identical',
            [2] = 'to last played hand,',
            [3] = 'gain {C:chips}+#1#{} hand this round',
            [4] = '{C:inactive}(Cards must be the{C:inactive}',
            [5] = '{C:inactive}same suit and rank){C:inactive}'
        }
    }

    local loc_twilight = {
        ['name'] = 'Twilight Joker',
        ['text'] = {
            [1] = 'From 7AM to 7PM:',
            [2] = '{C:hearts}Hearts{} and {C:diamonds}Diamonds{} gain {C:mult}+#1#{} Mult when scored.',
            [3] = 'From 7PM to 7AM:',
            [4] = '{C:clubs}Clubs{} and {C:spades}Spades{} gain {C:chips}+#2#{} Chips when scored',
            [5] = '{C:inactive}(Currently #3#){C:inactive}'
        }
    }

    local loc_promissory = {
        ['name'] = 'Promissory Note',
        ['text'] = {
            [1] = 'After defeating the Boss Blind',
            [2] = 'gain {C:money}$#1#{}, then',
            [3] = 'destroy this card'
        }
    }

    local loc_sealed = {
        ['name'] = 'Sealed Deck',
        ['text'] = {
            [1] = 'Start run with 2 of each {C:attention}seal{}',
            [2] = 'on random cards'
        }
    }

    local sealed_deck = SMODS.Deck:new(
        'Sealed Deck',
        'sealed',
        {sealed = true},
        {x = 0, y = 5},
        loc_sealed
    )

    local joker_overkill = SMODS.Joker:new(
        'Overkill Joker', -- Name
        'overkill', -- Slug
        {extra = {xmult_add = 0.5, xmult = 1, total_chips = 0}}, -- Config
        {x = 0, y = 0}, -- Sprite position
        loc_overkill, -- Localization
        2,
        5,
        true,
        true,
        true,
        true
    )
    
    local joker_reverse = SMODS.Joker:new(
        'Reverse Card',
        'reverse',
        {extra = {mult = 8, a_mult = 0}},
        {x = 1, y = 0},
        loc_reverse,
        2,
        5,
        true,
        true,
        true,
        true
    )
    
    local joker_recursive = SMODS.Joker:new(
        'Recursive Joker',
        'recursive',
        {extra = {a_hand = 1, last_hand = "", current_cards = ""}},
        {x = 2, y = 0},
        loc_recursive,
        3,
        6,
        true,
        true,
        true,
        true
    )

    local joker_twilight = SMODS.Joker:new(
        'Twilight Joker',
        'twilight',
        {extra = {a_mult = 5, a_chips = 15, time = 0, time_string = 'XX:XXPM/AM'}},
        {x = 3, y = 0},
        loc_twilight,
        2,
        5,
        true,
        true,
        true,
        true
    )
    local joker_promissory = SMODS.Joker:new(
        'Promissory Note',
        'promissory',
        {extra = {money = 8}},
        {x = 4, y = 0},
        loc_promissory,
        1,
        2,
        true,
        true,
        true,
        true
    )

    joker_overkill:register()
    joker_reverse:register()
    joker_recursive:register()
    joker_twilight:register()
    joker_promissory:register()
    sealed_deck:register()

    local Backapply_to_runRef = Back.apply_to_run
    function Back.apply_to_run(arg_56_0)
        Backapply_to_runRef(arg_56_0)

        if arg_56_0.effect.config.sealed then
            G.E_MANAGER:add_event(Event({
                func = function()
                    local seals_added = 0
                    local numbers = {}
                    while seals_added < 8 do 
                        local random_num = math.random(52)
                        if not in_list(random_num, numbers) then
                            table.insert(numbers, 1, random_num)
                            local card = G.playing_cards[random_num]
                            if seals_added < 2 then card:set_seal('Purple', true, true)
                            elseif seals_added < 4 then card:set_seal('Red', true, true)
                            elseif seals_added < 6 then card:set_seal('Blue', true, true)
                            else card:set_seal('Gold', true, true)
                            end
                            seals_added = seals_added + 1
                        end
                    end   
                    return true     
                end
            }))
        end
    end
    

    local evaluate_playref = G.FUNCS.evaluate_play
    function G.FUNCS.evaluate_play(self, e)
        evaluate_playref(self, e)

        for i = 1, #G.jokers.cards do
            local effects = eval_card(G.jokers.cards[i],
                { card = G.consumeables, after = true, scored_chips = hand_chips * mult })
            if effects.jokers then
                card_eval_status_text(G.jokers.cards[i], 'jokers', nil, 0.3, nil, effects.jokers)
            end
        end
    end

    SMODS.Jokers.j_overkill.calculate = function(self, context)
        if SMODS.end_calculate_context(context) then  
            return {
                x_mult = self.ability.extra.xmult,
                card = self,
                message = localize{
                    type = 'variable',
                    key = 'a_xmult',
                    vars = { self.ability.extra.xmult, self.ability.extra.xmult_add }
                },
                colour = G.C.MULT
            }
        end

        if context.scored_chips then
            self.ability.extra.total_chips = self.ability.extra.total_chips + context.scored_chips
        end

        if self.ability.extra.total_chips > G.GAME.blind.chips and context.after then
            self.ability.extra.xmult = self.ability.extra.xmult + self.ability.extra.xmult_add
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
                card = self
            }
        end

        if context.end_of_round and not context.individual and not context.repetition or context.after then
            self.ability.extra.total_chips = 0
        end
    end

    SMODS.Jokers.j_reverse.calculate = function(self, context)
        if context.debuffed_hand then
            if G.GAME.blind.triggered then
                self.ability.extra.a_mult = self.ability.extra.a_mult + 5
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.MULT,
                    card = self      
                }
            end
        end
        
        if SMODS.end_calculate_context(context) then
            return {
                mult_mod = self.ability.extra.a_mult,
                message = localize{type = 'variable', key = 'a_mult', vars = {self.ability.extra.a_mult}},
                card = self
            }
       end
    end

    if config.recursive_joker then
        SMODS.Jokers.j_recursive.calculate = function(self, context)

            -- Save previous cards
            if context.before then
                self.ability.extra.current_cards = ""
                for k, v in ipairs(context.full_hand) do
                    self.ability.extra.current_cards = self.ability.extra.current_cards .. v.base.suit .. v.base.id
                end
            end

            if SMODS.end_calculate_context(context) then
                -- check hands
                if self.ability.extra.current_cards == self.ability.extra.last_hand then
                    ease_hands_played(self.ability.extra.a_hand)
                    return {
                        message = localize {type = 'variable', key = 'a_hands', vars = {self.ability.extra.a_hand}}
                    }
                end

                self.ability.extra.last_hand = self.ability.extra.current_cards
                self.ability.extra.current_cards = ""
            end
        end
    end

    if config.twilight_joker then
        SMODS.Jokers.j_twilight.calculate = function(self, context)
            self.ability.extra.time_string = tostring(tonumber(os.date("%I"))) .. ":" .. os.date("%M") .. os.date("%p")
            if context.before then -- update current time
                local hour = tonumber(os.date("%H"))
                self.ability.extra.time = hour
            end

            if context.individual and context.cardarea == G.play then -- check every played card
                if self.ability.extra.time >= 7 and self.ability.extra.time <= 19 then -- during the day
                    if context.other_card:is_suit("Diamonds") or context.other_card:is_suit("Hearts") then -- buff diamonds and hearts
                        return {
                            mult = self.ability.extra.a_mult,
                            card = self
                        }
                    end
                else -- during night
                    if context.other_card:is_suit("Clubs") or context.other_card:is_suit("Spades") then -- buff spades and clubs
                        return {
                            chips = self.ability.extra.a_chips,
                            card = self
                        }
                    end
                end
            end
        end
    end

    SMODS.Jokers.j_promissory.calculate = function(self, context)
        if context.end_of_round and not context.individual and not context.repetition and G.GAME.blind.boss then
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    self.T.r = -0.2
                    self:juice_up(0.3, 0.4)
                    self.states.drag.is = true
                    self.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                        func = function()
                                G.jokers:remove_card(self)
                                self:remove()
                                self = nil
                            return true; end})) 
                    return true
                end
            })) 
            return {
                message = localize('$')..8,
                dollars = 8,
                colour = G.C.MONEY
            }
        end
    end
end

local generate_UIBox_ability_tableref = Card.generate_UIBox_ability_table
function Card.generate_UIBox_ability_table(self)
    local card_type, hide_desc = self.ability.set or 'None', nil
    local loc_vars = nil
    local main_start, main_end = nil, nil
    local no_badge = nil

    if self.config.center.unlocked == false and not self.bypass_lock then    -- For everyting that is locked
    elseif card_type == 'Undiscovered' and not self.bypass_discovery_ui then -- Any Joker or tarot/planet/voucher that is not yet discovered
    elseif self.debuff then
    elseif card_type == 'Default' or card_type == 'Enhanced' then
    elseif self.ability.set == 'Joker' then
        local customJoker = true

        if self.ability.name == 'Overkill Joker' then
            loc_vars = {self.ability.extra.xmult_add, self.ability.extra.xmult}
        elseif self.ability.name == 'Reverse Card' then
            loc_vars = {self.ability.extra.mult, self.ability.extra.a_mult}
        elseif self.ability.name == 'Recursive Joker' then 
            loc_vars = {self.ability.extra.a_hand}
        elseif self.ability.name == 'Twilight Joker' then
            loc_vars = {self.ability.extra.a_mult, self.ability.extra.a_chips, self.ability.extra.time_string}
        elseif self.ability.name == 'Promissory Note' then
            loc_vars = {self.ability.extra.money}
        else
            customJoker = false
        end

        if customJoker then
            local badges = {}
            if (card_type ~= 'Locked' and card_type ~= 'Undiscovered' and card_type ~= 'Default') or self.debuff then
                badges.card_type = card_type
            end
            if self.ability.set == 'Joker' and self.bypass_discovery_ui and (not no_badge) then
                badges.force_rarity = true
            end
            if self.edition then
                if self.edition.type == 'negative' and self.ability.consumeable then
                    badges[#badges + 1] = 'negative_consumable'
                else
                    badges[#badges + 1] = (self.edition.type == 'holo' and 'holographic' or self.edition.type)
                end
            end
            if self.seal then
                badges[#badges + 1] = string.lower(self.seal) .. '_seal'
            end
            if self.ability.eternal then
                badges[#badges + 1] = 'eternal'
            end
            if self.pinned then
                badges[#badges + 1] = 'pinned_left'
            end

            if self.sticker then
                loc_vars = loc_vars or {}
                loc_vars.sticker = self.sticker
            end

            return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start,
                main_end)
        end
    end

    return generate_UIBox_ability_tableref(self)
end

----------------------------------------------
------------MOD CODE END----------------------
