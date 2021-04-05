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
    },

    state = {
        intervals_sum = 0,
        min_interval = 0,
        words_joint = {},
        nihongo_words_joint = {}
    }
}

function writer:write_specification(tags, options)
    self.state.min_interval = options.join_short or 0
    local nihongo_words = {}
    local words = {}
    local intervals = {}

    for index, tag in pairs(tags) do
        local clean_word = options.as_hiragana and mapper:clean(
            options.clean_spaces and utf8.gsub(tag.word, '%s', '') or tag.word
        ) or utf8.gsub(mapper:transliterate(tag.word), 
            '[^%w' .. (options.clean_spaces and '' or '%s') .. '%d]', ''
        )

        clean_word = clean_word == '@' and '' or clean_word

        if options.join_short then
            if tag.interval < self.state.min_interval and index < #tags then
                if clean_word ~= '' then
                    table.insert(self.state.words_joint, 
                        self.state.words_joint[1] and 
                        clean_word:lower() or 
                        clean_word
                    )
                    table.insert(self.state.nihongo_words_joint,
                        self.state.nihongo_words_joint[1] and 
                        tag.word:lower() or 
                        tag.word
                    )

                    if not self.state.nihongo_words_joint.spaced then
                        self.state.nihongo_words_joint.spaced = 
                            utf8.match(tag.word, '%s') and true or false
                    end
                end

                self.state.intervals_sum = self.state.intervals_sum + tag.interval
            elseif self.state.words_joint[1] then
                local expanded_words = table.concat(
                    self.state.words_joint,
                    options.clean_spaces and '' or ' '
                )
                local expanded_nihongo_words = table.concat(
                    self.state.nihongo_words_joint,
                    self.state.nihongo_words_joint.spaced and ' ' or ''
                )

                nihongo_words[#nihongo_words + 1] =
                    self.templates['nihongoword']:format(expanded_nihongo_words)
                nihongo_words[#nihongo_words + 1] =
                    self.templates['nihongoword']:format(tag.word)
                    
                words[#words + 1] = self.templates['word']:format(
                    (
                        expanded_words == '' or utf8.gsub(expanded_words, '%s', '') == ''
                    ) and '@' or expanded_words
                )
                words[#words + 1] = self.templates['word']:format(
                    clean_word == '' and '@' or clean_word
                )

                intervals[#intervals + 1] = self.templates['interval']:format(self.state.intervals_sum)
                intervals[#intervals + 1] = self.templates['interval']:format(tag.interval)
                self.state.intervals_sum = 0
                self.state.words_joint = {}
                self.state.nihongo_words_joint = {}
            else
                nihongo_words[#nihongo_words + 1] = 
                    self.templates['nihongoword']:format(tag.word)
                words[#words + 1] = self.templates['word']:format(
                    clean_word == '' and '@' or clean_word
                )
                intervals[#intervals + 1] = self.templates['interval']:format(tag.interval)
            end
        else
            nihongo_words[#nihongo_words + 1] = 
                self.templates['nihongoword']:format(tag.word)
            words[#words + 1] = self.templates['word']:format(
                clean_word == '' and '@' or clean_word
            )
            intervals[#intervals + 1] = self.templates['interval']:format(tag.interval)
            self.state.intervals_sum = 0
        end
    end

    return self.templates['base']:format(#intervals, 
        table.concat(nihongo_words, '\n') .. '\n' .. 
        table.concat(words, '\n') .. '\n' .. 
        table.concat(intervals, '\n')
    )
end

return writer