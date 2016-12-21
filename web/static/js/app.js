// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "deps/phoenix_html/web/static/js/phoenix_html"
import 'phoenix_html';
import { createStore } from 'redux';
import chatApp from './reducers';
import visitor from './visitor';
import webmaster from './webmaster';
import showEmbedSite from './embedded_site';
import visitorRoomID from './visitor_room_id';
import updateVisitorInfo from './after_regist';

require('../css/app.css');
require('getmdl-select/getmdl-select.min.js');
require('es6-promise').polyfill();

// import 'bootstrap-sass/assets/javascripts/bootstrap.min.js';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".


const store = createStore(chatApp);
webmaster(store);

const roomID = visitorRoomID();
if (roomID) {
  visitor(store, roomID);
}

showEmbedSite();
updateVisitorInfo();
