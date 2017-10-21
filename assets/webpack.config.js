const path = require('path');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
// const webpack = require('webpack');

module.exports = {
  devtool: 'source-map',
  entry: {
    app: 'js/app.js',
    sdk: 'js/sdk.js',
  },
  output: {
    path: path.resolve(__dirname, '../priv/static'),
    filename: 'js/[name].js',
  },
  resolve: {
    modules: ['node_modules', __dirname],
    extensions: ['.js', '.jsx'],
  },
  module: {
    rules: [
      {
        test: /\.js[x]?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          plugins: ['transform-runtime'],
          presets: ['env', 'react'],
        },
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract({ fallback: 'style-loader', use: 'css-loader' }),
      },
    ],
  },
  plugins: [
    // new webpack.optimize.UglifyJsPlugin(),
    new ExtractTextPlugin('css/app.css'),
    new CopyWebpackPlugin([{
      from: './static',
      to: path.resolve(__dirname, '../priv/static'),
    }]),
  ],
};
