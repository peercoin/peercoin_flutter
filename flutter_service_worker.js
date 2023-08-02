'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "6ff9dc333fd4d722285c794ed6ae17c5",
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
"index.html": "d18381d570ebd04245d8346ec9b152e8",
"/": "d18381d570ebd04245d8346ec9b152e8",
"main.dart.js": "5baedd11d712073858c76b31fcdb428d",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"icons/Icon-192.png": "d8ed4418b7e314bca062868e82748e9f",
"icons/Icon-512.png": "2b839693a7a9604f2bde0cd67fd17abc",
"manifest.json": "10413e652ec1368443e68e96fa0b876f",
"assets/CHANGELOG.md": "f193cbe1423ef08165950213ee7dba26",
"assets/AssetManifest.json": "9d6b78f863af2be92d0cdcf322a56c78",
"assets/NOTICES": "8aa4020420b8cf7872d99d20353a4074",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "14de2c63eb470cec041f1cdaccd90674",
"assets/fonts/MaterialIcons-Regular.otf": "1ba78243876a2d42061a7b91ef72d3e8",
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
"assets/assets/translations/zh.json": "e3c87135c52a1b9aa6d3c48593ce335f",
"assets/assets/translations/ps.json": "6ece5c2c0266ce1e5b2be752443228a1",
"assets/assets/translations/tr.json": "1be69ce16109b98d5eed456798041c59",
"assets/assets/translations/or.json": "f8299d5a1c8035e7dbb9c1f832d83a82",
"assets/assets/translations/mk.json": "a19eb454a582dfd5ed24bb6abb30a241",
"assets/assets/translations/sl.json": "05a13e5e21a6ec9ddc4f1a61d3095c8f",
"assets/assets/translations/hu.json": "65c103b7385f8a03121c283214af497b",
"assets/assets/translations/mr.json": "6dd483e39fae4e086313f4c160558504",
"assets/assets/translations/lt.json": "efaebb488bb9058c9fff675a3b1fc09c",
"assets/assets/translations/is.json": "f0fa737b63cd56adefb0de8e008ad9a1",
"assets/assets/translations/ha.json": "7b4b38bc86f095d6c9c06dd8f30d8ffb",
"assets/assets/translations/kk.json": "69971590dae496edb6ab79163dfebe6b",
"assets/assets/translations/nl.json": "86197af5697abbfa7e6f322540dcd877",
"assets/assets/translations/ms.json": "2939efcbb285ed59c5d89493093fc0f7",
"assets/assets/translations/ja.json": "ed486cc3c61661343d636a38ddc15485",
"assets/assets/translations/de.json": "e26ebfceb42a0d7a162191349b5d5518",
"assets/assets/translations/ru.json": "c7cd1968fa286b3d75379637b53abe8e",
"assets/assets/translations/pl.json": "2befcb9de845a6d34f49d6770e3709b3",
"assets/assets/translations/uk.json": "ba7ff1e562e4dc5b9003ac1ac8efacba",
"assets/assets/translations/gsw.json": "a6a5b48e43e697571b0615586551030c",
"assets/assets/translations/ky.json": "fbe0ecc07e876bec44e0222e7420273c",
"assets/assets/translations/fi.json": "f2ca354413879b053584d26431318c81",
"assets/assets/translations/ta.json": "c1cfbb6ce6e5c2b17258e6acb471d528",
"assets/assets/translations/fil.json": "50490ef103ca6f2687e96cda7fe94d86",
"assets/assets/translations/ur.json": "a13cc625d900f2fe4b06701478205e2a",
"assets/assets/translations/sk.json": "0a71b0e494d14e672bde51a9e60d1d18",
"assets/assets/translations/ml.json": "2ad5958aee76522830be0e8c6990069c",
"assets/assets/translations/az.json": "f26829109438bf7888d568f23c989a4d",
"assets/assets/translations/pt.json": "ef3c8e23e41fd57229183ca1ffd85272",
"assets/assets/translations/be.json": "20411df4b823a0a51cc5c49d6af919f5",
"assets/assets/translations/en.json": "a72564f75fbf2a238899d8a1d3c496fa",
"assets/assets/translations/ka.json": "b1a40407d9e15b568b655099e775688d",
"assets/assets/translations/pa.json": "9d80f063c435332a8f9a4fa56e8cdc32",
"assets/assets/translations/my.json": "6a98c2cb9d47a4bd57f346bd14aae414",
"assets/assets/translations/km.json": "dfb0a0da01ae96a19af3fa1c16097366",
"assets/assets/translations/it.json": "e74b99024e6c40b3332b47f68b598bcf",
"assets/assets/translations/sr.json": "4378c4b2ccae27c21e5493b66ce53877",
"assets/assets/translations/hr.json": "6931c07034b7602724c30562c565dcc1",
"assets/assets/translations/tl.json": "60343ba2eb972d79ee63a68fec32d9fc",
"assets/assets/translations/zu.json": "63786a03373a0d823aae074f62e5ddb0",
"assets/assets/translations/et.json": "34e6c6688b141125efa3798d6a35fdfb",
"assets/assets/translations/kn.json": "1fa59aee60984539fd165378605c7ff7",
"assets/assets/translations/cy.json": "cb389d7bbc0336f1d169e24384ce3f40",
"assets/assets/translations/sq.json": "ae4ba18907e07048fdcb51931158ffff",
"assets/assets/translations/ne.json": "d5cbeb7af367bdb496517a29958f2768",
"assets/assets/translations/bs.json": "89685a064366ebc091afeda11b31e997",
"assets/assets/translations/fr.json": "d68c74b9fa561ef4324495af925a30f2",
"assets/assets/translations/am.json": "b4f3be60d6d25b79c3263cba6afd6408",
"assets/assets/translations/gu.json": "9422cc0f34634527ef8f2627305930ba",
"assets/assets/translations/el.json": "f71bba9c18a873a0f5816264cb175d2e",
"assets/assets/translations/bg.json": "817e9021d83e3ee549c6d1e649a361cb",
"assets/assets/translations/ro.json": "ae9c323da6816248e3641e75145e5847",
"assets/assets/translations/hi.json": "0d7c5f74b16d33e8c5e6e4eb888b94c4",
"assets/assets/translations/ca.json": "acb8e63be1d51a91e4d0eef72e2041f9",
"assets/assets/translations/mn.json": "de60fd7adc864de919d900a8563a0a8f",
"assets/assets/translations/si.json": "37603a1413ddbf53eb506ab093b562e1",
"assets/assets/translations/ko.json": "070e546f422b8b434c2f777960651fe3",
"assets/assets/translations/eu.json": "541a72307d01fda30a94772a40244871",
"assets/assets/translations/gl.json": "937b0642879f7ce11d75dc8a682a44e3",
"assets/assets/translations/he.json": "548d301a5efa1ecd73c87260904943ed",
"assets/assets/translations/vi.json": "546a8dfeff739cf1532f06bb2d8a3b3e",
"assets/assets/translations/nb_NO.json": "1a601f2f165a503bef5d856a586ad58a",
"assets/assets/translations/fa.json": "1cd32f9b76cba6596dba9afdf3788a2e",
"assets/assets/translations/lo.json": "dade3d63d039be2f83e67653bfa4e6a8",
"assets/assets/translations/cs.json": "b5b69b04fcc16366bfdd49cbe94cf4e0",
"assets/assets/translations/te.json": "dc132a3d10110dc163813da0b27a9af1",
"assets/assets/translations/as.json": "a198abb46f02ac26fe290147a266a801",
"assets/assets/translations/zh_Hant.json": "05f2c786560556be30694f0c0b893830",
"assets/assets/translations/id.json": "be38e1a8ec19aaebda6c71df4698c657",
"assets/assets/translations/uz.json": "aa3722a396080b6ef7ce840e86ea4618",
"assets/assets/translations/bn_BD.json": "ee65f0c62c5334a24abdb3cd015d1cd7",
"assets/assets/translations/lv.json": "a9f6f549eb85e3109284bef579498e14",
"assets/assets/translations/af.json": "1b6ef893ec89ee5a09e4dca44c0cb233",
"assets/assets/translations/sw.json": "086efe66bf1d0945c4383e81b16cd144",
"assets/assets/translations/da.json": "9da9e9679f581baa870a14a60eee782c",
"assets/assets/translations/th.json": "7c2d709dda9dc74477b3d5ef0b56d1f3",
"assets/assets/translations/sv.json": "0eae9b2f49f736377d322fd48568a030",
"assets/assets/translations/es.json": "55543837534f17a8e8178e69e64d8a67",
"assets/assets/translations/ar.json": "1b87e7542cc7e2daba23db16f176f5f3",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a"};
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
