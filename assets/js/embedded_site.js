function showProgress() {
  function show() {
    const progress = document.getElementById('progress');
    progress.setAttribute('style', '');
    return true;
  }

  const el = document.getElementById('try-url');
  if (el) {
    if (el.addEventListener) {
      el.addEventListener('submit', show);
    } else if (el.attachEvent) {
      el.attachEvent('onsubmit', show);
    }
  }
}

function showEmbedSite() {
  showProgress();
}

export default showEmbedSite;
