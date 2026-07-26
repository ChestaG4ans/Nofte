require("dotenv").config();

const express = require("express");
const cors = require("cors");
const path = require("path");

const app = express();

app.use(cors());
app.use(express.json());

// Serve static files
app.use(express.static(__dirname));

const API_KEY = process.env.GEMINI_API_KEY;

app.post("/api/chat", async (req, res) => {

    try {

        const message = req.body.message;

        if (!message) {

            return res.status(400).json({
                error: "Pesan kosong"
            });

        }

        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}`,
            {
                method: "POST",

                headers: {
                    "Content-Type": "application/json"
                },

                body: JSON.stringify({
                    contents: [
                        {
                            parts: [
                                {
                                    text: message
                                }
                            ]
                        }
                    ]
                })
            }
        );

        const data = await response.json();

        console.log(
            JSON.stringify(
                data,
                null,
                2
            )
        );

        let reply =
            "Maaf, saya tidak dapat menjawab saat ini.";

        if (
            data.candidates &&
            data.candidates.length > 0
        ) {

            reply =
                data.candidates[0]
                .content
                .parts[0]
                .text;

        }

        res.json({
            reply
        });

    } catch (err) {

        console.error(err);

        res.status(500).json({
            error: err.message
        });

    }

});

app.listen(3000, () => {

    console.log(
        "================================="
    );

    console.log(
        "SERVER BERJALAN"
    );

    console.log(
        "http://localhost:3000"
    );

    console.log(
        "================================="
    );

});