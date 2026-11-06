
// set up an HTTP server off port 3000

const express = require('express');
const app = express();
const PORT = 3000;

// Requires the exported pool object from the local 'mysql.js' file
const pool = require('./mysql');



//*** This handles the GET request at the root path (/)

app.get("/", async (req, res) => {
    // extract the strings received from the browser
    const category = req.query.category;
    const author = req.query.author;
    const format = req.query.format;

    // Use prepared statements (the '?' placeholder)
    let sql_query = "SELECT id, title, author, genre, price FROM books";
    let params = [];

    if (category) {
        sql_query += " WHERE genre = ?";
        params = [category];
    } else if (author) {
        sql_query += " WHERE author = ?";
        params = [author];
    }

    try {
        // Await the promise from pool.execute. It returns [result, fields].
        const [result, fields] = await pool.execute(sql_query, params);

        if (format === "text") {
            // start creating the html body for the browser
            let html_body = "<HTML><STYLE>body{font-family:arial}</STYLE>";
            html_body += "<BODY>";
            html_body += "<TABLE BORDER=1 WIDTH=800>";

            // print column headings
            html_body += "<TR>";
            // Use fields array from mysql2 for column names
            for (let i = 0; i < fields.length; i++) {
                html_body += (`<TH style="color:Tomato">${fields[i].name.toUpperCase()}</TH>`);
            }
            html_body += "</TR>";

            // prints rows of table data
            for (let i = 0; i < result.length; i++) {
                const row = result[i];
                html_body += (`<TR>
                    <TD style="vertical-align:top">${row.id}</TD>
                    <TD style="vertical-align:top"><b>${row.title}</b></TD>
                    <TD style="vertical-align:top">${row.author}</TD>
                    <TD style="vertical-align:top">${row.genre}</TD>
                    <TD style="vertical-align:top">${row.price.toFixed(2)}</TD>
                </TR>`);
            }

            html_body += "</TABLE>";

            // finish off the html body with a link back to all books
            html_body += "<BR><BR><BR><a href=http://localhost:3000/?format=text>All Books</a><BR><BR><BR>";
            html_body += "</BODY></HTML>";

            console.log("Text results generated for query:", req.query);
            res.send(html_body); // send query results back to the browser
        } else {
            // JSON is the default when format is "json" or not provided
            console.log("JSON results generated for query:", req.query);
            res.json(result);
        }

    } catch (err) {
        // Catch and handle database errors cleanly
        console.error("SQL Error in / GET:", err);
        res.status(500).json({ error: 'Database Query Error', details: err.message });
    }
});


// --- Global Error Handler Middleware ---
// Kept as a fallback for non-route-specific errors or errors passed by next()
app.use((err, req, res, next) => {
    // Log the error stack for debugging purposes
    console.error(err.stack);
    res.status(500).json({ error: 'An unexpected server error occurred.', details: err.message });
});


// set up an HTTP server off port 3000
app.listen(PORT, function () {
    console.log("NodeJS app listening on port " + PORT);
});
