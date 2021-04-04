-- Transliterates kana to a romaji standard

local utf8 = require('src.libs.utf8.utf8')

local mapping = {
    map = require('src.data.hepburn'),
    buffer = {
        caret = 0,
        content = '',
        append = function(self, str)
            self.content = self.content .. str
            self.caret = self.caret + utf8.len(str)
            return utf8.len(str)
        end
    }
}

setmetatable(mapping.buffer, {
    __call = function(self)
        local str = self.content
        self.content = ''
        self.caret = 0
        return str
    end
});

function mapping:transliterate(input)
    -- Read and convert
    local substring
    local move_caret = 0

    for caret = 1, utf8.len(input), 2 do
        substring = utf8.sub(input, caret, 1 + caret)
        if substring == '' then break end

        if (self.map[substring]) then
            self.buffer:append(self.map[substring])
        else
            for i = 1, 2 do
                local digraph = utf8.sub(substring, i, i)
                if digraph == "ー" then digraph = self.buffer.content:sub(-1, -1) end
                self.buffer:append(self.map[digraph] or digraph)
            end
        end
    end

    return self.buffer()
end

return mapping