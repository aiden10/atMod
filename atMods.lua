--- STEAMODDED HEADER
--- MOD_NAME: at Mod
--- MOD_ID: atMod
--- MOD_AUTHOR: [at]
--- MOD_DESCRIPTION: Add a joker.

----------------------------------------------
------------MOD CODE -------------------------
function SMODS.INIT.atMod()

    local at_mod = SMODS.findModByID('atMod')
    SMODS.Sprite:new('j_overkill', at_mod.path, 'jokers.png', 71, 95, 'asset_atli'):register()
    SMODS.Sprite:new('j_reverse', at_mod.path, 'jokers.png', 71, 95, 'asset_atli'):register()

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
            [2] = "triggers the ability Boss Blind's",
            [3] = '{C:inactive}(Currently {C:mult}+#2#{C:inactive})'
        }
    }

    local joker_overkill = SMODS.Joker:new(
        'Overkill Joker', -- Name
        'overkill', -- Slug
        {extra = {xmult_add = 0.5, xmult = 1, total_chips = 0}}, -- Config
        {x = 0, y = 0}, -- Sprite position
        loc_overkill, -- Localization
        3,
        8,
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

    joker_overkill:register()
    joker_reverse:register()

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
                message = localize{type='variable',key='a_mult',vars={self.ability.extra.a_mult}},
                card = self
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
