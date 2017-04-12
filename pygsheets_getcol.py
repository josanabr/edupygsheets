#!/usr/bin/env python
# -*- coding: latin-1 -*-
#
# Este script se encarga de recuperar los contenidos de celdas en una columna
# dada de una hoja calculo de Google Sheets. El script se debe ejecutar de la
# siguiente manera:
#
#./pygsheets_getcol.py 1udjSP39kTrNnxAO7ZUWQrSRLuQTZG6XqPorKRJCpIus Sheet1 A 1 3
# 
# Como se observa, el script espera 5 parametros. El primer argumento
# '1ud...pIus' se refiere al identificador de la hoja de calculo de Google 
# Sheets. El segundo argumento hace referencia a una 'sheet' dentro de la hoja
# de calculo. El tercer argumento hace referencia al identificador de la 
# columna. El cuarto y quinto argumentos hacen referencia al rango de filas, 
# que en esa columna, se accederan.
#
# En este ejemplo se accedera a la hoja de calculo de Google cuyo identificador
# es '1ud...pIus', se accedera a la 'sheet' llamada 'Sheet1' y se accederan a 
# las celdas con valores A1, A2 y A3
#
# Author: John Sanabria
# E-mail: john.sanabria@correounivalle.edu.co
# Date:   April 4, 2017
#
import pygsheets
import sys

gc = pygsheets.authorize()

sh = gc.open_by_key(str(sys.argv[1]))
wks = sh.worksheet_by_title(str(sys.argv[2]))

for i in range(int(sys.argv[4]),int(sys.argv[5]) + 1):
	xycell = str(sys.argv[3]) + str(i)
	cell = wks.cell(xycell)
	print cell.value + "\n"
