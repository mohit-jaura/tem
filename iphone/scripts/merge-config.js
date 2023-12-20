const { existsSync, writeFileSync } = require('fs')
const { resolve } = require('path')
const { exit } = require('process')

const targetPath = resolve(__dirname, '..', process.argv[2])
const sourcePath = resolve(__dirname, '..', process.argv[3])

if (!existsSync(sourcePath)) {
  console.error(`Source config ${sourcePath} can't be found`)
  exit(1)
}

if (!existsSync(targetPath)) {
  console.error(`Target config ${targetPath} can't be found`)
  exit(1)
}

let target = require(targetPath)
const source = require(sourcePath)

merge(target, source)

target = JSON.stringify(target, undefined, '  ')
console.log(`Build configuration:
${target}`)
writeFileSync(targetPath, target, { encoding: 'utf-8' })

function merge(target, patch) {
  for (const key in patch)
    if (patch.hasOwnProperty(key)) {
      if (typeof patch[key] === 'object') {
        if (!target[key])
          target[key] = {}
        merge(target[key], patch[key])
      }
      else
        target[key] = patch[key]
    }
}
