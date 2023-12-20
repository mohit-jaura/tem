const { execSync } = require('child_process')
const { exit } = require('process')

const mode = process.argv[2]

console.log('Bumping build version')
execSync(`agvtool bump`)
let buildVersion = execSync('agvtool what-version -terse', { encoding: 'utf-8' })
console.log(`Build version (CFBundleVersion): ${buildVersion}`)

const currentVersion = execSync('agvtool what-marketing-version -terse1', { encoding: 'utf-8' })
const parts = currentVersion.split('.')
let skipMarketingVersion
if (mode === 'major') {
    parts[0]++
    parts[1] = 0
    parts[2] = 0
} else if (mode === 'minor') {
    parts[1]++
    parts[2] = 0
}
else if (mode === 'patch')
    parts[2]++
else if (mode === 'same') {
    skipMarketingVersion = true
}
else {
    console.error('Unrecognised mode')
    exit(1)
}

if (!skipMarketingVersion) {
    const newVersion = parts.join('.')
    console.log(execSync(`agvtool new-marketing-version ${newVersion}`, { encoding: 'utf-8' }))
}
