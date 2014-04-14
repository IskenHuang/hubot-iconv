# Description:
#   Encoding convertor. pleaese install module "iconv". example: "npm install iconv --save"
#
# Commands:
#   hubot iconv list - List all of supported encording
#   hubot iconv from <Encoding> to <Encoding> <file> <new file> - Convert encording and new file

FS = require('fs')
Iconv = require('iconv').Iconv

IgnoreString = "//IGNORE"
TranslitString = "//TRANSLIT"
Encoding =
  European: [
    "ASCII",
    "ISO-8859-{1,2,3,4,5,7,9,10,13,14,15,16}",
    "KOI8-R",
    "KOI8-U",
    "KOI8-RU",
    "CP{1250,1251,1252,1253,1254,1257}",
    "CP{850,866,1131}",
    "Mac{Roman,CentralEurope,Iceland,Croatian,Romania}",
    "Mac{Cyrillic,Ukraine,Greek,Turkish}",
    "Macintosh",
  ]
  Semitic: [
    "ISO-8859-{6,8}",
    "CP{1255,1256}",
    "CP862",
    "Mac{Hebrew,Arabic}"
  ]
  Japanese: [
    "EUC-JP",
    "SHIFT_JIS",
    "CP932",
    "ISO-2022-JP",
    "ISO-2022-JP-2",
    "ISO-2022-JP-1",
  ]
  Chinese: [
    "EUC-CN",
    "HZ",
    "GBK",
    "CP936",
    "GB18030",
    "EUC-TW",
    "BIG5",
    "CP950",
    "BIG5-HKSCS",
    "BIG5-HKSCS:2004",
    "BIG5-HKSCS:2001",
    "BIG5-HKSCS:1999",
    "ISO-2022-CN",
    "ISO-2022-CN-EXT",
  ]
  Korean: [
    "EUC-KR",
    "CP949",
    "ISO-2022-KR",
    "JOHAB",
  ]
  Armenian: [
    "ARMSCII-8",
  ]
  Georgian: [
    "Georgian-Academy",
    "Georgian-PS",
  ]
  Tajik: [
    "KOI8-T",
  ]
  Kazakh: [
    "PT154",
    "RK1048",
  ]
  Thai: [
    "ISO-8859-11",
    "TIS-620",
    "CP874",
    "MacThai",
  ]
  Laotian: [
    "MuleLao-1",
    "CP1133",
  ]
  Vietnamese: [
    "VISCII",
    "TCVN",
    "CP1258",
  ]
  PlatformSpecifics: [
    "HP-ROMAN8",
    "NEXTSTEP",
  ]
  Unicode: [
    "UTF-8",
    "UCS-2",
    "UCS-2BE",
    "UCS-2LE",
    "UCS-4",
    "UCS-4BE",
    "UCS-4LE",
    "UTF-16",
    "UTF-16BE",
    "UTF-16LE",
    "UTF-32",
    "UTF-32BE",
    "UTF-32LE",
    "UTF-7",
    "C99",
    "JAVA",
  ]

arrayCompact = (array = [])->
  i = array.length - 1
  while i > 0
    _value = array[i]
    array.splice i, 1 if !_value or !_value.length
    i--

  return array;



inChinese = (encording = "")->
  if Encoding.Chinese.indexOf(encording) >= 0
    encording = addIgnore(encording)
    encording = addTranslitString(encording)

  return encording

addIgnore = (encording = "")->
  if encording.indexOf(IgnoreString) < 0
    encording += IgnoreString

  return encording

addTranslitString = (encording = "")->
  if encording.indexOf(TranslitString) < 0
    encording += TranslitString

  return encording

pathResolve = (path)->
  userRoot = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE
  path = path.replace(/\~/i, userRoot)

  return path




module.exports = (robot) ->
  robot.respond /(iconv)?( list)/i, (msg) ->
    result = "\n"

    msg.send _en for _en in ["1", "2", "3"]

    for _key, _value of Encoding
      result += "#{_key}\n"

      for _v in _value
        result += "    #{_v}\n"

    msg.send result


  robot.respond /(iconv)? (from|f) (\S*) (to|t) (\S*) (.*)/i, (msg) ->
    fromEncoding = msg.match[3].toUpperCase()
    toEncoding = msg.match[5].toUpperCase()
    filesString = msg.match[6]

    msg.send "please input file path or string" if !filesString.length

    files = filesString.split /\ /ig

    # clean empty path
    files = arrayCompact(files)
    msg.send "please input file path or string" if !files.length

    fromEncoding = inChinese(fromEncoding)
    toEncoding = inChinese(toEncoding)
    iconv = new Iconv( fromEncoding, toEncoding)

    console.log pathResolve(files[0])

    FS.readFile pathResolve(files[0]), (error, file)->
      msg.send error if error

      buff = iconv.convert(file);

      # print original string
      msg.send buff.toString('UTF-8')

      if files.length > 1
        FS.writeFile pathResolve(files[1]), buff, (err)->
          if err
            msg.send err
          else
            msg.send "It\'s saved!"

