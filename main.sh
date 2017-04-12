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
	echo -n "Cargando datos de la hoja de calculo [${ID}] .."
	echo " ${COL} ${LROW} ${HROW}"
	GITURLS=$( python pygsheets_getcol.py ${ID} ${SHEET} ${COL} ${LROW} ${HROW} )
	echo "."
	# Traverse through every Github URL
	count=$( echo ${LROW} )
	for i in $( echo $GITURLS ); do
		echo "Github URL: ${i}"
		proydir=$( gitclone $i ) # Clone the given URL
		if [ "${proydir:0:5}" == "ERROR" ]; then
			echo "Error retrieving ${i}... skipping"
			python ./pygsheets_updatecell.py ${ID} ${SHEET} ${RESULTCLONE}${count} "Error retrieving ${i}"
		else
			echo "Evaluating ${proydir}"
			python ./pygsheets_updatecell.py ${ID} ${SHEET} ${RESULTCLONE}${count} "OK"
			echo "Erasing dir [${proydir}]" 
			rm -rf ${proydir}
		fi
		count=$(( count + 1 ))
	done
}
#
DIRPRUEBAS="pruebas"
for i in $( ls ${DIRPRUEBAS}/*); do
	DIR=$( grep DIRECTORY ${i} | cut -d ' ' -f 2 )
	RESULT=$( grep RESULT ${i} | cut -d ' ' -f 2 )
done 
evaluargrupo ${DIR} ${RESULT}
#gitclone https://github.com/josanabr/OS.git
echo "-=*=-=*=-=*=-=*=-=*=-"
echo "Error file ${error_file}"
echo "Results ${result_file}"
