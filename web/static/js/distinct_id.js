import uuid from "uuid"

let DistinctID = {
  visitor(resource) {
    let key = "lwn_" + resource
    return this.getID(key)
  },

  webMaster() {
    let key = "distinct_id"
    return this.getID(key)
  },

  getID(key) {
    let distid = this.getCookie(key)
    if (distid != "") {
      return distid
    } else {
      distid = uuid.v4()
      this.setCookie(key, distid, 365)
      return distid
    }
  },

  setCookie(cname, cvalue, exdays) {
    let d = new Date()
    d.setTime(d.getTime() + (exdays*24*60*60*1000))
    let expires = "expires=" + d.toUTCString()
    document.cookie = cname + "=" + cvalue + "; " + expires
  },

  getCookie(cname) {
    let name = cname + "="
    let ca = document.cookie.split(';')
    for(var i=0; i<ca.length; i++) {
      let c = ca[i]
      while (c.charAt(0)==' ')
        c = c.substring(1)
      if (c.indexOf(name) == 0)
        return c.substring(name.length, c.length)
    }
    return ""
  }
}

export default DistinctID
