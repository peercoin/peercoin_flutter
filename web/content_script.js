function injectPageScript() {
    const script = document.createElement('script');
    script.src = chrome.runtime.getURL('page_script.js');
    script.onload = () => {
        console.log('Peercoin extension page script injected successfully.');
        script.remove(); // Optional: remove script after injection
    };
    (document.head || document.documentElement).appendChild(script);
}

// Inject the script when content script loads
injectPageScript();

// Listener for messages from the web page
window.addEventListener('message', (event) => {
    // Validate the event source and ensure it's a Peercoin-specific message
    if (event.source !== window || !event.data || event.data.type !== 'PEERCOIN_BROWSER_EXTENSION') return;

    console.log('Content script received Peercoin extension event:', event.data);

    // Relay the Peercoin event to the background script
    chrome.runtime.sendMessage(event.data, (response) => {
        if (chrome.runtime.lastError) {
            console.error('Error sending Peercoin extension message to background:', chrome.runtime.lastError.message);
        } else {
            console.log('Received response from extension background script:', response);
        }
    });
});

console.log('Peercoin extension content script initialized.');