import { host } from './global';
import { clientID } from './distinct_id';
import visitorRoomID from './visitor_room_id';


function updateVisitorInfo() {
  const el = document.getElementById('after-regist');
  if (!el) {
    return;
  }
  const userEmail = el.getAttribute('data-email');
  if (!userEmail) {
    return;
  }
  const userName = el.getAttribute('data-name');
  const data = {
    visitor: { email: userEmail, name: userName },
    uuid: clientID,
    room_uuid: visitorRoomID(),
  };
  // TODO: refactoring
  fetch(`//${host}/api/visitors`, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });
}

export default updateVisitorInfo;
