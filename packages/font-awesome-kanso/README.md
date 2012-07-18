Font Awesome Kanso
=================

Font Awesome for the kanso framework.

Usage
-----

Add the `@fontIconDirectory` variable to your main .less file so it matches your rewrites:

```css
@fontIconDirectory: '../font';
```

If you're adding less files individually, replace `@import "bootstrap/sprites.less"` with `@import "font-awesome.less"` in your main .less or bootsrap.less file. Otherwise, you can also just `@import "font-awesome.less"` after importing `bootstrap.less`.

You're done! See [Font Awesome](http://fortawesome.github.com/Font-Awesome/) for more.
