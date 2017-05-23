#!/usr/bin/env python
# -*- coding: latin-1 -*-
#
# Este script recibe como argumento una o varias llaves y recupera el valor
# de un archivo json pasado como argumento. 
#
# El archivo puede recibir hasta tres argumentos,
#
# 1er: El nombre del archivo json
# 2do: La primera llave
# [3er]: La segunda llave, este argumento es opcional
#

import json
import sys

def readvar(argv):
	result = ""
	if len(argv) < 2 or len(argv) > 4:
		print "Se deben proveer tres o cuatro argumentos a este script"
		print "	%s <file.json> <key1> [<key2>] [<key3>]"%(argv[0])
		exit(-1)
	filename=argv[0]
	with open(filename) as data_file:
		data = json.load(data_file)
	if len(argv) == 4:
		result = data[argv[1]][argv[2]][argv[3]]
	elif len(argv) == 3:
		result = data[argv[1]][argv[2]]
	else:
		result = data[argv[1]]
	return result

