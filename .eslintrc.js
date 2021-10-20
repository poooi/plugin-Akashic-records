const tsExtensions = ['.ts', '.tsx']

module.exports = {
  env: {
    browser: true,
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'poi-plugin',
    'prettier',
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: { "project": ["./tsconfig.json"] },
  plugins: [
      "@typescript-eslint"
  ],
  rules: {
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
  settings: {
    react: {
      version: '16.10.0',
    },
    'import/extensions': tsExtensions,
    'import/parsers': {
      '@typescript-eslint/parser': tsExtensions,
    },
    'import/resolver': {
      node: {
        extensions: tsExtensions,
      },
      typescript: {
        project: './',
      }
    },
  },
}
