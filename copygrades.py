#!/usr/bin/env python
#
# Este script se encarga de leer el archivo 'kahoo.json' y desde el cual 
# tomara los datos que le perimtiran copias los valores de una hoja de 
# calculo en Google Drive a otra
#
# La estructura del archivo 'kahoot.json' le dara una idea de los datos que
# requiere este script
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

def getlist(sheet, low, high, webtool="Kahoot"):
	low = unicode2str(low)
	high = unicode2str(high)
	values = sheet.get_values(low, high, returnas='range')
	result = []
	for i in values:
		value = ''.join(str(e) for e in i)
		if (webtool == "EDpuzzle"):
			value = value.split("'")[1] #obtengo nombre completo
			value = value.split(",")[0] #accedo solo al apellido
			result.append(value)
		else:
			result.append(value.split("'")[1]) #obtengo solo el codigo
	return result

def process_stu_id(stu_list):
	i = 0;
	for stu in stu_list:
		if len(stu) == 7:
			i = i + 1
			continue
		if len(stu) == 9: # id starting with 20...
			stu = stu[2:]
		elif len(stu) == 14: # id starting with 20... and trail -3743
			stu = stu.split("=")[0]
			stu = stu[2:]
		elif len(stu) == 12:
			stu = stu.split("-")[0]
		else:
			print "CODIGO ERRADO %s - [%d]"%(stu,len(stu))
		stu_list[i] = stu
		i = i + 1
	return stu_list

def gen_list_grades(s_id, s_grade, d_id):
	result = []
	for i in d_id:
		result.append('0')
	# En este ciclo recorro todos los estudiantes y los busco en 'd_id'
	l = 0 # itera sobre el s_id
	for i in s_id:
		k = 0 # itera sobre los de destino
		flag = 0
		for j in d_id:
			if i in j:
				result[k] = s_grade[l]
				flag = 1
				break
			k = k + 1
		if flag == 0:
			print "[WARN] %s no se encontro en la lista destino"%(i)
		l = l + 1
	if len(s_id) != l:
		print "[WARN] no se procesaron todos los estudiantes orig - %d - %d"%(len(s_id),l)
	return result

def validate(s_id, s_grade, d_id, d_grade, n):
	count = 0
	result = 0
	random_list = random.sample(range(0, len(s_id) - 1), n)
	for pos in random_list:
		stu_ref = s_id[pos]
		grade_ref = s_grade[pos]
		k = 0
		grade_d = 0
		for i in d_id:
			if stu_ref in i:
				grade_d = d_grade[k]
				break
			k = k + 1
		if grade_ref != grade_d:
			print stu_ref,type(stu_ref), grade_ref, type(grade_ref)
			print i, type(i), grade_d, type(grade_d)
			print "[ERROR] %s %s %s %s"%(stu_ref,grade_ref,i,grade_d)
			result = result + 1
		count = count + 1
	return result

def main():
	jsonfile = "kahoot.json"
	gc = pygsheets.authorize()
	# Tomar los datos de la pagina fuente, id, columna donde esta el codigo
	webtool = getjsonvalue([jsonfile, "web_tool"])
	sourceid = getjsonvalue([jsonfile, "source", "id"])
	s_sheet = gc.open_by_key(sourceid)
	s_sheet_name = getjsonvalue([jsonfile, "source", "sheet_name"])
	s_wks = s_sheet.worksheet_by_title(s_sheet_name)
	# Obteniendo la lista de estudiantes
	s_low_st_range =  getjsonvalue([jsonfile, "source", "studentid", "start_range"])
	s_high_st_range =  getjsonvalue([jsonfile, "source", "studentid", "end_range"])
	s_stud_id_list = getlist(s_wks, s_low_st_range, s_high_st_range,webtool)
	if webtool == "Kahoot":
		s_stud_id_list = process_stu_id(s_stud_id_list)
	#print s_stud_id_list
	# Obteniendo las notas de los estudiantes
	s_low_gr_range =  getjsonvalue([jsonfile, "source", "grade", "start_range"])
	s_high_gr_range =  getjsonvalue([jsonfile, "source", "grade", "end_range"])
	s_stud_grade_list = getlist(s_wks, s_low_gr_range, s_high_gr_range)
	#print s_stud_grade_list
	if len(s_stud_id_list) != len(s_stud_grade_list):
		print "# de estudiantes (%d) no coincide con # de notas (%d)"%(len(s_stud_id_list), len(s_stud_grade_list))
	#
	# Tomar los datos de la pagina destino
	#
	destid = getjsonvalue([jsonfile, "destination", "id"])
	d_sheet = gc.open_by_key(destid)
	d_sheet_name = getjsonvalue([jsonfile, "destination", "sheet_name"])
	d_wks = d_sheet.worksheet_by_title(d_sheet_name)
	## Obteniendo la lista de estudiantes
	d_low_st_range =  getjsonvalue([jsonfile, "destination", "studentid", "start_range"])
	d_high_st_range =  getjsonvalue([jsonfile, "destination", "studentid", "end_range"])
	d_stud_id_list = getlist(d_wks, d_low_st_range, d_high_st_range)
	if (len(s_stud_id_list) != len(d_stud_id_list)):
		print "[WARN] longitud listas estudiantes origen (%d) y destino (%d) NO COINCIDEN"%(len(s_stud_id_list), len(d_stud_id_list))
	d_stud_grade_list = gen_list_grades(s_stud_id_list, s_stud_grade_list, d_stud_id_list) 
	d_column_gr =  getjsonvalue([jsonfile, "destination", "grade", "column"])
	d_low_row_gr =  getjsonvalue([jsonfile, "destination", "grade", "low_row"])
	value = validate(s_stud_id_list, s_stud_grade_list, d_stud_id_list, d_stud_grade_list, int(len(s_stud_id_list)*.7))
	if value != 0:
		print "[ERR] Hubo %d errores en el paso de notas"%(value)
	k = int(d_low_row_gr)
	d_column_gr = unicode2str(d_column_gr)
	for i in d_stud_grade_list:
		d_wks.update_cell(d_column_gr+""+str(k),i)
		k = k + 1

if __name__ == '__main__':
	main()
