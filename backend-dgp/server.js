const express = require('express');
const mysql = require('mysql');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(bodyParser.json()); // para peticiones con cuerpo tipo application/json
app.use(bodyParser.urlencoded({ extended: true })); // para peticiones con cuerpo tipo application/x-www-form-urlencoded

app.use(cors());

// Modificar la conexión para que utilice 'APPDGP' como nombre de la base de datos
const db = mysql.createConnection({
    host: process.env.DATABASE_HOST,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    database: 'APPDGP'  // Aquí especificamos el nombre de tu base de datos directamente
});

db.connect((err) => {
    if(err) throw err;
    console.log('Connected to the database');
});

app.get('/', (req, res) => {
    res.send('Hola desde Node.js con MySQL!');
});

// Nueva ruta para obtener administradores
app.get('/administradores', (req, res) => {
    db.query('SELECT * FROM administrador', (err, rows) => {
        if (err) {
            res.status(500).send("Error al obtener datos");
            return;
        }
        res.json(rows);
    });
});

// en tu server.js o donde tengas tus rutas

app.post('/login', (req, res) => {
    const { username, password } = req.body;

    db.query('SELECT * FROM administrador WHERE username = ?', [username], (err, results) => {
        if (err) {
            res.status(500).send("Error en la consulta");
            return;
        }

        if (results.length > 0 && results[0].password === password) {
            res.json({ status: 'success', message: 'Inicio de sesión exitoso' });
        } else {
            res.json({ status: 'error', message: 'Usuario o contraseña incorrectos' });
        }
    });
});


// Implementamos a los alumnos en la base de datos

app.get('/alumnos', (req, res) => {
    db.query('SELECT * FROM alumnos', (err, rows) => {
        if (err) {
            res.status(500).send("Error al obtener datos");
            return;
        }
        res.json(rows);
    });
});

// Ruta para agregar un nuevo alumno
app.post('/alumnos', (req, res) => {
    console.log("Holiwi"); // Cambiamos print a console.log
    // Asumiendo que el cuerpo de la solicitud contiene 'nombre', 'imagen', 'texto', 'audio'
    const { nombre, imagen, texto, audio } = req.body;
    db.query('INSERT INTO alumnos (nombre, imagen, texto, audio) VALUES (?, ?, ?, ?)', 
    [nombre, imagen, texto, audio], (err, results) => {
        if (err) {
            res.status(500).send("Error al insertar alumno");
            return;
        }
        res.json({ status: 'success', message: 'Alumno añadido exitosamente', id: results.insertId });
    });
});



//----------------------- CREACION DE TAREAS Y ELEMENTO TAREAS -------------------------------//

app.get('/tareas', (req, res) => {
    db.query('SELECT * FROM tareas', (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json(results);
    });
});

app.post('/tareas', (req, res) => {
    const { nombre, tipo } = req.body;

    db.query('INSERT INTO tareas (nombre, tipo) VALUES (?, ?)', [nombre, tipo], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, id: results.insertId });
    });
});

app.post('/tareas/:id/elementos', (req, res) => {
    const tareaId = req.params.id;
    const { pictograma, descripcion, sonido, video } = req.body;
    db.query('INSERT INTO elementoTarea (pictograma, descripcion, sonido, video, tarea_id) VALUES (?, ?, ?, ?, ?)', [pictograma, descripcion, sonido, video, tareaId], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, id: results.insertId });
    });
});

app.get('/tareas/:id/elementos', (req, res) => {
    const tareaId = req.params.id;

    db.query('SELECT * FROM elementoTarea WHERE tarea_id = ?', [tareaId], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, elementos: results });
    });
});

//---------------------------------------------

// ...

// Ruta para asignar un Material a un Alumno
app.post('/alumnos/:alumnoId/asignar-material', (req, res) => {
    const { tarea_id } = req.body;
    const alumno_id = req.params.alumnoId;

    db.query('INSERT INTO MaterialAsignada (alumno_id, tarea_id) VALUES (?, ?)', [alumno_id, tarea_id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, message: 'Material asignado correctamente' });
    });
});

// Ruta para obtener Materiales Asignados a un Alumno
app.get('/alumnos/:alumnoId/materiales-asignados', (req, res) => {
    const alumno_id = req.params.alumnoId;

    // Utiliza un JOIN para obtener el nombre de la tarea
    db.query('SELECT M.*, T.nombre AS nombre_tarea FROM MaterialAsignada M JOIN tareas T ON M.tarea_id = T.id WHERE M.alumno_id = ?', [alumno_id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, materialesAsignados: results });
    });
});

// Ruta para asignar una cantidad a un MaterialElemento
app.post('/material-elemento', (req, res) => {
    const { materialAsignada_id, elementoTarea_id, cantidad } = req.body;

    db.query('INSERT INTO MaterialElemento (materialAsignada_id, elementoTarea_id, cantidad) VALUES (?, ?, ?)', [materialAsignada_id, elementoTarea_id, cantidad], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, message: 'Cantidad asignada correctamente' });
    });
});


// Ruta para asignar una Tarea Fija a un Alumno
app.post('/alumnos/:alumnoId/asignar-tarea-fija', (req, res) => {

    const { tarea_id, alumno_id } = req.body;

    console.log(tarea_id, alumno_id);

    db.query('INSERT INTO FijaAsignada (alumno_id, tarea_id) VALUES (?, ?)', [alumno_id, tarea_id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, message: 'Tarea Fija asignada correctamente' });
    });
});

// Ruta para obtener Tareas Fijas Asignadas a un Alumno
app.get('/alumnos/:alumnoId/tareas-fijas-asignadas', (req, res) => {
    const alumno_id = req.params.alumnoId;

    // Utiliza un JOIN para obtener el nombre de la tarea fija
    db.query('SELECT F.*, T.nombre AS nombre_tarea FROM FijaAsignada F JOIN tareas T ON F.tarea_id = T.id WHERE F.alumno_id = ?', [alumno_id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, tareasFijasAsignadas: results });
    });
});


// Ruta para asignar una Tarea Comanda a un Alumno
app.post('/alumnos/:alumnoId/asignar-tarea-comanda', (req, res) => {
    const { tarea_id } = req.body;
    const alumno_id = req.params.alumnoId;

    db.query('INSERT INTO ComandaAsignada (alumno_id, tarea_id) VALUES (?, ?)', [alumno_id, tarea_id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, message: 'Tarea Comanda asignada correctamente' });
    });
});

// Ruta para obtener Tareas Comandas Asignadas a un Alumno
app.get('/alumnos/:alumnoId/tareas-comandas-asignadas', (req, res) => {
    const alumno_id = req.params.alumnoId;

    // Utiliza un JOIN para obtener el nombre de la tarea comanda
    db.query('SELECT C.*, T.nombre AS nombre_tarea FROM ComandaAsignada C JOIN tareas T ON C.tarea_id = T.id WHERE C.alumno_id = ?', [alumno_id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, tareasComandasAsignadas: results });
    });
});




app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
