'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "57da9bf29ff876a529f3dd3ceb802744",
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
"index.html": "1d3a4b8f234d8e80ae5fd06c73ae5d16",
"/": "1d3a4b8f234d8e80ae5fd06c73ae5d16",
"main.dart.js": "09dca1bcc82ee8060761b6753cdd2efd",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"icons/Icon-192.png": "d8ed4418b7e314bca062868e82748e9f",
"icons/Icon-512.png": "2b839693a7a9604f2bde0cd67fd17abc",
"manifest.json": "10413e652ec1368443e68e96fa0b876f",
"assets/CHANGELOG.md": "08191b96d838640c50cb61922da26fbf",
"assets/AssetManifest.json": "9d6b78f863af2be92d0cdcf322a56c78",
"assets/NOTICES": "82c76a8f70b2bff69734a4f6fd7a9d4a",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "14de2c63eb470cec041f1cdaccd90674",
"assets/fonts/MaterialIcons-Regular.otf": "684bfb32c4ff85e42a2ff4f198291c07",
"assets/assets/img/setup-legal.png": "a5f0f4ec17060446a8f22f0aa143b3be",
"assets/assets/img/setup-consent.png": "11a73f79fff6cdd2f64a78793dcd0c32",
"assets/assets/img/setup-security.png": "0e38cf5b064c7559b1ca5f64fbd6e608",
"assets/assets/img/setup-protection.png": "7d1b5c326c6d648364d48c4d4c30c15d",
"assets/assets/img/list-empty.png": "0385368cc21600608a7f0c8ede129882",
"assets/assets/icon/ppc-icon-256.png": "e5893fe49cc40e589885c69aa6e8a1ed",
"assets/assets/icon/ppc-icon-48.png": "77a7f5e9cfab4965c9e356ade1087fde",
"assets/assets/icon/ppc-logo.png": "d564432a5793345b243bb4afcefd2611",
"assets/assets/icon/ppc-icon-white-48.png": "4cc5c9b1858468267167e5a9ec3ff62d",
"assets/assets/icon/ppc-icon-white-256.png": "817576d10026737e3423c39c05e1eed1",
"assets/assets/icon/ppc-icon-48-grey.png": "7db13d2026075562d5a2e3d8aed09c6e",
"assets/assets/icon/ppc-ios-app-xxl.png": "457ede70c42d9f8acc53d9e3c91137a2",
"assets/assets/icon/ppc-icon.png": "1614470da6cab032cc9afd1bad8ddbb3",
"assets/assets/icon/ppc-icon-white-bg.png": "60d7216eaee21cc15e50b2cea455a0c3",
"assets/assets/icon/ppc-icon-white.png": "96dc88b95eba378109c756e2e469ee1c",
"assets/assets/translations/hy.json": "66c74ce5ceceef3796fb6734c241e875",
"assets/assets/translations/zh.json": "7d40bd73d3682a349724dfdf4cf6f43b",
"assets/assets/translations/ps.json": "c902b0ee8ca7bd40575547b500613656",
"assets/assets/translations/tr.json": "f97caab441c86f1be983e840a040ef0a",
"assets/assets/translations/or.json": "f8299d5a1c8035e7dbb9c1f832d83a82",
"assets/assets/translations/mk.json": "01245d6ec1fd27e66fde6e4cf10e7da3",
"assets/assets/translations/sl.json": "b75a29c20e30bf5facd3977a40830b54",
"assets/assets/translations/hu.json": "1bf9ad6ae07f44b86eecb30bbe872265",
"assets/assets/translations/mr.json": "6dd483e39fae4e086313f4c160558504",
"assets/assets/translations/lt.json": "efaebb488bb9058c9fff675a3b1fc09c",
"assets/assets/translations/is.json": "dfc80853c88fbde9c2a58bc28e7889e3",
"assets/assets/translations/ha.json": "63d0003f5090aedb6ae1d42c25f0042f",
"assets/assets/translations/kk.json": "e4df2522410726d3bff749830dfc86f0",
"assets/assets/translations/nl.json": "d7d3a1f78cb3eacf2024dcb43ae0e3b2",
"assets/assets/translations/ms.json": "2939efcbb285ed59c5d89493093fc0f7",
"assets/assets/translations/ja.json": "5e337eaa6f6ee8637568dc110db36783",
"assets/assets/translations/de.json": "36679d3f061767425f3e2da9b0e2ed83",
"assets/assets/translations/ru.json": "51cae04f1616b8135db3493ac20e0c78",
"assets/assets/translations/pl.json": "ac415c4d760505e28e7d29538fc01ecb",
"assets/assets/translations/uk.json": "b76496e7bfa588928c8336e746925871",
"assets/assets/translations/gsw.json": "6b344347752ed968504329c59c426148",
"assets/assets/translations/ky.json": "9a591bf111bcb95a771eeaaa43653948",
"assets/assets/translations/fi.json": "3ffa92070921a3575ed865e52123be8b",
"assets/assets/translations/ta.json": "9134d850dbf40638a1b09db87a45274e",
"assets/assets/translations/fil.json": "1ffa1b9e5b8ca65138db173db43ea287",
"assets/assets/translations/ur.json": "ac22d9af8955beca0258af1fc304581a",
"assets/assets/translations/sk.json": "0a71b0e494d14e672bde51a9e60d1d18",
"assets/assets/translations/ml.json": "2ad5958aee76522830be0e8c6990069c",
"assets/assets/translations/az.json": "d0429ec42b1c7193a635824e650668f9",
"assets/assets/translations/pt.json": "37ab2a9544538f35a74b56f1fa8aeb4b",
"assets/assets/translations/be.json": "e04808f9a0d02dd4c9514c438aaf978b",
"assets/assets/translations/en.json": "b121eb605ed471e3cea0d4dae6aed50b",
"assets/assets/translations/ka.json": "9d3dae58d0abc2fc07ee64fc3cb9e18e",
"assets/assets/translations/pa.json": "7a6b26fa136c163640b69669e758a506",
"assets/assets/translations/my.json": "ccdd2894ebb01ad8d43cad9abca22f0f",
"assets/assets/translations/km.json": "dfb0a0da01ae96a19af3fa1c16097366",
"assets/assets/translations/it.json": "a6442d66bbe8c7df1ba032ee614ca719",
"assets/assets/translations/sr.json": "4378c4b2ccae27c21e5493b66ce53877",
"assets/assets/translations/hr.json": "c436003e507878661f5ba34d25543b89",
"assets/assets/translations/tl.json": "61d17d148d0e0929d633e73b4b49b4d6",
"assets/assets/translations/zu.json": "af7edfd5fd4fc1ec536b13351641f0db",
"assets/assets/translations/et.json": "34e6c6688b141125efa3798d6a35fdfb",
"assets/assets/translations/kn.json": "1fa59aee60984539fd165378605c7ff7",
"assets/assets/translations/cy.json": "0d9c9747ea88394e1bf5ead2478d9fbf",
"assets/assets/translations/sq.json": "c0d4aa554b07b9e05c705d5d62a49bf4",
"assets/assets/translations/ne.json": "d5cbeb7af367bdb496517a29958f2768",
"assets/assets/translations/bs.json": "7fe3381297c40a60990e5aef75dd9ec8",
"assets/assets/translations/fr.json": "2bdb44373eeb26ec65bf458831c62fa4",
"assets/assets/translations/am.json": "b4f3be60d6d25b79c3263cba6afd6408",
"assets/assets/translations/gu.json": "9422cc0f34634527ef8f2627305930ba",
"assets/assets/translations/el.json": "533d43bc87f718a0261fc466c67d8861",
"assets/assets/translations/bg.json": "d81c1319f3d0b5554fe744263c5aa5e0",
"assets/assets/translations/ro.json": "8d77e92abadada0e3d6a63d71559ba50",
"assets/assets/translations/hi.json": "89d9add9b39e680a82739e8c48645112",
"assets/assets/translations/ca.json": "acb8e63be1d51a91e4d0eef72e2041f9",
"assets/assets/translations/mn.json": "58a6762904bbaf66da02e8655b3b5c71",
"assets/assets/translations/si.json": "37603a1413ddbf53eb506ab093b562e1",
"assets/assets/translations/ko.json": "44d87affa659545cc6031a891fe8f402",
"assets/assets/translations/eu.json": "541a72307d01fda30a94772a40244871",
"assets/assets/translations/gl.json": "d80a3f42a63a0a09a2ce00e20dbd2efd",
"assets/assets/translations/he.json": "d6334e56fb17537b6cb23a5a86cf1ea4",
"assets/assets/translations/vi.json": "0d89aad1ce0087416d7c41bd5870a9d9",
"assets/assets/translations/nb_NO.json": "19b4328fa1bde609ec1e5c87887aa6ec",
"assets/assets/translations/fa.json": "99dc1642782c38e9042ca9a8929d817c",
"assets/assets/translations/lo.json": "dade3d63d039be2f83e67653bfa4e6a8",
"assets/assets/translations/cs.json": "9c0a9a2c5623b21c72bdc663a92e83c3",
"assets/assets/translations/te.json": "6b422e1f1a2df39834bccc99d1a4de27",
"assets/assets/translations/as.json": "a198abb46f02ac26fe290147a266a801",
"assets/assets/translations/zh_Hant.json": "bfcfab6931ac4fcf4ecaab2f6fffd225",
"assets/assets/translations/id.json": "667bb752cf7f1e4b2cf451ead0fd9dd1",
"assets/assets/translations/uz.json": "7529fc1afc5dd4aa292e3b1f614919ed",
"assets/assets/translations/bn_BD.json": "3382fb8a37af386078da7e11300aba27",
"assets/assets/translations/lv.json": "f8bf0ecf01f402b48d8cc35c9e87a41c",
"assets/assets/translations/af.json": "1b6ef893ec89ee5a09e4dca44c0cb233",
"assets/assets/translations/sw.json": "0cc05f07661c16052cf0a9a8836a8361",
"assets/assets/translations/da.json": "11ee2e9d2740dd74704147ccb9b38c3f",
"assets/assets/translations/th.json": "7a31db715086cedaca7194f2680026e1",
"assets/assets/translations/sv.json": "128ab08857405c8fda9296b079060b64",
"assets/assets/translations/es.json": "db2887102dccd97f502f932c92babdc4",
"assets/assets/translations/ar.json": "08788851981024b4b0ad1f875edf3bc5",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "d1fde2560be92c0b07ad9cf9acb10d05",
"canvaskit/chromium/canvaskit.js": "ffb2bb6484d5689d91f393b60664d530",
"canvaskit/chromium/canvaskit.wasm": "393ec8fb05d94036734f8104fa550a67",
"canvaskit/canvaskit.js": "5caccb235fad20e9b72ea6da5a0094e6",
"canvaskit/canvaskit.wasm": "d9f69e0f428f695dc3d66b3a83a4aa8e",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
