let MiniCssExtractPlugin = require("mini-css-extract-plugin");
let CopyPlugin = require("copy-webpack-plugin");
let path = require("path");

module.exports = {
  entry: {
    app: "./js/app.js"
  },
  output: {
    filename: "[name].js",
    path: __dirname + "/public"
  },
  devServer: {
    contentBase: path.join(__dirname, "public"),
    compress: true,
    port: 9000,
    host: "0.0.0.0"
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.css$/,
        use: [
          // { loader: MiniCssExtractPlugin.loader, options: {} },
          "style-loader",
          "css-loader",
          "postcss-loader"
        ]
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: "elm-webpack-loader",
          options: { debug: true }
        }
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "[name].css"
    }),
    new CopyPlugin([{ from: "static" }])
  ]
};
