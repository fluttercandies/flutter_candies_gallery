'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "70dfc6da97d58c6820e372f1a6ef6f54",
"index.html": "e4882e8f7c4173101576a69acd36e123",
"/": "e4882e8f7c4173101576a69acd36e123",
"main.dart.js": "3633db2f789a4ba0ede8227e88f67381",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "9fdac0a5b3ea0721e6bdc457eaf280e6",
"assets/AssetManifest.json": "3f1a3e42ff9d70e7d957b9b4aaa095c7",
"assets/NOTICES": "9c9d0f6352325e1e98c0df6bad4ba146",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/packages/flutter_markdown/assets/logo.png": "67642a0b80f3d50277c44cde8f450e50",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/assets/CandyChef/zmtzawqlp/candies.md": "419f94b80e65cf8e608b98ba957e3cb8",
"assets/assets/CandyChef/zmtzawqlp/PullPush/2.Flutter%2520%25E8%25BD%25BB%25E6%259D%25BE%25E6%259E%2584%25E5%25BB%25BA%25E5%258A%25A0%25E8%25BD%25BD%25E6%259B%25B4%25E5%25A4%259A(loading%2520more).md": "0cf281353b583ec2e587bdf7b7b2ca83",
"assets/assets/CandyChef/zmtzawqlp/PullPush/1.Flutter%2520%25E4%25B8%258B%25E6%258B%2589%25E5%2588%25B7%25E6%2596%25B0%25E8%258A%25B1%25E5%25BC%258F%25E7%258E%25A9%25E6%25B3%2595.md": "ffc3a5b7991aa9cd0382ea2454c9207c",
"assets/assets/CandyChef/zmtzawqlp/Tools/4.Flutter%2520%25E6%25B3%2595%25E6%25B3%2595%25E8%25B7%25AF%25E7%2594%25B1%25E6%25B3%25A8%25E8%25A7%25A3.md": "be22cc9ae10705717a2e535a2c069cf0",
"assets/assets/CandyChef/zmtzawqlp/Tools/5.Flutter%2520%25E6%25B3%2595%25E6%25B3%2595%25E6%25B3%25A8%25E8%25A7%25A3%25E8%25B7%25AF%25E7%2594%25B1%25202.0.md": "e1e7f715012e7d69db9ffda66f846d6a",
"assets/assets/CandyChef/zmtzawqlp/Tools/2.Flutter%2520JsonToDart%2520Mac%25E7%2589%2588%2520lei%25E4%25BA%2586%25EF%25BC%258C%25E7%259C%259F%25E7%259A%2584%25E4%25B8%258Dmark%25E5%2590%2597.md": "1d1da8ddb1676772ac9af64fc1f5e073",
"assets/assets/CandyChef/zmtzawqlp/Tools/6.Flutter%2520%25E6%25B3%2595%25E6%25B3%2595%25E6%25B3%25A8%25E8%25A7%25A3%25E8%25B7%25AF%25E7%2594%25B1%25204.0.md": "0ef252262ff2221198794247d7526d2e",
"assets/assets/CandyChef/zmtzawqlp/Tools/3.Flutter%2520JsonToDart%2520%25E5%25B7%25A5%25E5%2585%25B7.md": "6cab9aa9d5d04c1164beb10705917e70",
"assets/assets/CandyChef/zmtzawqlp/Tools/1.Flutter%2520%25E5%258A%259F%25E8%2583%25BD%25E6%259C%2580%25E5%2585%25A8%25E7%259A%2584JsonToDart%25E5%25B7%25A5%25E5%2585%25B7(%25E6%25A1%258C%25E9%259D%25A2Web%25E6%25B5%25B7%25E9%2599%2586%25E7%25A9%25BA%25E6%2594%25AF%25E6%258C%2581).md": "dc3043dc6c7b142db06523b705a819e4",
"assets/assets/CandyChef/zmtzawqlp/Sliver/2.Flutter%2520Sliver%25E4%25B8%2580%25E7%2594%259F%25E4%25B9%258B%25E6%2595%258C%2520(ExtendedList).md": "c033350f0f2615f498337e79da96f840",
"assets/assets/CandyChef/zmtzawqlp/Sliver/3.Flutter%2520Sliver%25E4%25BD%25A0%25E8%25A6%2581%25E7%259A%2584%25E7%2580%2591%25E5%25B8%2583%25E6%25B5%2581%25E5%25B0%258F%25E5%25A7%2590%25E5%25A7%2590.md": "ab6295dcfb3e580629cd48707804cd61",
"assets/assets/CandyChef/zmtzawqlp/Sliver/4.Flutter%2520Sliver%2520%25E9%2594%2581%25E4%25BD%258F%25E4%25BD%25A0%25E7%259A%2584%25E7%25BE%258E.md": "7d6a17c4b7e98efbdaee5acd402f17a7",
"assets/assets/CandyChef/zmtzawqlp/Sliver/1.Flutter%2520Sliver%25E4%25B8%2580%25E7%2594%259F%25E4%25B9%258B%25E6%2595%258C%2520(ScrollView).md": "e5110df858418d722dad4e0347f59e1f",
"assets/assets/CandyChef/zmtzawqlp/Web/2.Flutter%2520Candies%2520for%2520web.md": "e9e43e6e97d33e0e7dcf020d9f609254",
"assets/assets/CandyChef/zmtzawqlp/Web/1.Flutter%2520for%2520web%2520%25E6%259C%2580%25E6%2596%25B0%25E5%25A1%25AB%25E5%259D%2591.md": "64a3ce4b53df38fa46a67b278ce96765",
"assets/assets/CandyChef/zmtzawqlp/TextField/3.Flutter%2520%25E8%2587%25AA%25E5%25AE%259A%25E4%25B9%2589%25E8%25BE%2593%25E5%2585%25A5%25E6%25A1%2586Selection%25E8%258F%259C%25E5%258D%2595%25E5%2592%258C%25E9%2580%2589%25E6%258B%25A9%25E5%2599%25A8.md": "e463a1ca196023f3b576d1f218e5c35d",
"assets/assets/CandyChef/zmtzawqlp/TextField/1.Flutter%2520%25E6%2594%25AF%25E6%258C%2581%25E5%259B%25BE%25E7%2589%2587%25E4%25BB%25A5%25E5%258F%258A%25E7%2589%25B9%25E6%25AE%258A%25E6%2596%2587%25E5%25AD%2597%25E7%259A%2584%25E8%25BE%2593%25E5%2585%25A5%25E6%25A1%2586%25EF%25BC%2588%25E4%25B8%2580%25EF%25BC%2589%25E4%25BD%25BF%25E7%2594%25A8%25E6%2596%25B9%25E6%25B3%2595.md": "6938e0515c59027fa030c9cb1dda4e23",
"assets/assets/CandyChef/zmtzawqlp/TextField/2.Flutter%2520%25E6%2594%25AF%25E6%258C%2581%25E5%259B%25BE%25E7%2589%2587%25E4%25BB%25A5%25E5%258F%258A%25E7%2589%25B9%25E6%25AE%258A%25E6%2596%2587%25E5%25AD%2597%25E7%259A%2584%25E8%25BE%2593%25E5%2585%25A5%25E6%25A1%2586%25EF%25BC%2588%25E4%25BA%258C%25EF%25BC%2589%25E5%25AE%259E%25E7%258E%25B0%25E8%25BF%2587%25E7%25A8%258B.md": "c6eecfaffa2a36530264361594041dd0",
"assets/assets/CandyChef/zmtzawqlp/Desktop/1.Flutter%2520go%2520flutter%2520desktop%2520%25E5%25A1%25AB%25E5%259D%2591.md": "aa26105a9adb61787e12375a0b276e84",
"assets/assets/CandyChef/zmtzawqlp/Desktop/2.Dart%2520Pub%2520Global%2520%25E5%2588%259B%25E5%25BB%25BA%25E5%2591%25BD%25E4%25BB%25A4%25E8%25A1%258C%25E5%25BA%2594%25E7%2594%25A8%25E7%25A8%258B%25E5%25BA%258F%25EF%25BC%2588Windows).md": "69cacda522e549dfc286f312add1213f",
"assets/assets/CandyChef/zmtzawqlp/Image/4.Flutter%2520%25E5%259B%25BE%25E7%2589%2587%25E8%25A3%2581%25E5%2589%25AA%25E6%2597%258B%25E8%25BD%25AC%25E7%25BF%25BB%25E8%25BD%25AC%25E7%25BC%2596%25E8%25BE%2591%25E5%2599%25A8.md": "7a4ec994a8c5bcd37904e8945083b33f",
"assets/assets/CandyChef/zmtzawqlp/Image/1.Flutter%2520%25E4%25BB%2580%25E4%25B9%2588%25E5%258A%259F%25E8%2583%25BD%25E9%2583%25BD%25E6%259C%2589%25E7%259A%2584Image.md": "f3bbf54290c84772297c75fe33cf62e7",
"assets/assets/CandyChef/zmtzawqlp/Image/2.Flutter%2520%25E5%258F%25AF%25E4%25BB%25A5%25E7%25BC%25A9%25E6%2594%25BE%25E6%258B%2596%25E6%258B%25BD%25E7%259A%2584%25E5%259B%25BE%25E7%2589%2587.md": "2d8796b3fa1fde373ae019ceec139464",
"assets/assets/CandyChef/zmtzawqlp/Image/5.Flutter%2520%25E5%259B%25BE%25E7%2589%2587%25E5%2585%25A8%25E5%25AE%25B6%25E6%25A1%25B6.md": "0b031c76a0fdda25504ccbb7c90e38f4",
"assets/assets/CandyChef/zmtzawqlp/Image/3.Flutter%2520%25E4%25BB%25BF%25E6%258E%2598%25E9%2587%2591%25E5%25BE%25AE%25E4%25BF%25A1%25E5%259B%25BE%25E7%2589%2587%25E6%25BB%2591%25E5%258A%25A8%25E9%2580%2580%25E5%2587%25BA%25E9%25A1%25B5%25E9%259D%25A2%25E6%2595%2588%25E6%259E%259C.md": "cfb5869b9be51b7e4ed3bc7e5aa65337",
"assets/assets/CandyChef/zmtzawqlp/zmtzawqlp.md": "5e01c4eb04096756762d27a3ba662b1a",
"assets/assets/CandyChef/zmtzawqlp/SDK/1.Flutter%2520v1.12.13%2520%25E7%259A%2584%25E4%25B8%2580%25E4%25BA%259B%25E5%259D%2591.md": "ef2b1badf4910c114296450ccda5062a",
"assets/assets/CandyChef/zmtzawqlp/SDK/2.Flutter%2520Analysis%2520Options.md": "d4e542df31502566d7a7d1b34db39f0f",
"assets/assets/CandyChef/zmtzawqlp/GettingStarted/3.Flutter%2520widgets%2520Text%2520Icon%2520Button.md": "80b229e6b715bd9c44e37aa72aa10485",
"assets/assets/CandyChef/zmtzawqlp/GettingStarted/1.Flutter%2520%25E5%2585%25A5%25E9%2597%25A8%25E5%25AE%2589%25E8%25A3%2585%25E2%2580%2594%25E2%2580%2594C%2523%25E7%25A8%258B%25E5%25BA%258F%25E5%2596%25B5%25E7%259A%2584Flutter%25E4%25B9%258B%25E6%2597%2585.md": "84eeb36462de404bed33a6e77dc94394",
"assets/assets/CandyChef/zmtzawqlp/GettingStarted/2.Flutter%2520widgets%2520Container%2520Row%2520Column%2520Image.md": "953cfbe1e3d5230f25132ab4fc824968",
"assets/assets/CandyChef/zmtzawqlp/GettingStarted/5.Flutter%2520%25E4%25BD%25A0%25E6%2583%25B3%25E7%259F%25A5%25E9%2581%2593%25E7%259A%2584Widget%25E5%258F%25AF%25E8%25A7%2586%25E5%258C%25BA%25E5%259F%259F,%25E7%259B%25B8%25E5%25AF%25B9%25E4%25BD%258D%25E7%25BD%25AE,%25E5%25A4%25A7%25E5%25B0%258F.md": "3dc95690b060381a4b3ec5274f512b5e",
"assets/assets/CandyChef/zmtzawqlp/GettingStarted/4.Flutter%2520%25E8%2590%258C%25E6%2596%25B0%25E9%25AB%2598%25E9%25A2%2591%25E9%2597%25AE%25E9%25A2%2598(%25E5%258A%25A0%25E7%258F%25AD%25E7%258C%25BF%25E5%25A6%2588%25E5%25A6%2588%25E5%258F%25AB%25E4%25BD%25A0%25E5%259B%259E%25E5%25AE%25B6%25E5%2590%2583%25E9%25A5%25AD%25E4%25BA%2586).md": "58714d9996f6700f1c21960b04170afa",
"assets/assets/CandyChef/zmtzawqlp/Text/3.Flutter%2520RichText%25E6%2594%25AF%25E6%258C%2581%25E8%2587%25AA%25E5%25AE%259A%25E4%25B9%2589%25E6%2596%2587%25E5%25AD%2597%25E8%2583%258C%25E6%2599%25AF.md": "33bac22a158f9c99afe4a0982ee80dea",
"assets/assets/CandyChef/zmtzawqlp/Text/2.Flutter%2520RichText%25E6%2594%25AF%25E6%258C%2581%25E8%2587%25AA%25E5%25AE%259A%25E4%25B9%2589%25E6%2596%2587%25E6%259C%25AC%25E6%25BA%25A2%25E5%2587%25BA%25E6%2595%2588%25E6%259E%259C.md": "e8eeaefb0e624ec199ec878b00a2b1bc",
"assets/assets/CandyChef/zmtzawqlp/Text/5.Flutter%2520RichText%25E6%2594%25AF%25E6%258C%2581%25E6%2596%2587%25E6%259C%25AC%25E9%2580%2589%25E6%258B%25A9.md": "6b7a1630da0401287fc13850a0a09edc",
"assets/assets/CandyChef/zmtzawqlp/Text/4.Flutter%2520RichText%25E6%2594%25AF%25E6%258C%2581%25E7%2589%25B9%25E6%25AE%258A%25E6%2596%2587%25E5%25AD%2597%25E6%2595%2588%25E6%259E%259C.md": "71283f0d6c2eacf019578f364a572bb0",
"assets/assets/CandyChef/zmtzawqlp/Text/1.Flutter%2520RichText%25E6%2594%25AF%25E6%258C%2581%25E5%259B%25BE%25E7%2589%2587%25E6%2598%25BE%25E7%25A4%25BA%25E5%2592%258C%25E8%2587%25AA%25E5%25AE%259A%25E4%25B9%2589%25E5%259B%25BE%25E7%2589%2587%25E6%2595%2588%25E6%259E%259C.md": "f20965ba8d8edc239d07fcbb2db3dada",
"assets/assets/CandyChef/zmtzawqlp/Nested/2.Flutter%2520%25E6%2589%25A9%25E5%25B1%2595NestedScrollView%2520%25EF%25BC%2588%25E4%25BA%258C%25EF%25BC%2589%25E5%2588%2597%25E8%25A1%25A8%25E6%25BB%259A%25E5%258A%25A8%25E5%2590%258C%25E6%25AD%25A5%25E8%25A7%25A3%25E5%2586%25B3.md": "e68d50d21aed7faa678c3aa0ec91a00e",
"assets/assets/CandyChef/zmtzawqlp/Nested/3.Flutter%2520%25E6%2589%25A9%25E5%25B1%2595NestedScrollView%2520%25EF%25BC%2588%25E4%25B8%2589%25EF%25BC%2589%25E4%25B8%258B%25E6%258B%2589%25E5%2588%25B7%25E6%2596%25B0%25E7%259A%2584%25E8%25A7%25A3%25E5%2586%25B3.md": "dbaf3215f839e5d521555ef6edd8dcd2",
"assets/assets/CandyChef/zmtzawqlp/Nested/1.Flutter%2520%25E6%2589%25A9%25E5%25B1%2595NestedScrollView%2520%25EF%25BC%2588%25E4%25B8%2580%25EF%25BC%2589Pinned%25E5%25A4%25B4%25E5%25BC%2595%25E8%25B5%25B7%25E7%259A%2584bug%25E8%25A7%25A3%25E5%2586%25B3.md": "38251cc28efa361d6a152b03f8bc31a4",
"assets/assets/CandyChef/zmtzawqlp/Awesome/4.2019%2520C%2523%25E7%25A8%258B%25E5%25BA%258F%25E5%2596%25B5%25E7%259A%2584Flutter%25E4%25B9%258B%25E6%2597%2585.md": "555d69c73b1ff0009b27d8a1e6d6ce83",
"assets/assets/CandyChef/zmtzawqlp/Awesome/2.Flutter%2520%25E6%2589%25A9%25E5%25B1%2595%25E7%259A%2584%25E8%2581%2594%25E5%258A%25A8Tabs.md": "68cf73d5ec030961a9309b25ef40932c",
"assets/assets/CandyChef/zmtzawqlp/Awesome/5.Flutter%2520Candies%2520%25E7%25B3%2596%25E6%259E%259C%25E5%25B0%258F%25E5%258A%25A9%25E6%2589%258B.md": "2236e33dc5c2caaa2d986a62985e4e07",
"assets/assets/CandyChef/zmtzawqlp/Awesome/3.Flutter%2520Candies%2520%25E4%25B8%2580%25E6%25A1%25B6%25E5%25A4%25A9%25E4%25B8%258B.md": "3c084eeddd5315708ed9717fa682e0ba",
"assets/assets/CandyChef/zmtzawqlp/Awesome/1.Flutter%2520%25E4%25BB%25BF%25E6%258E%2598%25E9%2587%2591%25E6%258E%25A8%25E7%2589%25B9%25E7%2582%25B9%25E8%25B5%259E%25E6%258C%2589%25E9%2592%25AE.md": "d41d8cd98f00b204e9800998ecf8427e",
"assets/assets/images/flutter_candies_logo.png": "be4d473295d5af30e6af6cdcac3799bb",
"assets/assets/images/avatars/zmtzawqlp.jpg": "9d94b7d32210d27167e382af7d17b78d"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
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
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
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
  for (var resourceKey in Object.keys(RESOURCES)) {
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
