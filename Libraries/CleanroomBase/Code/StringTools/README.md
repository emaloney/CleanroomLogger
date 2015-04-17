# StringTools

The StringTools package of [`CleanroomBase`](https://github.com/emaloney/CleanroomBase) contains tools for simplifying the handling of `String`s.

## Pluralizer

`Pluralizer`s are used to represent multiple *forms* of a *term* intended to be used with specific *quantities*.

Here's an example of a `Pluralizer` that represents two forms of the term "`goose`":

```swift
let gooser = Pluralizer(singular: "goose", plural: "geese")
```

By calling the `termForQuantity()` function, `gooser` can then be used to select the appropriate form of the term for a given quantity:

```swift
let oneGoose = gooser.termForQuantity(1)      // oneGoose will be "goose"
let threeGeese = gooser.termForQuantity(3)    // threeGeese will be "geese"
```

### Quantity Replacement

You can also refer to the value passed to the `termForQuantity()` function from within the terms passed to `Pluralizer`'s constructor:

```swift
let gooser = Pluralizer(singular: "one goose", plural: "{#} geese")
```

With this type of `gooser`, the return values would be different:

```swift
let oneGoose = gooser.termForQuantity(1)      // oneGoose will be "one goose"
let threeGeese = gooser.termForQuantity(3)    // threeGeese will be "3 geese"
```

### Zero Quantities

Normally, when specifying a quantity of zero, the `Pluralizer` uses the plural form of the term:

```swift
let noGeese = gooser.termForQuantity(0)       // noGeese will be "0 geese"
```

If needed, the zero-quantity form of the term can also be explicitly specified to the initializer:

```swift
let gooser = Pluralizer(singular: "one goose", plural: "{#} geese", none: "no geese")
```

With this type of `gooser`, the return values would be different:

```swift
let noGeese = gooser.termForQuantity(0)       // noGeese will be "no geese"
let oneGoose = gooser.termForQuantity(1)      // oneGoose will be "one goose"
let threeGeese = gooser.termForQuantity(3)    // threeGeese will be "3 geese"
```


