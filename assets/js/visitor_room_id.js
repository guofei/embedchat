export default function visitorRoomID() {
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
