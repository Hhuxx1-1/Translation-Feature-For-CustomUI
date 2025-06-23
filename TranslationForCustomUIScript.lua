_T = {
    missingTranslations = {},
    playerSession = {},

    -- Supported languages
    supportedLanguages = {
        tw = true, en = true, cn = true, tha = true, esn = true, 
        ptb = true, fra = true, jpn = true, ara = true, kor = true, 
        vie = true, rus = true, tur = true, ita = true, ger = true, 
        ind = true, msa = true
    },

    -- Detect player's language
    LANGUAGE_UPDATE = function(self, playerid)
        local r, lc, ar = Player:GetLanguageAndRegion(playerid)
        if r == 0 then
            lc = tonumber(lc) and (lc >= 0 and lc + 1 or 1) or lc
            self.playerSession[playerid] = { lc = self.supportedLanguages[lc] and lc or "en", ar = ar or "" }
        else
            self.playerSession[playerid] = { lc = "en", ar = "EN" }
        end
        Player:notifyGameInfo2Self(playerid, "Language Detected: " .. self.playerSession[playerid].lc)
    end,

    -- Update player language manually
    SET_PLAYER_LANGUAGE = function(self, playerid, langcode)
        if self.supportedLanguages[langcode] then
            self.playerSession[playerid] = { lc = langcode, ar = "" }
            Player:notifyGameInfo2Self(playerid, "Preferred language set to: " .. langcode)
        else
            Player:notifyGameInfo2Self(playerid, "#RERROR:#W Unsupported language: " .. langcode)
        end
    end,

    -- Get formatted key name
    toIndex = function(self, key)
        return key:gsub("[%s%p]", "_")
    end,

    -- Get player's language session
    getSession = function(self, playerid)
        return self.playerSession[playerid] and self.playerSession[playerid].lc or "en"
    end
}

-- Metatable for translation handling
setmetatable(_T, {
    __index = function(tbl, key)
        if not tbl.missingTranslations[key] then
            tbl.missingTranslations[key] = true
        end
        return key
    end,

    -- Add translations using `+`
    __add = function(tbl, translations)
        for key, langTable in pairs(translations) do
            local indexKey = tbl:toIndex(key)
            tbl[indexKey] = tbl[indexKey] or {}
            for lang, value in pairs(langTable) do
                tbl[indexKey][lang] = value
            end
        end
        return tbl
    end,

    -- Remove translations with `-`
    __sub = function(tbl, b)
        local key, lang = tbl:toIndex(b[1]), b[2]
        if tbl[key] then tbl[key][lang] = nil end
    end,

    -- Retrieve translation
    __call = function(tbl, playerid, key)
        local indexedKey = tbl:toIndex(key)
        local lang = tbl:getSession(playerid)
        if tbl[indexedKey] and tbl[indexedKey][lang] then
            return tbl[indexedKey][lang]
        else
            tbl.missingTranslations[indexedKey] = true
            return key
        end
    end
})

-- Auto-set language on player join
ScriptSupportEvent:registerEvent("Game.AnyPlayer.EnterGame", function(e)
    -- Add a Delay if necessary;
    _T:LANGUAGE_UPDATE(e.eventobjid);
end)
