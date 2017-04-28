#!/usr/bin/env bash
#
# Este script permite validar si dado un URL de GitHub, el URL es un enlace
# valido.
#
# Argumentos:
# 1- URL de GitHub.
#
# Retorna:
# - OK, existe el repositorio
# - ERROR, no existe el repositorio o se pasaron el numero equivocado de args.
#
# +-----------+
# |IMPORTANTE:| este script depende del archivo --> config.json <--
# +-----------+
#
# AUTHOR: John Sanabria
# EMAIL: john.sanabria@correounivalle.edu.co
# DATE: Abril 27, 2017
#
function checkGitRepo() {
	usuario=$(./processGitURL.py -u ${1})
	repo=$(./processGitURL.py -r ${1} | cut -d '.' -f 1)
	ghuser=$( ./jsonValue.py config.json user )
	ghtoken=$( ./jsonValue.py config.json token )
	salida=$(curl -u ${ghuser}:${ghtoken} https://api.github.com/repos/${usuario}/${repo})
	notfound=$(echo ${salida} | grep "Not Found")
	if [ "${notfound}" == "" ]; then
		echo "OK"
	else
		echo "ERROR repo does not exist"
	fi
}
if [ $# -eq 1 ]; then
	echo $(checkGitRepo "${1}")
else
	echo "ERROR numero de argumentos"
fi
