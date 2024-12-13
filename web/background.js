chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    // Ensure we're handling Peercoin-specific messages
    if (message.type === '$PEERCOIN_BROWSER_EXTENSION') {
        console.log('Background script received Peercoin extesion message:', message);

        try {
            // Example message processing logic
            // You would replace this with your actual extension-specific logic
            sendResponse({
                success: true,
                message: 'Message received and processed',
                receivedPayload: message.payload
            });
        } catch (error) {
            console.error('Error in background script:', error);
            sendResponse({
                success: false,
                error: error.message
            });
        }

        // Critical: return true to enable asynchronous sendResponse
        return true;
    }
});

console.log('Extension background script initialized');