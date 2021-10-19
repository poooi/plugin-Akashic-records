const jsExtensions = ['.js', '.es']
const tsExtensions = ['.ts', '.tsx', '*.d.ts']
const allExtensions = jsExtensions.concat(tsExtensions)

module.exports = {
  'env': {
    'browser': true,
    'es6': true,
    'node': true,
  },
  'extends': [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'poi-plugin',
  ],
  'plugins': [
    'import',
    'react',
  ],
  'parser': '@babel/eslint-parser',
  'parserOptions': {
    'babelOptions': {
      'configFile': './node_modules/poi-util-transpile/babel.config.js'
    }
  }
  'rules': {
    'comma-dangle': ['error', 'always-multiline'],
    'indent': ['warn', 2],
    'linebreak-style': ['error', 'unix'],
    'no-console': ['warn', {'allow': ['warn', 'error']}],
    'no-var': 'error',
    'no-unused-vars': ['warn', {'args': 'none'}],
    'semi': ['error', 'never'],
    'unicode-bom': 'error',
    'prefer-const': ['error', {'destructuring': 'all'}],
    'react/prop-types': [0],
    'no-irregular-whitespace': ['error', {'skipStrings': true, 'skipTemplates': true}],
  },
  'settings': {
    react: {
      version: '16.10.0',
    },
    'import/extensions': allExtensions,
    'import/parsers': {
      '@typescript-eslint/parser': tsExtensions,
    },
    'import/resolver': {
      node: {
        extensions: allExtensions,
      },
    },
  },
  'overrides': [
    {
      files: tsExtensions,
      parser: '@typescript-eslint/parser',
    },
  ],
}
