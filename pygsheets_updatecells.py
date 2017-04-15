#!/usr/bin/env python
# -*- coding: latin-1 -*-
#
# Este script se encarga de actualizar el valor de un rango de celdas dada una 
# hoja de calculo de la siguiente manera:
#
#./pygsheets_updatecell.py 1udjSP39kTrNnxAO7ZUWQrSRLuQTZG6XqPorKRJCpIus Sheet1\ 
# A1:B1 "hola mundo"
# 
# Las celdas quedaran con los siguientes valores:
# A1 <- 'hola'
# B1 <- 'mundo'
#
# Como se observa, el script espera 4 parametros. El primer argumento
# '1ud...pIus' se refiere al identificador de la hoja de calculo de Google 
# Sheets. El segundo argumento hace referencia a una 'sheet' dentro de la hoja
# de calculo. El tercer argumento hace referencia al rango de celdas  
# y el cuarto argumento el valor que actualizara la celda
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
rango = str(sys.argv[3])
wks.update_cells(rango, [ str(sys.argv[4]).split() ])
