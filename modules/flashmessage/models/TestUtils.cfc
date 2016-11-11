component name="TestUtils" singleton {
    
    /**
     * @flashStorage.inject coldbox:flash
     * @config.inject coldbox:setting:flashmessage
     */
    public TestUtils function init(any flashStorage, any config) {
        instance.flashKey = arguments.config.flashKey;
        singleton.flashStorage = arguments.flashStorage;

        return this;
    }

    public boolean function messageExists(required string checkMessage, string type = "") {
        var messages = getMessages();
        var exists = false;
        for (var message in messages) {
            if (message.message == arguments.checkMessage) {
                if (arguments.type == "" || (arguments.type != "" && arguments.type == message.type)) {
                    exists = true;
                }
            }
        }
        return exists;
    }

    public array function getMessages() {
        return singleton.flashStorage.get(instance.flashKey, []);
    }

}