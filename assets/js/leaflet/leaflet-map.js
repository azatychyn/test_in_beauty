import L from 'leaflet'
import "leaflet.markercluster";
import { basemapLayer } from 'esri-leaflet';
import { vectorBasemapLayer, vectorTileLayer } from "esri-leaflet-vector";

const template = document.createElement('template');
template.innerHTML = `
		<link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
		integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
		crossorigin=""/>
		<style>
			.leaflet-cluster-anim .leaflet-marker-icon, .leaflet-cluster-anim .leaflet-marker-shadow {
				-webkit-transition: -webkit-transform 0.3s ease-out, opacity 0.3s ease-in;
				-moz-transition: -moz-transform 0.3s ease-out, opacity 0.3s ease-in;
				-o-transition: -o-transform 0.3s ease-out, opacity 0.3s ease-in;
				transition: transform 0.3s ease-out, opacity 0.3s ease-in;
			}
			
			.leaflet-cluster-spider-leg {
				/* stroke-dashoffset (duration and function) should match with leaflet-marker-icon transform in order to track it exactly */
				-webkit-transition: -webkit-stroke-dashoffset 0.3s ease-out, -webkit-stroke-opacity 0.3s ease-in;
				-moz-transition: -moz-stroke-dashoffset 0.3s ease-out, -moz-stroke-opacity 0.3s ease-in;
				-o-transition: -o-stroke-dashoffset 0.3s ease-out, -o-stroke-opacity 0.3s ease-in;
				transition: stroke-dashoffset 0.3s ease-out, stroke-opacity 0.3s ease-in;
			}

			.marker-cluster-small {
				background-color: #FECDD3;
				}
			.marker-cluster-small div {
				background-color: #FDA4AF;
				}
			
			.marker-cluster-medium {
				background-color: #FB7185;
				}
			.marker-cluster-medium div {
				background-color: #F43F5E;
				}
			
			.marker-cluster-large {
				background-color: #E11D48;
				}
			.marker-cluster-large div {
				background-color: #BE123C;
				}
			
				/* IE 6-8 fallback colors */
			.leaflet-oldie .marker-cluster-small {
				background-color: #FECDD3;
				}
			.leaflet-oldie .marker-cluster-small div {
				background-color: #FDA4AF;
				}
			
			.leaflet-oldie .marker-cluster-medium {
				background-color: #FB7185;
				}
			.leaflet-oldie .marker-cluster-medium div {
				background-color: #F43F5E;
				}
			
			.leaflet-oldie .marker-cluster-large {
				background-color: #E11D48;
				}
			.leaflet-oldie .marker-cluster-large div {
				background-color: #BE123C;
			}
			
			.marker-cluster {
				background-clip: padding-box;
				border-radius: 20px;
				}
			.marker-cluster div {
				width: 30px;
				height: 30px;
				margin-left: 5px;
				margin-top: 5px;
			
				text-align: center;
				border-radius: 15px;
				font: 12px "Helvetica Neue", Arial, Helvetica, sans-serif;
				}
			.marker-cluster span {
				line-height: 30px;
				}		
		</style>
		<div style="height: 100%">
				<slot />
		</div>
`

class LeafletMap extends HTMLElement {
	static get observedAttributes() {
		return ['lat'];
	}

	get lat() {
		return this.hasAttribute('lat');
	}

	constructor() {
		super();

		this.attachShadow({ mode: 'open' });
		this.shadowRoot.appendChild(template.content.cloneNode(true));
		this.mapElement = this.shadowRoot.querySelector('div')

		this.map = L.map(this.mapElement).setView([this.getAttribute('lat'), this.getAttribute('lng')], 10);
		// const apiKey = "AAPKcd71902c963b4af8b466de93d050d306Il55eQMr22J02J23qi1cd9tEX99rtsKM7LJO0nCcVTPEsoS0MDMX_RNkhrHMYTtN";
		// vectorTileLayer("61c80b171d1b44759d9d6d6f51ddc560", {
    //   apiKey: apiKey,
		// 	maxZoom: 18
    // }).addTo(this.map);	

		// var serviceUrl = 'https://pkk.rosreestr.ru/arcgis/rest/services/BaseMaps/Anno/MapServer/tile/{z}/{y}/{x}';
		// var credits = 'Tiles &copy; Esri &mdash; Source: Esri, DeLorme, NAVTEQ, USGS, Intermap, iPC, NRCAN, Esri Japan, METI, Esri China (Hong Kong), Esri (Thailand), TomTom, 2012 etc. etc. etc.';
		// L.tileLayer(serviceUrl, { attribution: credits }).addTo(this.map); 

		L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoidGVyMSIsImEiOiJja25yOWx4djgwbW1hMm9wZndieGFuc29pIn0.9_xHg7W0x-GIAw3uXzI6pw', {
			attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
			maxZoom: 18,
			id: 'mapbox/streets-v11',
			tileSize: 512,
			zoomOffset: -1,
			accessToken: 'pk.eyJ1IjoidGVyMSIsImEiOiJja25yOWx4djgwbW1hMm9wZndieGFuc29pIn0.9_xHg7W0x-GIAw3uXzI6pw'
		}).addTo(this.map);

		this.defaultIcon = L.icon({
			iconUrl: '/images/marker-icon.svg',
			iconSize: [32, 32],
		});

	}

	connectedCallback() {
		var clusters = L.markerClusterGroup({
			polygonOptions: { opacity: 0, fillOpacity: 0 }
		});

		const markerElements = this.querySelectorAll('leaflet-marker')
		markerElements.forEach(markerEl => {
			const lat = markerEl.getAttribute('lat')
			const lng = markerEl.getAttribute('lng')
			const leafletMarker = L.marker([lat, lng], { icon: this.defaultIcon })
			leafletMarker.addEventListener('click', (_event) => {
				let code = markerEl.getAttribute('phx-value-code')
				document.getElementById(code).scrollIntoView({ behavior: 'smooth' });
				markerEl.click()
			})

			clusters.addLayer(leafletMarker);
			const iconEl = markerEl.querySelector('leaflet-icon');
			const iconSize = [iconEl.getAttribute('width'), iconEl.getAttribute('height')]

			iconEl.addEventListener('url-updated', (e) => {
				leafletMarker.setIcon(L.icon({
					iconUrl: e.detail,
					iconSize: iconSize,
					iconAnchor: iconSize
				}))
			})
		})
		this.map.addLayer(clusters);
		this.map.flyTo([this.getAttribute('lat'), this.getAttribute('lng')], 12)
	}

	attributeChangedCallback(name, oldValue, newValue) {
		if (this.lat) {
			this.map.flyTo([this.getAttribute('lat'), this.getAttribute('lng')], 16)
		}
	}

}


window.customElements.define('leaflet-map', LeafletMap);
