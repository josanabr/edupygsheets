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
#
# gitclone(): Esta funcion recibe un argumento y es el URL de un proyecto
# en Github que, e.g. 
# 'https://github.com/josanabr/OS.git'
#
# RETORNA el nombre del directorio donde quedaron los archivos descargados del 
# repositorio
#
temp_date=$(date +%s)
result_file="/tmp/evaluation-results-${temp_date}.txt"
error_file="/tmp/tmp-evalresults-${temp_date}.txt"
function Echo() {
	echo "${1}" >> ${result_file}
	echo "${1}"
}
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
# VARIABLES DE CONFIGURACION
# Este archivo contiene la deficion de cuatro parametros
# ID: identificador de la hoja de calculo
# SHEET: nombre de la hoja en particular que se desea acceder
# COLUMN: Columna de la cual se revisara para traer los datos
# LROW: Limite bajo del numero de fila
# HROW: Limite alto del numero de fila
CONF_SHEET_FILE="sheet.conf"
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
	docker run --rm -ti -v $(pwd)/${1}:/source build-essential2 ./${2} > ${OUTPUTFILE}
	output=$(grep Estudiante_1 ${OUTPUTFILE} | cut -d ' ' -f 2)
	output="${output}|$(grep Estudiante_2 ${OUTPUTFILE} | cut -d ' ' -f 2)"
	output="${output}|$(grep archivos ${OUTPUTFILE} | cut -d ' ' -f 3)"
	output="${output}|$(grep bytes ${OUTPUTFILE} | cut -d ' ' -f 3)"
	mv ${OUTPUTFILE} ${1}
	echo ${output}
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
	ID=$( grep ID ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	SHEET=$( grep SHEET ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	COL=$( grep COL ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	LROW=$( grep LROW ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	HROW=$( grep HROW ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	RESULTCLONE=$( grep RESULTCLONE ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	RESULTCOMPILE=$( grep RESULTCOMPILE ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	RESULTEXECUTE=$( grep RESULTEXECUTE ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	REVIEWEDDIR=$( grep REVIEWEDDIR ${CONF_SHEET_FILE} | cut -d ' ' -f 2 )
	echo -n "Cargando datos de la hoja de calculo [${ID}] .."
	GITURLS=$( python pygsheets_getcol.py ${ID} ${SHEET} ${COL} ${LROW} ${HROW} )
	echo "."
	# Traverse through every Github URL
	count=$( echo ${LROW} )
	for i in $( echo $GITURLS ); do
		echo "Github URL: ${i}"
		proydir=$( gitclone $i ) # Clone the given URL
		if [ "${proydir:0:5}" == "ERROR" ]; then
			echo "Error retrieving ${i}... skipping"
			#python ./pygsheets_updatecell.py ${ID} ${SHEET} ${RESULTCLONE}${count} "Error retrieving ${i}"
			updatecell ${ID} ${SHEET} "${RESULTCLONE}${count}" "Error retrieving ${i}"
			continue
		fi

		echo "Evaluating ${proydir}"
		# cloning OK
		updatecell ${ID} ${SHEET} "${RESULTCLONE}${count}" "OK"
		# compiling
		dockcompiling ${proydir} 
		result=$( testcompilation ${proydir} )
		updatecell ${ID} ${SHEET} "${RESULTCOMPILE}${count}" ${result} 
		if [ "${result:0:5}" == "ERROR" ]; then
			echo "Error on ${proydir}"
			continue
		fi
		# preparing dir
		cp README.md ${proydir}
		# executing
		result=$(dockexecution ${proydir} io)
		echo ${result}
		result=$(dockexecution ${proydir} iofork)
		echo ${result}
		echo "Moving dir [${proydir}] to [${REVIEWEDDIR}]" 
		moverdir ${proydir} ${REVIEWEDDIR}
		count=$(( count + 1 ))
	done
}
#
#
#
evaluargrupo ${DIR} ${RESULT}
echo "-=*=-=*=-=*=-=*=-=*=-"
echo "Error file ${error_file}"
echo "Results ${result_file}"
