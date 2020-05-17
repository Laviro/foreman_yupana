#!/bin/bash
set -ev

if [[ $( git diff --name-only origin/master..HEAD webpack/ .travis.yml babel.config.js .eslintrc package.json | wc -l ) -ne 0 ]]; then
  npm run test;
  npm run publish-coverage;
  npm run lint;
fi
