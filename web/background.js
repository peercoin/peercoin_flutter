if (!chrome.runtime.onMessage.hasListener) {
    chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
        console.log('Background script received event:', message);

        if (message.type === '$PEERCOIN_BROWSER_EXTENSION') {
            console.log('Forwarding $PEERCOIN_BROWSER_EXTENSION to extension page:', message.detail);

            chrome.runtime.sendMessage(message, (response) => {
                if (chrome.runtime.lastError) {
                    if (chrome.runtime.lastError.message === 'Could not establish connection. Receiving end does not exist.') {
                        console.log('No active listener. Retrying or handling appropriately.');
                    } else {
                        console.error('Error forwarding message:', chrome.runtime.lastError.message);
                    }
                } else {
                    console.log('Response from extension page:', response);
                }
            });

            sendResponse({ success: true, detail: 'Message forwarded to extension page' });
            return true;
        }

        sendResponse({ success: true });
    });
    chrome.runtime.onMessage.hasListener = true;
}