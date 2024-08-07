const express = require('express');
const {Pool} = require('pg');
const cors = require('cors');
const fcm = require("./services/push_notification");
require('dotenv').config();

const app = express();
const http = require('http').createServer(app);
const PORT = process.env.PORT || 3000;

app.use(express.urlencoded({extended: false}));
app.use(express.json());
app.use(cors());

const socketio = require('socket.io')(http)

var clients = new Map();

socketio.on("connection", (socket) => {
  console.log("connetetd");
  console.log(socket.id, "has joined");
  socket.on("signin", async (id) => {
    console.log(id);
    clients[id] = await socket;
    clients[id].on('disconnect', () => {
        console.log('disconnected');
        clients[id] = null;
    console.log(clients[id])
    });
  });

    

  socket.on("message", async (msg) => {
    console.log(msg);
    let targetId = msg.targetId;
    console.log(clients[targetId])
    if(clients[targetId]){
    clients[targetId].emit("message", msg);
    }else{
        try{
            const {sender, targetId, message} = msg;
            console.log({sender, targetId, message});
            pool.query(
                `select COALESCE(s.name, f.name) as name, ses.token as token
                 from session ses
                 LEFT JOIN
                 student s ON s.email = $1
                 LEFT JOIN
                 faculty f ON f.email = $1
                 where ses.email = $2`, [sender, targetId], (err, results) => {
                if (err) {
                    console.log(err.message);
                    
                } else {
                    console.log(results.rows);
                    if (results.rows.length > 0) {
                        var fcmsender = fcm();
                            const send_message = {
                                "message": {
                                    "token": results.rows[0].token,
                                    "data": {
                                        "sender": sender,
                                        "message": message
                                    },
                                    "notification": {
                                        "body": message,
                                        "title": `${results.rows[0].name}`,
                                    },
                                    "android": {
                                        "notification": {
                                            "channel_id": "pushnotification"
                                        }
                                    }
                                }
                            };
                            try {
                                fcmsender.getAccessToken().then(async () => {
                                    await fcmsender.sendMessage(send_message);
                                });
                                //await sender.sendMessage(send_message);
                            } catch (e) {
                                console.error(`Error for row : ${e.message}`);
                            }
                        
                        console.log("Messages sent");
                    } else {
                        console.log({ message: "No Active receivers" });
                    }
                }
            }
            )   
                }catch(e){
                    console.log(e);
                    res.sendStatus(500);
                }
    }
  },);
});

const pool = new Pool({
  connectionString: process.env.DB_URL
});

app.get('/checkUser', (req, res) => {
    try{
    const email = req.query.email;
    if(email.includes("victoriousvasikaran123@gmail.com") || email.includes('vutukuruvineesha2004@gmail.com')){
        console.log("Admin");
        res.sendStatus(201);
    }else if(
        email.includes("tce.edu") ||
        email.includes("vasikaran6131@gmail.com") ||
        email.includes("vineesha.v0102@gmail.com") ||
        email.includes("testfaculty6@gmail.com")
      ){
        console.log("College User");
        res.sendStatus(200);
      }else{
        res.sendStatus(400);
      }
    }catch(e){
        console.log(e.message);
        res.sendStatus(500);
    }
});

app.get('/faculties', async (req, res) => {
    try{
        await pool.query(`select * from faculty where name != 'Admin' order by name;`, (err, results) => {
            if(err){
                console.log(err.message);
            }else{
                console.log(results.rows);
        res.status(200).send(results.rows);
            }
        });
    }catch(e){
        console.log(e.message);
        res.status(500).send({error: e.message});
    }
})

app.get('/checkStudent',(req, res) => {
    try{
        const email = req.query.email
        console.log({email});
        pool.query(`select s.name, s.email, s.phone, s.regnum, f.name as pname, f.email as pemail, f.phone as pphone 
                    from student s, faculty f 
                    where s.proctor = f.email and s.email = $1`, [email], async (err, results) => {
            if(err){
                console.log(err.message);
                res.status(500).send({error: err.message});
            }else{
                console.log(results.rows);
                if(results.rows.length == 0){
                    res.sendStatus(400);
                }else{
                    res.status(200).send(results.rows[0]);
                }
            }
        });
    }catch(e){
        console.log(e.message);
        res.status(500).send({error: e.message});
    }
})

app.get('/checkFaculty',(req, res) => {
    try{
        const email = req.query.email
        console.log({email});
        pool.query(`select name, email, phone
                    from faculty 
                    where email = $1`, [email], async (err, results) => {
            if(err){
                console.log(err.message);
                res.status(500).send({error: err.message});
            }else{
                console.log(results.rows);
                if(results.rows[0]['phone'] == null){
                    res.sendStatus(400);
                }else{
                    res.status(200).send(results.rows[0]);
                }
            }
        });
    }catch(e){
        console.log(e.message);
        res.status(500).send({error: e.message});
    }
})

app.get('/savetoken', async (req, res) => {
    try{
    const token = req.query.token;
    const email = req.query.email;
    console.log({token, email});
    await pool.query(
        `insert into session(email, token)
         values($1, $2)`, [email, token], (err, results) => {
            if(err){
                console.log(err.message);
                res.sendStatus(500);
            }else{
                console.log(results.rows + 'inserted');
                res.sendStatus(200);
            }
         }
    );
       }catch(e){
            console.log(e);
            res.sendStatus(500);
        }
});

app.get('/removetoken', async (req, res) => {
    try{
    const token = req.query.token;
    console.log({token});
    await pool.query(
        `delete from session
         where token = $1`, [token], (err, results) => {
            if(err){
                console.log(err.message);
                res.sendStatus(500);
            }else{
                console.log(results.rows + 'deleted');
                res.sendStatus(200);
            }
         }
    );
        }catch(e){
            console.log(e);
            res.sendStatus(500);
        }
});


app.post('/sendmessage', async (req, res) => {
    try{
    const {sname, semail, remail, message} = req.body;
    console.log({sname, semail, remail, message});
    await pool.query(
        `with ts as (insert into messages(sender, receiver, message)
         values($1, $2, $3))
         select token
         from session 
         where email = $4`, [semail, remail, message, remail], (err, results) => {
            if(err){
                console.log(err.message);
                res.sendStatus(500);
            }else{
                console.log(results.rows);
                if(results.rows.length > 0){
                    var sender = fcm();
                    for(let i = 0; i < results.rows.length; i++){    
                            const send_message = {
                                "message": {
                                    "token": results.rows[i].token,
                                    "notification": {
                                        "body": message,
                                        "title": `${sname}`,
                                    },
                                    "android": {
                                        "notification": {
                                          "channel_id": "pushnotification"
                                        }
                                    }
                                }
                            };
                            try {
                                sender.getAccessToken().then(async () => {
                                    await sender.sendMessage(send_message);
                                })
                                //await sender.sendMessage(send_message);
                            } catch (e) {
                                console.error(`Error for row ${i + 1}: ${e.message}`);
                                return res.status(500).json({error: e.message});
                            }
                    }
                    console.log("Messages sent");
                    return res.sendStatus(200);
                }else{
                    console.log({message: "No Active receivers"});
                    return res.sendStatus(200);
                }
            }
         }
        )   
        }catch(e){
            console.log(e);
            res.sendStatus(500);
        }
});

app.post('/addStudent', async (req, res) => {
    try{
        let {name, email, phone, regnum, proctor} = req.body;
        console.log({name, email, phone, regnum, proctor});
        await pool.query(`with inserted_student as (
            insert into student(name, email, phone, regnum, proctor) 
            values($1, $2, $3, $4, $5)
            returning name, email, phone, regnum, proctor
          )
          select s.*, f.name as pname, f.email as pemail, f.phone as pphone
          from inserted_student s
          join faculty f on s.proctor = f.email;`, [name, email, phone, regnum, proctor], (err, results) => {
            if(err){
                console.log(err.message);
                res.status(500).send({error: err.message});
            }else{
                console.log(results.rows);
                res.status(200).send(results.rows[0]);
            }
        });
    }catch(e){
        console.log(e.message);
        res.status(500).send({error: e.message});
    }
})

app.post('/addFaculty', async (req, res) => {
    try{
        let {name, oemail, nemail, phone} = req.body;
        console.log({name, oemail, nemail, phone});
        await pool.query(`
        update faculty
        set name = $1,phone = $2, email= $3
        where email = $4
        returning name, email, phone`, [name, phone, nemail, oemail], (err, results) => {
            if(err){
                console.log(err.message);
                res.status(500).send({error: err.message});
            }else{
                console.log(results.rows);
                res.status(200).send(results.rows[0]);
            }
        });
    }catch(e){
        console.log(e.message);
        res.status(500).send({error: e.message});
    }
})

app.post('/addnewFaculty', async (req, res) => {
    try{
        console.log("Success");
        let {name, email, phone} = req.body;
        console.log({name, email, phone});
        await pool.query(`
        insert into faculty(name,phone,email)
        values($1, $2, $3)
        returning name, email, phone`, [name, phone, email], (err, results) => {
            if(err){
                console.log(err.message);
                res.status(500).send({error: err.message});
            }else{
                console.log(results.rows);
                res.status(200).send(results.rows[0]);
            }
        });
    }catch(e){
        console.log(e.message);
        res.status(500).send({error: e.message});
    }
})

app.get('/fetchStudents',(req, res) => {
    try{
        const proctor = req.query.proctor;
        if(proctor != null){
            pool.query(`select s.name, s.email, s.phone, s.regnum, f.name as pname, f.email as pemail, f.phone as pphone 
                    from student s, faculty f 
                    where s.proctor = f.email and s.proctor = $1`, [proctor], async (err, results) => {
            if(err){
                console.log(err.message);
                res.status(500).send({error: err.message});
            }else{
                console.log(results.rows);
                res.status(200).send(results.rows);
                
            }
        });
        }else{
            console.log("No proctor");
            pool.query(`select s.name, s.email, s.phone, s.regnum, f.name as pname, f.email as pemail, f.phone as pphone 
            from student s, faculty f 
            where s.proctor = f.email`, async (err, results) => {
                if(err){
                    console.log(err.message);
                    res.status(500).send({error: err.message});
                }else{
                    console.log(results.rows);
                    res.status(200).send(results.rows);
                    
                }
            });
        }
        
    }catch(e){
        console.log(e.message);
        res.status(500).send({error: e.message});
    }
})

app.get('/getmessages', async (req, res) => {
    const remail = req.query.email; 
    console.log({remail});
    try{
        pool.query(
            `SELECT m.message AS message,
             COALESCE(s.name, f.name) AS title,
             TO_CHAR(m.time, 'DD-MM-YYYY HH:MI AM') AS time
             FROM messages m
             LEFT JOIN
             student s ON m.sender = s.email
             LEFT JOIN
             faculty f ON m.sender = f.email
             WHERE
             m.receiver = $1
             order by time DESC;`, [remail],
            (err, results)=>{
                if(err) {
                    console.log(err.message);
                    return res.status(500).json({error: err.message});
                }else{
                    return res.status(200).json(results.rows);
                }
            }
        )
        console.log("Fetched messages");
    }catch(e){
        console.log(e.message);
        return res.status(500).json({error: e.message});
    }
});

http.listen(PORT, () => {
    console.log(`Server running on ${PORT}`);
});