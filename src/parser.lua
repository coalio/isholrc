-- Parses the file into words and intervals

local utf8 = require('src.libs.utf8.utf8')

local parser = {
    pattern = {
        ['line'] = '%[(.-)%](.-)[\r\n]'
    }
}

function parser.to_milliseconds(timestamp)
    local m, s, ms = timestamp:match('(%d+):(%d+).(%d+)')
    return m * 60000 + s * 1000 + (('0.' .. ms) * 100)
end

function parser:parse(input)
    input = input .. '\n'
    local intervals = {}
    local words = {}
    local tags = {}

    for timestamp, word in utf8.gmatch(input, self.pattern['line']) do
        intervals[#intervals + 1] = self.to_milliseconds(timestamp)
        words[#words + 1] =
            (word == '' or word:gsub('%s', '') == '') and '@' or word
    end

    for i = 1, #words do
        tags[i] = {
            word = words[i],
            interval = (intervals[i + 1] or intervals[i] + 10) - intervals[i]
        }
    end

    return tags
end

return parser