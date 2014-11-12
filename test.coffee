# Test by @anodynos
# See https://github.com/cujojs/when/issues/403

fs = require 'fs'

When = require 'when'
When.node = require 'when/node'
When.sequence = require 'when/sequence'
readFileP = When.node.lift fs.readFile

path = require 'path'
expand = require 'glob-expand'
esprima = require 'esprima'

jspath = './node_modules/lodash'

arrayItems = []
for i in [1..1000]
  arrayItems.push do (i)-> -> When(i)

fileTxt = null

files = expand {cwd: jspath, filter: 'isFile'}, ['**/*.js']
for file in files
  fileTxt = fs.readFileSync(path.join(jspath, file), 'utf8')
  esprima.parse(fileTxt)
  console.log "test parsing file is ok `#{file}`"

catchCount = 0
When.iterate(
  (i)-> i + 1
  (i)-> !(i < arrayItems.length)
  (i)->
    item = arrayItems[i]

    When.iterate(
      (j)-> j + 1
      (j)-> !(j < files.length)
      (j)->
        file = files[j]
        p = When.sequence([
          ->
            item().then (v)-> When(v).delay(1).then (v)->
              console.log "##{v} reading file with promise: `#{file}`"
              readFileP(path.join(jspath, file), 'utf8').then (res)->
                fileTxt = res

          ->
            item().then (v)-> When(v).delay(1).then (v)->
              console.log "##{v} parsing file: `#{file}`"
              # 7 is the magic number
              # < 7 and this test passes
              # >= 7 and the test will fail with the exception
              for i in [1..7]
                ast = esprima.parse(fileTxt)
              console.log fileTxt[1..100], ast.type
        ])

        console.log 'registering catch #', catchCount++
        p.catch (err)->
          l.error "An error was caught:", err
          process.exit 1
    ,0)
,0)
