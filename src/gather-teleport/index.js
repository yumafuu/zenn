const teleportButton = (text, x, y) => {
  const btn = document.createElement('button');
  btn.innerHTML = text;
  btn.style = `
    border: none;
    outline: none;
    font: inherit;
    color: inherit;
    background-color: rgba(51, 51, 51, 0.4);
    color: #fff;
    padding: 5px 12px;
  `
  btn.onclick = (() => {
    console.log('teleport');
    const mapId = window.game.getMyPlayer().map;
    window.game.teleport(mapId, x, y);
  })

  return btn;
}

const e = document.createElement('div');
e.style = `
  position: absolute;
  margin-top: 60px;
  margin-left: 30px;
  z-index: 1;
`

e.appendChild(teleportButton('MyDesk', 78, 44));
e.appendChild(teleportButton('もくもく', 68, 23));
e.appendChild(teleportButton('全社', 47, 28));
e.appendChild(document.createElement('br'));
e.appendChild(teleportButton('MTG1', 50, 16));
e.appendChild(teleportButton('MTG2', 55, 16));
e.appendChild(teleportButton('MTG3', 60, 16));
e.appendChild(teleportButton('MTG4', 65, 16));
e.appendChild(document.createElement('br'));
e.appendChild(teleportButton('1on1-1', 78, 34));
e.appendChild(teleportButton('1on1-2', 74, 34));
e.appendChild(teleportButton('1on1-3', 76, 31));
e.appendChild(teleportButton('1on1-4', 72, 31));
e.appendChild(teleportButton('1on1-5', 78, 23));
e.appendChild(teleportButton('1on1-6', 74, 23));

document.getElementById('root').appendChild(e);
