# Flash Messages

[![Build Status](https://travis-ci.org/elpete/flashmessage.svg?branch=master)](https://travis-ci.org/elpete/flashmessage)

## Easy, customizable messages across requests for ColdFusion

### About
Flash Messages is a simple-to-use ColdFusion package for displaying messages across requests using flash or session RAM.

You can drop the current version into your application and start using flash messages customized for Bootstrap's `alert` classes.  Or, you can create your own templates and control the look of the flash messages completely!

### Installation
#### Using ColdBox
None!  `ModuleConfig.cfc` wires everything up for you.  Just inject FlashMessage into your application using the `FlashMessage@flashmessage` Wirebox binding.

#### Other / No Framework
The `FlashMessage.cfc` needs three parameters to work:

1. A reference to your flash storage object.  This object will need `get(key)` and `put(key, value)` methods.
2. A config object with the following properties:
    1. A unique `flashKey` name to avoid naming conflicts.
    2. A reference to your `containerTemplatePath`.  This is the view that surrounds each of the individual messages.  It will have references to a `flashMessages` array and your `messageTemplatePath`.
    3. A reference to your `messageTemplatePath`.  This is the view that represents a single message in FlashMessage.  It will have a reference to a single flash message.  The name is chosen by you in your container template.

Create your object with your two parameters and then use it as normal.

### Usage

Create the `FlashMessage.cfc` object either by instantiating the object yourself (`new path.to.FlashMessage()`) or through a dependency injection framework like Wirebox (`inject="FlashMessage@flashmessage"`);


#### Default Messages
`public void function message(required string text, string type = "default")`

The `message()` function takes a string for the text and an optional type and adds it to the flash storage for the next request.

#### "Magic Methods"
Alternatively, you can call any named method to have that name become the message type.  For example:
```js
flash.danger("My Awesome Message");
// becomes...
flash.message("My Awesome Message", "danger");
```

Easy, simple, and cool.

> There is a small list of reserved words for this feature:
> 
> * message
> * render
> * init
> * onMissingMethod
>
> If you need to use any of these words as the type, set the type using `flash.message()`


#### Rendering the Flash Messages
`public any function render()`

The `render()` function compiles the provided container template and message template(s) and returns the html content.

A common place to put the `render()` call is in your main layout file (`layouts/main` in Coldbox).

Calling `render()` also clears out the flash message store.


### Customization

#### Custom Flash Key
Flash Message uses a unique key to avoid naming conflicts in the flash scope.  You can set your own flash key in your configuration structure.

```js
var config = {
    flashKey = "myCustomFlashKey"
};

var flash = new path.to.FlashMessage(flashStorage, config);
```

> In Coldbox, the flash key may be defined in your `config/Coldbox.cfc` file using the `flashmessage` key:
> 
> ```js
> flashmessage = {
>     flashKey = "myCustomFlashKey"
> };
> ```

#### Custom Templates
By default, Flash Message provides a Bootstrap-ready template for display your messages.  You can customize this by passing in the path to your container template and your message template inside a config structure.

```js
var config = {
    containerTemplatePath = "/path/to/my/CustomFlashMessageContainer.cfm",
    messageTemplatePath = "/path/to/my/CustomFlashMessage.cfm"    
};

var flash = new path.to.FlashMessage(flashStorage, config);
```

> In Coldbox, the template paths may be defined in your `config/Coldbox.cfc` file using the `flashmessage` key:
> 
> ```js
> flashmessage = {
>     containerTemplatePath = "/views/_templates/MyCustomFlashMessageContainer.cfm",
>     messageTemplatePath = "/views/_templates/MyCustomFlashMessage.cfm"
> };
> ```

##### Container Template
The container template has access to a `flashMessages` array (can be empty) and a reference to the `messageTemplatePath`.

In your custom template, you should loop through the `flashMessages` array and include the `messageTemplatePath` for each record.

##### Message Template
The message template has access to an individual flash message (format below).  The name of the variable is set by you in your container template.

#### Message Format
Messages take the following format:
```js
{ message: "message text here", type: "type name here" }
```

### Testing
Flash Message includes a basic `TestUtils` component to help you out in testing.  You can instantiate it either manually (`new path.to.flashmessage.TestUtils(flashStorage, config)`) or through a Wirebox binding (`testUtils@flashmessage`).

`Test Utils` only includes two methods, but that should be enough.

#### `public array function getMessages()`
Returns all the messages currently in the flash storage.  Returns an empty array if there are no messages.

#### `public boolean function messageExists(required string checkMessage, string type = "")`
Returns true if the provided message exists, false if not.
If a type is provided, it will also check that the types are equal.

For example, if I had the following flash message — `{ message = "Test message", type = "warning" }` — and I called `testUtils.messageExists("Test message", "default")`, I would receive `false`.  If I called `testUtils.messageExists("Test message")`, I would receive `true`.