#!/usr/bin/env bash
#
# Este script sirve para llevar a cabo el proceso de evaluacion de resultados
# de la ejecucion de programas de computador elaborados por estudiantes en
# respuesta a una asigancion academica.
#
# AUTHOR: John Sanabria
# EMAIL: john.sanabria@correounivalle.edu.co
# DATE: Abril 4, 2017
#
# Inicializando variables globales
#
# ID: identificador de la hoja de calculo
# SHEET: nombre de la hoja en particular que se desea acceder
# COLUMN: Columna de la cual se revisara para traer los datos
# LROW: Limite bajo del numero de fila
# HROW: Limite alto del numero de fila
#
CONF_SHEET_FILE="sheet.json"
ID=$( ./jsonValue.py ${CONF_SHEET_FILE} id )
SHEET=$( ./jsonValue.py ${CONF_SHEET_FILE} sheet )
COL=$( ./jsonValue.py ${CONF_SHEET_FILE} columns repo )
LROW=$( ./jsonValue.py ${CONF_SHEET_FILE} rows low )
HROW=$( ./jsonValue.py ${CONF_SHEET_FILE} rows high )
RESULTCLONE=$( ./jsonValue.py ${CONF_SHEET_FILE} columns clone )
RESULTCOMPILE=$( ./jsonValue.py ${CONF_SHEET_FILE} columns compile )
ESTUDIANTE_1=$( ./jsonValue.py ${CONF_SHEET_FILE} columns estudiante_1 )
ESTUDIANTE_2=$( ./jsonValue.py ${CONF_SHEET_FILE} columns estudiante_2 )
RESULT_1_A=$( ./jsonValue.py ${CONF_SHEET_FILE} columns execute_1_a )
RESULT_1_B=$( ./jsonValue.py ${CONF_SHEET_FILE} columns execute_1_b )
RESULT_2_A=$( ./jsonValue.py ${CONF_SHEET_FILE} columns execute_2_a )
RESULT_2_B=$( ./jsonValue.py ${CONF_SHEET_FILE} columns execute_2_b )
#
# Archivos y directorios
#
temp_date=$(date +%s)
result_file="/tmp/evaluation-results-${temp_date}.txt"
error_file="/tmp/tmp-evalresults-${temp_date}.txt"
REVIEWEDDIR=reviewed
TESTDIR=testdir
#
# Valores de referencia
#
REFVALORARCHIVOS=5
REFVALORBYTES=22243
#
#
#
rango=""
rangovalores=""
#
#
#
function checkGitRepo() {
	usuario=$(./processGitURL.py -u ${1})
	repo=$(./processGitURL.py -r ${1} | cut -d '.' -f 1)
	salida=$(curl https://api.github.com/repos/${usuario}/${repo})
	notfound=$(echo ${salida} | grep "Not Found")
	if [ "${notfound}" == "" ]; then
		echo "OK"
	else
		echo "ERROR repo does not exist"
	fi
}
# -=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-
#
# gitclone(): Esta funcion recibe un argumento y es el URL de un proyecto
# en Github que, e.g. 
# 'https://github.com/josanabr/OS.git'
#
# RETORNA el nombre del directorio donde quedaron los archivos descargados del 
# repositorio
#
function gitclone() {
	git clone $1 &> ${error_file} 
	if [ ! $? -eq 0 ]; then
		echo "[ERROR] cloning ${1}" >> ${result_file}
		cat ${error_file} >> ${result_file}
		rm ${error_file}
		echo "ERROR cloning ${1}"
	else 
		newdirectory=$( cat ${error_file} | cut -d "'" -f 2 )
		echo $newdirectory
	fi
}
#
# Esta funcion recibe tres argumentos, un nombre de archivo, una 'expresion'
# regular y un numero entero. La funcion busca en el archivo, dicha 'expresion'
# y en esa linea la corta por el delimitador ' ' y extrae el campo indicado en
# en el tercer argumento. 
# 
# Esta funcion se puede invocar como
#
# getValueWS output.txt Estudiante_1 2
#
function getValueWS() {
	echo $(grep $2 $1 | cut -d ' ' -f ${3})
}
#
# Esta funcion se encarga de compilar el codigo que se encuentra en el
# directorio que se le pasa como argumento. Esta compilacion se hace a traves
# de un contenedor en Docker
#
function dockcompiling() {
	echo "Compiling ${1}"
	docker run --rm -ti -v $(pwd)/${1}:/source build-essential2 make io
	docker run --rm -ti -v $(pwd)/${1}:/source build-essential2 make iofork
}
#
# Esta funcion se encarga de valorar si la ejecucion arroja los valores de 
# ejecucion esperados
#
# El primer argumento denota la fila (o grupo) que se esta evaluando. El 2do
# argumento hace referencia al numero de archivos y el 3er argumento al 
# numero de bytes.
#
function evaluarExe1() {
	echo "Evaluando ejecucion 1"
	varchivos=${2::-1}
	vbytes=${3::-1}
	echo "	Valores de referencia ${REFVALORARCHIVOS} ${REFVALORBYTES}."
	echo "	Valores obtenidos ${varchivos} ${vbytes}."
	if [ "${2}" == "" ]; then
		rangovalores="${rangovalores} 0 0"
	else 
		if [ "$varchivos" == "$REFVALORARCHIVOS" ]; then
			rangovalores="${rangovalores} 1"
		else
			rangovalores="${rangovalores} 0"
		fi
		if [ "$vbytes" == "$REFVALORBYTES" ]; then
			rangovalores="${rangovalores} 1"
		else
			rangovalores="${rangovalores} 0"
		fi
	fi
}
#
# Esta funcion se encarga de valorar si la ejecucion arroja los valores de 
# ejecucion esperados
#
# El primer argumento denota la fila (o grupo) que se esta evaluando. El 2do
# argumento hace referencia al numero de archivos y el 3er argumento al 
# numero de bytes.
#
function evaluarExe2() {
	echo "Evaluando ejecucion 2"
	varchivos=${2::-1}
	vbytes=${3::-1}
	echo "	Valores de referencia ${REFVALORARCHIVOS} ${REFVALORBYTES}."
	echo "	Valores obtenidos ${varchivos} ${vbytes}."
	if [ "${2}" == "" ]; then
		rangovalores="${rangovalores} 0 0"
	else 
		if [ "${varchivos}" == "${REFVALORARCHIVOS}" ]; then
			rangovalores="${rangovalores} 1"
		else
			rangovalores="${rangovalores} 0"
		fi
		if [ "${vbytes}" == "${REFVALORBYTES}" ]; then
			rangovalores="${rangovalores} 1"
		else
			rangovalores="${rangovalores} 0"
		fi
	fi
}
#
# Esta funcion recibe como parametro un directorio y valida que los archivos
# que se debieron crear en la compilacion, aparezcan (io e iofork)
#
function testcompilation() {
	result=""
	if [ -f ${1}/io -a -f ${1}/iofork ]; then
		result="OK"
	else
		result="ERROR compiling ${1}"
	fi
	echo ${result}
}
#
#
#
function dockexecution() {
	OUTPUTFILE="/tmp/output-${temp_date}.txt"
	docker run --rm -ti -v $(pwd)/${1}:/source build-essential2 ./${2} ${3} > ${OUTPUTFILE} 2>&1
	echo ${OUTPUTFILE}
}
#
#
#
#function checkoutput() {
#	
#}
#
# Este metodo se encarga de llamar un script en Python que actualiza datos en
# una hoja de calculo en Google Drive
#
function updatecell() {
	python ./pygsheets_updatecell.py ${1} ${2} ${3} ${4}
}
#
# Este metodo se encarga de llamar un script en Python que actualiza un rango de
#  datos en una hoja de calculo en Google Drive
#
function updatecells() {
	echo "${2}"
	echo "${4}"
	python ./pygsheets_updatecells.py ${1} ${2} ${3} "${4}"
}
#
#
#
function moverdir() {
	if [ ! -d ${2} ]; then
		mkdir ${2}
	fi
	mv ${1} ${2}
	echo $?
}
#
# evaluargrupo(): carga los datos de una hoja de calculo y se encarga de evaluar
# los distintos repositorios con los valores esperados
#
# La variable 'CONF_SHEET_FILE' referencia a una hoja de calculo que contiene
# el identificador de la hoja de calculo de donde se extraeran los datos para 
# evaluar al grupo
# 
function evaluargrupo() {
	#
	# Ir a hoja calculo, recuperar los URLs desde Github de los proyectos
	#
	echo -n "Cargando datos de la hoja de calculo [${ID}] .."
	GITURLS=$( python pygsheets_getcol.py ${ID} ${SHEET} ${COL} ${LROW} ${HROW} )
	echo "."
	# Traverse through every Github URL
	count=$( echo ${LROW} )
	echo "-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-"
	for i in $( echo $GITURLS ); do
		echo "Github URL: ${i}"
		check=$(checkGitRepo ${i})
		if [ "${check:0:5}" == "ERROR" ]; then
			echo "Repo [${i}] does not exist"
			updatecell ${ID} ${SHEET} "${RESULTCLONE}${count}" "ERROR repo ${i}"
			count=$(( count + 1 ))
			continue
			
		fi
		proydir=$( gitclone $i ) # Clone the given URL
		if [ "${proydir:0:5}" == "ERROR" ]; then
			echo "Error retrieving ${i}... skipping"
			updatecell ${ID} ${SHEET} "${RESULTCLONE}${count}" "Error retrieving ${i}"
			count=$(( count + 1 ))
			continue
		fi
		rangovalores="OK"
		rango="${RESULTCLONE}${count}:"
		echo "Evaluating ${proydir}"
		# cloning OK
		echo "Cloning OK"
		# compiling
		dockcompiling ${proydir} 
		result=$( testcompilation ${proydir} )
		if [ "${result:0:5}" == "ERROR" ]; then
			rangovalores="${rangovalores} ERROR"
			rango="${rango}${RESULTCOMPILE}${count}"
			updatecells ${ID} ${SHEET} ${rango} "${rangovalores}"
			echo "Error compiling ${proydir}"
			moverdir ${proydir} ${REVIEWEDDIR}
			count=$(( count + 1 ))
			continue
		fi
		echo "Compiling OK"
		rangovalores="${rangovalores} OK"
		# preparando directorio de pruebas
		cp -R ${TESTDIR} ${proydir}
		# ejecutando el primer programa
		# 'result' contiene la salida de ejecutar 'io'
		result=$(dockexecution ${proydir} io ${TESTDIR})
		# Copiar el resultado de la ejecucion en el directorio del
		# proyecto bajo evaluacion
		cp ${result} ${proydir} 
		# Guardando codigo de los estudiantes
		estudiante=$(getValueWS ${result} Estudiante_1 2)
		updatecell ${ID} ${SHEET} "${ESTUDIANTE_1}${count}" "${estudiante}"
		estudiante=$(getValueWS ${result} Estudiante_2 2)
		updatecell ${ID} ${SHEET} "${ESTUDIANTE_2}${count}" "${estudiante}"
		# Obteniendo valores de la primera ejecucion
		valueBytes=$(getValueWS ${result} bytes 3)
		valueArchivos=$(getValueWS ${result} archivos 3)
		evaluarExe1 ${count} ${valueArchivos} ${valueBytes} 
		# ejecutando el segundo programa
		# 'result' contiene la salida de ejecutar 'iofork'
		result=$(dockexecution ${proydir} iofork ${TESTDIR})
		echo "----" >> ${proydir}/$(basename ${result})
		cat ${result} >> ${proydir}/$(basename ${result})
		# Obteniendo valores de la segunda ejecucion
		valueBytes=$(getValueWS ${result} bytes 3)
		valueArchivos=$(getValueWS ${result} archivos 3)
		evaluarExe2 ${count} ${valueArchivos} ${valueBytes} 
		updatecells ${ID} ${SHEET} "${rango}${RESULT_2_B}${count}" "${rangovalores}"
		rm ${result}
		rm -rf ${proydir}/${TESTDIR}
		echo "Moving dir [${proydir}] to [${REVIEWEDDIR}]" 
		moverdir ${proydir} ${REVIEWEDDIR}
		count=$(( count + 1 ))
		echo "-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-"
	done
}
#
#
#
evaluargrupo ${DIR} ${RESULT}
echo "Error file ${error_file}"
echo "Results ${result_file}"
