const uiClassName = 'lewini-block';

const css = `
.${uiClassName} input {
  box-shadow: none !important;
  -moz-box-shadow: none !important;
  -webkit-box-shadow: none !important;
}
`;

export default function insertNormalizeCSS() {
  const style = document.createElement('style');
  style.type = 'text/css';
  if (style.styleSheet) {
    style.styleSheet.cssText = css;
  } else {
    style.appendChild(document.createTextNode(css));
  }
  const head = document.head || document.getElementsByTagName('head')[0];
  head.appendChild(style);
}
