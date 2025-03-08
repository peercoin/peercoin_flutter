'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "9d43117ad6945782231d2b70b9c184af",
"version.json": "b8b2a69cae0a9ce8039d6e07bc638572",
"splash/img/light-2x.png": "0406724cfad97ca88d46dfac0340e48c",
"splash/img/dark-4x.png": "3dbea66ebb7a3302e8dcae4fc8c9d8a4",
"splash/img/light-3x.png": "863fff472ecfa710700cde74a4f4bd11",
"splash/img/dark-3x.png": "863fff472ecfa710700cde74a4f4bd11",
"splash/img/light-4x.png": "3dbea66ebb7a3302e8dcae4fc8c9d8a4",
"splash/img/dark-2x.png": "0406724cfad97ca88d46dfac0340e48c",
"splash/img/dark-1x.png": "cee13247444b1493e230450ac7f2f3ba",
"splash/img/light-1x.png": "cee13247444b1493e230450ac7f2f3ba",
"splash/splash.js": "123c400b58bea74c1305ca3ac966748d",
"splash/style.css": "8632f66b778ab6afb1cdff5a5d50857a",
"favicon.ico": "ad86c3b942b739addeee37dae114ade7",
"index.html": "9b890bf2541e42f176f425b8f73e730e",
"/": "9b890bf2541e42f176f425b8f73e730e",
"main.dart.js": "39d0913e3fba0261fd44cf5b5b56ced5",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"icons/Icon-192.png": "d8ed4418b7e314bca062868e82748e9f",
"icons/Icon-512.png": "2b839693a7a9604f2bde0cd67fd17abc",
"manifest.json": "ff12baa35f1b91e7b9e67a490d458564",
"assets/CHANGELOG.md": "411caea1d1b3349be0a9a592cb21b4bd",
"assets/AssetManifest.json": "1a5d7e2d9cfc41247d97f52d65391621",
"assets/NOTICES": "b7efab00082c6df72fab7d68326f3d35",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "5bafe60be1b7937d949558e9b50f1a7c",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "ac43e8cafa38e0c12df18da84bad9d79",
"assets/fonts/MaterialIcons-Regular.otf": "8b5f3f8d4bd9b3095d6519d1bede6dc0",
"assets/assets/img/setup-legal.png": "6df4b8f279087247b64aa6f48db166d8",
"assets/assets/img/setup-consent.png": "5114ed20317c6f3a1db71a91b6b19f6a",
"assets/assets/img/setup-security.png": "1c2f69c434fd1014d41fe42614aa9430",
"assets/assets/img/setup-protection.png": "172f677d94a8b34c16550f9157b0e404",
"assets/assets/img/list-empty.png": "76912e9df8d196d382d6aca13d25dac0",
"assets/assets/icon/ppc-icon-256.png": "e5893fe49cc40e589885c69aa6e8a1ed",
"assets/assets/icon/ppc-icon-48.png": "77a7f5e9cfab4965c9e356ade1087fde",
"assets/assets/icon/ppc-logo.png": "d564432a5793345b243bb4afcefd2611",
"assets/assets/icon/ppc-icon-white-48.png": "4cc5c9b1858468267167e5a9ec3ff62d",
"assets/assets/icon/ppc-icon-white-256.png": "817576d10026737e3423c39c05e1eed1",
"assets/assets/icon/ppc-icon-48-grey.png": "7db13d2026075562d5a2e3d8aed09c6e",
"assets/assets/icon/roast-icon-64-grey.png": "769d08cea8c408b800a71c9c904dff5b",
"assets/assets/icon/roast-icon-64.png": "3eac379649eb28e2a99f27257c81fc51",
"assets/assets/icon/ppc-ios-app-xxl.png": "457ede70c42d9f8acc53d9e3c91137a2",
"assets/assets/icon/ppc-icon.png": "1614470da6cab032cc9afd1bad8ddbb3",
"assets/assets/icon/ppc-icon-white-bg.png": "60d7216eaee21cc15e50b2cea455a0c3",
"assets/assets/icon/ppc-icon-white.png": "96dc88b95eba378109c756e2e469ee1c",
"assets/assets/translations/hy.json": "39714a9d4a90ebfc0f0bafcff00c7fe3",
"assets/assets/translations/zh.json": "2bf211f97ff4d7971771a31918800baf",
"assets/assets/translations/ps.json": "0469166826219824c9d8a5a46fda1c75",
"assets/assets/translations/tr.json": "bc18d37e40da638ef680db9e21ef1add",
"assets/assets/translations/or.json": "bfeeb5cf407af13b9fc3bec657edf807",
"assets/assets/translations/mk.json": "81b9c831b1e43e92b78b79c820f291f9",
"assets/assets/translations/sl.json": "efd9076a05e3e91488058e2b5f62e583",
"assets/assets/translations/hu.json": "9c627d3a4909f3ca316f8a172279354b",
"assets/assets/translations/mr.json": "549ba790e711583159cf5289c22bf517",
"assets/assets/translations/lt.json": "e4fae6c741ac5b014c173cb2fa5d7c21",
"assets/assets/translations/is.json": "4443290864305c592405ed2374065add",
"assets/assets/translations/ha.json": "d0b91a5b4e57c90338c580f512f653ee",
"assets/assets/translations/kk.json": "b3227cde160f37cc92df0eabe48f91e8",
"assets/assets/translations/nl.json": "a16fc1d538176ec2886d65ea2a6cfb99",
"assets/assets/translations/ms.json": "13b1edf34df98f0da9446d9421039dd5",
"assets/assets/translations/ja.json": "ab4c0640084538277177f585a75c92ae",
"assets/assets/translations/de.json": "cc26dc368d052e3300c20b17cd2df016",
"assets/assets/translations/ru.json": "748ed92f4897b0ba95f5b336b0897e65",
"assets/assets/translations/pl.json": "50b402f20f1e96fde84b71011b8e8c9c",
"assets/assets/translations/uk.json": "c2170bb126ad95e29977b2945727ff5b",
"assets/assets/translations/gsw.json": "e172b53de30207d9032fe7e1b4031752",
"assets/assets/translations/ky.json": "fe6f875b28ffdc63eba8f4b1c1337f03",
"assets/assets/translations/fi.json": "22bf8e527fc333f0369799ef3edf0ec7",
"assets/assets/translations/ta.json": "4a556538c4a7bdd68f6001b0e558af0d",
"assets/assets/translations/fil.json": "e37875e86dac4c7ae77491e891c6d322",
"assets/assets/translations/ur.json": "983039493976bb50c00a263d0d57de4a",
"assets/assets/translations/sk.json": "e54df92fa2ab2639e7c1556fbb283bfd",
"assets/assets/translations/ml.json": "09a30c8a1a0ebaa6724bddea64d18c8d",
"assets/assets/translations/az.json": "38dafdaae782fc085159ea892996f90a",
"assets/assets/translations/pt.json": "0a16accb109ce771998a2b170de2e508",
"assets/assets/translations/be.json": "72993cf3be5c158c072529cfd09cb568",
"assets/assets/translations/en.json": "9255a3148bd1e9ed9462cec1278c4252",
"assets/assets/translations/ka.json": "4824a2a890771c84b7091a4e1c9657ed",
"assets/assets/translations/pa.json": "b4dbc172b1891b4371ab577145df96fd",
"assets/assets/translations/my.json": "9f3f9f0763b8143af5ede9772dd09fca",
"assets/assets/translations/km.json": "2c379105649b7a83eb59caf1004483ee",
"assets/assets/translations/it.json": "6e7ac89ae61b530f77968fa62540d0d2",
"assets/assets/translations/sr.json": "cfe376819588473e7a5359af956be553",
"assets/assets/translations/hr.json": "3a6212eea2e254849f66e45f27a9e942",
"assets/assets/translations/tl.json": "eec85fde46ec26a697e87970a4529865",
"assets/assets/translations/zu.json": "016200ef678fd56c16645ff14235ed2c",
"assets/assets/translations/et.json": "5e5fa19c686ba20c893d10ed9d5677e8",
"assets/assets/translations/kn.json": "02362ab2d3556eb68d7cc06ddd706428",
"assets/assets/translations/cy.json": "a867f7fa69972d8448fe2d7ea5b0126b",
"assets/assets/translations/sq.json": "5d1ccfdf674a3db7c8f8320c7b70819e",
"assets/assets/translations/ne.json": "bef3479018ab2d670016a5f23b66058e",
"assets/assets/translations/bs.json": "e8f4a95866f2ea1b6e078dbe12823c3d",
"assets/assets/translations/fr.json": "0657c947a4eac08fa1c786d520bbf681",
"assets/assets/translations/am.json": "31c37f2fe7d6035df0672fdb092cf102",
"assets/assets/translations/gu.json": "e71b222b35da1295e1e61df2c60bee95",
"assets/assets/translations/el.json": "178eda506607a470ad7cc4ddc24c1086",
"assets/assets/translations/bg.json": "56ce8c915d612525ce96c6f3be0dc15b",
"assets/assets/translations/ro.json": "aa93872769a01bfd32193094dbd8feb8",
"assets/assets/translations/hi.json": "264270964d70e04ad0f11a44cae0e194",
"assets/assets/translations/ca.json": "315d2ba8160a2aed244f1109aa1bd671",
"assets/assets/translations/mn.json": "8ccded9372b2ec7b96439719bf553c85",
"assets/assets/translations/si.json": "c7d07919a7cde7f55b748b5575135a17",
"assets/assets/translations/enm.json": "8a80554c91d9fca8acb82f023de02f11",
"assets/assets/translations/ko.json": "d35c051f02856edcdc26b4292c34b1bc",
"assets/assets/translations/eu.json": "5dc3aba9d0ebb6099ccfd311d450201e",
"assets/assets/translations/gl.json": "3c74bba4eb98f2b7267e386aff7fecce",
"assets/assets/translations/he.json": "87eb6f942e3da2bb296486fc9123d77c",
"assets/assets/translations/vi.json": "e01bc0ee3bb22a989c92366ea85d6e73",
"assets/assets/translations/nb_NO.json": "9c1859212dbfe6734f451461090d3283",
"assets/assets/translations/fa.json": "9ba79573f74a2c3d8d32b0acafa3fa51",
"assets/assets/translations/lo.json": "02e824b730d3edf518b8fd883c3212b5",
"assets/assets/translations/cs.json": "a1d703b297b3b0b053338f0c662659b5",
"assets/assets/translations/te.json": "0250600b9c4cb21169eabcb3cfa8d8b1",
"assets/assets/translations/as.json": "770943db60c1a1cd40ff91188fc7bba8",
"assets/assets/translations/zh_Hant.json": "7b0fe1a35794ec32d5ed8aafbd38f0cc",
"assets/assets/translations/id.json": "b3e6200f41b79b8f2b0d7d9d8a7c7984",
"assets/assets/translations/uz.json": "d50ffe5a0a61fadcf728bf020e6ed468",
"assets/assets/translations/bn_BD.json": "81435ea48466b6266c7ac18a041ba5b5",
"assets/assets/translations/lv.json": "24b412831b46ac333477e54b6bb70d3d",
"assets/assets/translations/af.json": "03e20783a4b647147d31c0b9adc8e3dd",
"assets/assets/translations/sw.json": "6c7a1c40cdf1a70b27b55d205c59e20c",
"assets/assets/translations/da.json": "257928a66c810650dcb0b228e2c177af",
"assets/assets/translations/th.json": "e727646077b771291d328d42f1f0d6a7",
"assets/assets/translations/sv.json": "211c1fff0f7a1cb94f80aa2b2341fa97",
"assets/assets/translations/es.json": "98dd69c69bf09ee86849cf0e18c48d5b",
"assets/assets/translations/ar.json": "e3948b1c11eaaccfc234a5d4a2e38164",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
