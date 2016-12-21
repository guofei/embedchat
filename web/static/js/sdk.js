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
// import 'phoenix_html';

// import 'bootstrap-sass/assets/javascripts/bootstrap.min.js';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import { createStore } from 'redux';

import visitor from './visitor';
import visitorRoomID from './visitor_room_id';
import chatApp from './reducers';

require('es6-promise').polyfill();

const store = createStore(chatApp);


function runChat() {
  const roomID = visitorRoomID();
  visitor(store, roomID);
}

runChat();
