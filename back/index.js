const express = require('express')
const app = express()

const cors = require('cors');                           //서버간 통신 모듈
app.use(cors())
const { DateTime } = require('luxon');

const bodyParser = require('body-parser')
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: true}))        //extended: true -> qs라이브러리로 중첩 허용, 중첩을 허용해야하나? 아니지 않나


const PORT = 8080
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

const database = require('./database/index')            //데이터베이스 파일 경로

//로그인 필요 없음
//회원가입 필요 없음

function CheckSession(s1, s2) {
    const r1 = String(s1)
    const r2 = s2[0];
    return r1 === r2
}

const request = require('request')

app.post('/user/login', (req, res) => {
    const id = req.body.id                         //로그인시 아이디
    const pw = req.body.pw                //로그인시 비밀번호

    database.login(id, pw, (data, cookie) => {
        database.setSession(data.id, cookie)

        // libseat login
        request.post({
            url: 'https://libseat.khu.ac.kr/login_library',
            followAllRedirects: false,
            form: {
                STD_ID: data.id
            },
            headers: {
                'User-Agent': 'request',
                Cookie: cookie
            }
        }, function(err, result, body) {
            if (err) {
                console.log('lib login err', err)
                res.status(400).json({
                    ok: false,
                    err: err
                })
                return
            }

            database.setSession2(data.id, result.headers['set-cookie'])

            res.json({
                ok: true,
                name: data.name,
                id: data.id,
                cookie: cookie
            })
        })
    },
    (err) => {
        res.status(400).json({
            ok: false,
            err: err
        })
    })
    
})

app.post('/user/status', (req, res) => {                 // 유저 정보 확인
    const id = req.body.id
    if (!id) {
        res.json({
            ok: false,
            err: 'id is required'
        })
        return
    }

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    const data = database.getSeatById(id)
    if(data.length !== 0) {    
        res.json({
            ok: true,
            ismy: true,
            data: data[0]
        })
        return
    }

    database.getUserInfo(database.getSession2(id), (data) => {
        res.json({
            ok: true,
            data: data
        })
    }, (err) => {
        res.status(404).json({
            ok: false,
            err: err
        })
    })
})

app.post('/user/seat/exit', (req, res) => {
    const id = req.body.id
    if (!id) {
        res.json({
            ok: false,
            err: 'id is required'
        })
        return
    }

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    database.getUserInfo(database.getSession2(id), (data) => {
        if (!data['data']['mySeat']) {
            let data = database.getSeatById(id)
            if (data.length == 0) {                          //예약한 자리 없음
                res.status(404).json({
                    ok: false,
                    err: 'No reservation found for the given id'
                })
                return
            }
        
            //예약된 좌석을 취소
            database.deleteSeat(data)

            console.log('no seat err')
            res.status(404).json({
                ok: true
            })
            return
        }

        request.post({
            url: "https://libseat.khu.ac.kr/libraries/leave/" + String(data['data']['mySeat']['seat']['code']),
            followAllRedirects: false,
            headers: {
                'User-Agent': 'request',
                Cookie: database.getSession2(id)
            }
        }, function(err, result, body) {
            if (err) {
                console.log('lib login err', err)
                res.status(400).json({
                    ok: false,
                    err: err
                })
                return
            }

            console.log('exit success')
            res.json({
                ok: true
            })
        })
    }, (err) => {
        res.status(404).json({
            ok: false,
            err: err
        })
    })
})

app.post('/user/seat/use', (req, res) => {
    const id = req.body.id
    if (!id) {
        res.json({
            ok: false,
            err: 'id is required'
        })
        return
    }

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    request.post({
        uri: 'https://libseat.khu.ac.kr/libraries/seat',
        body: {
            "seatId": req.body.code,
            "time": req.body.time
        },
        headers: {
            'User-Agent': 'request',
            Cookie: database.getSession2(req.body.id)
        },
        json: true
    }, (err, result, body) => {
        if (err) {
            console.log('lib login err', err)
            res.status(400).json({
                ok: false,
                err: err
            })
            return
        }

        console.log(body)
        if (body['code'] != 1) {
            res.status(400).json({
                ok: false,
                err: '예약 실패'
            })
            return
        }

        res.json({
            ok: true
        })
    })
})

app.post('/user/seat/extend', (req, res) => {
    const id = req.body.id
    if (!id) {
        res.json({
            ok: false,
            err: 'id is required'
        })
        return
    }

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    request.post({
        uri: 'https://libseat.khu.ac.kr/libraries/seat-extension',
        body: {
            "code": req.body.seat,
            "groupCode": req.body.group,
            "time": 60,
            "beacon": [
                {
                    "major": 1,
                    "minor": 1
                }
            ]
        },
        headers: {
            'User-Agent': 'request',
            Cookie: database.getSession2(req.body.id)
        },
        json: true
    }, (err, result, body) => {
        if (err) {
            console.log('err ', err)
            res.json({
                ok: false,
                err: err
            })
            return
        }

        console.log('body ', body)

        res.json({
            ok: true
        })
    })
})

app.post('/user/qr', (req,res) => {                     //qr코드 발급
    const id = req.body.id
    if (!id) {
        res.json({
            ok: false,
            err: 'id is required'
        })
        return
    }

    const sessionRecv = req.body.session
    const session = database.getSession(id)
    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    database.getMID(session, (mid) => {
        database.getQR(mid, session, (QR) => {
            res.json({
                ok: true,
                QR: QR
            })
        },
        (err) => {
            res.json({
                ok: false,
                err: err
            })
        })
    },
    (err) => {
        res.json({
            ok: false,
            err: err
        })
    })
})

app.get('/user/seat', (req, res) => {                   //예약한 자리 정보 확인
    const id = req.body.id

    const sessionRecv = req.body.session
    const session = database.getSession(id)
    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    const data = database.getSeatById(id)
    if(data.length === 0) {                          //예약한 자리가 없는 상태
        res.status(404).json({
            ok: false,
            err: 'No reserved seat'
        })
        return
    }

    res.json(data)
})

//자리 예약할 때 시간을 어떻게 처리할지 잘 모르겠음

app.put('/user/reserve', (req,res) => {                 //자리 예약, 예약x -> 예약o
    console.log(res.body,": body")
    const id = req.body.id
    const sessionRecv = req.body.session
    const session = database.getSession(id)
    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    if(database.getSeatById(id).length != 0) {      //이미 예약한 자리 존재
        res.json({
            ok: false,
            err: 'already reserved seat'
        })
        return
    }
    else {
        const seatNumber = req.body.seatNumber
        if(database.getSeatBySeatNumber(seatNumber)[0].reservedTime != null) {   //다른 사람이 예약중인 좌석
            res.json({
                ok: false,
                err: 'already reserved seat'
            })
            return
        }

        const reservedTime = DateTime.now().toMillis();
        const time = req.body.time;
        database.reserveSeat(seatNumber,id,reservedTime,time)       //잘 모르겠는 부분
        res.json({
            ok: true
        })
    }
})

app.put('/user/reserve/off', (req, res) => {                //자리 예약, 예약 o -> 예약 x
    const id = req.body.id

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    let data = database.getSeatById(id)
    if (data.length == 0) {                          //예약한 자리 없음
        res.status(404).json({
            ok: false,
            err: 'No reservation found for the given id'
        })
        return
    }

    //예약된 좌석을 취소
    database.deleteSeat(data)

    res.json({
        ok: true,
        message: 'Reservation cancelled',
        data: data //취소된 좌석 정보
    })
})

app.put('/seats/time/add', (req, res) => {                  //시간 연장
    const id = req.body.id

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    const data = database.getSeatById(id)[0]

    const data2 = database.getSeatById(id)

    if (data2.length == 0) {
        res.status(404).json({
            ok: false,
            err: 'No reservation found for the given id'
        })
        return
    }

    if (data.addCount == 0) {                       //연장 가능 횟수가 남아있지 않음
        res.status(403).json({
            ok: false,
            err: 'No time extension left'
        })
        return
    }

    const time = req.body.addTime                   //얼마나 연장할건지
    let newAddCount = data.addCount - 1           //연장 가능 횟수 차감
    database.addTime(data,time,newAddCount)

    res.json({
        ok: true,
        message: 'extension time successfully'
    })
})

const seatToRoom = {};

app.post('/seats/reserve/reserve', (req,res) => {           //예약의 예약 추가
    const id = req.body.id

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }

    let session2 = database.getSession3(id)
    const seatNumber = req.body.seatNumber

    if (session2.includes(seatNumber)) {
        res.json({
            ok: false,
            err: 'already reserved reserve'
        })
        return
    }
    // database.getSeatBySeatNumber(seatNumber)[0].reserveReserve.push(id)     //seat DB의 reserveReserve키의 벨류값은 리스트
    session2.push(seatNumber)

    seatToRoom[seatNumber] = {}
    seatToRoom[seatNumber].name = req.body.seatName
    seatToRoom[seatNumber].group = req.body.seatGroup

    res.json({
        ok: true,
        message: 'add reserve reserve successfully'
    })
})

app.post('/seats/reserve/reserve/off', (req,res) => {
    const id = req.body.id

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }
    let session2 = database.getSession3(id)

    const seatNumber = req.body.seatNumber
    if(!session2.includes(seatNumber)) {
        res.json({
            ok: false,
            err: 'No reserve reserve found'
        })
        return
    }

    const index = session2.indexOf(seatNumber);
    if (index !== -1) {
        session2.splice(index, 1);
    }

    res.json({
        ok: true,
        message: 'delete reserve reserve successfully'
    })
})

app.post('/seats/reserve/reserve/my', (req,res) => {             // my reserve reserve
    const id = req.body.id

    const sessionRecv = req.body.session
    const session = database.getSession(id)

    if (!session || !CheckSession(sessionRecv, session)) {
        res.status(401).json({
            ok: false,
            err: 'incorrect Session'
        })
        return
    }
    
    const session2 = database.getSession3(id)

    res.json({
        ok: true,
        data: session2.map((code) => ({'code': code, 'name': seatToRoom[code].name, 'group': seatToRoom[code].group}))
    })
})

// 열람실 좌석 정보
app.get('/room/seats', (req, res) => {
    res.json({
        ok: true,
        data: [
            {"code":1,"name":"1","xpos":1389,"ypos":747,"width":45,"height":30,"textSize":12},
            {"code":2,"name":"2","xpos":1293,"ypos":747,"width":45,"height":30,"textSize":12},
            {"code":3,"name":"3","xpos":1197,"ypos":747,"width":45,"height":30,"textSize":12},
            {"code":4,"name":"4","xpos":1101,"ypos":747,"width":45,"height":30,"textSize":12},
            {"code":5,"name":"5","xpos":1005,"ypos":747,"width":45,"height":30,"textSize":12},
            {"code":6,"name":"6","xpos":909,"ypos":747,"width":45,"height":30,"textSize":12},
            {"code":7,"name":"7","xpos":1389,"ypos":627,"width":45,"height":30,"textSize":12},
            {"code":8,"name":"8","xpos":1293,"ypos":627,"width":45,"height":30,"textSize":12},
            {"code":9,"name":"9","xpos":1197,"ypos":627,"width":45,"height":30,"textSize":12},
            {"code":10,"name":"10","xpos":1101,"ypos":627,"width":45,"height":30,"textSize":12},
            {"code":11,"name":"11","xpos":1005,"ypos":627,"width":45,"height":30,"textSize":12},
            {"code":12,"name":"12","xpos":909,"ypos":627,"width":45,"height":30,"textSize":12},
            {"code":13,"name":"13","xpos":1389,"ypos":579,"width":45,"height":30,"textSize":12},
            {"code":14,"name":"14","xpos":1293,"ypos":579,"width":45,"height":30,"textSize":12},
            {"code":15,"name":"15","xpos":1197,"ypos":579,"width":45,"height":30,"textSize":12},
            {"code":16,"name":"16","xpos":1101,"ypos":579,"width":45,"height":30,"textSize":12},
            {"code":17,"name":"17","xpos":1005,"ypos":579,"width":45,"height":30,"textSize":12},
            {"code":18,"name":"18","xpos":909,"ypos":579,"width":45,"height":30,"textSize":12},
            {"code":19,"name":"19","xpos":1389,"ypos":506,"width":45,"height":30,"textSize":12},
            {"code":20,"name":"20","xpos":1293,"ypos":506,"width":45,"height":30,"textSize":12},
            {"code":21,"name":"21","xpos":1197,"ypos":506,"width":45,"height":30,"textSize":12},
            {"code":22,"name":"22","xpos":1101,"ypos":506,"width":45,"height":30,"textSize":12},
            {"code":23,"name":"23","xpos":1005,"ypos":506,"width":45,"height":30,"textSize":12},
            {"code":24,"name":"24","xpos":1293,"ypos":391,"width":45,"height":30,"textSize":12},
            {"code":25,"name":"25","xpos":1197,"ypos":391,"width":45,"height":30,"textSize":12},
            {"code":26,"name":"26","xpos":1101,"ypos":391,"width":45,"height":30,"textSize":12},
            {"code":27,"name":"27","xpos":1005,"ypos":391,"width":45,"height":30,"textSize":12},
            {"code":28,"name":"28","xpos":1389,"ypos":333,"width":45,"height":30,"textSize":12},
            {"code":29,"name":"29","xpos":1293,"ypos":333,"width":45,"height":30,"textSize":12},
            {"code":30,"name":"30","xpos":1197,"ypos":333,"width":45,"height":30,"textSize":12},
            {"code":31,"name":"31","xpos":1101,"ypos":333,"width":45,"height":30,"textSize":12},
            {"code":32,"name":"32","xpos":1005,"ypos":333,"width":45,"height":30,"textSize":12},
            {"code":33,"name":"33","xpos":1389,"ypos":228,"width":45,"height":30,"textSize":12},
            {"code":34,"name":"34","xpos":1293,"ypos":228,"width":45,"height":30,"textSize":12},
            {"code":35,"name":"35","xpos":1197,"ypos":228,"width":45,"height":30,"textSize":12},
            {"code":36,"name":"36","xpos":1101,"ypos":228,"width":45,"height":30,"textSize":12},
            {"code":37,"name":"37","xpos":1005,"ypos":228,"width":45,"height":30,"textSize":12},
            {"code":38,"name":"38","xpos":612,"ypos":596,"width":30,"height":45,"textSize":12},
            {"code":39,"name":"39","xpos":612,"ypos":503,"width":30,"height":45,"textSize":12},
            {"code":40,"name":"40","xpos":612,"ypos":409,"width":30,"height":45,"textSize":12},
            {"code":41,"name":"41","xpos":612,"ypos":316,"width":30,"height":45,"textSize":12},
            {"code":42,"name":"42","xpos":612,"ypos":223,"width":30,"height":45,"textSize":12},
            {"code":43,"name":"43","xpos":754,"ypos":446,"width":30,"height":45,"textSize":12},
            {"code":44,"name":"44","xpos":754,"ypos":352,"width":30,"height":45,"textSize":12},
            {"code":45,"name":"45","xpos":815,"ypos":446,"width":30,"height":45,"textSize":12},
            {"code":46,"name":"46","xpos":815,"ypos":352,"width":30,"height":45,"textSize":12},
            {"code":47,"name":"47","xpos":769,"ypos":293,"width":45,"height":30,"textSize":12},
        ]
    })
})