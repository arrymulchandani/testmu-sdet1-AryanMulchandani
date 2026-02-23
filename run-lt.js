require('dotenv').config();
const { execSync } = require('child_process');
const fs = require('fs');

const config = JSON.parse(fs.readFileSync('./lambdatest-config.json', 'utf-8'));

config.lambdatest_auth.username = process.env.LT_USERNAME;
config.lambdatest_auth.access_key = process.env.LT_ACCESS_KEY;

fs.writeFileSync('./lambdatest-config.json', JSON.stringify(config, null, 2));

try {
  execSync('lambdatest-cypress run --cy="--config-file cypress.config.js"', { stdio: 'inherit' });
} finally {
  // Always clears creds even if run fails
  config.lambdatest_auth.username = "";
  config.lambdatest_auth.access_key = "";
  fs.writeFileSync('./lambdatest-config.json', JSON.stringify(config, null, 2));
}