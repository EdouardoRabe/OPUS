/**
 * Leaflet.draw assumes that you have already included the Leaflet library.
 */
L.drawVersion = '0.4.2';
/**
 * @class L.Draw
 * @aka Draw
 *
 *
 * To add the draw toolbar set the option drawControl: true in the map options.
 *
 * @example
 * ```js
 *      var map = L.map('map', {drawControl: true}).setView([51.505, -0.09], 13);
 *
 *      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
 *          attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
 *      }).addTo(map);
 * ```
 *
 * ### Adding the edit toolbar
 * To use the edit toolbar you must initialise the Leaflet.draw control and manually add it to the map.
 *
 * ```js
 *      var map = L.map('map').setView([51.505, -0.09], 13);
 *
 *      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
 *          attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
 *      }).addTo(map);
 *
 *      // FeatureGroup is to store editable layers
 *      var drawnItems = new L.FeatureGroup();
 *      map.addLayer(drawnItems);
 *
 *      var drawControl = new L.Control.Draw({
 *          edit: {
 *              featureGroup: drawnItems
 *          }
 *      });
 *      map.addControl(drawControl);
 * ```
 *
 * The key here is the featureGroup option. This tells the plugin which FeatureGroup contains the layers that
 * should be editable. The featureGroup can contain 0 or more features with geometry types Point, LineString, and Polygon.
 * Leaflet.draw does not work with multigeometry features such as MultiPoint, MultiLineString, MultiPolygon,
 * or GeometryCollection. If you need to add multigeometry features to the draw plugin, convert them to a
 * FeatureCollection of non-multigeometries (Points, LineStrings, or Polygons).
 */
L.Draw = {};

/**
 * @class L.drawLocal
 * @aka L.drawLocal
 *
 * The core toolbar class of the API â€” it is used to create the toolbar ui
 *
 * @example
 * ```js
 *      var modifiedDraw = L.drawLocal.extend({
 *          draw: {
 *              toolbar: {
 *                  buttons: {
 *                      polygon: 'Draw an awesome polygon'
 *                  }
 *              }
 *          }
 *      });
 * ```
 *
 * The default state for the control is the draw toolbar just below the zoom control.
 *  This will allow map users to draw vectors and markers.
 *  **Please note the edit toolbar is not enabled by default.**
 */
L.drawLocal = {
	// format: {
	// 	numeric: {
	// 		delimiters: {
	// 			thousands: ',',
	// 			decimal: '.'
	// 		}
	// 	}
	// },
	draw: {
		toolbar: {
			// #TODO: this should be reorganized where actions are nested in actions
			// ex: actions.undo  or actions.cancel
			actions: {
				title: 'Annuler le dessin',
				text: 'Annuler'
			},
			finish: {
				title: 'Terminer le dessin',
				text: 'Terminer'
			},
			undo: {
				title: 'Effacer le dernier point dessiné',
				text: 'Effacer le dernier point'
			},
			buttons: {
				polyline: 'Tracer une ligne',
				polygon: 'Dessiner un polygone',
				rectangle: 'Dessiner rectangle',
				circle: 'Tracer un cercle',
				marker: 'Poser un marqueur',
				circlemarker: 'Poser un marqueur arrondi'
			}
		},
		handlers: {
			circle: {
				tooltip: {
					start: 'Cliquer et déplacer pour dessiner un cercle.'
				},
				radius: 'Rayon'
			},
			circlemarker: {
				tooltip: {
					start: 'Cliquer pour placer un marqueur arrondi.'
				}
			},
			marker: {
				tooltip: {
					start: 'Cliquez sur la carte pour placer le marqueur.'
				}
			},
			polygon: {
				tooltip: {
					start: 'Click to start drawing shape.',
					cont: 'Click to continue drawing shape.',
					end: 'Click first point to close this shape.'
				}
			},
			polyline: {
				error: '<strong>Error:</strong> shape edges cannot cross!',
				tooltip: {
					start: 'Cliquer pour commencer à tracer la ligne.',
					cont: 'Cliquer pour continuer à dessiner la ligne',
					end: 'Cliquer un dernier point pour finir le tracé'
				}
			},
			rectangle: {
				tooltip: {
					start: 'Cliquer et déplacer pour dessiner un rectangle'
				}
			},
			simpleshape: {
				tooltip: {
					end: 'Release mouse to finish drawing.'
				}
			}
		}
	},
	edit: {
		toolbar: {
			actions: {
				save: {
					title: 'Sauvegarder les changements',
					text: 'Sauvegarder'
				},
				cancel: {
					title: 'Annuler',
					text: 'Annuler'
				},
				clearAll: {
					title: 'Annuler tout',
					text: 'Annuler tout'
				}
			},
			buttons: {
				edit: 'Modifier',
				editDisabled: 'Rien à modifier',
				remove: 'Supprimer les modifications',
				removeDisabled: 'Rien à supprimer'
			}
		},
		handlers: {
			edit: {
				tooltip: {
					text: 'Drag handles or markers to edit features.',
					subtext: 'Click cancel to undo changes.'
				}
			},
			remove: {
				tooltip: {
					text: 'Click on a feature to remove.'
				}
			}
		}
	}
};
