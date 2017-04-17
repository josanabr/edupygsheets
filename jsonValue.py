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

if len(sys.argv) < 3 or len(sys.argv) > 4:
	print "Se deben proveer dos o tres argumentos a este script"
	print "	%s <file.json> <key1> [<key2>]"%(sys.argv[0])
	sys.exit(-1)
filename=sys.argv[1]
with open(filename) as data_file:
	data = json.load(data_file)
if len(sys.argv) == 4:
	print data[sys.argv[2]][sys.argv[3]]
else:
	print data[sys.argv[2]]

