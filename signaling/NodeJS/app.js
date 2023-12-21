const WebSocket = require('ws');
var roomTable = {};

const getCircularReplacer = () => {
  const seen = new WeakSet();
  return (key, value) => {
    if (typeof value === "object" && value !== null) {
      if (seen.has(value)) {
        return;
      }
      seen.add(value);
    }
    return value;
  };
};

const getWSRoomId = (wsObj, flag) => {
    var matchRoomId = ""
    var keyAry = Object.keys(roomTable);
    for(var k=0; k < keyAry.length; k++)
    {
        var roomId = keyAry[k];
        var wsAry = roomTable[roomId];
        console.log("roomTable=>", roomId, "->", wsAry.length);
        for(var i = 0; i < wsAry.length; i++) {
            console.log("roomTable=> wsAry.forEach", wsAry[i] === wsObj, wsAry[i].readyState === flag);
            if ( wsAry[i] === wsObj && wsAry[i].readyState === flag) {
                k = keyAry.length;
                matchRoomId = roomId;
                break;
            }
        }
    }
    return matchRoomId;
}

const wss = new WebSocket.Server({ port: 8080 }, () => {
    console.log("Signaling server is now listening on port 8080")
});

// Broadcast to all.
wss.broadcast = (ws, data) => {
    wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === WebSocket.OPEN) {
            client.send(data);
        }
    });
};

// send to other peers.
wss.sendToPeer = (peers, ws, data) => {
    var ret = false;
    peers.forEach((client) => {
        console.log("sendToPeer=> peers.forEach", client !== ws, client.readyState === WebSocket.OPEN);
        if (client !== ws && client.readyState === WebSocket.OPEN) {
            client.send(data);
            ret = true;
        }
    });
    return ret;
};

wss.on('connection', (ws) => {
    console.log(`Client connected. Total connected clients: ${wss.clients.size}`)
    
    ws.onmessage = (message) => {
        const payload = JSON.parse(message.data);
        console.log("onmessage=>", payload.payload.roomId, "->", message.data + "\n");
        if(payload.payload.sdp == "close")
        {//
            console.log("onmessage=>Close", "\n");
            ws.close();
            return;
        }

        var wsRoomId = getWSRoomId(ws, WebSocket.OPEN);
        console.log("onmessage=>getWSRoomId->",  wsRoomId+"\n");
        if(  wsRoomId.length == 0 )
        {
            //console.log("onmessage=>roomTable->",  roomTable[payload.payload.roomId]+"\n");
            if( roomTable[payload.payload.roomId] == null || roomTable[payload.payload.roomId] == undefined ) roomTable[payload.payload.roomId] = [ws];
            else roomTable[payload.payload.roomId].push(ws);
        }        
        console.log("onmessage=>count->",  roomTable[payload.payload.roomId].length+"\n");

        //wss.broadcast(ws, message.data);
        if( !wss.sendToPeer(roomTable[payload.payload.roomId], ws, message.data) )
        {
            //wss.broadcast(ws, message.data);
        }
    }

    ws.onclose = () => {
        console.log(`Client disconnected. Total connected clients: ${wss.clients.size}`)

        var wsRoomId = getWSRoomId(ws, WebSocket.CLOSED);
        console.log(`onclose RoomID=${wsRoomId}`)
        if(wsRoomId.length > 0)
        {
            var wsAry = roomTable[wsRoomId];
            console.log("onclose-roomTable=>", wsRoomId, "->", wsAry.length);
            for (var i = 0; i < wsAry.length; i++) {
                console.log("roomTable=> wsAry.forEach", wsAry[i] === ws);
                if (wsAry[i] === ws) {
                    roomTable[wsRoomId].splice(i, 1);
                    break;
                }
            }
            console.log(`onclose count=${roomTable[wsRoomId].length}`)
        }
    }
});