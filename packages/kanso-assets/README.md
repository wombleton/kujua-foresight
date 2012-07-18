## kanso-assets

Transparent file compilation and dependency management for the [kanso](http://github.com/kanso/kanso) framework

## Usage

Add `kanso-assets` to your dependencies section in `kanso.json`.

```javascript
  ...
  "dependencies": {
    "kanso-assets": null,
    ...
  }
```

Run `kanso install` to fetch the package.

Then add the following specially formatted comment to any html file:

```html
  <!-- js('app.coffee') -->
```

This tells kanso-assets to look in the `assets` folder and compile the `app.coffee` (or `app.js` if you prefer) file it finds there with its dependencies. It then replaces the comment with the following tag referring to the compiled file:

```html
  <script src="js/app.js">
```

Dependencies are marked up as follows:

```coffeescript
  #= require dependency
```

or, for JavaScript:

```javascript
  //= require dependency
```

See <http://github.com/TrevorBurnham/snockets> for more details on how dependencies.

## Configuration

You can change the defaults by adding a `kanso-assets` section to `kanso.json`.

```javascript
  ...
  "kanso-assets": {
    "assets": "assets"
    "minify": true // defaults to false
    "output": "static/js"
    "prefix": "prefix"
  }
```

## Caveat

This package is still in its infancy. Development mode will come shortly.
