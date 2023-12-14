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

// En tu archivo de rutas de Node.js

app.get('/alumnos/:id', (req, res) => {
    const { id } = req.params;
    db.query('SELECT * FROM alumnos WHERE id = ?', [id], (err, results) => {
        if (err) {
            res.status(500).send("Error en la consulta");
            return;
        }

        if (results.length > 0) {
            res.json(results[0]);
        } else {
            res.status(404).send("Alumno no encontrado");
        }
    });
});

app.get('/alumnos/:id/tareas-asignadas', (req, res) => {
    const { id } = req.params;
    const query = `
        SELECT 
            tareas.*, 
            ComandaAsignada.id AS comandaAsignadaId,
            FijaAsignada.id AS fijaAsignadaId,
            MaterialAsignada.id AS materialAsignadaId
        FROM 
            tareas
        LEFT JOIN ComandaAsignada ON tareas.id = ComandaAsignada.tarea_id
        LEFT JOIN FijaAsignada ON tareas.id = FijaAsignada.tarea_id
        LEFT JOIN MaterialAsignada ON tareas.id = MaterialAsignada.tarea_id
        WHERE 
            ComandaAsignada.alumno_id = ?
            OR FijaAsignada.alumno_id = ?
            OR MaterialAsignada.alumno_id = ?;
    `;

    db.query(query, [id, id, id], (err, results) => {
        if (err) {
            res.status(500).send("Error en la consulta: " + err.message);
            return;
        }
        res.json(results);
    });
});







// Ruta para agregar un nuevo alumno
app.post('/alumnos', (req, res) => {

    const { nombre, password, imagen, texto, audio } = req.body;
    console.log('Recibido:', { nombre, password, imagen, texto, audio }); // Para depuración

    db.query('INSERT INTO alumnos (nombre, password, imagen, texto, audio) VALUES (?, ?, ?, ?, ?)', 
    [nombre, password, imagen, texto, audio], (err, results) => {
        if (err) {
            res.status(500).send("Error al insertar alumno");
            return;
        }
        res.json({ status: 'success', message: 'Alumno añadido exitosamente', id: results.insertId });
    });
});

app.delete('/alumnos/:id', (req, res) => {
    const { id } = req.params;

    db.query('DELETE FROM alumnos WHERE id = ?', [id], (err, results) => {
        if (err) {
            res.status(500).send("Error al eliminar alumno");
            return;
        }
        res.json({ status: 'success', message: 'Alumno eliminado exitosamente' });
    });
});


app.put('/alumnos/:id', (req, res) => {
    const { id } = req.params;
    const { nombre, Imagen, Texto, Audio, password } = req.body;

    db.query('UPDATE alumnos SET nombre = ?, Imagen = ?, Texto = ?, Audio = ?, password = ? WHERE id = ?',
        [nombre, Imagen, Texto, Audio, password, id],
        (err, results) => {
            if (err) {
                res.status(500).send("Error en la actualización");
                return;
            }
            res.json({ status: 'success', message: 'Datos actualizados correctamente' });
        }
    );
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

    console.log('Agrego esta tarea: nombre:' + nombre + " tipo: " + tipo);
    db.query('INSERT INTO tareas (nombre, tipo) VALUES (?, ?)', [nombre, tipo], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, id: results.insertId });
    });
});

// Backend: En tu servidor Express (Node.js)

app.delete('/tareas/:id', (req, res) => {
    const { id } = req.params;

    console.log('Eliminando tarea con ID:', id);
    db.query('DELETE FROM tareas WHERE id = ?', [id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        if (results.affectedRows === 0) {
            return res.status(404).json({ message: 'No se encontró la tarea' });
        }
        res.json({ success: true, message: 'Tarea eliminada' });
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

app.post('/alumnos/:alumnoId/asignar-material', (req, res) => {
    const { tarea_id } = req.body;
    const alumno_id = req.params.alumnoId;

    db.query('INSERT INTO MaterialAsignada (alumno_id, tarea_id) VALUES (?, ?)', [alumno_id, tarea_id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        const insertId = results.insertId; // Obtener el ID de la tarea creada
        res.json({ success: true, message: 'Material asignado correctamente', id: insertId });
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

app.patch('/alumnos/:alumnoId/materiales-asignados/:tareaId/completar', (req, res) => {
    const { alumnoId, tareaId } = req.params;
    const { completada, ultimoPaso } = req.body; // Este valor debe ser TRUE o FALSE

    db.query('UPDATE MaterialAsignada SET completada = ?, ultimo_paso = ? WHERE alumno_id = ? AND id = ?', [completada, ultimoPaso, alumnoId, tareaId], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, message: 'Estado de la tarea material actualizado correctamente' });
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
        const insertId = results.insertId; // Obtener el ID de la tarea creada
        res.json({ success: true, message: 'Tarea Fija asignado correctamente', id: insertId });
        
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

// Ruta para actualizar el estado de completada de una Tarea Fija
app.patch('/alumnos/:alumnoId/tareas-fijas/:tareaId/completar', (req, res) => {
    const { alumnoId, tareaId } = req.params;
    const { completada, ultimoPaso } = req.body; // Este valor debe ser TRUE o FALSE

    db.query('UPDATE FijaAsignada SET completada = ?, ultimo_paso = ? WHERE alumno_id = ? AND id = ?', [completada, ultimoPaso, alumnoId, tareaId], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, message: 'Estado de la tarea fija actualizado correctamente' });
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
        const insertId = results.insertId; // Obtener el ID de la tarea creada
        res.json({ success: true, message: 'Comanda asignada correctamente', id: insertId });
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

// Ruta para actualizar el estado de completada de una Tarea Comanda
app.patch('/alumnos/:alumnoId/tareas-comandas/:tareaId/completar', (req, res) => {
    const { alumnoId, tareaId } = req.params;
    const { completada, ultimoPaso } = req.body; // Este valor debe ser TRUE o FALSE

    db.query('UPDATE ComandaAsignada SET completada = ?, ultimo_paso = ? WHERE alumno_id = ? AND id = ?', [completada, ultimoPaso, alumnoId, tareaId], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({ success: true, message: 'Estado de la tarea comanda actualizado correctamente' });
    });
});


//------------------------------------------

app.get('/aulas', (req, res) => {
    db.query('SELECT * FROM Aula', (error, results) => {
        if (error) {
            console.error("Error al obtener aulas:", error);
            return res.status(500).json({ error: "Error al obtener aulas" });
        }

        // Aquí se añade el console.log para ver los resultados
        console.log("Resultados de la consulta de aulas:", results);

        res.json({ success: true, aulas: results });
    });
});

// En tu archivo server.js (o el archivo donde tengas tu servidor Express)

app.post('/comanda-elemento', (req, res) => {
    const { comandaAsignada_id, elementoTarea_id, cantidad, id_aula } = req.body;

    // Asegúrate de que todos los campos necesarios estén presentes
    if (!comandaAsignada_id || !elementoTarea_id || !cantidad || !id_aula) {
        return res.status(400).send('Faltan datos requeridos');
    }

    const query = 'INSERT INTO ComandaElemento (comandaAsignada_id, elementoTarea_id, cantidad, id_aula) VALUES (?, ?, ?, ?)';
    
    db.query(query, [comandaAsignada_id, elementoTarea_id, cantidad, id_aula], (error, results) => {
        if (error) {
            console.error('Error al insertar en ComandaElemento:', error);
            return res.status(500).json({ error: 'Error interno del servidor' });
        }
        res.json({ success: true, message: 'ComandaElemento creado exitosamente', id: results.insertId });
    });
});

//---------------------------

// Backend: En tu servidor Express (Node.js)

// Endpoint para obtener la cantidad de un elemento en MaterialElemento
app.get('/material-elemento/:id', (req, res) => {
    const elementoId = req.params.id;

    db.query('SELECT cantidad FROM MaterialElemento WHERE elementoTarea_id = ?', [elementoId], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        if (results.length === 0) {
            return res.status(404).json({ message: 'No se encontró el elemento' });
        }
        const cantidad = results[0].cantidad;
        res.json({ success: true, cantidad });
    });
});

app.get('/alumnos/:alumnoId/tareas/:tipo/:id', (req, res) => {
    const { alumnoId, tipo, id } = req.params;

    let tableName;
    if (tipo === "Fija") {
        tableName = "FijaAsignada";
    } else if (tipo === "Comanda") {
        tableName = "ComandaAsignada";
    } else if (tipo === "Material") {
        tableName = "MaterialAsignada";
    } else {
        return res.status(400).json({ error: "Tipo de tarea no válido" });
    }

    const query = `SELECT * FROM ${tableName} WHERE alumno_id = ? AND id = ?`;
    db.query(query, [alumnoId, id], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        if (results.length > 0) {
            res.json(results[0]);
        } else {
            res.status(404).json({ message: 'Tarea no encontrada' });
        }
    });
});

//--------------------------------------------

// Endpoint para obtener tareas completadas
app.get('/tareas-completadas', (req, res) => {
    const query = `
      SELECT FA.id AS asignadaId, FA.tarea_id AS tareaId, FA.alumno_id, A.nombre AS nombre_alumno, T.nombre AS nombre_tarea, T.tipo, FA.ultimo_paso
      FROM FijaAsignada FA
      INNER JOIN tareas T ON FA.tarea_id = T.id
      INNER JOIN alumnos A ON FA.alumno_id = A.id
      WHERE FA.completada = 1
      UNION
      SELECT CA.id AS asignadaId, CA.tarea_id AS tareaId, CA.alumno_id, A.nombre AS nombre_alumno, T.nombre AS nombre_tarea, T.tipo, CA.ultimo_paso
      FROM ComandaAsignada CA
      INNER JOIN tareas T ON CA.tarea_id = T.id
      INNER JOIN alumnos A ON CA.alumno_id = A.id
      WHERE CA.completada = 1
      UNION
      SELECT MA.id AS asignadaId, MA.tarea_id AS tareaId, MA.alumno_id, A.nombre AS nombre_alumno, T.nombre AS nombre_tarea, T.tipo, MA.ultimo_paso
      FROM MaterialAsignada MA
      INNER JOIN tareas T ON MA.tarea_id = T.id
      INNER JOIN alumnos A ON MA.alumno_id = A.id
      WHERE MA.completada = 1
    `;
    db.query(query, (error, results) => {
      if (error) {
        return res.status(500).json({ error });
      }
      res.json({ tareasCompletadas: results });
    });
});


  
  
  app.post('/confirmar-tarea', (req, res) => {
    const { asignadaId, tareaId, alumnoId, nombre, tipo } = req.body;
  
    db.beginTransaction((err) => {
      if (err) { throw err; }
  
      // Inserta en TareasFinalizadas
      const insertFinalizada = 'INSERT INTO TareasFinalizadas (alumno_id, nombre, tipo) VALUES (?, ?, ?)';
      db.query(insertFinalizada, [alumnoId, nombre, tipo], (error, results) => {
        if (error) {
          return db.rollback(() => {
            throw error;
          });
        }
  
        // Elimina de la tabla de tarea asignada
        const deleteTareaAsignada = `DELETE FROM ${tipo}Asignada WHERE id = ?`;
        db.query(deleteTareaAsignada, [asignadaId], (error, results) => {
          if (error) {
            return db.rollback(() => {
              throw error;
            });
          }
  
          // Elimina de la tabla tareas
          const deleteTarea = `DELETE FROM tareas WHERE id = ?`;
          db.query(deleteTarea, [tareaId], (error, results) => {
            if (error) {
              return db.rollback(() => {
                throw error;
              });
            }
  
            db.commit((err) => {
              if (err) {
                return db.rollback(() => {
                  throw err;
                });
              }
              res.json({ success: true, message: 'Tarea confirmada y movida a finalizadas' });
            });
          });
        });
      });
    });
  });

  app.get('/tareas-finalizadas', (req, res) => {
    const query = `
    SELECT TF.*, A.nombre AS nombre_alumno, TF.fecha_finalizacion
    FROM TareasFinalizadas TF
    INNER JOIN alumnos A ON TF.alumno_id = A.id
    ORDER BY A.nombre, TF.fecha_finalizacion
  `;
    db.query(query, (error, results) => {
      if (error) {
        return res.status(500).json({ error });
      }
      res.json({ tareasFinalizadas: results });
    });
  });
  
  app.get('/historial-alumno/:alumnoId', (req, res) => {
    const { alumnoId } = req.params;
    const query = `
      SELECT TF.*, A.nombre AS nombre_alumno, TF.fecha_finalizacion, TF.tipo
      FROM TareasFinalizadas TF
      INNER JOIN alumnos A ON TF.alumno_id = A.id
      WHERE TF.alumno_id = ?
      ORDER BY TF.fecha_finalizacion DESC
    `;
    db.query(query, [alumnoId], (error, results) => {
      if (error) {
        return res.status(500).json({ error });
      }
      res.json({ tareasFinalizadas: results });
    });
  });
  
  

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
