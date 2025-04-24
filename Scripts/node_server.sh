#!/bin/bash

# Update system and install required packages
apt update && apt install -y curl gnupg2 ca-certificates lsb-release

# Install Node.js 18 using NodeSource
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Setup application directory and install dependencies as adminuser
runuser -l adminuser -c '
mkdir -p /home/adminuser/app && cd /home/adminuser/app
npm init -y
npm install express body-parser mysql2 cors

cat <<EOF > /home/adminuser/app/server.js
const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
const app = express();
app.use(cors());
app.use(express.json());

const config = {
    host: "${db_host}",
    user: "${db_user}",
    password: "${db_pswd}",
    database: "userdetails"
};

app.post("/add_user", async (req, res) => {
    const { name, age, email } = req.body;
    if (!name || !age || !email) {
        return res.status(400).send({ error: "All fields required" });
    }

    try {
        const connection = await mysql.createConnection(config);
        await connection.execute(
            "INSERT INTO users (name, age, email) VALUES (?, ?, ?)",
            [name, age, email]
        );
        await connection.end();
        res.status(201).send({ message: "User added successfully" });
    } catch (err) {
        console.error(err);
        res.status(500).send({ error: "Failed to add user" });
    }
});

app.listen(5000, () => console.log("Server running on port 5000"));
EOF

nohup node /home/adminuser/app/server.js > /home/adminuser/app/server.log 2>&1 &
'