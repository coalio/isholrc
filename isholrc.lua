-- Convert .lrc lyrics to IshoTyping XML

local writer = require('src.writer')
local parser = require('src.parser')

local help = 
    'usage: isholrc <path> [--romanize | -r] [--leave-spaces | -s] [ --join-short | -j <ms \\d> ]\n' ..
    '\9--romanize (-r): Transliterate the kana to a romaji equivalent using the Hepburn standard\n' ..
    '\9--leave-spaces (-s): Avoid removing spaces from the <word> output\n' ..
    '\9--join-short (-j <ms>): Join short intervals under the ms specified in one to make them easier to type\n' ..
    
    '\nProvide the path to your .lrc file as a first argument\n\9example: isholrc "Hatsune Miku - Ievan Polkka.lrc"\n' ..
    '\noptionally, you can specify flags\n\9example: isholrc "Hatsune Miku - Ievan Polkka.lrc" -r -s'

if not arg[1] then print(help) os.exit(22) end
local filename = arg[1]:sub(-4, -1) == '.lrc' and arg[1]
table.remove(arg, 1)

local args = table.concat(arg, ' ')
local options = {
    leave_spaces = args:find('--leave-spaces')
                   or args:find('-s'),
    romanize     = args:find('--romanize')
                   or args:find('-r'),
    join_short   = args:match('%-%-join%-short (%d+)')
                   or args:match('%-j (%d+)')
}

options.as_hiragana = not options.romanize -- hiragana by default
options.clean_spaces = not options.leave_spaces -- clean spaces by default
options.join_short = (options.join_short or 0) + 0 -- 0 by default, convert to number

if filename then
    local source = io.open(filename, 'r')
    if not source then
        print(('File %s wasnt found or is not readable'):format(filename))
    end

    local output = writer:write_specification(parser:parse(source:read '*a'), options)
    
    -- write the output xml
    local dir, output_filename = filename:gsub('\\', '/'):match('(.+/)(.-)%.[%w%d]+$')
    io.open(dir .. output_filename .. '.xml', 'w'):write(output)
    
    print(('Exported %s to %s'):format(output_filename, dir))
else
    print('Invalid path provided')
end