function onEmbeddedLoad() {
  const roomDIV = document.createElement('div');
  roomDIV.setAttribute('data-id', window.room_uuid);
  roomDIV.setAttribute('id', 'lewini-chat');

  const jsNode = document.createElement('script');
  jsNode.setAttribute('src', window.js_src);

  const element = document.getElementById('embedded-site');
  document.documentElement.innerHTML = '';
  document.documentElement.innerHTML = element.innerHTML;
  document.body.appendChild(roomDIV);
  document.body.appendChild(jsNode);
  document.documentElement.style.display = '';
}

function showProgress() {
  function show() {
    const progress = document.getElementById('progress');
    progress.setAttribute('style', '');
    return true;
  }

  const el = document.getElementById('try-url');
  if (el) {
    el.addEventListener('submit', show);
  }
}

function showEmbedSite() {
  showProgress();
  const embedded = document.getElementById('embedded-site');
  if (embedded) {
    if (window.addEventListener) {
      window.addEventListener('load', onEmbeddedLoad, false);
    } else if (window.attachEvent) {
      window.attachEvent('onload', onEmbeddedLoad);
    }
  }
}

export default showEmbedSite;
