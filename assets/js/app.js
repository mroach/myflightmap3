// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
//
// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}
Hooks.MapboxRoutePairs = {
  mounted() {
    mapboxgl.accessToken = 'pk.eyJ1IjoibXJvYWNoIiwiYSI6InFkWGlVem8ifQ.KsIKtzCpEykzZF-yfvn8zQ';

    let allAirportCoordinates = (pairs, name) => {
      return pairs.map(p => {
        var airport = p[name];
        return [airport.longitude, airport.latitude];
      })
    };

    let routePairs = JSON.parse(this.el.querySelector('[data-purpose="route-pairs"]').innerText);
    console.debug(routePairs);

    let points = [].concat(
      allAirportCoordinates(routePairs, "airport_1"),
      allAirportCoordinates(routePairs, "airport_2")
    );

    console.debug(points)
    let features = turf.points(points);
    let center = turf.center(features).geometry.coordinates;

    const map = new mapboxgl.Map({
      container: this.el.id,
      style: 'mapbox://styles/mroach/cl9lq4rmt002714o2e3juzmtq',
      // style: 'mapbox://styles/mapbox/dark-v10',
      center: center, // starting position [lng, lat]
      zoom: 2, // starting zoom
      // pitch: 40,
      maxZoom: 5,
      projection: 'naturalEarth' // display the map as a 3D globe
    });
  }
}

Hooks.Mapbox = {
  mounted() {
    mapboxgl.accessToken = 'pk.eyJ1IjoibXJvYWNoIiwiYSI6InFkWGlVem8ifQ.KsIKtzCpEykzZF-yfvn8zQ';

    let parse = (s) => { return s.split(/\s*,\s*/).map(s => parseFloat(s)) };

    let attrs = this.el.attributes;
    const origin = parse(attrs["data-depart-coords"].value).reverse();
    const destination = parse(attrs["data-arrive-coords"].value).reverse();

    var features = turf.points([
      origin,
      destination
    ]);

    var center = turf.center(features).geometry.coordinates;
    var bbox = turf.bbox(features);
    var bboxObj = [ [bbox[0], bbox[1]], [bbox[2], bbox[3]] ];

    const map = new mapboxgl.Map({
      container: this.el.id,
      style: 'mapbox://styles/mroach/cl9lq4rmt002714o2e3juzmtq',
      // style: 'mapbox://styles/mapbox/dark-v10',
      center: center, // starting position [lng, lat]
      zoom: 3, // starting zoom
      // pitch: 40,
      maxZoom: 5,
      projection: 'naturalEarth' // display the map as a 3D globe
    });

    // const cameraTransform = map.cameraForBounds([ [bbox[0], bbox[1]], [bbox[2], bbox[3]] ], {
    //   padding: { top: 100, bottom: 100, left: 200, right: 200 }
    // });

    map.fitBounds(bboxObj, { padding: { top: 100, bottom: 100, left: 100, right: 100}});

    map.on('style.load', () => {
      // map.setFog({ 'horizon-blend': 0.05 });
    });

    const route = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'geometry': {
            'type': 'LineString',
            'coordinates': [origin, destination]
          }
        }
      ]
    };

    // A single point that animates along the route.
    // Coordinates are initially set to origin.
    const point = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {},
          'geometry': {
            'type': 'Point',
            'coordinates': origin
          }
        }
      ]
    };

    // Calculate the distance in kilometers between route start/end point.
    const lineDistance = turf.length(route.features[0]);

    const arc = [];

    // Number of steps to use in the arc and animation, more steps means
    // a smoother arc and animation, but too many steps will result in a
    // low frame rate
    const steps = 500;

    // Draw an arc between the `origin` & `destination` of the two points
    for (let i = 0; i < lineDistance; i += lineDistance / steps) {
      const segment = turf.along(route.features[0], i);
      arc.push(segment.geometry.coordinates);
    }

    // Update the route with calculated arc coordinates
    route.features[0].geometry.coordinates = arc;

    let counter = 0;

    map.on('load', () => {
      // Add a source and layer displaying a point which will be animated in a circle.
      map.addSource('route', {
        'type': 'geojson',
        'data': route
      });

      map.addSource('point', {
        'type': 'geojson',
        'data': point
      });

      map.addLayer({
        'id': 'route',
        'source': 'route',
        'type': 'line',
        'paint': {
          'line-width': 3,
          'line-color': 'gold'
        }
      });

      map.addLayer({
        'id': 'point',
        'source': 'point',
        'type': 'symbol',
        'layout': {
          // This icon is a part of the Mapbox Streets style.
          // To view all images available in a Mapbox style, open
          // the style in Mapbox Studio and click the "Images" tab.
          // To add a new image to the style at runtime see
          // https://docs.mapbox.com/mapbox-gl-js/example/add-image/
          'icon-image': 'departure',
          'icon-size': 0.1,
          'icon-rotate': ['get', 'bearing'],
          'icon-rotation-alignment': 'map',
          'icon-allow-overlap': true,
          'icon-ignore-placement': true
        }
      });
    });
   }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// Scroll to the item identified by a selector
window.addEventListener("phx:scroll-to-item", (e) => {
  let el = document.querySelector(e.detail.selector)
  if (el) {
    el.scrollIntoView({block: "center"});
  }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
>> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
