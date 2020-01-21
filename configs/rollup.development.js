import livereload from 'rollup-plugin-livereload';
import node_resolve from 'rollup-plugin-node-resolve';
import postcss from 'rollup-plugin-postcss';

export default {
  input: './src/Main.bs.js',
  output: {
    file: './release/main.js',
    name: 'starter',
    format: 'iife'
  },
  plugins: [
    node_resolve({ module: true, browser: true }),
    livereload('release'),
    postcss({plugins: []})
  ],
  watch: {
    clearScreen: false
  }
};
