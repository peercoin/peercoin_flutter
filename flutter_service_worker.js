'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "af60a81b72a879197cfa71cf4f70b1b8",
"splash/img/light-2x.png": "0406724cfad97ca88d46dfac0340e48c",
"splash/img/dark-4x.png": "3dbea66ebb7a3302e8dcae4fc8c9d8a4",
"splash/img/light-3x.png": "863fff472ecfa710700cde74a4f4bd11",
"splash/img/dark-3x.png": "863fff472ecfa710700cde74a4f4bd11",
"splash/img/light-4x.png": "3dbea66ebb7a3302e8dcae4fc8c9d8a4",
"splash/img/dark-2x.png": "0406724cfad97ca88d46dfac0340e48c",
"splash/img/dark-1x.png": "cee13247444b1493e230450ac7f2f3ba",
"splash/img/light-1x.png": "cee13247444b1493e230450ac7f2f3ba",
"splash/splash.js": "123c400b58bea74c1305ca3ac966748d",
"splash/style.css": "2e6df68c18efc965e0beb1b72c5b4ae9",
"favicon.ico": "ad86c3b942b739addeee37dae114ade7",
"index.html": "789dcfbc3ca546b1462ceb37b52fd394",
"/": "789dcfbc3ca546b1462ceb37b52fd394",
"main.dart.js": "f31cb40d0ddbb9dd67080ae512d60512",
"flutter.js": "1cfe996e845b3a8a33f57607e8b09ee4",
"icons/Icon-192.png": "d8ed4418b7e314bca062868e82748e9f",
"icons/Icon-512.png": "2b839693a7a9604f2bde0cd67fd17abc",
"manifest.json": "10413e652ec1368443e68e96fa0b876f",
"assets/CHANGELOG.md": "6985c4bccf0bebcbf32512700befa389",
"assets/AssetManifest.json": "83e86804fba17c920830c4f80149a802",
"assets/NOTICES": "9d1586d2338688d98394b52f16e18bb5",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/shaders/ink_sparkle.frag": "5204a3971c531eae051cf6e2abe83b1e",
"assets/fonts/MaterialIcons-Regular.otf": "e7069dfd19b331be16bed984668fe080",
"assets/assets/img/setup-legal.png": "a5f0f4ec17060446a8f22f0aa143b3be",
"assets/assets/img/setup-launch.png": "12fc61363b074ce7c51cb1f353433345",
"assets/assets/img/setup-consent.png": "11a73f79fff6cdd2f64a78793dcd0c32",
"assets/assets/img/setup-security.png": "0e38cf5b064c7559b1ca5f64fbd6e608",
"assets/assets/img/setup-protection.png": "7d1b5c326c6d648364d48c4d4c30c15d",
"assets/assets/img/list-empty.png": "0385368cc21600608a7f0c8ede129882",
"assets/assets/icon/ppc-icon-256.png": "e5893fe49cc40e589885c69aa6e8a1ed",
"assets/assets/icon/ppc-icon-48.png": "77a7f5e9cfab4965c9e356ade1087fde",
"assets/assets/icon/ppc-logo.png": "d564432a5793345b243bb4afcefd2611",
"assets/assets/icon/ppc-icon-white-48.png": "4cc5c9b1858468267167e5a9ec3ff62d",
"assets/assets/icon/ppc-icon-white-256.png": "817576d10026737e3423c39c05e1eed1",
"assets/assets/icon/ppc-ios-app-xxl.png": "457ede70c42d9f8acc53d9e3c91137a2",
"assets/assets/icon/ppc-icon.png": "1614470da6cab032cc9afd1bad8ddbb3",
"assets/assets/icon/ppc-icon-white-bg.png": "60d7216eaee21cc15e50b2cea455a0c3",
"assets/assets/translations/zh.json": "9efc6fd15862aa3daedcb9169001c40a",
"assets/assets/translations/tr.json": "72cf2373a9b326bcbd5373783ed0d74e",
"assets/assets/translations/ha.json": "7b4b38bc86f095d6c9c06dd8f30d8ffb",
"assets/assets/translations/nl.json": "86197af5697abbfa7e6f322540dcd877",
"assets/assets/translations/ja.json": "ed486cc3c61661343d636a38ddc15485",
"assets/assets/translations/de.json": "e26ebfceb42a0d7a162191349b5d5518",
"assets/assets/translations/ru.json": "1de871a6d174d7393a6f68c969228608",
"assets/assets/translations/pl.json": "2befcb9de845a6d34f49d6770e3709b3",
"assets/assets/translations/uk.json": "ba7ff1e562e4dc5b9003ac1ac8efacba",
"assets/assets/translations/fil.json": "50490ef103ca6f2687e96cda7fe94d86",
"assets/assets/translations/ur.json": "a13cc625d900f2fe4b06701478205e2a",
"assets/assets/translations/pt.json": "c7eee21110f059b4d4ed3b89ba0245c1",
"assets/assets/translations/en.json": "47ea6b4914efc16aa68fb3e20fc66bde",
"assets/assets/translations/it.json": "e74b99024e6c40b3332b47f68b598bcf",
"assets/assets/translations/hr.json": "6931c07034b7602724c30562c565dcc1",
"assets/assets/translations/fr.json": "d68c74b9fa561ef4324495af925a30f2",
"assets/assets/translations/el.json": "7b610e956700ed0d2e7fa177548dc3d0",
"assets/assets/translations/ro.json": "c2bd1c221a14226d1651bcc95510fbc3",
"assets/assets/translations/hi.json": "0cc5c79533cd77007e99fb7841dd92c2",
"assets/assets/translations/ko.json": "4c7eb52f77072d0867d9920b4af68fa9",
"assets/assets/translations/vi.json": "546a8dfeff739cf1532f06bb2d8a3b3e",
"assets/assets/translations/nb_NO.json": "1a601f2f165a503bef5d856a586ad58a",
"assets/assets/translations/fa.json": "ae88f53a588938bc6e64aa7d6e75d9ad",
"assets/assets/translations/id.json": "1ca3f62f57a27367416363bfbbdddf65",
"assets/assets/translations/bn_BD.json": "751f0603d20340345de2175d9040f150",
"assets/assets/translations/sw.json": "086efe66bf1d0945c4383e81b16cd144",
"assets/assets/translations/da.json": "9da9e9679f581baa870a14a60eee782c",
"assets/assets/translations/th.json": "e8ce8140eb31f34053a299b72579eec0",
"assets/assets/translations/sv.json": "0eae9b2f49f736377d322fd48568a030",
"assets/assets/translations/es.json": "30cddc03ec655bc5e96371535a24147f",
"assets/assets/translations/ar.json": "6c1937b7464ea464bc73269f63083f03",
"canvaskit/canvaskit.js": "97937cb4c2c2073c968525a3e08c86a3",
"canvaskit/profiling/canvaskit.js": "c21852696bc1cc82e8894d851c01921a",
"canvaskit/profiling/canvaskit.wasm": "371bc4e204443b0d5e774d64a046eb99",
"canvaskit/canvaskit.wasm": "3de12d898ec208a5f31362cc00f09b9e"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
