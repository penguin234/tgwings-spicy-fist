//databse seat: made by 김성민 v.2024-08-15 

const rooms = [
    { roomNumber: 0, totalSeats: 20 }, //0: 자대열람실
    { roomNumber: 1, totalSeats: 410 }, //1: 1열람실
    { roomNumber: 2, totalSeats: 326 }, //2: 2열람실
    { roomNumber: 3, totalSeats: 156 }, //3: 벗터
    { roomNumber: 4, totalSeats: 187 } //4: 혜윰
];

let seats = [];

rooms.forEach(room => {
    for (let i = 1; i <= room.totalSeats; i++) {
        seats.push({
            roomNumber: room.roomNumber,
            seatNumber: i,
            id: null,
            reservedTime: null,
            time: null,
            addCount: 3
        });
    }
});


const reserveSeat = function(roomNumber, seatNumber, id, reservedTime, time) {
    let seat = seats.find(seat => seat.roomNumber === roomNumber && seat.seatNumber === seatNumber);
    if (seat) {
        seat.id = id;
        seat.reservedTime = reservedTime;
        seat.time = time;
    } else {
        console.log('Seat not found');
    }
};

const deleteSeat = function(seat) {
    if (seat.id!=null) {
        seat.id = null;
        seat.reservedTime = null;
        seat.time = null;
        seat.addCount=3;
    } else {
        console.log('Unavailable delete');
    }
};

const getSeatBySeatNumber = function(roomnumber,seatNumber) {
    return seats.filter((seat) => seat.roomNumber == roomnumber && seat.seatNumber == seatNumber)
};
const getSeatById = function(id) {
    return seats.filter((seat) => seat.id == id)
};

const addTime = function(seat,time,newAddCount) {
    seat.time += time
    seat.addCount = newAddCount
};
const { DateTime } = require('luxon'); // Using luxon for date/time handling

const checkAndResetSeats = () => {
    seats.forEach(seat => {
        if (seat.reservedTime) {
            const reservationEnd = DateTime.fromISO(seat.reservedTime).plus({ minutes: seat.time });
            const now = DateTime.now();

            if (now >= reservationEnd) {
                console.log(`Resetting seat ${seat.seatNumber} in room ${seat.roomNumber} as its reservation has expired.`);
                deleteSeat(seat);
            }
        }
    });
};

// Run the check every minute
setInterval(checkAndResetSeats, 60000); // 60000 ms = 1 minute



//database Qr: made by 황재현 v.2024-07-25
// ssl 이슈 해결
process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;

const request = require('request')

function getpublickey(callback) {
    request.get({uri:'https://lib.khu.ac.kr/login'}, function(err, res, body) {
        const cookie = res.headers['set-cookie']

        let data = body.split("encrypt.setPublicKey('")[1]
        data = data.split("'")[0]
        callback(data, cookie)
    })
}

const JSEncrypt = require('node-jsencrypt');

function login(id, pw, callback) {
    getpublickey((key, cookie) => {
        let enc = new JSEncrypt()
        enc.setPublicKey(key)
        let encid = enc.encrypt(id)
        let encpw = enc.encrypt(pw)

        request.post({
            url: 'https://lib.khu.ac.kr/login',
            followAllRedirects: true,
            'Content-type': 'application/x-www-form-urlencoded',
            headers: {
                'User-Agent': 'request',
                Cookie: cookie
            },
            form: {
                encId: encid,
                encPw: encpw,
                autoLoginChk: 'N'
            }
        }, function(err, res, body) {
            if (err) {
                console.log('err', err)
                return
            }
            
            let data = body
            data = data.split('<p class="userName">')
            if (data.length == 1) {
                console.log('login failed')
                return
            }   
            data = data[2]
            data = data.split('<span class="name">')[1]
            data = data.split('</span>')[0]
            
            callback(data, cookie)
        })
    })
}

function getMID(cookie, callback) {
    request.get({
        url: 'https://lib.khu.ac.kr/relation/mobileCard',
        followAllRedirects: false,
        headers: {
            'User-Agent': 'request',
            Cookie: cookie
        }
    }, function(err, res, body) {
        if (err) {
            console.log('err', err)
            return
        }

        let mid = body
        mid = mid.split('<input type="hidden" name="mid_user_id" value="')
        if (mid.length == 1) {
            console.log('err: cannot get MID')
            return
        }
        mid = mid[1]
        mid = mid.split('"')[0]
        console.log('mid', mid)
        callback(mid)
    })
}

function getQR(id, pw, callback) {
    login(id, pw, (data, cookie) => {
        getMID(cookie, (mid) => {
            request.post({
                url: 'https://lib.khu.ac.kr:8443/mconnect/makeCode',
                followAllRedirects: false,
                'Content-type': 'application/x-www-form-urlencoded',
                form: {
                    mid_user_id: mid
                },
                headers: {
                    'User-Agent': 'request',
                    Cookie: cookie
                }
            }, function(err, res, body) {
                if (err) {
                    console.log('err', err)
                    return
                }

                let QR = body
                QR = QR.split('text: "')
                if (QR.length == 1) {
                    console.log('err: cannot get QR')
                }
                QR = QR[1]
                QR = QR.split('"')[0]

                callback(data, cookie, QR)
            })
        })
    })
}
module.exports = {
    rooms, seats, reserveSeat, deleteSeat, getSeatBySeatNumber, getSeatById, addTime, getQR
};