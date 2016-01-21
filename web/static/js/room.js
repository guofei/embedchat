let Room = {
  join(socket, element) {
    if(!element){ return }
    socket.connect()
    let roomID  = element.getAttribute("data-id")
    let channel = socket.channel("rooms:" + roomID)
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
  }
}

export default Room
