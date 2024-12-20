chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    console.log('Message from website:', message);

    // Check if the message type matches "PEERCOIN_BROWSER_EXTENSION"
    if (message.type === "PEERCOIN_BROWSER_EXTENSION") {
        // Forward the message to Flutter and handle the response
        chrome.runtime.sendMessage(message, (response) => {
            console.log('Response from Flutter:', response);

            // Send the response back to the website
            sendResponse(response);
        });

        // Indicate sendResponse will be handled asynchronously
        return true;
    }

    // Ignore messages that do not match the type
    return false;
});
