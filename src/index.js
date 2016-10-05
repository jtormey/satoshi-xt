
// xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx

require('!style!css!sass!./main.scss')
let { HDNode } = require('bitcoinjs-lib')

let deriveFromXpub = (xpub, index) => (
  HDNode.fromBase58(xpub).derive(0).derive(index).getAddress()
)

let Elm = require('./Main')
let app = Elm.Main.embed(document.getElementById('main'))

app.ports.derive.subscribe(({ xpub, index }) => {
  let address = deriveFromXpub(xpub, index)
  app.ports.derivation.send(address)
})

app.ports.set.subscribe((data) => {
  let [key, value] = data.split(',')
  localStorage.setItem(key, value)
})

app.ports.get.subscribe((key) => {
  let value = localStorage.getItem(key)
  app.ports.storage.send([key, value].join(','))
})
