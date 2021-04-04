-- Returns a XML specification of the parsed contents

local mapper = require('src.mapping')
local utf8 = require('src.libs.utf8.utf8')

local writer = {
    templates = {
        ['base'] = 
[[<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
<musicXML>
]]..'\9'..[[<saidaimondaisuu>%d</saidaimondaisuu>
%s
</musicXML>]],
        ['nihongoword'] = '\9<nihongoword>%s</nihongoword>',
        ['word'] = '\9<word>%s</word>',
        ['interval'] = '\9<interval>%d</interval>'
    }
}

function writer:write_specification(tags, options)
    local nihongo_words = {}
    local words = {}
    local intervals = {}

    for index, tag in pairs(tags) do
        local clean_word = 
            options.as_hiragana and (
                options.clean_spaces and utf8.gsub(tag.word, '%s', '') or tag.word
            ) or
            utf8.gsub(mapper:transliterate(tag.word), 
                '[^%w' .. (options.clean_spaces and '' or '%s') .. '%d]', ''
            )
        nihongo_words[#nihongo_words + 1] = self.templates['nihongoword']:format(tag.word)
        words[#words + 1] = self.templates['word']:format(
             clean_word == '' and '@' or clean_word
        )
        intervals[#intervals + 1] = self.templates['interval']:format(tag.interval)
    end

    return self.templates['base']:format(#intervals, 
        table.concat(nihongo_words, '\n') .. '\n' .. 
        table.concat(words, '\n') .. '\n' .. 
        table.concat(intervals, '\n')
    )
end

return writer