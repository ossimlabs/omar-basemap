# OMAR Basemap

![](./Basemap_Mapproxy.png)

## Installation in Openshift

Assumption: Mapproxy and omar-basemap are already pushed to the openshift server's internal docker registry.

Configuring the basemap on “Open Shift” development and production environments.

1) On the associated NFS server, you need to create a directory to store the mbtiles file (currently it is at /basemap-dev or basemap-rel)
2) Download the planet mbtiles file from here: https://openmaptiles.com/downloads/dataset/osm/#0.23/-0/0.
3) Copy your .mbtiles file into the appropriate directory. (from step 1)
4) Configure Openshift to create "persistent volume storage" and mount it to the directory from step 1
5) Deploy the omar-basemap image into the appropriate project.The associated pod will deploy using port 80, and spin up and utilize the planet mbtiles file that was downloaded 
6) On the NFS server, you need to create a directory to store the mapproxy.yml file, and the tile cache directory. (Currently it is at /basemap-cache-dev or /basemap-cache-rel)
7) Create a new file in the directory created in step 6: touch mapproxy.yml
8) Add the following to the mapproxy.yml file 
```yaml
services:
  demo:
  tms:
    use_grid_names: true
    # origin for /tiles service
    origin: 'nw'
  kml:
      use_grid_names: true
  wmts:
  wms:
    md:
      title: o2 Map Proxy
      abstract: Provides a set of tiles for the o2 basemaps.


layers:
  - name: o2-basemap-basic
    title: o2 Basic Basemap
    sources: [o2_basic_tiles_cache]
  - name: o2-basemap-bright
    title: o2 Bright Basemap
    sources: [o2_bright_tiles_cache]


caches:
  o2_basic_tiles_cache:
    grids: [webmercator]
    sources: [o2_basic_tiles]
  o2_bright_tiles_cache:
    grids: [webmercator]
    sources: [o2_bright_tiles]


sources:
  o2_basic_tiles:
     type: tile
     url: http://omar-basemap:80/styles/klokantech-basic/%(z)s/%(x)s/%(y)s.png
     grid: webmercator
  o2_bright_tiles:
    type: tile
    url: http://omar-basemap:80/styles/osm-bright/%(z)s/%(x)s/%(y)s.png
    grid: webmercator


grids:
    webmercator:
        base: GLOBAL_WEBMERCATOR
    geodetic:
        base: GLOBAL_GEODETIC
```

9) The important part of the mapproxy file is the sources > omar-basemap:80. This needs to be pointed at the omar-basemap pod you wish to proxy and cache on the mapproxy server. 
10) Configure Openshift to create "persistent volume storage" and mount it to the directory from step 6.
11) Deploy the omar-mapproxy image into the appropriate project. The associated pod will deploy using port 8080, and spin up and utilize the planet mbtiles file that was downloaded 

## Verification

This assumes that the omar-UI is deployed in openshift and is running.To verify that the basemap and mapproxy are working properly, open up the UI and go to the map search page.For example, go to https://omar-dev.ossim.io/omar-ui/omar#/map and make sure the basemap loads in the map.

## Troubleshooting

From openshift, if the basemap is not loading into the UI, the following steps would help you troubleshoot the issues.
1) You should see a webpage that has a title of TileServer GL.
2) You can also test the the TileServer by navigating to the route created in step 1. 
A test image from the server will be returned that looks like:
![](./test_image.png)
3) To test the proxy you will need to copy/paste the following into the browser: http://mapproxy.omar-dev.ossim.io
You should see the following page if you click demo:
![](./mapproxy_screenshot.png)
4) Make sure that the o2-basemap-basic and o2-basemap-bright layers show up.If they don't, make sure the mapproxy.yml is on the NFS server.If mapproxy.yml is loaded, make sure it is pointed to omar-base and is mounted correctly.
5) If the above steps aren't work, add a route to the mapproxy service pertinent to testing.Give it a name and make sure the service is "omar-basemap".You should see some Styles and Data sections if you click on the hyperlink. If you aren't seeing any of that, make sure omar-base is up and running.
6) At this point your are ready to use the basemap and proxy in a mapping application.The following HTML/Javascript code can be used to test the basemap stack:
```html
<!DOCTYPE html>
<html>
  <head>
    <title>o2 | Tile WMS</title>
    <link rel="stylesheet" href="https://openlayers.org/en/v3.19.1/css/ol.css" type="text/css">
    <!-- The line below is only needed for old environments like Internet Explorer and Android 4.x -->
    <script src="https://cdn.polyfill.io/v2/polyfill.min.js?features=requestAnimationFrame,Element.prototype.classList,URL"></script>
    <script src="https://openlayers.org/en/v3.19.1/build/ol.js"></script>
  </head>
  <body>
    <div class="zoomLevel"></div>
    <div id="map" class="map"></div>
    <script>
      var layers = [
        new ol.layer.Tile({
          source: new ol.source.TileWMS({
            url: 'http://localhost/o2-basemap-proxy/wms',
            params: {
              'VERSION': '1.1.1',
              'LAYERS': 'o2-basemap-bright',
            },
          })
        }),
      ];
      var map = new ol.Map({
        layers: layers,
        target: 'map',
        view: new ol.View({
          center: [0, 0],
          projection: 'EPSG:4326',
          //center: [-10997148, 4569099],
          zoom: 2
        })
      });


      map.on('moveend', function () {
        console.log('Zoom Level: ' + map.getView().getZoom());
        document.getElementsByClassName('zoomLevel')[0].innerHTML = 'Zoom Level: ' + map.getView().getZoom()
      });


    </script>
  </body>
</html>
```

## Running omar-basemap locally
1) Clone the following repo: https://github.com/ossimlabs/omar-basemap/tree/master
2) Download the necessary plugins and put them in a folder
3) Add those plugins to a directory and make sure you add that directory to the build.gradle file
4) Do a gradlew buildDockerImage which should generate a Dockerfile in the docker directory
5) Do a docker build . in the directory of the Dockerfile
6) Download an mbtiles file. An example of a file to download us by doing the following command:curl -o zurich_switzerland.mbtiles https://openmaptiles.os.zhdk.cloud.switch.ch/v3.3/extracts/zurich_switzerland.mbtiles
7) You can run the tile server by either doing a) tileserver-gl zurich_switzerland.mbtiles or b) docker run -it -v /data -p 8080:80 klokantech/tileserver-gl
