const libc = require('detect-libc')
const { arch, platform, env } = process
const { modules } = process.versions
const tagName = env.CANVAS_VERSION_TO_BUILD;

(async () => {
  console.log(['canvas', tagName, 'node-v' + modules, platform, (await libc.family()) || 'unknown', arch].join('-'))
})()
