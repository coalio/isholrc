# ```isholrc```
An utility that allows you to convert .lrc files to XML which can be used with [IshoTyping](https://sites.google.com/site/ishotyping) and [TypingMania](http://www.sightseekerstudio.com/typingmania)

[TypingMania](http://www.sightseekerstudio.com/typingmania) や [IshoTyping](https://sites.google.com/site/ishotyping) で使用できる音楽 XML ファイルの作成をサポートするツール


```lua isholrc.lua <path> [flags]```  
-----
`You need to install lua to use this utility`  
## `path`: the (relative) path to your lrc file  
## `flags`: flags that specify how to handle the file   
```
--romanize | -r: Transliterate the kana to a romaji equivalent using the Hepburn standard
--leave-spaces | -s: Avoid removing spaces from the <word> output
```

## Remarks

- You will need to convert the lyrics manually to kana (it can be romanized automatically for the `<word>` output, the original kana will be left in `<nihongoword>`)
- You will need to manually add the xml to your IshoTyping/Typing Mania folder and add it to a list xml
