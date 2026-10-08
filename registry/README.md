# Recipes

These are the parts of poise you copy into your app and own. Each one is built on the ten motion words, so it follows whatever personality your app uses and respects reduce motion without you doing anything.

Every recipe lives in its own folder under `lib/`:

```
lib/pressable/
├── pressable.dart   the code
├── recipe.yaml      the facts: name, which words it uses, which files, which other recipes it needs
└── README.md        what it's for, when to use it, and an example
```

To use one, copy its folder into `lib/poise/` in your app, along with any recipes listed under `needs` in its `recipe.yaml`, and add `poise` to your dependencies. That's all. Recipes only ever depend on Flutter, poise and each other.

The code here is compiled and tested in this repo, and the gallery runs on these exact files, so what you copy is what's been checked.
