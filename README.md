# Evaluacion de tareas de programacion

En este repositorio se han desarrollado una serie de scripts (en Bash y Python)
para llevar a cabo la evaluacion de tareas de programacion radicadas en un 
repositorio de GitHub. 

Estos scripts se desarrollaron pensando en el uso de documentos en Google Drive 
y que permitiran recuperar y almacenar informacion en estos.

El uso del proyecto es el siguiente, se asume que una lista de URLs de GitHub
se localizan en una hoja de calculo de Google Drive. 
Esta lista es consumida por el script `main.sh` quien se apoya en scripts en
Python para acceder a documentos de Google Drive y con scripts en Bash se 
encarga de descargar cada uno de los proyecto en GitHub, los compila, los 
ejecuta y compara la salida de las ejecuciones con valores esperados. 
Todos los tres pasos (descargar, compilar, ejecutar) son monitoreados y se 
lleva a la hoja de calculo cada una de las etapas para facilitar la evaluacion
de los programas.

Este repositorio consiste de los siguienes scripts:

* `main.sh` este script toma informacion del archivo de configuracion 
`sheet.conf` y descarga la lista de repositorios que se van a evaluar.
* `pygsheets_*.py` scripts en Python que se encargan de acceder a documentos
en Google Drive. 
* `copygrades.py` Este script en Python permite copiar la columna de una hoja
de calculo en otra hoja de calculo. Es usada para copiar, por ejemplo, los 
resultados arrojados por Kahoot o EDpuzzle a otra hoja de calculo en Google
Drive. Se asume que tanto las hojas de calculo fuente como destino estan en 
Google Drive. En un archivo de configuracion en formato json se especifica la
columna que contiene los identificadores de estudiantes, sus respectivas notas
y la hoja de calculo destino, con la columna, que contiene los identificadores 
de los estudiantes y la columna donde se almacenaran las notas.
* `convertunicode2string.py` Este script en Python permite convertir las celdas
de una columna de formato Unicode a cadena. En un archivo de configuracion en
formato json se especifica la hoja de calculo y el rango de celdas en dicha 
hoja de calculo a la que se le va a hacer el proceso de transformacion.

---

## Requerimientos

- Necesita instalar la libreria [pygsheets](https://github.com/nithinmurali/pygsheets)

- Necesita crear un archivo llamado `config.json` el cual tiene la siguiente informacion

```
	{
		"user": "gitHubUser",
		"token": "tokenvalue"
	}
```

Para obtener el valor `tokenvalue` debe visitar este enlace en [GitHub](https://github.com/settings/tokens/new). 
Allí usted podra crear un token que le perimitirá tener un mayor número de accesos al API de GitHub.
