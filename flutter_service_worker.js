'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "dd1469d74072d18be062cf2f6244caa1",
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
"index.html": "e81b5d9d829096e31b37895de62be1dc",
"/": "e81b5d9d829096e31b37895de62be1dc",
"main.dart.js": "a1b7107e32871fd6a9cc407b6e466a74",
"flutter.js": "eb2682e33f25cd8f1fc59011497c35f8",
"icons/Icon-192.png": "d8ed4418b7e314bca062868e82748e9f",
"icons/Icon-512.png": "2b839693a7a9604f2bde0cd67fd17abc",
"manifest.json": "10413e652ec1368443e68e96fa0b876f",
"assets/CHANGELOG.md": "d4c190953c9bc006113d1ed56b86d59f",
"assets/AssetManifest.json": "83e86804fba17c920830c4f80149a802",
"assets/NOTICES": "87fa1ab8f163515f127a1ba2730f74eb",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
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
"assets/assets/translations/zh.json": "2910c94a851dac9980290d47bc81ef54",
"assets/assets/translations/tr.json": "2b7af67377d6fbb82f0e75750ae7e5ca",
"assets/assets/translations/ha.json": "7b4b38bc86f095d6c9c06dd8f30d8ffb",
"assets/assets/translations/nl.json": "6fa553a56049131b1a097d0e31432d2f",
"assets/assets/translations/ja.json": "184bfe7cde55cb98749ecdcc1433f98e",
"assets/assets/translations/de.json": "11a511ba61f39a342c8d6cb14f2ac59a",
"assets/assets/translations/ru.json": "5b9493cde52d7d2c33becc041122df69",
"assets/assets/translations/pl.json": "3f439431cad3318020514d85698e08aa",
"assets/assets/translations/uk.json": "8dfd1d5d368c15b220a8e561b569632c",
"assets/assets/translations/fil.json": "992cccd784d3ea8b324845b4bc60c247",
"assets/assets/translations/ur.json": "e8cfdb41d99036218cf52d7646f761b0",
"assets/assets/translations/pt.json": "aca1f1bd8331e3f33722522edd199878",
"assets/assets/translations/en.json": "26caf64a4da6b72cb93616252c9507ef",
"assets/assets/translations/it.json": "e757ba072cb1dd37f54a401eaf891d23",
"assets/assets/translations/hr.json": "6931c07034b7602724c30562c565dcc1",
"assets/assets/translations/fr.json": "932e8113727feae0eb3df390a7882b48",
"assets/assets/translations/el.json": "7b610e956700ed0d2e7fa177548dc3d0",
"assets/assets/translations/ro.json": "021d83552eec5f738752393f69ce34d4",
"assets/assets/translations/hi.json": "082d7a285183773095ce94fd8a60ee67",
"assets/assets/translations/ko.json": "6c5ab2d069cb4e2980f0585a124044be",
"assets/assets/translations/vi.json": "ed0706bebf29d34a0888100eaeda2dca",
"assets/assets/translations/nb_NO.json": "a8d40b5583165ce839cc9d0b9ba4a8c2",
"assets/assets/translations/fa.json": "3da81359335ef5066903829f8e46dd1a",
"assets/assets/translations/id.json": "e932db40a6b69c674ed42ed6b3450d3b",
"assets/assets/translations/bn_BD.json": "7c56605b29574736cb13ac0dea7782bc",
"assets/assets/translations/sw.json": "367e4fdb078739f880139ad9fe248134",
"assets/assets/translations/da.json": "769497d80d34bf5518cfa12a4ba6eb04",
"assets/assets/translations/th.json": "8c887614f9237edced420ee50d29822a",
"assets/assets/translations/sv.json": "ae3e9c58fec87b5297075f23cc8408f3",
"assets/assets/translations/es.json": "403a4ac48c62e380cd5167727472680c",
"assets/assets/translations/ar.json": "e88ddc35824bca52d4fb7988d6c0815f",
"canvaskit/canvaskit.js": "c2b4e5f3d7a3d82aed024e7249a78487",
"canvaskit/profiling/canvaskit.js": "ae2949af4efc61d28a4a80fffa1db900",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/NOTICES",
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
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
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
