import store from 'store';
import fetch from 'isomorphic-fetch';

import { clientID } from './distinct_id';
import { host } from './global';

function getBrowserLanguage() {
  const first = window.navigator.languages
    ? window.navigator.languages[0]
    : null;

  const lang = first
    || window.navigator.language
    || window.navigator.browserLanguage
    || window.navigator.userLanguage;

  return lang;
}

function autoIncrement(key) {
  if (store.get(key)) {
    const oldNumber = store.get(key);
    store.set(key, oldNumber + 1);
    return oldNumber + 1;
  }
  store.set(key, 1);
  return 1;
}

function visitView() {
  const key = `${window.location.pathname}_vv`;
  return autoIncrement(key);
}

function totalPageView() {
  const key = 'lwn_total_pv_';
  return autoIncrement(key);
}

function currentTrack() {
  const singlePageView = visitView();
  const totalView = totalPageView();
  const info = {
    agent: window.navigator.userAgent,
    current_url: window.location.href,
    referrer: document.referrer,
    screen_width: window.screen.width,
    screen_height: window.screen.height,
    language: getBrowserLanguage(),
    visit_view: singlePageView,
    single_page_view: singlePageView,
    total_page_view: totalView,
  };
  return info;
}

function getRoomID() {
  const roomElement = document.getElementById('lewini-chat');
  if (roomElement) {
    const roomID = roomElement.getAttribute('data-id');
    if (roomID) {
      return roomID;
    }
  }
  if (!window.lwn || !window.lwn.q) {
    return null;
  }
  let rid = null;
  window.lwn.q.forEach((e) => {
    if (e[0] === 'init') {
      rid = e[1];
    }
  });
  return rid;
}

export default function sendTrack() {
  if (window.userToken) {
    return;
  }

  const track = { track: currentTrack(), address_uuid: clientID, room_uuid: getRoomID() };
  fetch(`//${host}/api/tracks`, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(track),
  });
}
