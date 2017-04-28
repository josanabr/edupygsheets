#!/usr/bin/env bash
#
# Este script sirve para actualizar, dado una hoja de calculo en Google Drive
# si son validos una serie de links de la plataforma GitHub
#
#
# AUTHOR: John Sanabria
# EMAIL: john.sanabria@correounivalle.edu.co
# DATE: Abril 27, 2017
#
#
# Este metodo se encarga de llamar un script en Python que actualiza datos en
# una hoja de calculo en Google Drive
#
function updatecell() {
	python ./pygsheets_updatecell.py ${1} "${2}" ${3} "${4}"
}

#
# Inicializando variables globales
#
CONF_SHEET_FILE="sheet.json"

if [ $# -eq 1 ]; then
	CONF_SHEET_FILE="${1}"
	if [ ! -f "${CONF_SHEET_FILE}" ]; then
		echo "Archivo \"${CONF_SHEET_FILE}\" does not exist"
		exit 1
	fi
fi
echo "Using \"${CONF_SHEET_FILE}\" as config file"
echo -n "Initialiazing variables.."
ID=$( ./jsonValue.py ${CONF_SHEET_FILE} id )
SHEET=$( ./jsonValue.py ${CONF_SHEET_FILE} sheet )
COL=$( ./jsonValue.py ${CONF_SHEET_FILE} columns repo )
LROW=$( ./jsonValue.py ${CONF_SHEET_FILE} rows low )
HROW=$( ./jsonValue.py ${CONF_SHEET_FILE} rows high )
RESULTCLONE=$( ./jsonValue.py ${CONF_SHEET_FILE} columns clone )
echo "."
#
# Ir a hoja calculo, recuperar los URLs desde Github de los proyectos
#
echo -n "Cargando datos de la hoja de calculo [${ID}] .."
GITURLS=$( python pygsheets_getcol.py ${ID} "${SHEET}" ${COL} ${LROW} ${HROW} )
echo "."
# Traverse through every Github URL
logFile="/tmp/checkGit_$(date +%s).log"
count=$( echo ${LROW} )
echo "-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-=*=-"
for i in $( echo $GITURLS ); do
	echo "Checking github URL: ${i}"
	check=$(./checkGitURL.sh ${i})
	message="[${count}] Repo [${i}] does exist"
	mess2cell="OK"
	if [ "${check:0:5}" == "ERROR" ]; then
		message="[${count}] E - Repo [${i}] does not exist"
		mess2cell="ERROR repo ${i}"
	fi
	echo ${message} >> ${logFile} 2>&1
	updatecell ${ID} "${SHEET}" "${RESULTCLONE}${count}" "${mess2cell}"
	count=$(( count + 1 ))
done
echo "Log file \"${logFile}\""
