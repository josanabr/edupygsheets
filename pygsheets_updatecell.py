#!/usr/bin/env python
# -*- coding: latin-1 -*-
#
# Este script se encarga de actualizar el valor de una celda dada una 
# hoja de calculo de la siguiente manera:
#
#./pygsheets_updatecell.py 1udjSP39kTrNnxAO7ZUWQrSRLuQTZG6XqPorKRJCpIus Sheet1\ 
# A1 "hola mundo"
# 
# Como se observa, el script espera 4 parametros. El primer argumento
# '1ud...pIus' se refiere al identificador de la hoja de calculo de Google 
# Sheets. El segundo argumento hace referencia a una 'sheet' dentro de la hoja
# de calculo. El tercer argumento hace referencia al identificador de la 
# celda ('A1') y el cuarto argumento el valor que actualizara la celda
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
xycell = str(sys.argv[3])
cell = wks.cell(xycell)
cell.value = str(sys.argv[4])
