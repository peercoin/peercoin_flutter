window.sendPeercoinExtensionMessage = function (message) {
    const extensionMessage = {
        type: '$PEERCOIN_BROWSER_EXTENSION',
        payload: message,
        timestamp: Date.now()
    };
    window.postMessage(extensionMessage, '*');
};

console.log('Peercoin extension page script loaded');