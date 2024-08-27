//databse seat: made by 김성민 v.2024-08-15 
let seats = [];
const totalSeats=47;//자대 열람실 자리 수
    for (let i = 1; i <= totalSeats; i++) {
        seats.push({
            seatNumber: i,
            id: null,
            reservedTime: null,
            time: null,
            addCount: 3,
            reserveReserve: []
        });
    }
const session=[];
const setSession = function(id,cookie) { 
    //중복 로그인시 최근 로그인 정보를 덮어씀
    const sessionAvaliable = session.find(user => user.id === id);
    if (!sessionAvaliable) {
    session.push({
        id: id,
        Cookie: cookie,
        reserveReserve: []
    });}
    else {
        sessionAvaliable.Cookie = cookie;
    }
}
const setSession2 = function(id, cookie) {
    const sessionAvaliable = session.find(user => user.id === id);
    if (sessionAvaliable) {
        sessionAvaliable.Cookie2 = cookie
    }
}

const getSession = function(id) {
    return session.find(user => user.id == id)['Cookie'];
}
const getSession2 = function(id) {
    return session.find(user => user.id == id)['Cookie2'];
}
const getSession3= function(id) {
    return session.find(user => user.id == id)['reserveReserve'];
}


const reserveSeat = function(seatNumber, id, reservedTime, time) {
    let seat = seats.find(seat => seat.seatNumber === seatNumber);
    if (seat) {
        seat.id = id;
        seat.reservedTime = reservedTime;
        seat.time = time;
    } else {
        console.log('Seat not found');
    }
};

const deleteSeat = function(seat) {
    if (seat&&seat[0].id!==null) {
        seat[0].id= null;
        seat[0].reservedTime = null;
        seat[0].time = null;
        seat[0].addCount = 3;
    } else {
        console.log('Unavailable delete');
    }
};

const getSeatBySeatNumber = function(seatNumber) {
    return seats.filter((seat) => seat.seatNumber == seatNumber)
};
const getSeatById = function(id) {
    return seats.filter((seat) => seat.id == id && seat.id!==null);
};

const addTime = function(seat,time,newAddCount) {
    seat.time = String(parseInt(seat.time) + parseInt(time))
    seat.addCount = newAddCount
};
const { DateTime } = require('luxon'); // Using luxon for date/time handling

const checkAndResetSeats = () => {
    seats.forEach(seat => {
        if (seat.reservedTime) {
            const reservationEnd = DateTime.fromISO(seat.reservedTime).plus({ minutes: seat.time });
            const now = DateTime.now();

            if (30000 <= reservationEnd - now && reservationEnd - now < 31000) {            // Before 30 minutes
                console.log("Before 30 minutes");                                           // 1800000 over 1860000 under
            }

            if (now >= reservationEnd) {
                console.log(`Resetting seat ${seat.seatNumber} as its reservation has expired.`);
                seatArray=[];
                seatArray.push(seat);
                deleteSeat(seatArray);
            }
        }
    });
};

// Run the check every minute
setInterval(checkAndResetSeats, 10000); // 60000 ms = 1 minute



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

function login(id, pw, callback, ecallback) {
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
                ecallback(err)
                return
            }
            
            let data = body
            data = data.split('<p class="userName">')
            if (data.length == 1) {
                console.log('login failed')
                ecallback('login failed')
                return
            }   
            data = data[2]
            data = data.split('<span class="name">')[1]
            data = data.split('</span>')[0]

            data = data.split(')')[0]
            let [name, id] = data.split('(')
            
            callback({name: name, id: id}, cookie)
        })
    })
}

function getMID(cookie, callback, ecallback) {
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
            ecallback(err)
            return
        }

        let mid = body
        mid = mid.split('<input type="hidden" name="mid_user_id" value="')
        if (mid.length == 1) {
            console.log('err: cannot get MID')
            ecallback(err)
            return
        }
        mid = mid[1]
        mid = mid.split('"')[0]
        callback(mid)
    })
}

function getQR(mid, cookie, callback, ecallback) {
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
            ecallback(err)
            return
        }

        let QR = body
        QR = QR.split('text: "')
        if (QR.length == 1) {
            console.log('err: cannot get QR')
            ecallback('cannot get QR')
            return
        }
        QR = QR[1]
        QR = QR.split('"')[0]

        callback(QR)
    })
}

function getUserInfo(cookie, callback, ecallback) {
    request.get({
        url: 'https://libseat.khu.ac.kr/user/my-status',
        headers: {
            'User-Agent': 'request',
            Cookie: cookie
        }
    }, function(err, res, body) {
        if (err) {
            console.log('err at getUserInfo', err)
            ecallback(err)
            return
        }

        callback(JSON.parse(body))
    })
}

module.exports = {
    seats, reserveSeat, deleteSeat, getSeatBySeatNumber, getSeatById, addTime, getQR, login,getMID, setSession, getSession, setSession2, getSession2, getUserInfo, getSession3
};