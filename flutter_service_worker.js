'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "d4c7ab0c957c53e7783f9cd8394f32f7",
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
"index.html": "60cf32b341c1e896139644e06c6b0f5f",
"/": "60cf32b341c1e896139644e06c6b0f5f",
"main.dart.js": "d0477e0bfb959afc0710e7d23f5a9da3",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"icons/Icon-192.png": "d8ed4418b7e314bca062868e82748e9f",
"icons/Icon-512.png": "2b839693a7a9604f2bde0cd67fd17abc",
"manifest.json": "10413e652ec1368443e68e96fa0b876f",
"assets/CHANGELOG.md": "7c4955efc0d0871e67e2233d9c3f08b2",
"assets/AssetManifest.json": "9d6b78f863af2be92d0cdcf322a56c78",
"assets/NOTICES": "a89fd34087193664ac758bbd2e209d4c",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "1025ce688ee334d27f0aaeffb9693eec",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "14de2c63eb470cec041f1cdaccd90674",
"assets/fonts/MaterialIcons-Regular.otf": "ed365d88379743a6c36cd7cbdb483d98",
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
"assets/assets/translations/hy.json": "82d935835daf1464bb6b1e7b42ada788",
"assets/assets/translations/zh.json": "de1ba5c603b2308ad049dd2403a5eee0",
"assets/assets/translations/ps.json": "e67f4fcef6edd1e820e82bea4f554b57",
"assets/assets/translations/tr.json": "535c474c68d36f948b80c2e0cdbccf58",
"assets/assets/translations/or.json": "116d5c8762400ae06141ef7a9db3d9e9",
"assets/assets/translations/mk.json": "ffc6836ae7b4198b40f81663649c4db1",
"assets/assets/translations/sl.json": "90ad8b18e10193fbe89d951d006af200",
"assets/assets/translations/hu.json": "cf0092abe9120a2a0f443e70f5bcc580",
"assets/assets/translations/mr.json": "8943e0a806cc55a24fe07e199785423f",
"assets/assets/translations/lt.json": "5d7d9258fab9307962711cec57a9a516",
"assets/assets/translations/is.json": "979fa50124e7b5363304f1abc6811c8e",
"assets/assets/translations/ha.json": "d0b91a5b4e57c90338c580f512f653ee",
"assets/assets/translations/kk.json": "37642f98f305065a379c3f08d00f1d48",
"assets/assets/translations/nl.json": "f0167e639c5c611e7aa3796d0f17627b",
"assets/assets/translations/ms.json": "f02d1df08a6e7f78b2ca5d9ed159cc15",
"assets/assets/translations/ja.json": "e2a6fc73936601ea4abee7428f6f73f2",
"assets/assets/translations/de.json": "da929a75e3c2b0c0506d14191e6d00cf",
"assets/assets/translations/ru.json": "10d9513d6923e02084c00ba6a7cd6fd2",
"assets/assets/translations/pl.json": "5ed8e6eeff8c7c7e90bb01073994f9f3",
"assets/assets/translations/uk.json": "703766f166bf7fd7c0403652434bb424",
"assets/assets/translations/gsw.json": "b2d0aa2675177da76457566f8cfa699a",
"assets/assets/translations/ky.json": "c14021697300f1832251b7f34f4c4214",
"assets/assets/translations/fi.json": "3d404db8250b98c70351117729af3be4",
"assets/assets/translations/ta.json": "4ce71d5b65132146028508e861563f5e",
"assets/assets/translations/fil.json": "1d0ff52200d117bcd061eb4f18e7eb87",
"assets/assets/translations/ur.json": "908132a45fa9abf55116d991e6c7aba5",
"assets/assets/translations/sk.json": "91ba537b9c6020b7d5cda08507a114d9",
"assets/assets/translations/ml.json": "ead10a2b8f90019ba248437a122f068c",
"assets/assets/translations/az.json": "db50181244573d1b6ffe577df430b3e6",
"assets/assets/translations/pt.json": "267cc28396cae384d231b6a75d4f1927",
"assets/assets/translations/be.json": "49490d8a0f2502268e053b614cea357c",
"assets/assets/translations/en.json": "05193ca94dfff92130297ba6f8acb5cb",
"assets/assets/translations/ka.json": "5e9a1e00925adc9eefd9222dd8395a51",
"assets/assets/translations/pa.json": "307e103d3b276fc390f4a5840cdb12fa",
"assets/assets/translations/my.json": "c9d3efc4c0b21e12ba8bb59c4c4ee499",
"assets/assets/translations/km.json": "f9f5cab48dfe3cb1d412fee3106fb1a3",
"assets/assets/translations/it.json": "76b9ceb4e1fcc1718ced94e45ddfed04",
"assets/assets/translations/sr.json": "25955d3c1615e4e05dc7a6c7d9499ed3",
"assets/assets/translations/hr.json": "776dcc2ac41a6eaa7589e84fc3200638",
"assets/assets/translations/tl.json": "6fd1675eff21cebc5692a9ec956b2bb8",
"assets/assets/translations/zu.json": "aea18cee1a5bbe2386d394a866474324",
"assets/assets/translations/et.json": "272cb102a55332551a83c07b08bb32f9",
"assets/assets/translations/kn.json": "49e827734ddbb4039f84203902f997ff",
"assets/assets/translations/cy.json": "9f9feeb42effec1ba51aa8e08496ee9e",
"assets/assets/translations/sq.json": "4e730499303a0b8034c196f7185abdb0",
"assets/assets/translations/ne.json": "09ec96618c81954631861b55abbf3240",
"assets/assets/translations/bs.json": "d402647147e3084611d84d76933da3e5",
"assets/assets/translations/fr.json": "7c24f71632d6de1c144800993c9e5a24",
"assets/assets/translations/am.json": "0a7cf587e82a0e826e85f49a084e0c09",
"assets/assets/translations/gu.json": "d82437f4360ffecdef69a5f8cd5fd5e8",
"assets/assets/translations/el.json": "4c02562ca3aef7f9dbabfa0b6fa565b4",
"assets/assets/translations/bg.json": "f129dcf365f2045bead6ddc5d2c28099",
"assets/assets/translations/ro.json": "86fa0e1e28189413e2031972d99dec64",
"assets/assets/translations/hi.json": "cfdfd99d2b013aadb3ac9ab56d23ded0",
"assets/assets/translations/ca.json": "0fa55f69321522e33870aa686c179c5b",
"assets/assets/translations/mn.json": "703524ed9725aeb6ab577ec40d0f9a17",
"assets/assets/translations/si.json": "f49e75dfc48137733b028ef953bf582f",
"assets/assets/translations/ko.json": "4d67b4399bf0781221569f2fe7b85b19",
"assets/assets/translations/eu.json": "c929c0c5a7de6091fef0bf5ece7c415a",
"assets/assets/translations/gl.json": "37bd4a8a331ce6584a4f28b07d585357",
"assets/assets/translations/he.json": "dd15fd1d42b714b8c988ec30b3d99cbd",
"assets/assets/translations/vi.json": "7e72281c8538de627e68318fb579d952",
"assets/assets/translations/nb_NO.json": "38ec432b2718af1f3d189c64ff7670aa",
"assets/assets/translations/fa.json": "b7502d0e667c30b070e5b55c65a82fda",
"assets/assets/translations/lo.json": "e86d3779675a86ef8f7c09585addb651",
"assets/assets/translations/cs.json": "6291652f1d9af9381638ba83a2066a9c",
"assets/assets/translations/te.json": "86becb2823a9c7bddd3156f3a4fb9b6d",
"assets/assets/translations/as.json": "4091e5b41fdc0950d69e1b98c2c99e13",
"assets/assets/translations/zh_Hant.json": "0516c7f11a5d1a04980fee7fe35f5be6",
"assets/assets/translations/id.json": "b960c6b7186ed3d8c89692f08c1e17ca",
"assets/assets/translations/uz.json": "8f1d713ba9d8d0b5b4947d5ff1e58355",
"assets/assets/translations/bn_BD.json": "c9d74a68e64f0f2be2f819b2a5c0bfe0",
"assets/assets/translations/lv.json": "49d1a16f2620080547f15d9647aa24d6",
"assets/assets/translations/af.json": "80bffae3ca202f1c3f57f464999c078d",
"assets/assets/translations/sw.json": "48031a8831502384952997d74bd190eb",
"assets/assets/translations/da.json": "2054138e85cf4014abfe31e775749013",
"assets/assets/translations/th.json": "c55d97fb446efcd8fa1235b0303adc1b",
"assets/assets/translations/sv.json": "442d7a19ffcc0d92116f876d04a53930",
"assets/assets/translations/es.json": "5c70c43c68c0603f8b08a9ce74ba24d9",
"assets/assets/translations/ar.json": "95ead135faabae3aed63002b12db543a",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
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
