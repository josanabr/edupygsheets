#!/usr/bin/env python
#
# Este script se encarga de leer el archivo 'unicode2string.json' y desde el cual 
# tomara los datos que le perimtiran dada una columna con caracteres unicode
# convertir estos al formato String
#
# -*- coding: latin-1 -*-

import pygsheets
import os
import jsonvalue
import unicodedata
import random

def getjsonvalue(args):
	return jsonvalue.readvar(args)

def unicode2str(x):
	return unicodedata.normalize('NFKD',x).encode('ascii','ignore')

def main():
	jsonfile = "unicode2string.json"
	gc = pygsheets.authorize()
	# Tomar los datos de la pagina fuente, id, columna donde esta el codigo
	sourceid = getjsonvalue([jsonfile, "id"])
	s_sheet = gc.open_by_key(sourceid)
	s_sheet_name = getjsonvalue([jsonfile, "sheet_name"])
	s_wks = s_sheet.worksheet_by_title(s_sheet_name)
	# Obteniendo la lista de estudiantes
	getjsonvalue([jsonfile, "range"])
	rang = getjsonvalue([jsonfile, "range"])
	print "Actualizando '%s', sheet '%s', rango '%s'"%(sourceid, s_sheet_name,rang)
	rang = unicode2str(rang)
	cell_list = s_wks.range(rang)
	result_list = []
	for i in cell_list:
		i = ''.join(str(e) for e in i)
		i = i.split("'")[1].upper()
		result_list.append([i])
	s_wks.update_cells(rang, result_list)

if __name__ == '__main__':
	main()
